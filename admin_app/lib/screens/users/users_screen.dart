import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/date_formatter.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/models/user_model.dart';
import 'package:adentweets_admin/providers/admin_users_provider.dart';
import 'package:adentweets_admin/widgets/user_action_dialog.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);
    final filteredUsers = state.filteredUsers;
    final padding = ResponsiveUtils.horizontalPadding(context);

    ref.listen(adminUsersProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!)),
        );
        ref.read(adminUsersProvider.notifier).clearActionMessage();
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('إدارة المستخدمين'),
          actions: [
            IconButton(
              icon: Icon(Iconsax.refresh),
              onPressed: () => ref.read(adminUsersProvider.notifier).loadUsers(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => ref.read(adminUsersProvider.notifier).setSearchQuery(q),
                decoration: InputDecoration(
                  hintText: 'بحث عن مستخدم...',
                  prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Iconsax.close_circle, size: 18, color: AppColors.textTertiary),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(adminUsersProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            // Filter chips
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: UserFilter.values.map((filter) {
                    final isActive = state.filter == filter;
                    final label = switch (filter) {
                      UserFilter.all => 'الكل',
                      UserFilter.verified => 'موثقين',
                      UserFilter.suspended => 'معلقين',
                      UserFilter.admin => 'مدراء',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isActive,
                        onSelected: (_) => ref.read(adminUsersProvider.notifier).setFilter(filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // List
            Expanded(
              child: state.isLoading
                  ? _buildShimmer()
                  : filteredUsers.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
                          itemCount: filteredUsers.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: AppColors.borderLight,
                          ),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            return _UserListItem(
                              user: user,
                              onTap: () => context.push('/users/${user.uid}'),
                              onLongPress: () => _showActions(user),
                            ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(UserModel user) {
    UserActionDialog.show(
      context,
      user: user,
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundElevated,
      highlightColor: AppColors.backgroundCard,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.user, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('لا يوجد مستخدمون', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 4),
          Text('لم يتم العثور على مستخدمين', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _UserListItem({
    required this.user,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isVerified)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Iconsax.verify,
                            size: 14,
                            color: user.verificationType == 'blue'
                                ? AppColors.badgeBlue
                                : AppColors.badgeGray,
                          ),
                        ),
                      if (user.isAdmin)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.userAdmin.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'مدير',
                            style: TextStyle(color: AppColors.userAdmin, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatRelative(user.createdAt),
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Iconsax.more_2, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.avatarBase64 != null && user.avatarBase64!.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 22,
          backgroundImage: MemoryImage(
            const Base64Codec().decode(user.avatarBase64!.split(',').last),
          ),
        );
      } catch (_) {}
    }
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(user.avatarUrl!),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.backgroundElevated,
      child: Text(
        user.displayName.isNotEmpty ? user.displayName[0] : '?',
        style: TextStyle(
          color: AppColors.accentPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (user.isSuspended) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.userSuspended.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('معلق', style: TextStyle(color: AppColors.userSuspended, fontSize: 11, fontWeight: FontWeight.w500)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.userActive.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('نشط', style: TextStyle(color: AppColors.userActive, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}