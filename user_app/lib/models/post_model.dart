import 'package:adentweets_app/models/user_model.dart';

class PostModel {
  final String postId;
  final String userId;
  final String username;
  final String? userAvatar;
  final String userFullName;
  final VerificationBadge userBadge;
  final String content;
  final String? imageBase64;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final int viewsCount;
  final DateTime createdAt;
  final bool isPinned;
  final bool isDeleted;
  final String? parentPostId;
  final String? repostedBy;
  final List<String> hashtags;

  const PostModel({
    required this.postId,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.userFullName,
    this.userBadge = VerificationBadge.none,
    required this.content,
    this.imageBase64,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.viewsCount = 0,
    required this.createdAt,
    this.isPinned = false,
    this.isDeleted = false,
    this.parentPostId,
    this.repostedBy,
    this.hashtags = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      userAvatar: json['userAvatar'] as String?,
      userFullName: json['userFullName'] as String? ?? '',
      userBadge: _parseBadge(json['userBadge'] as String?),
      content: json['content'] as String? ?? '',
      imageBase64: json['imageBase64'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      repostsCount: json['repostsCount'] as int? ?? 0,
      viewsCount: json['viewsCount'] as int? ?? 0,
      createdAt: _parseDate(json['createdAt']),
      isPinned: json['isPinned'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      parentPostId: json['parentPostId'] as String?,
      repostedBy: json['repostedBy'] as String?,
      hashtags: (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'userAvatar': userAvatar,
      'userFullName': userFullName,
      'userBadge': userBadge.name,
      'content': content,
      'imageBase64': imageBase64,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'repostsCount': repostsCount,
      'viewsCount': viewsCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isPinned': isPinned,
      'isDeleted': isDeleted,
      'parentPostId': parentPostId,
      'repostedBy': repostedBy,
      'hashtags': hashtags,
    };
  }

  PostModel copyWith({
    String? postId,
    String? userId,
    String? username,
    String? userAvatar,
    String? userFullName,
    VerificationBadge? userBadge,
    String? content,
    String? imageBase64,
    int? likesCount,
    int? commentsCount,
    int? repostsCount,
    int? viewsCount,
    DateTime? createdAt,
    bool? isPinned,
    bool? isDeleted,
    String? parentPostId,
    String? repostedBy,
    List<String>? hashtags,
    bool clearImage = false,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      userFullName: userFullName ?? this.userFullName,
      userBadge: userBadge ?? this.userBadge,
      content: content ?? this.content,
      imageBase64: clearImage ? null : (imageBase64 ?? this.imageBase64),
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      repostsCount: repostsCount ?? this.repostsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      parentPostId: parentPostId ?? this.parentPostId,
      repostedBy: repostedBy ?? this.repostedBy,
      hashtags: hashtags ?? this.hashtags,
    );
  }

  bool get isReply => parentPostId != null;
  bool get isRepost => repostedBy != null;
  bool get hasImage => imageBase64 != null && imageBase64!.isNotEmpty;

  static VerificationBadge _parseBadge(String? badge) {
    switch (badge) {
      case 'blue':
        return VerificationBadge.blue;
      case 'gray':
        return VerificationBadge.gray;
      default:
        return VerificationBadge.none;
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}