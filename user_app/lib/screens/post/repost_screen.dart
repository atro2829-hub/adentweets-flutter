import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/utils/date_formatter.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/core/widgets/verification_badge.dart';
import 'package:adentweets_app/services/post_service.dart';

class RepostScreen extends ConsumerStatefulWidget {
  final PostModel originalPost;

  const RepostScreen({super.key, required this.originalPost});

  @override
  ConsumerState<RepostScreen> createState() => _RepostScreenState();
}

class _RepostScreenState extends ConsumerState<RepostScreen> {
  final _quoteController = TextEditingController();
  bool _isReposting = false;

  @override
  void dispose() {
    _quoteController.dispose();
    super.dispose();
  }

  Future<void> _handleRepost() async {
    setState(() => _isReposting = true);
    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.uid;
      final username = authState.userData?.username ?? '';
      if (userId == null) return;

      final postService = ref.read(postServiceProvider);
      await postService.repost(
        widget.originalPost.postId,
        userId,
        username,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعادة النشر'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isReposting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في إعادة النشر'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.originalPost;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.iconPrimary),
          onPressed: _isReposting ? null : () => context.pop(),
        ),
        title: Text(
          'إعادة نشر',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أعد نشر هذا المنشور',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/profile/${post.userId}'),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.surfaceVariant,
                            backgroundImage: post.userAvatar != null
                                ? MemoryImage(base64Decode(post.userAvatar!))
                                : null,
                            child: post.userAvatar == null
                                ? Icon(Icons.person, size: 16, color: AppColors.iconTertiary)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () => context.push('/profile/${post.userId}'),
                                      child: Text(
                                        post.userFullName,
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  if (post.userBadge != VerificationBadge.none) ...[
                                    const SizedBox(width: 4),
                                    VerificationBadgeWidget(badge: post.userBadge, size: 14),
                                  ],
                                  const SizedBox(width: 6),
                                  Text(
                                    '@${post.username}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormatter.relativeTime(post.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                post.content,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textOnSurface,
                                      height: 1.5,
                                    ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (post.hasImage) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    base64Decode(post.imageBase64!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 180,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 180,
                                      color: AppColors.surfaceVariant,
                                      child: const Icon(Icons.broken_image_outlined, color: AppColors.iconTertiary),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05, end: 0),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _quoteController,
                    maxLines: 4,
                    minLines: 3,
                    enabled: !_isReposting,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                    decoration: InputDecoration(
                      hintText: 'أضف تعليقًا (اختياري)...',
                      hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isReposting ? null : _handleRepost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: _isReposting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'إعادة نشر',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}