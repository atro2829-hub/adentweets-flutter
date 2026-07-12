class NotificationModel {
  final String notificationId;
  final String type; // like, repost, comment, follow, mention, verification
  final String actorUserId;
  final String actorUsername;
  final String? actorAvatar;
  final String? postId;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.notificationId,
    required this.type,
    required this.actorUserId,
    required this.actorUsername,
    this.actorAvatar,
    this.postId,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return NotificationModel(
      notificationId: id,
      type: json['type'] as String? ?? '',
      actorUserId: json['actorUserId'] as String? ?? '',
      actorUsername: json['actorUsername'] as String? ?? '',
      actorAvatar: json['actorAvatar'] as String?,
      postId: json['postId'] as String?,
      message: json['message'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'actorUserId': actorUserId,
      'actorUsername': actorUsername,
      'actorAvatar': actorAvatar,
      'postId': postId,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    String? notificationId,
    String? type,
    String? actorUserId,
    String? actorUsername,
    String? actorAvatar,
    String? postId,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      type: type ?? this.type,
      actorUserId: actorUserId ?? this.actorUserId,
      actorUsername: actorUsername ?? this.actorUsername,
      actorAvatar: actorAvatar ?? this.actorAvatar,
      postId: postId ?? this.postId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  bool get isLike => type == 'like';
  bool get isRepost => type == 'repost';
  bool get isComment => type == 'comment';
  bool get isFollow => type == 'follow';
  bool get isMention => type == 'mention';
  bool get isVerification => type == 'verification';
  bool get hasPost => postId != null && postId!.isNotEmpty;

  static DateTime _parseDate(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}