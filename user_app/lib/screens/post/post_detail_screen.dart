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
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/models/comment_model.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/widgets/post_card.dart';
import 'package:adentweets_app/services/post_service.dart';
import 'package:adentweets_app/services/database_service.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  PostModel? _post;
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isLoadingComments = true;
  String? _error;
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSendingComment = false;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final postService = ref.read(postServiceProvider);
      final post = await postService.getPostById(widget.postId);
      if (post != null) {
        await postService.incrementViewCount(widget.postId);
        if (mounted) setState(() => _post = post);
      } else {
        if (mounted) setState(() => _error = 'المنشور غير موجود');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'فشل في تحميل المنشور');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final db = ref.read(databaseServiceProvider);
      final commentsData = await db.getList(
        '${AppConstants.commentsPath}',
      );
      final comments = commentsData
          .where((c) => c['postId'] == widget.postId)
          .map((c) => CommentModel.fromJson(c))
          .toList();
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (mounted) setState(() => _comments = comments);
    } catch (e) {
      // silent
    } finally {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSendingComment = true);
    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.uid;
      final userData = authState.userData;
      if (userId == null || userData == null) return;

      final db = ref.read(databaseServiceProvider);
      final commentId = DateTime.now().millisecondsSinceEpoch.toString();
      await db.setData('${AppConstants.commentsPath}/$commentId', {
        'commentId': commentId,
        'postId': widget.postId,
        'userId': userId,
        'username': userData.username,
        'userAvatar': userData.avatarBase64,
        'content': content,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'likesCount': 0,
      });

      final newComment = CommentModel(
        commentId: commentId,
        postId: widget.postId,
        userId: userId,
        username: userData.username,
        userAvatar: userData.avatarBase64,
        content: content,
        createdAt: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
          _commentController.clear();
        });
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إرسال التعليق'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.iconPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'المنشور',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? LoadingSkeleton.postCard()
          : _error != null
              ? ErrorStateWidget(message: _error!, onRetry: _loadPost)
              : _post == null
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              children: [
                                PostCard(post: _post!, isDetail: true, showActions: true)
                                    .animate()
                                    .fadeIn(duration: 300.ms),
                                const Divider(color: AppColors.divider, height: 1),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${_post!.commentsCount} رد',
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isLoadingComments)
                                  LoadingSkeleton.postCardList(count: 3)
                                else if (_comments.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Center(
                                      child: Text(
                                        'لا توجد ردود بعد',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppColors.textTertiary,
                                            ),
                                      ),
                                    ),
                                  )
                                else
                                  ..._comments.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final comment = entry.value;
                                    return _buildCommentItem(comment, index);
                                  }),
                              ],
                            ),
                          ),
                        ),
                        _buildCommentInput(),
                      ],
                    ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push('/profile/${comment.userId}'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceElevated,
              backgroundImage: comment.userAvatar != null
                  ? MemoryImage(base64Decode(comment.userAvatar!))
                  : null,
              child: comment.userAvatar == null
                  ? Icon(Icons.person, size: 14, color: AppColors.iconTertiary)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile/${comment.userId}'),
                  child: Row(
                    children: [
                      Text(
                        comment.username,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '@${comment.username}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '·',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormatter.relativeTime(comment.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textOnSurface,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: ref.read(authProvider).userData?.avatarBase64 != null
                  ? MemoryImage(base64Decode(ref.read(authProvider).userData!.avatarBase64!))
                  : null,
              child: ref.read(authProvider).userData?.avatarBase64 == null
                  ? Icon(Icons.person, size: 12, color: AppColors.iconTertiary)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _commentController,
                enabled: !_isSendingComment,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                decoration: InputDecoration(
                  hintText: 'أضف ردك...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 38,
              height: 38,
              child: ElevatedButton(
                onPressed: _isSendingComment ? null : _sendComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _commentController.text.trim().isNotEmpty
                      ? AppColors.primary
                      : AppColors.surfaceVariant,
                  foregroundColor: _commentController.text.trim().isNotEmpty
                      ? Colors.white
                      : AppColors.textTertiary,
                  disabledBackgroundColor: AppColors.surfaceVariant,
                  disabledForegroundColor: AppColors.textTertiary,
                  shape: const CircleBorder(),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: _isSendingComment
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}