import 'package:adentweets_admin/services/database_service.dart';

class AdminStatsService {
  AdminStatsService._();

  static Future<Map<String, int>> fetchAllStats() async {
    final usersSnapshot = await DatabaseService.get('users');
    final postsSnapshot = await DatabaseService.get('posts');
    final reportsSnapshot = await DatabaseService.get('reports');
    final commentsSnapshot = await DatabaseService.get('comments');

    int totalUsers = 0;
    int verifiedCount = 0;
    int suspendedCount = 0;
    int adminCount = 0;
    int todayUsers = 0;

    if (usersSnapshot.exists && usersSnapshot.value != null) {
      final usersMap = usersSnapshot.value as Map;
      totalUsers = usersMap.length;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      for (final entry in usersMap.entries) {
        final user = Map<String, dynamic>.from(entry.value as Map);
        if (user['isVerified'] == true) verifiedCount++;
        if (user['isSuspended'] == true) suspendedCount++;
        if (user['isAdmin'] == true) adminCount++;

        final createdAt = user['createdAt'] as int? ?? user['joinedAt'] as int? ?? 0;
        if (createdAt >= todayStart) todayUsers++;
      }
    }

    int totalPosts = 0;
    int todayPosts = 0;
    int thisWeekPosts = 0;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final weekAgo = now.subtract(const Duration(days: 7)).millisecondsSinceEpoch;

    if (postsSnapshot.exists && postsSnapshot.value != null) {
      final postsMap = postsSnapshot.value as Map;
      for (final entry in postsMap.entries) {
        final post = Map<String, dynamic>.from(entry.value as Map);
        if (post['isDeleted'] != true) totalPosts++;

        final createdAt = post['createdAt'] as int? ?? 0;
        if (createdAt >= todayStart) todayPosts++;
        if (createdAt >= weekAgo) thisWeekPosts++;
      }
    }

    int totalReports = 0;
    int pendingReports = 0;

    if (reportsSnapshot.exists && reportsSnapshot.value != null) {
      final reportsMap = reportsSnapshot.value as Map;
      totalReports = reportsMap.length;
      for (final entry in reportsMap.entries) {
        final report = Map<String, dynamic>.from(entry.value as Map);
        if (report['status'] == 'pending') pendingReports++;
      }
    }

    int totalComments = 0;
    if (commentsSnapshot.exists && commentsSnapshot.value != null) {
      final commentsMap = commentsSnapshot.value as Map;
      for (final entry in commentsMap.entries) {
        final comment = Map<String, dynamic>.from(entry.value as Map);
        if (comment['isDeleted'] != true) totalComments++;
      }
    }

    return {
      'totalUsers': totalUsers,
      'totalPosts': totalPosts,
      'totalReports': totalReports,
      'totalComments': totalComments,
      'verifiedCount': verifiedCount,
      'suspendedCount': suspendedCount,
      'adminCount': adminCount,
      'pendingReports': pendingReports,
      'todayPosts': todayPosts,
      'thisWeekPosts': thisWeekPosts,
      'todayUsers': todayUsers,
    };
  }

  static Future<int> getCommentsCount() async {
    final snapshot = await DatabaseService.get('comments');
    if (!snapshot.exists || snapshot.value == null) return 0;
    final map = snapshot.value as Map;
    int count = 0;
    for (final entry in map.entries) {
      final comment = Map<String, dynamic>.from(entry.value as Map);
      if (comment['isDeleted'] != true) count++;
    }
    return count;
  }
}