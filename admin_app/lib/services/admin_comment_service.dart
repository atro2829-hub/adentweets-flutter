import 'package:adentweets_admin/models/comment_model.dart';
import 'package:adentweets_admin/services/database_service.dart';

class AdminCommentService {
  AdminCommentService._();

  static Future<List<CommentModel>> fetchComments({int limit = 50}) async {
    final items = await DatabaseService.getList(
      'comments',
      limit: limit,
      orderBy: 'createdAt',
    );

    return items.map((item) {
      final id = item.remove('id') as String;
      return CommentModel.fromMap(item, id);
    }).where((c) => !c.isDeleted).toList();
  }

  static Future<void> deleteComment(String commentId) async {
    await DatabaseService.update('comments/$commentId', {'isDeleted': true});
  }

  static Future<List<CommentModel>> fetchPostComments(String postId) async {
    final snapshot = await DatabaseService.get('comments');
    final List<CommentModel> comments = [];

    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map;
      for (final entry in map.entries) {
        final commentMap = Map<String, dynamic>.from(entry.value as Map);
        if (commentMap['postId'] == postId) {
          final comment = CommentModel.fromMap(commentMap, entry.key as String);
          if (!comment.isDeleted) {
            comments.add(comment);
          }
        }
      }
    }

    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return comments;
  }

  static Future<List<CommentModel>> searchComments(String query) async {
    final snapshot = await DatabaseService.get('comments');
    final List<CommentModel> comments = [];

    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map;
      final lowerQuery = query.toLowerCase();

      for (final entry in map.entries) {
        final commentMap = Map<String, dynamic>.from(entry.value as Map);
        final content = (commentMap['content'] as String? ?? '').toLowerCase();
        final authorName = (commentMap['authorName'] as String? ?? commentMap['username'] as String? ?? '').toLowerCase();

        if (content.contains(lowerQuery) || authorName.contains(lowerQuery)) {
          final comment = CommentModel.fromMap(commentMap, entry.key as String);
          if (!comment.isDeleted) {
            comments.add(comment);
          }
        }
      }
    }

    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return comments;
  }
}