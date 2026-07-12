import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/core/utils/hashtag_extractor.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/services/post_service.dart';
import 'package:adentweets_app/services/image_service.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? replyToPostId;
  final PostModel? replyToPost;

  const CreatePostScreen({super.key, this.replyToPostId, this.replyToPost});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  String? _imageBase64;
  bool _isPosting = false;
  final List<String> _hashtagSuggestions = [];
  bool _showHashtags = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _textController.text;
    final hashtags = HashtagExtractor.extract(text);
    if (hashtags.isNotEmpty) {
      setState(() {
        _hashtagSuggestions.clear();
        _hashtagSuggestions.addAll(hashtags);
        _showHashtags = true;
      });
    } else {
      setState(() => _showHashtags = false);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageService = ref.read(imageServiceProvider);
    try {
      final base64 = await imageService.pickFromGallery();
      if (base64 != null && mounted) {
        setState(() => _imageBase64 = base64);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _submitPost() async {
    final content = _textController.text.trim();
    if (content.isEmpty && _imageBase64 == null) return;
    if (content.length > AppConstants.maxPostLength) return;

    setState(() => _isPosting = true);

    final authState = ref.read(authProvider);
    final user = authState.userData;
    final userId = authState.user?.uid;
    if (user == null || userId == null) {
      setState(() => _isPosting = false);
      return;
    }

    try {
      final postService = ref.read(postServiceProvider);
      await postService.createPost(
        userId: userId,
        username: user.username,
        userFullName: user.fullName,
        userAvatar: user.avatarBase64,
        userBadge: user.verificationBadge.name,
        content: content,
        imageBase64: _imageBase64,
        parentPostId: widget.replyToPostId,
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في نشر المنشور'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _textController.text.length;
    final isOverLimit = charCount > AppConstants.maxPostLength;
    final canPost = (charCount > 0 || _imageBase64 != null) && !isOverLimit && !_isPosting;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.iconPrimary, size: 24),
          onPressed: _isPosting ? null : () => context.pop(),
        ),
        title: Text(
          widget.replyToPostId != null ? 'رد' : 'منشور جديد',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: SizedBox(
              width: 80,
              height: 38,
              child: ElevatedButton(
                onPressed: canPost ? _submitPost : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canPost ? AppColors.primary : AppColors.surfaceVariant,
                  foregroundColor: canPost ? Colors.white : AppColors.textTertiary,
                  disabledBackgroundColor: AppColors.surfaceVariant,
                  disabledForegroundColor: AppColors.textTertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: _isPosting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'نشر',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (widget.replyToPost != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.surfaceVariant,
                            backgroundImage: widget.replyToPost!.userAvatar != null
                                ? MemoryImage(base64Decode(widget.replyToPost!.userAvatar!))
                                : null,
                            child: widget.replyToPost!.userAvatar == null
                                ? Icon(Icons.person, size: 14, color: AppColors.iconTertiary)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.replyToPost!.userFullName,
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '@${widget.replyToPost!.username}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.textTertiary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.replyToPost!.content,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surfaceVariant,
                        backgroundImage: ref.read(authProvider).userData?.avatarBase64 != null
                            ? MemoryImage(
                                base64Decode(
                                  ref.read(authProvider).userData!.avatarBase64!,
                                ),
                              )
                            : null,
                        child: ref.read(authProvider).userData?.avatarBase64 == null
                            ? Icon(Icons.person, size: 16, color: AppColors.iconTertiary)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              maxLines: null,
                              minLines: 5,
                              maxLength: AppConstants.maxPostLength + 10,
                              enabled: !_isPosting,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.6,
                                  ),
                              decoration: InputDecoration(
                                hintText: 'ما الجديد؟',
                                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                border: InputBorder.none,
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_imageBase64 != null) ...[
                    const SizedBox(height: 12),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            base64Decode(_imageBase64!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              color: AppColors.surfaceElevated,
                              child: const Icon(Icons.broken_image_outlined, color: AppColors.iconTertiary),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageBase64 = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().scale(begin: const Offset(0.95, 0.95), duration: 200.ms),
                  ],
                  if (_showHashtags) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _hashtagSuggestions.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  onPressed: _isPosting ? null : _pickImage,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$charCount/${AppConstants.maxPostLength}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isOverLimit ? AppColors.error : AppColors.textTertiary,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}