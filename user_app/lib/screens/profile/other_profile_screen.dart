import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/utils/date_formatter.dart';
import 'package:adentweets_app/core/widgets/loading_skeleton.dart';
import 'package:adentweets_app/core/widgets/error_state_widget.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/core/widgets/verification_badge.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/providers/profile_provider.dart';
import 'package:adentweets_app/widgets/post_card.dart';

class OtherProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const OtherProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends ConsumerState<OtherProfileScreen> {
  @override
  void initState() {
    super.initState();
    final currentUserId = ref.read(authProvider).user?.uid ?? '';
    ref.read(profileProvider.notifier).setCurrentUserId(currentUserId);
    ref.read(profileProvider.notifier).loadProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final currentUserId = ref.read(authProvider).user?.uid;

    if (profileState.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.iconPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: LoadingSkeleton.profileHeader(),
      );
    }

    if (profileState.error != null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.iconPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: ErrorStateWidget(
          message: profileState.error!,
          onRetry: () => ref.read(profileProvider.notifier).loadProfile(widget.userId),
        ),
      );
    }

    final user = profileState.user;
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.iconPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: const ErrorStateWidget(message: 'المستخدم غير موجود'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.scaffoldBackground,
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.iconPrimary),
              onPressed: () => context.pop(),
            ),
            title: Text(
              user.fullName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      color: AppColors.surfaceElevated,
                      child: user.bannerBase64 != null
                          ? Image.memory(
                              base64Decode(user.bannerBase64!),
                              fit: BoxFit.cover,
                            )
                          : const SizedBox.shrink(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 16,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.scaffoldBackground,
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.surfaceVariant,
                          backgroundImage: user.avatarBase64 != null
                              ? MemoryImage(base64Decode(user.avatarBase64!))
                              : null,
                          child: user.avatarBase64 == null
                              ? Icon(Icons.person, size: 28, color: AppColors.iconTertiary)
                              : null,
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
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user.fullName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (user.verificationBadge != VerificationBadge.none) ...[
                                      const SizedBox(width: 4),
                                      VerificationBadgeWidget(badge: user.verificationBadge),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '@${user.username}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildActionButton(
                                label: profileState.isFollowing ? 'إلغاء المتابعة' : 'متابعة',
                                isFollowing: profileState.isFollowing,
                                onTap: () => ref.read(profileProvider.notifier).toggleFollow(),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 36,
                                child: OutlinedButton(
                                  onPressed: () {
                                    _navigateToChat(context, currentUserId ?? '', user);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.iconPrimary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.bio.isEmpty ? 'لا يوجد نبذة بعد' : user.bio,
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
                            'انضم في ${DateFormatter.formatDate(user.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/users?type=following&userId=${user.uid}'),
                            child: _buildStat('${user.followingCount}', 'متابَعين'),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => context.push('/users?type=followers&userId=${user.uid}'),
                            child: _buildStat('${user.followersCount}', 'متابعون'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),
          ),
          const SliverToBoxAdapter(
            child: Divider(color: AppColors.divider, height: 1),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'المنشورات',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          profileState.isLoadingPosts
              ? SliverToBoxAdapter(child: LoadingSkeleton.postCardList(count: 3))
              : profileState.posts.isEmpty
                  ? SliverToBoxAdapter(
                      child: EmptyStateWidget(
                        icon: Icons.article_outlined,
                        title: 'لا توجد منشورات',
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return PostCard(post: profileState.posts[index])
                              .animate()
                              .fadeIn(delay: (index * 30).ms, duration: 300.ms);
                        },
                        childCount: profileState.posts.length,
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required bool isFollowing,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 36,
      child: isFollowing
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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

  void _navigateToChat(BuildContext context, String currentUserId, dynamic otherUser) {
    if (otherUser is! UserModel) return;
    context.push('/new-message');
  }
}