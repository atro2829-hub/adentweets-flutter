class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String? authorAvatarBase64;
  final String authorVerificationType;
  final String content;
  final List<String> images;
  final List<String> imageBase64List;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final int bookmarksCount;
  final int viewsCount;
  final List<String> hashtags;
  final String? replyToPostId;
  final String? quotePostId;
  final String? quoteContent;
  final DateTime createdAt;
  final bool isDeleted;
  final bool isReported;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    this.authorAvatarBase64,
    this.authorVerificationType = 'none',
    required this.content,
    this.images = const [],
    this.imageBase64List = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.repostsCount = 0,
    this.bookmarksCount = 0,
    this.viewsCount = 0,
    this.hashtags = const [],
    this.replyToPostId,
    this.quotePostId,
    this.quoteContent,
    required this.createdAt,
    this.isDeleted = false,
    this.isReported = false,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      authorId: map['authorId'] as String? ?? map['userId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? map['username'] as String? ?? '',
      authorUsername: map['authorUsername'] as String? ?? map['username'] as String? ?? '',
      authorAvatarUrl: map['authorAvatarUrl'] as String?,
      authorAvatarBase64: map['authorAvatarBase64'] as String?,
      authorVerificationType: map['authorVerificationType'] as String? ?? 'none',
      content: map['content'] as String? ?? '',
      images: List<String>.from(map['images'] ?? []),
      imageBase64List: List<String>.from(map['imageBase64List'] ?? []),
      likesCount: map['likesCount'] as int? ?? 0,
      commentsCount: map['commentsCount'] as int? ?? 0,
      repostsCount: map['repostsCount'] as int? ?? 0,
      bookmarksCount: map['bookmarksCount'] as int? ?? 0,
      viewsCount: map['viewsCount'] as int? ?? 0,
      hashtags: List<String>.from(map['hashtags'] ?? []),
      replyToPostId: map['replyToPostId'] as String?,
      quotePostId: map['quotePostId'] as String?,
      quoteContent: map['quoteContent'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
      isDeleted: map['isDeleted'] as bool? ?? false,
      isReported: map['isReported'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatarUrl': authorAvatarUrl,
      'authorAvatarBase64': authorAvatarBase64,
      'authorVerificationType': authorVerificationType,
      'content': content,
      'images': images,
      'imageBase64List': imageBase64List,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'repostsCount': repostsCount,
      'bookmarksCount': bookmarksCount,
      'viewsCount': viewsCount,
      'hashtags': hashtags,
      'replyToPostId': replyToPostId,
      'quotePostId': quotePostId,
      'quoteContent': quoteContent,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'isReported': isReported,
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.now();
  }

  bool get hasImages => images.isNotEmpty || imageBase64List.isNotEmpty;
  bool get isReply => replyToPostId != null;
  bool get isQuote => quotePostId != null;
}