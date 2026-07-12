import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/utils/date_formatter.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/providers/chat_provider.dart';
import 'package:adentweets_app/services/image_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _imageBase64;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final userId = ref.read(authProvider).user?.uid ?? '';
    ref.read(chatProvider.notifier).openConversation(widget.conversationId, userId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    ref.read(chatProvider.notifier).clearCurrentChat();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final imageService = ref.read(imageServiceProvider);
    try {
      final base64 = await imageService.pickFromGallery();
      if (base64 != null && mounted) {
        setState(() => _imageBase64 = base64);
      }
    } catch (e) {
      // silent
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty && _imageBase64 == null) return;

    final userId = ref.read(authProvider).user?.uid ?? '';
    if (userId.isEmpty) return;

    setState(() => _isSending = true);

    try {
      await ref.read(chatProvider.notifier).sendMessage(
            conversationId: widget.conversationId,
            senderId: userId,
            content: content.isEmpty ? '📷 صورة' : content,
            imageBase64: _imageBase64,
          );

      if (mounted) {
        setState(() {
          _messageController.clear();
          _imageBase64 = null;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في إرسال الرسالة'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final userId = ref.read(authProvider).user?.uid ?? '';

    // Auto-scroll when new messages arrive
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous != null && next.currentMessages.length > previous.currentMessages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.iconPrimary),
          onPressed: () {
            ref.read(chatProvider.notifier).clearCurrentChat();
            context.pop();
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceVariant,
              child: Icon(Icons.person, size: 14, color: AppColors.iconTertiary),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محادثة',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'متصل الآن',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onlineIndicator,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoadingMessages
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : chatState.currentMessages.isEmpty
                    ? Center(
                        child: Text(
                          'ابدأ المحادثة',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: chatState.currentMessages.length,
                        itemBuilder: (context, index) {
                          final msg = chatState.currentMessages[index];
                          return _buildMessageBubble(msg, userId, index);
                        },
                      ),
          ),
          _buildImagePreview(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, String userId, int index) {
    final isMe = msg.senderId == userId;
    final isSystem = msg.type == 'system';
    final isImage = msg.type == 'image';

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            msg.content,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
        ),
      ).animate().fadeIn(delay: (index * 20).ms, duration: 200.ms);
    }

    return Align(
      alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: isImage ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.messageBubbleMe : AppColors.messageBubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isImage && msg.imageBase64 != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(msg.imageBase64!),
                  fit: BoxFit.cover,
                  width: 200,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
                    width: 200,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.broken_image_outlined, color: AppColors.iconTertiary),
                  ),
                ),
              ),
            if (!isImage)
              Text(
                msg.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormatter.formatChatTime(msg.createdAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textTertiary,
                        fontSize: 10,
                      ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 20).ms, duration: 200.ms).slideY(begin: 0.02, end: 0);
  }

  Widget _buildImagePreview() {
    if (_imageBase64 == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              base64Decode(_imageBase64!),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: GestureDetector(
              onTap: () => setState(() => _imageBase64 = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image_outlined, color: AppColors.primary, size: 24),
              onPressed: _isSending ? null : _pickImage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_isSending,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                  filled: true,
                  fillColor: AppColors.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              height: 40,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.surfaceVariant,
                  disabledForegroundColor: AppColors.textTertiary,
                  shape: const CircleBorder(),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}