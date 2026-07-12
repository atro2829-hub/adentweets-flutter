import 'package:adentweets_admin/services/database_service.dart';

class AdminAnalyticsService {
  AdminAnalyticsService._();

  static Future<Map<String, dynamic>> fetchAnalytics({int days = 7}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final startTimestamp = startDate.millisecondsSinceEpoch;

    final usersSnapshot = await DatabaseService.get('users');
    final postsSnapshot = await DatabaseService.get('posts');

    final registrationTrends = <DateTime, int>{};
    final postActivity = <DateTime, int>{};
    int blueVerified = 0;
    int grayVerified = 0;
    int noneVerified = 0;
    final userActivity = <String, int>{};

    if (usersSnapshot.exists && usersSnapshot.value != null) {
      final usersMap = usersSnapshot.value as Map;
      for (final entry in usersMap.entries) {
        final user = Map<String, dynamic>.from(entry.value as Map);
        final createdAt = user['createdAt'] as int? ?? user['joinedAt'] as int? ?? 0;
        if (createdAt >= startTimestamp) {
          final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
          final day = DateTime(date.year, date.month, date.day);
          registrationTrends[day] = (registrationTrends[day] ?? 0) + 1;
        }

        final vType = user['verificationType'] as String? ?? user['verificationBadge'] as String? ?? 'none';
        if (vType == 'blue') {
          blueVerified++;
        } else if (vType == 'gray') {
          grayVerified++;
        } else {
          noneVerified++;
        }
      }
    }

    if (postsSnapshot.exists && postsSnapshot.value != null) {
      final postsMap = postsSnapshot.value as Map;
      for (final entry in postsMap.entries) {
        final post = Map<String, dynamic>.from(entry.value as Map);
        if (post['isDeleted'] == true) continue;

        final createdAt = post['createdAt'] as int? ?? 0;
        if (createdAt >= startTimestamp) {
          final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
          final day = DateTime(date.year, date.month, date.day);
          postActivity[day] = (postActivity[day] ?? 0) + 1;
        }

        final authorId = post['authorId'] as String? ?? post['userId'] as String? ?? '';
        if (authorId.isNotEmpty) {
          userActivity[authorId] = (userActivity[authorId] ?? 0) + 1;
        }
      }
    }

    final sortedUsers = userActivity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topActiveUsers = sortedUsers.take(10).map((e) => {
      'userId': e.key,
      'postCount': e.value,
    }).toList();

    return {
      'registrationTrends': registrationTrends,
      'postActivity': postActivity,
      'verificationDistribution': {
        'blue': blueVerified,
        'gray': grayVerified,
        'none': noneVerified,
      },
      'topActiveUsers': topActiveUsers,
      'totalNewUsers': registrationTrends.values.fold(0, (a, b) => a + b),
      'totalNewPosts': postActivity.values.fold(0, (a, b) => a + b),
    };
  }
}