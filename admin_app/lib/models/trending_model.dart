class TrendingModel {
  final String hashtag;
  final int postCount;
  final DateTime? lastUpdated;
  final bool isPinned;

  TrendingModel({
    required this.hashtag,
    required this.postCount,
    this.lastUpdated,
    this.isPinned = false,
  });

  factory TrendingModel.fromMap(Map<String, dynamic> map, String hashtag) {
    return TrendingModel(
      hashtag: hashtag,
      postCount: map['postCount'] as int? ?? map['count'] as int? ?? 0,
      lastUpdated: _parseNullableTimestamp(map['lastUpdated']),
      isPinned: map['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postCount': postCount,
      'count': postCount,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'isPinned': isPinned,
    };
  }

  TrendingModel copyWith({
    int? postCount,
    DateTime? lastUpdated,
    bool? isPinned,
  }) {
    return TrendingModel(
      hashtag: hashtag,
      postCount: postCount ?? this.postCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  static DateTime? _parseNullableTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }

  String get displayHashtag => hashtag.startsWith('#') ? hashtag : '#$hashtag';
}