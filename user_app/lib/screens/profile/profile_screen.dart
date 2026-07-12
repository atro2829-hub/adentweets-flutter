import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/core/utils/date_formatter.dart';
import 'package:adentweets_app/core/widgets/loading_skeleton.dart';
import 'package:adentweets_app/core/widgets/error_state_widget.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/core/widgets/verification_badge.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/providers/profile_provider.dart';
import 'package:adentweets_app/widgets/post_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.uid ?? '';

    return BottomNavShell(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: AppColors.scaffoldBackground,
                elevation: 0,
                pinned: true,
                leading: const SizedBox.shrink(),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, color: AppColors.iconPrimary),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(userId, authState),
                ),
                expandedHeight: 320,
              ),
              SliverPersistentHeader(
                delegate: _ProfileTabDelegate(
                  tabController: _tabController,
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPostsList(userId),
              const Center(
                child: Text('الردود', style: TextStyle(color: AppColors.textTertiary)),
              ),
              const Center(
                child: Text('الإعجابات', style: TextStyle(color: AppColors.textTertiary)),
              ),
              _buildBookmarksTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userId, AuthState authState) {
    final userData = authState.userData;
    if (userData == null) return LoadingSkeleton.profileHeader();

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                image: userData.bannerBase64 != null
                    ? DecorationImage(
                        image: MemoryImage(base64Decode(userData.bannerBase64!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 16,
              child: GestureDetector(
                onTap: () => context.push('/profile/$userId'),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.scaffoldBackground,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: userData.avatarBase64 != null
                        ? MemoryImage(base64Decode(userData.avatarBase64!))
                        : null,
                    child: userData.avatarBase64 == null
                        ? Icon(Icons.person, size: 28, color: AppColors.iconTertiary)
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            userData.fullName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (userData.verificationBadge != VerificationBadge.none) ...[
                            const SizedBox(width: 4),
                            VerificationBadgeWidget(badge: userData.verificationBadge),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${userData.username}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => context.push('/edit-profile'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(
                        'تعديل الملف',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                userData.bio.isEmpty ? 'لا يوجد نبذة بعد' : userData.bio,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textOnSurface,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'انضم في ${DateFormatter.formatDate(userData.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat('${userData.postsCount}', 'منشورات'),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => context.push('/users?type=following&userId=$userId'),
                    child: _buildStat('${userData.followingCount}', 'متابَعين'),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => context.push('/users?type=followers&userId=$userId'),
                    child: _buildStat('${userData.followersCount}', 'متابعون'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStat(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
      ],
    );
  }

  Widget _buildPostsList(String userId) {
    final profileState = ref.watch(profileProvider);
    final posts = profileState.posts;

    if (profileState.isLoadingPosts) {
      return LoadingSkeleton.postCardList(count: 4);
    }

    if (posts.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.article_outlined,
        title: 'لا توجد منشورات بعد',
        subtitle: 'عندما تنشر شيئًا، سيظهر هنا',
      );
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: posts[index])
            .animate()
            .fadeIn(delay: (index * 30).ms, duration: 300.ms);
      },
    );
  }

  Widget _buildBookmarksTab() {
    return GestureDetector(
      onTap: () => context.push('/bookmarks'),
      child: const Center(
        child: Text(
          'عرض المرجعية',
          style: TextStyle(color: AppColors.primary, fontSize: 16),
        ),
      ),
    );
  }
}

class _ProfileTabDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _ProfileTabDelegate({required this.tabController});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: TabBar(
        controller: tabController,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 3,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 32),
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        dividerColor: AppColors.divider,
        tabs: const [
          Tab(text: 'المنشورات'),
          Tab(text: 'الردود'),
          Tab(text: 'الإعجابات'),
          Tab(text: 'المرجعية'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileTabDelegate oldDelegate) {
    return tabController != oldDelegate.tabController;
  }
}