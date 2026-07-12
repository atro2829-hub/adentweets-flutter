import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/date_formatter.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/models/comment_model.dart';
import 'package:adentweets_admin/services/admin_comment_service.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  List<CommentModel> _comments = [];
  List<CommentModel> _filteredComments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments = await AdminCommentService.fetchComments();
      if (mounted) {
        setState(() {
          _comments = comments;
          _filteredComments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter(String query) {
    _searchQuery = query.toLowerCase();
    setState(() {
      _filteredComments = _comments.where((c) =>
        c.content.toLowerCase().contains(_searchQuery) ||
        c.authorName.toLowerCase().contains(_searchQuery)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.horizontalPadding(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('إدارة التعليقات'),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: _loadComments,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'بحث في التعليقات...',
                  prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : _filteredComments.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
                          itemCount: _filteredComments.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final comment = _filteredComments[index];
                            return Dismissible(
                              key: ValueKey(comment.id),
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
                                    title: const Text('حذف التعليق'),
                                    content: const Text('هل تريد حذف هذا التعليق؟'),
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
                                await AdminCommentService.deleteComment(comment.id);
                                setState(() {
                                  _comments.removeWhere((c) => c.id == comment.id);
                                  _filteredComments.removeWhere((c) => c.id == comment.id);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف التعليق')));
                              },
                              child: _CommentItem(comment: comment),
                            ).animate().fadeIn(delay: (index * 20).ms, duration: 300.ms);
                          },
                        ),
            ),
          ],
        ),
      ),
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
          height: 72,
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
          Icon(Iconsax.message_text, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('لا توجد تعليقات', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentModel comment;

  const _CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.backgroundElevated,
                child: Text(
                  comment.authorName.isNotEmpty ? comment.authorName[0] : '?',
                  style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comment.authorName, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                        if (comment.authorVerificationType != 'none') ...[
                          const SizedBox(width: 4),
                          Icon(Iconsax.verify, size: 13, color: AppColors.badgeBlue),
                        ],
                      ],
                    ),
                    Text('@${comment.authorUsername}', style: TextStyle(color: AppColors.textSecondary, fontSize: 11), textDirection: TextDirection.ltr),
                  ],
                ),
              ),
              Text(DateFormatter.formatRelative(comment.createdAt), style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'منشور: ${comment.postId.substring(0, 8)}...',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Iconsax.heart, size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('${comment.likesCount}', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}