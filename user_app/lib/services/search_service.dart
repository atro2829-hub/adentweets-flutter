import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/models/trending_model.dart';
import 'package:adentweets_app/services/database_service.dart';

class SearchService {
  final DatabaseService _db;

  SearchService(this._db);

  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    try {
      final allUsers = await _db.getData(AppConstants.usersPath);
      if (allUsers == null) return [];

      final lowerQuery = query.toLowerCase();
      return allUsers.entries
          .map((e) => UserModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
              ))
          .where((u) {
        final usernameMatch = u.username.toLowerCase().contains(lowerQuery);
        final nameMatch = u.fullName.toLowerCase().contains(lowerQuery);
        return usernameMatch || nameMatch;
      })
          .take(limit)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PostModel>> searchPosts(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];
    try {
      final allPosts = await _db.getData(AppConstants.postsPath);
      if (allPosts == null) return [];

      final lowerQuery = query.toLowerCase();
      return allPosts.entries
          .map((e) => PostModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
              ))
          .where((p) {
        if (p.isDeleted) return false;
        final contentMatch = p.content.toLowerCase().contains(lowerQuery);
        final usernameMatch = p.username.toLowerCase().contains(lowerQuery);
        final nameMatch = p.userFullName.toLowerCase().contains(lowerQuery);
        final hashtagMatch = p.hashtags.any(
          (h) => h.contains(lowerQuery),
        );
        return contentMatch || usernameMatch || nameMatch || hashtagMatch;
      })
          .take(limit)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TrendingModel>> getTrendingHashtags({int limit = 20}) async {
    try {
      final data = await _db.getData(AppConstants.trendingPath);
      if (data == null) return [];

      return data.entries
          .map((e) => TrendingModel.fromJson(
                e.key,
                Map<String, dynamic>.from(e.value as Map),
              ))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count))
        ..take(limit)
        .toList();
    } catch (e) {
      return [];
    }
  }
}

final searchServiceProvider = Provider<SearchService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SearchService(db);
});