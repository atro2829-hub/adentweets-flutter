import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/models/notification_model.dart';
import 'package:adentweets_app/services/notification_service.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? filterType;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.filterType,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? filterType,
    String? error,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      filterType: clearFilter ? null : (filterType ?? this.filterType),
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<NotificationModel> get filteredNotifications {
    if (filterType == null || filterType!.isEmpty) return notifications;
    return notifications.where((n) => n.type == filterType).toList();
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notifService;

  NotificationNotifier(this._notifService) : super(const NotificationState());

  Future<void> loadNotifications(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final notifs = await _notifService.getNotifications(userId);
      final unread = await _notifService.getUnreadCount(userId);
      state = state.copyWith(
        notifications: notifs,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل الإشعارات',
      );
    }
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _notifService.markAsRead(
      userId: userId,
      notificationId: notificationId,
    );
    final updated = state.notifications.map((n) {
      if (n.notificationId == notificationId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unread);
  }

  Future<void> markAllAsRead(String userId) async {
    await _notifService.markAllAsRead(userId);
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);
  }

  void setFilter(String? type) {
    state = state.copyWith(filterType: type, clearFilter: type == null);
  }

  void addNotification(NotificationModel notif) {
    final updated = [notif, ...state.notifications];
    final unread = state.unreadCount + (notif.isRead ? 0 : 1);
    state = state.copyWith(notifications: updated, unreadCount: unread);
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service);
});