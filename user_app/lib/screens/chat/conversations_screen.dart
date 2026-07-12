import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/utils/date_formatter.dart';
import 'package:adentweets_app/core/widgets/loading_skeleton.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/providers/chat_provider.dart';
import 'package:adentweets_app/models/conversation_model.dart';
import 'package:adentweets_app/widgets/bottom_nav_shell.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    final userId = ref.read(authProvider).user?.uid ?? '';
    if (userId.isNotEmpty) {
      ref.read(chatProvider.notifier).loadConversations(userId);
    }
  }

  String _getOtherParticipantName(ConversationModel conv, String currentUserId) {
    final currentIdx = conv.participants.keys.toList().indexOf(currentUserId);
    if (currentIdx >= 0 && currentIdx < conv.participantNames.length) {
      return conv.participantNames[currentIdx == 0 ? 1 : 0] ?? 'مستخدم';
    }
    return conv.participantNames.isNotEmpty ? conv.participantNames.first : 'مستخدم';
  }

  String? _getOtherParticipantAvatar(ConversationModel conv, String currentUserId) {
    final currentIdx = conv.participants.keys.toList().indexOf(currentUserId);
    if (currentIdx >= 0 && currentIdx < conv.participantAvatars.length) {
      return conv.participantAvatars[currentIdx == 0 ? 1 : 0];
    }
    return conv.participantAvatars.isNotEmpty ? conv.participantAvatars.first : null;
  }

  String _getOtherParticipantId(ConversationModel conv, String currentUserId) {
    for (final id in conv.participants.keys) {
      if (id != currentUserId) return id;
    }
    return conv.participants.keys.firstOrNull ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final currentUserId = ref.read(authProvider).user?.uid ?? '';

    return BottomNavShell(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          title: Text(
            'الرسائل',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          centerTitle: true,
        ),
        body: chatState.isLoadingConversations
            ? LoadingSkeleton.conversationList(count: 6)
            : chatState.conversations.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'لا توجد محادثات',
                    subtitle: 'ابدأ محادثة جديدة مع شخص',
                    actionLabel: 'رسالة جديدة',
                    onAction: () => context.push('/new-message'),
                  )
                : ListView.builder(
                    itemCount: chatState.conversations.length,
                    itemBuilder: (context, index) {
                      final conv = chatState.conversations[index];
                      return _buildConversationItem(conv, currentUserId, index);
                    },
                  ),
      ),
    );
  }

  Widget _buildConversationItem(ConversationModel conv, String currentUserId, int index) {
    final name = _getOtherParticipantName(conv, currentUserId);
    final avatar = _getOtherParticipantAvatar(conv, currentUserId);
    final otherId = _getOtherParticipantId(conv, currentUserId);

    return Dismissible(
      key: ValueKey(conv.conversationId),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        // Remove from list locally
      },
      child: GestureDetector(
        onTap: () => context.push('/chat/${conv.conversationId}'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: avatar != null ? MemoryImage(base64Decode(avatar)) : null,
                    child: avatar == null
                        ? Icon(Icons.person, size: 20, color: AppColors.iconTertiary)
                        : null,
                  ),
                  if (conv.unreadCount > 0)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          border: Border.all(color: AppColors.scaffoldBackground, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '${conv.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: conv.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conv.lastMessageTime != null)
                          Text(
                            DateFormatter.formatChatTime(conv.lastMessageTime!),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: conv.unreadCount > 0 ? AppColors.primary : AppColors.textTertiary,
                                ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conv.lastMessage ?? '',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: conv.unreadCount > 0 ? AppColors.textSecondary : AppColors.textTertiary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms).slideX(begin: 0.03, end: 0);
  }
}