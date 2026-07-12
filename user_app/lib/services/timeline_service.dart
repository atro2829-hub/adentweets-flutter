import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/services/database_service.dart';

class TimelineService {
  final DatabaseService _db;

  TimelineService(this._db);

  Future<List<PostModel>> getForYouFeed({
    int limit = 20,
    String? lastPostKey,
  }) async {
    try {
      List<Map<String, dynamic>> postsData;

      if (lastPostKey != null) {
        postsData = await _db.getListAfter(
          AppConstants.postsPath,
          startAfterKey: lastPostKey,
          limit: limit,
        );
      } else {
        postsData = await _db.getList(
          AppConstants.postsPath,
          limit: limit,
        );
      }

      var posts = postsData
          .where((p) =>
              !(p['isDeleted'] as bool? ?? false) &&
              p['parentPostId'] == null)
          .map((p) => PostModel.fromJson(p))
          .toList();

      posts = _rankPosts(posts);
      return posts;
    } catch (e) {
      return [];
    }
  }

  Future<List<PostModel>> getFollowingFeed({
    required String userId,
    int limit = 20,
    String? lastPostKey,
  }) async {
    try {
      final followsData = await _db.getData(
        '${AppConstants.followsPath}/$userId',
      );

      if (followsData == null || followsData.isEmpty) return [];

      final followingIds = followsData.keys.toSet();

      List<Map<String, dynamic>> postsData;
      if (lastPostKey != null) {
        postsData = await _db.getListAfter(
          AppConstants.postsPath,
          startAfterKey: lastPostKey,
          limit: limit * 3,
        );
      } else {
        postsData = await _db.getList(
          AppConstants.postsPath,
          limit: limit * 3,
        );
      }

      final posts = postsData
          .where((p) =>
              followingIds.contains(p['userId'] as String?) &&
              !(p['isDeleted'] as bool? ?? false) &&
              p['parentPostId'] == null)
          .map((p) => PostModel.fromJson(p))
          .toList();

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  List<PostModel> _rankPosts(List<PostModel> posts) {
    final now = DateTime.now();
    final ranked = posts.map((post) {
      final ageHours = now.difference(post.createdAt).inHours + 1;
      final score = (post.likesCount * AppConstants.likeWeight +
              post.commentsCount * AppConstants.commentWeight +
              post.repostsCount * AppConstants.repostWeight +
              post.viewsCount * AppConstants.viewWeight) /
          ageHours;
      return MapEntry(post, score);
    }).toList();

    ranked.sort((a, b) => b.value.compareTo(a.value));
    return ranked.map((e) => e.key).toList();
  }
}

final timelineServiceProvider = Provider<TimelineService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return TimelineService(db);
});