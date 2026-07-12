class CommentModel {
  final String commentId;
  final String postId;
  final String userId;
  final String username;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final int likesCount;

  const CommentModel({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    this.likesCount = 0,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['commentId'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
      likesCount: json['likesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commentId': commentId,
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'likesCount': likesCount,
    };
  }

  CommentModel copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? username,
    String? userAvatar,
    String? content,
    DateTime? createdAt,
    int? likesCount,
  }) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}