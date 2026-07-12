import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/models/notification_model.dart';
import 'package:adentweets_app/services/database_service.dart';

class NotificationService {
  final DatabaseService _db;

  NotificationService(this._db);

  Future<void> sendNotification({
    required String userId,
    required String type,
    required String actorUserId,
    required String actorUsername,
    String? actorAvatar,
    String? postId,
    required String message,
  }) async {
    try {
      final notifId = const Uuid().v4();
      final notification = NotificationModel(
        notificationId: notifId,
        type: type,
        actorUserId: actorUserId,
        actorUsername: actorUsername,
        actorAvatar: actorAvatar,
        postId: postId,
        message: message,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _db.setData(
        '${AppConstants.notificationsPath}/$userId/$notifId',
        notification.toJson(),
      );
    } catch (e) {
      // Silent fail for notifications
    }
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _db.updateData(
        '${AppConstants.notificationsPath}/$userId/$notificationId',
        {'isRead': true},
      );
    } catch (e) {
      // Silent
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final notifs = await _db.getData(
        '${AppConstants.notificationsPath}/$userId',
      );
      if (notifs == null) return;

      final updates = <String, dynamic>{};
      for (final key in notifs.keys) {
        updates['$key/isRead'] = true;
      }
      await _db.updateData(
        '${AppConstants.notificationsPath}/$userId',
        updates,
      );
    } catch (e) {
      // Silent
    }
  }

  Future<List<NotificationModel>> getNotifications(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final data = await _db.getData(
        '${AppConstants.notificationsPath}/$userId',
      );

      if (data == null) return [];

      return data.entries
          .map((e) => NotificationModel.fromJson(
                e.key,
                Map<String, dynamic>.from(e.value as Map),
              ))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
        ..take(limit)
        .toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final data = await _db.getData(
        '${AppConstants.notificationsPath}/$userId',
      );

      if (data == null) return 0;

      int count = 0;
      for (final entry in data.entries) {
        final value = entry.value as Map<String, dynamic>;
        if (value['isRead'] == false) count++;
      }
      return count;
    } catch (e) {
      return 0;
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return NotificationService(db);
});