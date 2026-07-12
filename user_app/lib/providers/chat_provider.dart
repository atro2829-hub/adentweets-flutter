import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/models/conversation_model.dart';
import 'package:adentweets_app/models/message_model.dart';
import 'package:adentweets_app/services/chat_service.dart';

class ChatState {
  final List<ConversationModel> conversations;
  final List<MessageModel> currentMessages;
  final bool isLoadingConversations;
  final bool isLoadingMessages;
  final int unreadTotal;
  final String? currentConversationId;
  final String? error;

  const ChatState({
    this.conversations = const [],
    this.currentMessages = const [],
    this.isLoadingConversations = false,
    this.isLoadingMessages = false,
    this.unreadTotal = 0,
    this.currentConversationId,
    this.error,
  });

  ChatState copyWith({
    List<ConversationModel>? conversations,
    List<MessageModel>? currentMessages,
    bool? isLoadingConversations,
    bool? isLoadingMessages,
    int? unreadTotal,
    String? currentConversationId,
    String? error,
    bool clearError,
    bool clearMessages,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentMessages: clearMessages ? [] : (currentMessages ?? this.currentMessages),
      isLoadingConversations:
          isLoadingConversations ?? this.isLoadingConversations,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      unreadTotal: unreadTotal ?? this.unreadTotal,
      currentConversationId:
          currentConversationId ?? this.currentConversationId,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;

  ChatNotifier(this._chatService) : super(const ChatState());

  Future<void> loadConversations(String userId) async {
    state = state.copyWith(isLoadingConversations: true, clearError: true);
    try {
      final convs = await _chatService.getConversations(userId);
      int unreadTotal = 0;
      for (final c in convs) {
        unreadTotal += c.unreadCount;
      }
      state = state.copyWith(
        conversations: convs,
        isLoadingConversations: false,
        unreadTotal: unreadTotal,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingConversations: false,
        error: 'فشل في تحميل المحادثات',
      );
    }
  }

  Future<void> openConversation(String conversationId, String userId) async {
    state = state.copyWith(
      currentConversationId: conversationId,
      clearMessages: true,
      isLoadingMessages: true,
    );

    try {
      await _chatService.markAsRead(
        conversationId: conversationId,
        userId: userId,
      );

      _chatService.listenToMessages(conversationId).listen((messages) {
        state = state.copyWith(
          currentMessages: messages,
          isLoadingMessages: false,
        );
      });
    } catch (e) {
      state = state.copyWith(isLoadingMessages: false);
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String? imageBase64,
  }) async {
    try {
      await _chatService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        content: content,
        imageBase64: imageBase64,
      );
    } catch (e) {
      // Silent
    }
  }

  void clearCurrentChat() {
    state = state.copyWith(
      currentConversationId: null,
      clearMessages: true,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chat = ref.watch(chatServiceProvider);
  return ChatNotifier(chat);
});