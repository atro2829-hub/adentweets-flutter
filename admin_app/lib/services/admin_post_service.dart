import 'package:adentweets_admin/models/post_model.dart';
import 'package:adentweets_admin/services/database_service.dart';

class AdminPostService {
  AdminPostService._();

  static Future<List<PostModel>> fetchPosts({int limit = 50}) async {
    final items = await DatabaseService.getList(
      'posts',
      limit: limit,
      orderBy: 'createdAt',
    );

    return items.map((item) {
      final id = item.remove('id') as String;
      return PostModel.fromMap(item, id);
    }).where((p) => !p.isDeleted).toList();
  }

  static Future<List<PostModel>> searchPosts(String query) async {
    final snapshot = await DatabaseService.get('posts');
    final List<PostModel> posts = [];

    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map;
      final lowerQuery = query.toLowerCase();

      for (final entry in map.entries) {
        final postMap = Map<String, dynamic>.from(entry.value as Map);
        final content = (postMap['content'] as String? ?? '').toLowerCase();
        final authorName = (postMap['authorName'] as String? ?? postMap['username'] as String? ?? '').toLowerCase();

        if (content.contains(lowerQuery) || authorName.contains(lowerQuery)) {
          final post = PostModel.fromMap(postMap, entry.key as String);
          if (!post.isDeleted) {
            posts.add(post);
          }
        }
      }
    }

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }

  static Future<void> deletePost(String postId) async {
    await DatabaseService.update('posts/$postId', {'isDeleted': true});
  }

  static Future<List<PostModel>> fetchUserPosts(String userId) async {
    final snapshot = await DatabaseService.get('posts');
    final List<PostModel> posts = [];

    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map;
      for (final entry in map.entries) {
        final postMap = Map<String, dynamic>.from(entry.value as Map);
        final authorId = postMap['authorId'] as String? ?? postMap['userId'] as String? ?? '';
        if (authorId == userId) {
          final post = PostModel.fromMap(postMap, entry.key as String);
          if (!post.isDeleted) {
            posts.add(post);
          }
        }
      }
    }

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }
}