import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/core/utils/hashtag_extractor.dart';
import 'package:adentweets_app/services/database_service.dart';

class TrendingService {
  final DatabaseService _db;

  TrendingService(this._db);

  Future<void> updateTrendingFromPost(String content) async {
    try {
      final hashtags = HashtagExtractor.extract(content);
      if (hashtags.isEmpty) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      for (final tag in hashtags) {
        final path = '${AppConstants.trendingPath}/$tag';
        final existing = await _db.getData(path);

        if (existing != null) {
          await _db.updateData(path, {
            'count': (existing['count'] as int? ?? 0) + 1,
            'lastUpdated': now,
          });
        } else {
          await _db.setData(path, {
            'count': 1,
            'lastUpdated': now,
            'posts': [],
          });
        }
      }
    } catch (e) {
      // Silent fail for trending
    }
  }

  Future<Map<String, int>> getTopTrending({int limit = 10}) async {
    try {
      final data = await _db.getData(AppConstants.trendingPath);
      if (data == null) return {};

      final trending = <String, int>{};
      for (final entry in data.entries) {
        final count = entry.value['count'] as int? ?? 0;
        trending[entry.key] = count;
      }

      final sorted = Map.fromEntries(
        trending.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );

      return Map.fromEntries(sorted.entries.take(limit));
    } catch (e) {
      return {};
    }
  }
}

final trendingServiceProvider = Provider<TrendingService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return TrendingService(db);
});