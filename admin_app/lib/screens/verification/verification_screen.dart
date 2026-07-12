import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/date_formatter.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/core/constants/app_constants.dart';
import 'package:adentweets_admin/models/user_model.dart';
import 'package:adentweets_admin/services/admin_user_service.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _filter = 'all';
  int _blueCount = 0;
  int _grayCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await AdminUserService.fetchUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _blueCount = users.where((u) => u.verificationType == 'blue').length;
          _grayCount = users.where((u) => u.verificationType == 'gray').length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<UserModel> get _filteredUsers {
    switch (_filter) {
      case 'blue': return _users.where((u) => u.verificationType == 'blue').toList();
      case 'gray': return _users.where((u) => u.verificationType == 'gray').toList();
      case 'none': return _users.where((u) => u.verificationType == 'none' && !u.isVerified).toList();
      default: return _users;
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.horizontalPadding(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('إدارة التوثيق'),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: _loadUsers,
            ),
          ],
        ),
        body: Column(
          children: [
            // Stats
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.badgeBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.badgeBlue.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Text('$_blueCount', style: TextStyle(color: AppColors.badgeBlue, fontSize: 22, fontWeight: FontWeight.w700)),
                          Text('موثق أزرق', style: TextStyle(color: AppColors.badgeBlue.withValues(alpha: 0.8), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.badgeGray.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.badgeGray.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Text('$_grayCount', style: TextStyle(color: AppColors.badgeGray, fontSize: 22, fontWeight: FontWeight.w700)),
                          Text('موثق رمادي', style: TextStyle(color: AppColors.badgeGray.withValues(alpha: 0.8), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filter
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('الكل', 'all'),
                    const SizedBox(width: 8),
                    _filterChip('الأزرق', 'blue'),
                    const SizedBox(width: 8),
                    _filterChip('الرمادي', 'gray'),
                    const SizedBox(width: 8),
                    _filterChip('غير موثق', 'none'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // List
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : _filteredUsers.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
                          itemCount: _filteredUsers.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _VerificationCard(
                              user: user,
                              onAction: (type) async {
                                await AdminUserService.verifyUser(user.uid, type);
                                _loadUsers();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('تم تحديث التوثيق')),
                                  );
                                }
                              },
                            ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isActive = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundElevated,
      highlightColor: AppColors.backgroundCard,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(10),
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
          Icon(Iconsax.verify, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('لا توجد نتائج', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final UserModel user;
  final Function(String) onAction;

  const _VerificationCard({required this.user, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (user.verificationType == 'blue')
                      Icon(Iconsax.verify, size: 16, color: AppColors.badgeBlue)
                    else if (user.verificationType == 'gray')
                      Icon(Iconsax.shield_tick, size: 16, color: AppColors.badgeGray),
                  ],
                ),
                const SizedBox(height: 2),
                Text('@${user.username}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12), textDirection: TextDirection.ltr),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${user.followersCount} متابع', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                    const SizedBox(width: 8),
                    Text('انضم ${DateFormatter.formatRelative(user.createdAt)}', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: onAction,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'blue', child: Row(
                children: [Icon(Iconsax.verify, color: AppColors.badgeBlue, size: 18), SizedBox(width: 8), Text('توثيق أزرق')],
              )),
              PopupMenuItem(value: 'gray', child: Row(
                children: [Icon(Iconsax.shield_tick, color: AppColors.badgeGray, size: 18), SizedBox(width: 8), Text('توثيق رمادي')],
              )),
              PopupMenuItem(value: 'none', child: Row(
                children: [Icon(Iconsax.close_circle, color: AppColors.textSecondary, size: 18), SizedBox(width: 8), Text('إزالة التوثيق')],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.avatarBase64 != null && user.avatarBase64!.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: 22,
          backgroundImage: MemoryImage(const Base64Codec().decode(user.avatarBase64!.split(',').last)),
        );
      } catch (_) {}
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.backgroundElevated,
      child: Text(
        user.displayName.isNotEmpty ? user.displayName[0] : '?',
        style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.w600, fontSize: 18),
      ),
    );
  }
}