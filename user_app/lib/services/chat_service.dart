import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/models/conversation_model.dart';
import 'package:adentweets_app/models/message_model.dart';
import 'package:adentweets_app/services/database_service.dart';

class ChatService {
  final DatabaseService _db;

  ChatService(this._db);

  Future<ConversationModel> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    required String currentUsername,
    required String otherUsername,
    String? currentAvatar,
    String? otherAvatar,
  }) async {
    try {
      final convId = _getConversationId(currentUserId, otherUserId);
      final existing = await _db.getData(
        '${AppConstants.conversationsPath}/$convId',
      );

      if (existing != null) {
        return ConversationModel.fromJson(convId, existing);
      }

      final conversation = ConversationModel(
        conversationId: convId,
        participants: {
          currentUserId: DateTime.now().millisecondsSinceEpoch,
          otherUserId: DateTime.now().millisecondsSinceEpoch,
        },
        type: AppConstants.conversationTypeDirect,
        participantNames: [currentUsername, otherUsername],
        participantAvatars: [currentAvatar, otherAvatar],
      );

      await _db.setData(
        '${AppConstants.conversationsPath}/$convId',
        conversation.toJson(),
      );

      return conversation;
    } catch (e) {
      throw Exception('فشل في إنشاء المحادثة');
    }
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    String? imageBase64,
    String type = 'text',
  }) async {
    try {
      final messageId = const Uuid().v4();
      final message = MessageModel(
        messageId: messageId,
        senderId: senderId,
        content: content,
        imageBase64: imageBase64,
        createdAt: DateTime.now(),
        type: imageBase64 != null ? 'image' : type,
      );

      await _db.setData(
        '${AppConstants.messagesPath}/$conversationId/$messageId',
        message.toJson(),
      );

      await _db.updateData(
        '${AppConstants.conversationsPath}/$conversationId',
        {
          'lastMessage': content,
          'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
          'lastMessageSender': senderId,
        },
      );

      return message;
    } catch (e) {
      throw Exception('فشل في إرسال الرسالة');
    }
  }

  Stream<List<MessageModel>> listenToMessages(String conversationId) {
    return _db
        .listenToPath('${AppConstants.messagesPath}/$conversationId')
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final data = Map<String, dynamic>.from(
        event.snapshot.value as Map,
      );
      return data.entries
          .map((e) => MessageModel.fromJson(e.value as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  Future<void> markAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await _db.updateData(
        '${AppConstants.conversationsPath}/$conversationId/participants/$userId',
        {'lastRead': DateTime.now().millisecondsSinceEpoch},
      );
    } catch (e) {
      // Silent
    }
  }

  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final allConvs = await _db.getData(
        AppConstants.conversationsPath,
      );

      if (allConvs == null) return [];

      final conversations = <ConversationModel>[];
      for (final entry in allConvs.entries) {
        final data = entry.value as Map<String, dynamic>;
        final participants =
            (data['participants'] as Map<String, dynamic>?)?.keys.toSet() ?? {};

        if (participants.contains(userId)) {
          conversations.add(ConversationModel.fromJson(entry.key, data));
        }
      }

      conversations.sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime(2000);
        final bTime = b.lastMessageTime ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return conversations;
    } catch (e) {
      return [];
    }
  }

  String _getConversationId(String id1, String id2) {
    final sorted = [id1, id2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ChatService(db);
});