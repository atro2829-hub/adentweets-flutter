import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/date_formatter.dart';
import 'package:adentweets_admin/core/constants/app_constants.dart';
import 'package:adentweets_admin/models/user_model.dart';
import 'package:adentweets_admin/models/post_model.dart';
import 'package:adentweets_admin/services/admin_user_service.dart';
import 'package:adentweets_admin/services/admin_post_service.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  UserModel? _user;
  List<PostModel> _posts = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await AdminUserService.fetchUser(widget.userId);
      final posts = await AdminPostService.fetchUserPosts(widget.userId);
      if (mounted) {
        setState(() {
          _user = user;
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_right),
            onPressed: () => context.go('/users'),
          ),
          title: Text(_user?.displayName ?? 'تفاصيل المستخدم'),
          actions: [
            if (_user != null)
              PopupMenuButton<String>(
                onSelected: (action) => _handleAction(action),
                itemBuilder: (context) => [
                  if (_user!.isSuspended)
                    PopupMenuItem(value: 'unsuspend', child: Row(
                      children: [Icon(Iconsax.tick_circle, color: AppColors.success), SizedBox(width: 8), Text('إلغاء التعليق')],
                    ))
                  else
                    PopupMenuItem(value: 'suspend', child: Row(
                      children: [Icon(Iconsax.slash, color: AppColors.warning), SizedBox(width: 8), Text('تعليق الحساب')],
                    )),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'blue', child: Row(
                    children: [Icon(Iconsax.verify, color: AppColors.badgeBlue), SizedBox(width: 8), Text('توثيق أزرق')],
                  )),
                  PopupMenuItem(value: 'gray', child: Row(
                    children: [Icon(Iconsax.shield_tick, color: AppColors.badgeGray), SizedBox(width: 8), Text('توثيق رمادي')],
                  )),
                  PopupMenuItem(value: 'none', child: Row(
                    children: [Icon(Iconsax.close_circle, color: AppColors.textSecondary), SizedBox(width: 8), Text('إزالة التوثيق')],
                  )),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'delete', child: Row(
                    children: [Icon(Iconsax.trash, color: AppColors.error), SizedBox(width: 8), Text('حذف المستخدم', style: TextStyle(color: AppColors.error))],
                  )),
                ],
              ),
          ],
        ),
        body: _isLoading
            ? _buildShimmer()
            : _user == null
                ? _buildNotFound()
                : _buildContent(),
      ),
    );
  }

  void _handleAction(String action) async {
    if (_user == null) return;

    if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('حذف المستخدم'),
          content: Text('هل أنت متأكد من حذف @${_user!.username}؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('حذف'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    try {
      switch (action) {
        case 'suspend': await AdminUserService.suspendUser(_user!.uid);
        case 'unsuspend': await AdminUserService.unsuspendUser(_user!.uid);
        case 'blue': await AdminUserService.verifyUser(_user!.uid, AppConstants.verificationBlue);
        case 'gray': await AdminUserService.verifyUser(_user!.uid, AppConstants.verificationGray);
        case 'none': await AdminUserService.verifyUser(_user!.uid, AppConstants.verificationNone);
        case 'delete': await AdminUserService.deleteUser(_user!.uid);
      }
      if (mounted) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تنفيذ الإجراء بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildProfileHeader()),
        SliverToBoxAdapter(child: _buildStatsRow()),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(_tabController),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsTab(),
              _buildPlaceholderTab('المتابعون'),
              _buildPlaceholderTab('المتابَعين'),
              _buildPlaceholderTab('النشاط'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(radius: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _user!.displayName,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (_user!.isVerified)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Iconsax.verify,
                              size: 18,
                              color: _user!.verificationType == 'blue'
                                  ? AppColors.badgeBlue
                                  : AppColors.badgeGray,
                            ),
                          ),
                        if (_user!.isAdmin)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.userAdmin.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('مدير', style: TextStyle(color: AppColors.userAdmin, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('@${_user!.username}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13), textDirection: TextDirection.ltr),
                  ],
                ),
              ),
            ],
          ),
          if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_user!.bio!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (_user!.location != null) ...[
                Icon(Iconsax.location, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(_user!.location!, style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                const SizedBox(width: 12),
              ],
              Icon(Iconsax.calendar, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('انضم ${DateFormatter.formatRelative(_user!.createdAt)}', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatItem(count: _user!.postsCount, label: 'منشور'),
          const SizedBox(width: 24),
          _StatItem(count: _user!.followersCount, label: 'متابع'),
          const SizedBox(width: 24),
          _StatItem(count: _user!.followingCount, label: 'يتابع'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _user!.isSuspended
                  ? AppColors.userSuspended.withValues(alpha: 0.12)
                  : AppColors.userActive.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _user!.isSuspended ? 'معلق' : 'نشط',
              style: TextStyle(
                color: _user!.isSuspended ? AppColors.userSuspended : AppColors.userActive,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_posts.isEmpty) {
      return Center(child: Text('لا توجد منشورات', style: TextStyle(color: AppColors.textTertiary)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      separatorBuilder: (_, __) => Divider(color: AppColors.borderLight),
      itemBuilder: (context, index) {
        final post = _posts[index];
        return Dismissible(
          key: ValueKey(post.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            color: AppColors.error.withValues(alpha: 0.1),
            child: Icon(Iconsax.trash, color: AppColors.error),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('حذف المنشور'),
                content: Text('هل تريد حذف هذا المنشور؟'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('حذف'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) async {
            await AdminPostService.deletePost(post.id);
            setState(() => _posts.removeWhere((p) => p.id == post.id));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormatter.formatRelative(post.createdAt),
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      '${post.likesCount} إعجاب · ${post.commentsCount} تعليق',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.hasImages) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: post.imageBase64List.map((b64) {
                        try {
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(base64Decode(b64), width: 60, height: 60, fit: BoxFit.cover),
                            ),
                          );
                        } catch (_) {
                          return const SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderTab(String label) {
    return Center(
      child: Text('قريباً: $label', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
    );
  }

  Widget _buildAvatar({double radius = 22}) {
    if (_user!.avatarBase64 != null && _user!.avatarBase64!.isNotEmpty) {
      try {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(base64Decode(_user!.avatarBase64!.split(',').last)),
        );
      } catch (_) {}
    }
    if (_user!.avatarUrl != null && _user!.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(_user!.avatarUrl!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.backgroundElevated,
      child: Text(
        _user!.displayName.isNotEmpty ? _user!.displayName[0] : '?',
        style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.w600, fontSize: radius * 0.8),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundElevated,
      highlightColor: AppColors.backgroundCard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.backgroundElevated, shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Expanded(child: Column(children: [
              Container(height: 20, width: 160, decoration: BoxDecoration(color: AppColors.backgroundElevated, borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 8),
              Container(height: 14, width: 100, decoration: BoxDecoration(color: AppColors.backgroundElevated, borderRadius: BorderRadius.circular(4))),
            ])),
          ]),
          const SizedBox(height: 24),
          Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: AppColors.backgroundElevated, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 24),
          ...List.generate(4, (_) => Container(height: 80, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: AppColors.backgroundElevated, borderRadius: BorderRadius.circular(8)))),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.user_remove, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('المستخدم غير موجود', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(DateFormatter.formatNumber(count), style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _TabBarDelegate(this.tabController);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.backgroundPrimary,
      child: TabBar(
        controller: tabController,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: const [
          Tab(text: 'المنشورات'),
          Tab(text: 'المتابعون'),
          Tab(text: 'المتابَعين'),
          Tab(text: 'النشاط'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}