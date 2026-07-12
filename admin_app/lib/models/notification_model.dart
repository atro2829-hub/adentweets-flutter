class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String? actorId;
  final String? actorName;
  final String? actorUsername;
  final String? actorAvatarUrl;
  final String? postId;
  final String? commentId;
  final String? message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    this.actorId,
    this.actorName,
    this.actorUsername,
    this.actorAvatarUrl,
    this.postId,
    this.commentId,
    this.message,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      actorId: map['actorId'] as String?,
      actorName: map['actorName'] as String?,
      actorUsername: map['actorUsername'] as String?,
      actorAvatarUrl: map['actorAvatarUrl'] as String?,
      postId: map['postId'] as String?,
      commentId: map['commentId'] as String?,
      message: map['message'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.now();
  }
}