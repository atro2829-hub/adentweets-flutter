class TrendingModel {
  final String hashtag;
  final int count;
  final DateTime lastUpdated;
  final List<String> posts;

  const TrendingModel({
    required this.hashtag,
    this.count = 0,
    required this.lastUpdated,
    this.posts = const [],
  });

  factory TrendingModel.fromJson(String tag, Map<String, dynamic> json) {
    return TrendingModel(
      hashtag: tag,
      count: json['count'] as int? ?? 0,
      lastUpdated: _parseDate(json['lastUpdated']),
      posts: (json['posts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'posts': posts,
    };
  }

  TrendingModel copyWith({
    String? hashtag,
    int? count,
    DateTime? lastUpdated,
    List<String>? posts,
  }) {
    return TrendingModel(
      hashtag: hashtag ?? this.hashtag,
      count: count ?? this.count,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      posts: posts ?? this.posts,
    );
  }

  String get displayHashtag => '#$hashtag';

  static DateTime _parseDate(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}