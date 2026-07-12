import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/services/database_service.dart';
import 'package:adentweets_app/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class PostService {
  final DatabaseService _db;
  final DatabaseReference _ref;

  PostService(this._db) : _ref = FirebaseService.ref;

  Future<PostModel> createPost({
    required String userId,
    required String username,
    required String userFullName,
    String? userAvatar,
    String userBadge = 'none',
    required String content,
    String? imageBase64,
    String? parentPostId,
  }) async {
    try {
      final postId = const Uuid().v4();
      final hashtags = _extractHashtags(content);

      final postData = PostModel(
        postId: postId,
        userId: userId,
        username: username,
        userAvatar: userAvatar,
        userFullName: userFullName,
        userBadge: userBadge == 'blue'
            ? VerificationBadge.blue
            : userBadge == 'gray'
                ? VerificationBadge.gray
                : VerificationBadge.none,
        content: content,
        imageBase64: imageBase64,
        createdAt: DateTime.now(),
        hashtags: hashtags,
        parentPostId: parentPostId,
      );

      await _db.setData(
        '${AppConstants.postsPath}/$postId',
        postData.toJson(),
      );

      await _db.incrementValue(
        '${AppConstants.usersPath}/$userId',
        'postsCount',
      );

      if (parentPostId != null) {
        await _db.incrementValue(
          '${AppConstants.postsPath}/$parentPostId',
          'commentsCount',
        );
      }

      return postData;
    } catch (e) {
      throw Exception('فشل في إنشاء المنشور');
    }
  }

  Future<void> deletePost(String postId, String userId) async {
    try {
      await _db.updateData(
        '${AppConstants.postsPath}/$postId',
        {'isDeleted': true},
      );

      await _db.incrementValue(
        '${AppConstants.usersPath}/$userId',
        'postsCount',
        amount: -1,
      );

      final comments = await _db.getList(
        '${AppConstants.commentsPath}',
      );
      for (final c in comments) {
        final cid = c['_key'] as String?;
        final cPostId = c['postId'] as String?;
        if (cPostId == postId && cid != null) {
          await _db.deleteData('${AppConstants.commentsPath}/$cid');
        }
      }
    } catch (e) {
      throw Exception('فشل في حذف المنشور');
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await _db.setData(
        '${AppConstants.likesPath}/$postId/$userId',
        true,
      );
      await _db.incrementValue(
        '${AppConstants.postsPath}/$postId',
        'likesCount',
      );
    } catch (e) {
      throw Exception('فشل في الإعجاب بالمنشور');
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _db.deleteData(
        '${AppConstants.likesPath}/$postId/$userId',
      );
      await _db.incrementValue(
        '${AppConstants.postsPath}/$postId',
        'likesCount',
        amount: -1,
      );
    } catch (e) {
      throw Exception('فشل في إزالة الإعجاب');
    }
  }

  Future<bool> isPostLiked(String postId, String userId) async {
    try {
      return await _db.exists(
        '${AppConstants.likesPath}/$postId/$userId',
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> bookmarkPost(String postId, String userId) async {
    try {
      await _db.setData(
        '${AppConstants.bookmarksPath}/$userId/$postId',
        true,
      );
    } catch (e) {
      throw Exception('فشل في حفظ المنشور');
    }
  }

  Future<void> unbookmarkPost(String postId, String userId) async {
    try {
      await _db.deleteData(
        '${AppConstants.bookmarksPath}/$userId/$postId',
      );
    } catch (e) {
      throw Exception('فشل في إزالة الحفظ');
    }
  }

  Future<bool> isPostBookmarked(String postId, String userId) async {
    try {
      return await _db.exists(
        '${AppConstants.bookmarksPath}/$userId/$postId',
      );
    } catch (e) {
      return false;
    }
  }

  Future<PostModel?> getPostById(String postId) async {
    try {
      final data = await _db.getData('${AppConstants.postsPath}/$postId');
      if (data == null) return null;
      return PostModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20}) async {
    try {
      final posts = await _db.getListOrdered(
        AppConstants.postsPath,
        orderBy: 'createdAt',
        limit: limit,
      );

      return posts
          .where((p) => p['userId'] == userId && !(p['isDeleted'] as bool? ?? false))
          .map((p) => PostModel.fromJson(p))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<PostModel>> getReplies(String postId, {int limit = 20}) async {
    try {
      final comments = await _db.getList(
        AppConstants.commentsPath,
        limit: limit,
      );

      final postIds = comments
          .where((c) => c['postId'] == postId)
          .map((c) => c['postId'] as String)
          .toList();

      final replies = <PostModel>[];
      for (final c in comments) {
        final parentPostId = c['postId'] as String?;
        if (parentPostId == postId) {
          final cid = c['_key'] as String;
          final data = await _db.getData('${AppConstants.postsPath}/$cid');
          if (data != null && !(data['isDeleted'] as bool? ?? false)) {
            replies.add(PostModel.fromJson(data));
          }
        }
      }

      replies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return replies;
    } catch (e) {
      return [];
    }
  }

  Future<List<PostModel>> getBookmarkedPosts(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final bookmarks = await _db.getData(
        '${AppConstants.bookmarksPath}/$userId',
      );

      if (bookmarks == null) return [];

      final postIds = bookmarks.keys.toList().reversed.take(limit).toList();
      final posts = <PostModel>[];

      for (final postId in postIds) {
        final data = await _db.getData('${AppConstants.postsPath}/$postId');
        if (data != null && !(data['isDeleted'] as bool? ?? false)) {
          posts.add(PostModel.fromJson(data));
        }
      }

      return posts;
    } catch (e) {
      return [];
    }
  }

  Future<void> pinPost(String postId, String userId) async {
    try {
      await _db.updateData(
        '${AppConstants.usersPath}/$userId',
        {'pinnedPostId': postId},
      );
      await _db.updateData(
        '${AppConstants.postsPath}/$postId',
        {'isPinned': true},
      );
    } catch (e) {
      throw Exception('فشل في تثبيت المنشور');
    }
  }

  Future<void> unpinPost(String postId, String userId) async {
    try {
      await _db.updateData(
        '${AppConstants.usersPath}/$userId',
        {'pinnedPostId': null},
      );
      await _db.updateData(
        '${AppConstants.postsPath}/$postId',
        {'isPinned': false},
      );
    } catch (e) {
      throw Exception('فشل في إلغاء تثبيت المنشور');
    }
  }

  Future<void> incrementViewCount(String postId) async {
    try {
      await _db.incrementValue(
        '${AppConstants.postsPath}/$postId',
        'viewsCount',
      );
    } catch (e) {
      // Silent fail for views
    }
  }

  Future<void> repost(String postId, String userId, String username) async {
    try {
      final repostId = const Uuid().v4();
      final original = await getPostById(postId);
      if (original == null) throw Exception('المنشور غير موجود');

      final repost = PostModel(
        postId: repostId,
        userId: userId,
        username: username,
        userFullName: original.userFullName,
        userAvatar: original.userAvatar,
        userBadge: original.userBadge,
        content: original.content,
        imageBase64: original.imageBase64,
        createdAt: DateTime.now(),
        repostedBy: username,
      );

      await _db.setData(
        '${AppConstants.postsPath}/$repostId',
        repost.toJson(),
      );

      await _db.incrementValue(
        '${AppConstants.postsPath}/$postId',
        'repostsCount',
      );
    } catch (e) {
      throw Exception('فشل في إعادة النشر');
    }
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#(\S+)');
    return regex
        .allMatches(text)
        .map((m) => m.group(1)!.toLowerCase())
        .toSet()
        .toList();
  }
}

final postServiceProvider = Provider<PostService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return PostService(db);
});