import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/utils/date_formatter.dart';
import 'package:adentweets_app/core/widgets/verification_badge.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/providers/feed_provider.dart';
import 'package:adentweets_app/services/post_service.dart';
import 'package:adentweets_app/services/notification_service.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;
  final bool showActions;
  final bool isDetail;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.showActions = true,
    this.isDetail = false,
    this.onTap,
  });

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _isBookmarked = false;
  bool _showLikeAnimation = false;
  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimController,
        curve: Curves.elasticOut,
      ),
    );

    final userId = ref.read(authProvider).user?.uid;
    if (userId != null) {
      _checkLikeStatus(widget.post.postId, userId);
      _checkBookmarkStatus(widget.post.postId, userId);
    }
  }

  Future<void> _checkLikeStatus(String postId, String userId) async {
    final service = ref.read(postServiceProvider);
    final liked = await service.isPostLiked(postId, userId);
    if (mounted) setState(() => _isLiked = liked);
  }

  Future<void> _checkBookmarkStatus(String postId, String userId) async {
    final service = ref.read(postServiceProvider);
    final bookmarked = await service.isPostBookmarked(postId, userId);
    if (mounted) setState(() => _isBookmarked = bookmarked);
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return GestureDetector(
      onTap: widget.onTap ?? () => context.push('/post/${post.postId}'),
      onLongPress: _showOptions,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(post),
              const SizedBox(width: 12),
              Expanded(child: _buildContent(context, post)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(PostModel post) {
    Uint8List avatarBytes;
    try {
      if (post.userAvatar != null && post.userAvatar!.isNotEmpty) {
        avatarBytes = base64Decode(post.userAvatar!);
      } else {
        avatarBytes = base64Decode(AppConstants.defaultAvatar);
      }
    } catch (e) {
      avatarBytes = base64Decode(AppConstants.defaultAvatar);
    }

    return GestureDetector(
      onTap: () => context.push('/profile/${post.userId}'),
      child: CircleAvatar(
        radius: 22,
        backgroundImage: MemoryImage(avatarBytes),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  Widget _buildContent(BuildContext context, PostModel post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, post),
        const SizedBox(height: 4),
        if (post.isRepost) ...[
          Row(
            children: [
              const Icon(Icons.repeat_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'أعاد نشره ${post.repostedBy ?? ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        _buildPostText(context, post),
        if (post.hasImage) ...[
          const SizedBox(height: 8),
          _buildImage(post.imageBase64!),
        ],
        const SizedBox(height: 8),
        if (widget.showActions) _buildActions(post),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, PostModel post) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/profile/${post.userId}'),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    post.userFullName,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (post.userBadge != VerificationBadge.none) ...[
                  const SizedBox(width: 4),
                  VerificationBadgeWidget(badge: post.userBadge, size: 16),
                ],
                const SizedBox(width: 6),
                Text(
                  '@${post.username}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
                if (post.isPinned) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.push_pin, size: 14, color: AppColors.textTertiary),
                ],
              ],
            ),
          ),
        ),
        Text(
          DateFormatter.relativeTime(post.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
      ],
    );
  }

  Widget _buildPostText(BuildContext context, PostModel post) {
    return Text.rich(
      _buildHighlightedContent(post.content),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textOnSurface,
            height: 1.5,
          ),
    );
  }

  TextSpan _buildHighlightedContent(String text) {
    final hashtagRegex = RegExp(r'(#\S+)');
    final matches = hashtagRegex.allMatches(text);

    if (matches.isEmpty) {
      return TextSpan(text: text);
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(color: AppColors.primary),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return TextSpan(children: spans);
  }

  Widget _buildImage(String base64Image) {
    final bytes = base64Decode(base64Image);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: GestureDetector(
        onTap: () => _showFullImage(context, bytes),
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.broken_image_outlined,
                  color: AppColors.iconTertiary),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, Uint8List bytes) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: InteractiveViewer(
                child: Image.memory(bytes, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(PostModel post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionButton(
          icon: Icons.chat_bubble_outline_rounded,
          count: post.commentsCount,
          onTap: () => context.push('/post/${post.postId}'),
        ),
        _actionButton(
          icon: Icons.repeat_rounded,
          count: post.repostsCount,
          onTap: () => _handleRepost(post),
          activeColor: AppColors.repostActive,
        ),
        _buildLikeButton(post),
        _actionButton(
          icon: Icons.bar_chart_rounded,
          count: post.viewsCount,
          onTap: null,
        ),
        _buildBookmarkButton(post),
        _actionButton(
          icon: Icons.ios_share_rounded,
          count: null,
          onTap: () => _handleShare(post),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    int? count,
    required VoidCallback? onTap,
    Color? activeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.iconSecondary),
            if (count != null && count > 0) ...[
              const SizedBox(width: 4),
              Text(
                _formatCount(count),
                style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(PostModel post) {
    return InkWell(
      onTap: () => _handleLike(post),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: AnimatedBuilder(
          animation: _likeScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _showLikeAnimation ? _likeScaleAnimation.value : 1.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                    color: _isLiked
                        ? AppColors.likeActive
                        : AppColors.iconSecondary,
                  ),
                  if (post.likesCount > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      _formatCount(post.likesCount),
                      style: TextStyle(
                        fontSize: 13,
                        color: _isLiked
                            ? AppColors.likeActive
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookmarkButton(PostModel post) {
    return InkWell(
      onTap: () => _handleBookmark(post),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Icon(
          _isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          size: 18,
          color:
              _isBookmarked ? AppColors.bookmarkActive : AppColors.iconSecondary,
        ),
      ),
    );
  }

  Future<void> _handleLike(PostModel post) async {
    final userId = ref.read(authProvider).user?.uid;
    if (userId == null) return;

    setState(() => _isLiked = !_isLiked);

    if (_isLiked) {
      _showLikeAnimation = true;
      _likeAnimController.forward().then((_) {
        if (mounted) {
          _likeAnimController.reverse();
          setState(() => _showLikeAnimation = false);
        }
      });
    }

    final service = ref.read(postServiceProvider);
    try {
      if (_isLiked) {
        await service.likePost(post.postId, userId);
        final authState = ref.read(authProvider);
        ref.read(notificationServiceProvider).sendNotification(
              userId: post.userId,
              type: AppConstants.notifTypeLike,
              actorUserId: userId,
              actorUsername: authState.userData?.username ?? '',
              actorAvatar: authState.userData?.avatarBase64,
              postId: post.postId,
              message: 'أعجب بمنشورك',
            );
      } else {
        await service.unlikePost(post.postId, userId);
      }
    } catch (e) {
      if (mounted) setState(() => _isLiked = !_isLiked);
    }
  }

  Future<void> _handleBookmark(PostModel post) async {
    final userId = ref.read(authProvider).user?.uid;
    if (userId == null) return;

    setState(() => _isBookmarked = !_isBookmarked);
    final service = ref.read(postServiceProvider);

    try {
      if (_isBookmarked) {
        await service.bookmarkPost(post.postId, userId);
      } else {
        await service.unbookmarkPost(post.postId, userId);
      }
    } catch (e) {
      if (mounted) setState(() => _isBookmarked = !_isBookmarked);
    }
  }

  Future<void> _handleRepost(PostModel post) async {
    final userId = ref.read(authProvider).user?.uid;
    final username = ref.read(authProvider).userData?.username ?? '';
    if (userId == null) return;

    final service = ref.read(postServiceProvider);
    try {
      await service.repost(post.postId, userId, username);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إعادة النشر')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إعادة النشر')),
      );
    }
  }

  Future<void> _handleShare(PostModel post) async {
    await Share.share(post.content);
  }

  void _showOptions() {
    final userId = ref.read(authProvider).user?.uid;
    final isOwner = userId == widget.post.userId;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: AppColors.iconPrimary),
              title: const Text('نسخ النص'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.post.content));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.ios_share_rounded, color: AppColors.iconPrimary),
              title: const Text('مشاركة'),
              onTap: () {
                Navigator.pop(ctx);
                _handleShare(widget.post);
              },
            ),
            if (!isOwner)
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: AppColors.error),
                title: const Text('إبلاغ'),
                onTap: () {
                  Navigator.pop(ctx);
                },
              ),
            if (isOwner)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                title: const Text('حذف المنشور'),
                onTap: () {
                  Navigator.pop(ctx);
                  _deletePost();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePost() async {
    final userId = ref.read(authProvider).user?.uid;
    if (userId == null) return;
    final service = ref.read(postServiceProvider);
    try {
      await service.deletePost(widget.post.postId, userId);
      ref.read(feedProvider.notifier).removePost(widget.post.postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف المنشور')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في حذف المنشور')),
        );
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}م';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}ك';
    return count.toString();
  }
}