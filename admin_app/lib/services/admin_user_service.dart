import 'package:adentweets_admin/models/user_model.dart';
import 'package:adentweets_admin/services/database_service.dart';

class AdminUserService {
  AdminUserService._();

  static Future<List<UserModel>> fetchUsers({
    int limit = 50,
  }) async {
    final snapshot = await DatabaseService.get('users');
    final List<UserModel> users = [];

    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map;
      final entries = map.entries.toList();
      entries.sort((a, b) {
        final aTime = _getTime(a.value);
        final bTime = _getTime(b.value);
        return bTime.compareTo(aTime);
      });

      for (final entry in entries) {
        if (users.length >= limit) break;
        final userMap = Map<String, dynamic>.from(entry.value as Map);
        users.add(UserModel.fromMap(userMap, entry.key as String));
      }
    }

    return users;
  }

  static Future<UserModel?> fetchUser(String userId) async {
    final snapshot = await DatabaseService.get('users/$userId');
    if (!snapshot.exists) return null;
    final userMap = Map<String, dynamic>.from(snapshot.value as Map);
    return UserModel.fromMap(userMap, userId);
  }

  static Future<void> suspendUser(String userId) async {
    await DatabaseService.update('users/$userId', {'isSuspended': true});
  }

  static Future<void> unsuspendUser(String userId) async {
    await DatabaseService.update('users/$userId', {'isSuspended': false});
  }

  static Future<void> verifyUser(String userId, String verificationType) async {
    final isVerified = verificationType != 'none';
    await DatabaseService.update('users/$userId', {
      'isVerified': isVerified,
      'verificationType': verificationType,
    });
  }

  static Future<void> deleteUser(String userId) async {
    final postsSnapshot = await DatabaseService.get('posts');
    if (postsSnapshot.exists && postsSnapshot.value != null) {
      final postsMap = postsSnapshot.value as Map;
      for (final entry in postsMap.entries) {
        final post = Map<String, dynamic>.from(entry.value as Map);
        if (post['authorId'] == userId || post['userId'] == userId) {
          await DatabaseService.remove('posts/${entry.key}');
        }
      }
    }

    final commentsSnapshot = await DatabaseService.get('comments');
    if (commentsSnapshot.exists && commentsSnapshot.value != null) {
      final commentsMap = commentsSnapshot.value as Map;
      for (final entry in commentsMap.entries) {
        final comment = Map<String, dynamic>.from(entry.value as Map);
        if (comment['authorId'] == userId || comment['userId'] == userId) {
          await DatabaseService.remove('comments/${entry.key}');
        }
      }
    }

    await DatabaseService.remove('users/$userId');
  }

  static Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await DatabaseService.get('users');
    final List<UserModel> users = [];

    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map;
      final lowerQuery = query.toLowerCase();

      for (final entry in map.entries) {
        final userMap = Map<String, dynamic>.from(entry.value as Map);
        final displayName = (userMap['displayName'] as String? ?? userMap['fullName'] as String? ?? '').toLowerCase();
        final username = (userMap['username'] as String? ?? '').toLowerCase();
        final email = (userMap['email'] as String? ?? '').toLowerCase();

        if (displayName.contains(lowerQuery) ||
            username.contains(lowerQuery) ||
            email.contains(lowerQuery)) {
          users.add(UserModel.fromMap(userMap, entry.key as String));
        }
      }
    }

    return users;
  }

  static int _getTime(dynamic value) {
    if (value is Map) {
      return (value['createdAt'] as int? ?? value['joinedAt'] as int? ?? 0);
    }
    return 0;
  }
}