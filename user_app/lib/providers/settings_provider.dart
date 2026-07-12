import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/services/database_service.dart';

class SettingsState {
  final bool notificationsEnabled;
  final bool likeNotifications;
  final bool commentNotifications;
  final bool followNotifications;
  final bool mentionNotifications;
  final bool repostNotifications;
  final bool isPrivateAccount;
  final bool showOnlineStatus;
  final bool allowMessagesFromAnyone;

  const SettingsState({
    this.notificationsEnabled = true,
    this.likeNotifications = true,
    this.commentNotifications = true,
    this.followNotifications = true,
    this.mentionNotifications = true,
    this.repostNotifications = true,
    this.isPrivateAccount = false,
    this.showOnlineStatus = true,
    this.allowMessagesFromAnyone = true,
  });

  Map<String, dynamic> toJson() => {
        'notificationsEnabled': notificationsEnabled,
        'likeNotifications': likeNotifications,
        'commentNotifications': commentNotifications,
        'followNotifications': followNotifications,
        'mentionNotifications': mentionNotifications,
        'repostNotifications': repostNotifications,
        'isPrivateAccount': isPrivateAccount,
        'showOnlineStatus': showOnlineStatus,
        'allowMessagesFromAnyone': allowMessagesFromAnyone,
      };

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      likeNotifications: json['likeNotifications'] as bool? ?? true,
      commentNotifications: json['commentNotifications'] as bool? ?? true,
      followNotifications: json['followNotifications'] as bool? ?? true,
      mentionNotifications: json['mentionNotifications'] as bool? ?? true,
      repostNotifications: json['repostNotifications'] as bool? ?? true,
      isPrivateAccount: json['isPrivateAccount'] as bool? ?? false,
      showOnlineStatus: json['showOnlineStatus'] as bool? ?? true,
      allowMessagesFromAnyone:
          json['allowMessagesFromAnyone'] as bool? ?? true,
    );
  }

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? likeNotifications,
    bool? commentNotifications,
    bool? followNotifications,
    bool? mentionNotifications,
    bool? repostNotifications,
    bool? isPrivateAccount,
    bool? showOnlineStatus,
    bool? allowMessagesFromAnyone,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      likeNotifications: likeNotifications ?? this.likeNotifications,
      commentNotifications: commentNotifications ?? this.commentNotifications,
      followNotifications: followNotifications ?? this.followNotifications,
      mentionNotifications: mentionNotifications ?? this.mentionNotifications,
      repostNotifications: repostNotifications ?? this.repostNotifications,
      isPrivateAccount: isPrivateAccount ?? this.isPrivateAccount,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      allowMessagesFromAnyone:
          allowMessagesFromAnyone ?? this.allowMessagesFromAnyone,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final DatabaseService _db;
  String? _userId;

  SettingsNotifier(this._db) : super(const SettingsState());

  void setUserId(String userId) {
    _userId = userId;
  }

  Future<void> loadSettings() async {
    if (_userId == null) return;
    try {
      final data = await _db.getData(
        '${AppConstants.usersPath}/$_userId/settings',
      );
      if (data != null) {
        state = SettingsState.fromJson(data);
      }
    } catch (e) {
      // Use defaults
    }
  }

  Future<void> updateSettings(SettingsState newSettings) async {
    state = newSettings;
    if (_userId == null) return;
    try {
      await _db.setData(
        '${AppConstants.usersPath}/$_userId/settings',
        newSettings.toJson(),
      );
    } catch (e) {
      // Silent
    }
  }

  Future<void> toggleNotificationType(String type) async {
    SettingsState updated;
    switch (type) {
      case 'like':
        updated = state.copyWith(likeNotifications: !state.likeNotifications);
        break;
      case 'comment':
        updated =
            state.copyWith(commentNotifications: !state.commentNotifications);
        break;
      case 'follow':
        updated =
            state.copyWith(followNotifications: !state.followNotifications);
        break;
      case 'mention':
        updated =
            state.copyWith(mentionNotifications: !state.mentionNotifications);
        break;
      case 'repost':
        updated =
            state.copyWith(repostNotifications: !state.repostNotifications);
        break;
      default:
        return;
    }
    await updateSettings(updated);
  }

  Future<void> togglePrivateAccount() async {
    final updated = state.copyWith(isPrivateAccount: !state.isPrivateAccount);
    await updateSettings(updated);
  }

  Future<void> toggleOnlineStatus() async {
    final updated =
        state.copyWith(showOnlineStatus: !state.showOnlineStatus);
    await updateSettings(updated);
  }

  Future<void> toggleMessagePermissions() async {
    final updated = state.copyWith(
      allowMessagesFromAnyone: !state.allowMessagesFromAnyone,
    );
    await updateSettings(updated);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SettingsNotifier(db);
});