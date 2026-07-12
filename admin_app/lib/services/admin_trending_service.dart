import 'package:adentweets_admin/models/trending_model.dart';
import 'package:adentweets_admin/services/database_service.dart';

class AdminTrendingService {
  AdminTrendingService._();

  static Future<List<TrendingModel>> fetchTrending() async {
    final snapshot = await DatabaseService.get('trending');
    final List<TrendingModel> items = [];

    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map;
      for (final entry in map.entries) {
        items.add(TrendingModel.fromMap(
          Map<String, dynamic>.from(entry.value as Map),
          entry.key as String,
        ));
      }
    }

    items.sort((a, b) => b.postCount.compareTo(a.postCount));
    final pinned = items.where((t) => t.isPinned).toList();
    final unpinned = items.where((t) => !t.isPinned).toList();
    return [...pinned, ...unpinned];
  }

  static Future<void> pinTrending(String hashtag) async {
    await DatabaseService.update('trending/$hashtag', {
      'isPinned': true,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> unpinTrending(String hashtag) async {
    await DatabaseService.update('trending/$hashtag', {
      'isPinned': false,
    });
  }

  static Future<void> resetCount(String hashtag) async {
    await DatabaseService.update('trending/$hashtag', {
      'postCount': 0,
      'count': 0,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> deleteTrending(String hashtag) async {
    await DatabaseService.remove('trending/$hashtag');
  }

  static Future<void> addTrending(String hashtag) async {
    final cleanHashtag = hashtag.startsWith('#') ? hashtag.substring(1) : hashtag;
    await DatabaseService.update('trending/$cleanHashtag', {
      'postCount': 0,
      'count': 0,
      'isPinned': false,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });
  }
}