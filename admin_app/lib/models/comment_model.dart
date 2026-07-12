class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String? authorAvatarBase64;
  final String authorVerificationType;
  final String content;
  final int likesCount;
  final String? replyToCommentId;
  final DateTime createdAt;
  final bool isDeleted;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    this.authorAvatarBase64,
    this.authorVerificationType = 'none',
    required this.content,
    this.likesCount = 0,
    this.replyToCommentId,
    required this.createdAt,
    this.isDeleted = false,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      postId: map['postId'] as String? ?? '',
      authorId: map['authorId'] as String? ?? map['userId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '',
      authorUsername: map['authorUsername'] as String? ?? map['username'] as String? ?? '',
      authorAvatarUrl: map['authorAvatarUrl'] as String?,
      authorAvatarBase64: map['authorAvatarBase64'] as String?,
      authorVerificationType: map['authorVerificationType'] as String? ?? 'none',
      content: map['content'] as String? ?? '',
      likesCount: map['likesCount'] as int? ?? 0,
      replyToCommentId: map['replyToCommentId'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatarUrl': authorAvatarUrl,
      'authorAvatarBase64': authorAvatarBase64,
      'authorVerificationType': authorVerificationType,
      'content': content,
      'likesCount': likesCount,
      'replyToCommentId': replyToCommentId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.now();
  }
}