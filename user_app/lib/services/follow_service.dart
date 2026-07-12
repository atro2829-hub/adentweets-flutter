import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/services/database_service.dart';

class FollowService {
  final DatabaseService _db;

  FollowService(this._db);

  Future<void> followUser(String followerId, String followingId) async {
    try {
      await _db.setData(
        '${AppConstants.followsPath}/$followerId/$followingId',
        {'timestamp': DateTime.now().millisecondsSinceEpoch},
      );

      await _db.incrementValue(
        '${AppConstants.usersPath}/$followerId',
        'followingCount',
      );

      await _db.incrementValue(
        '${AppConstants.usersPath}/$followingId',
        'followersCount',
      );
    } catch (e) {
      throw Exception('فشل في المتابعة');
    }
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      await _db.deleteData(
        '${AppConstants.followsPath}/$followerId/$followingId',
      );

      await _db.incrementValue(
        '${AppConstants.usersPath}/$followerId',
        'followingCount',
        amount: -1,
      );

      await _db.incrementValue(
        '${AppConstants.usersPath}/$followingId',
        'followersCount',
        amount: -1,
      );
    } catch (e) {
      throw Exception('فشل في إلغاء المتابعة');
    }
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      return await _db.exists(
        '${AppConstants.followsPath}/$followerId/$followingId',
      );
    } catch (e) {
      return false;
    }
  }

  Future<List<UserModel>> getFollowers(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final followsData = await _db.getData(
        '${AppConstants.followsPath}/$userId',
      );

      if (followsData == null) return [];

      final followerIds = followsData.keys.take(limit).toList();
      final users = <UserModel>[];

      for (final fid in followerIds) {
        final data = await _db.getData('${AppConstants.usersPath}/$fid');
        if (data != null) {
          users.add(UserModel.fromJson(data));
        }
      }

      return users;
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getFollowing(
    String userId, {
    int limit = 30,
  }) async {
    try {
      final followsData = await _db.getData(
        '${AppConstants.followsPath}/$userId',
      );

      if (followsData == null) return [];

      final followingIds = followsData.keys.take(limit).toList();
      final users = <UserModel>[];

      for (final fid in followingIds) {
        final data = await _db.getData('${AppConstants.usersPath}/$fid');
        if (data != null) {
          users.add(UserModel.fromJson(data));
        }
      }

      return users;
    } catch (e) {
      return [];
    }
  }
}

final followServiceProvider = Provider<FollowService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return FollowService(db);
});