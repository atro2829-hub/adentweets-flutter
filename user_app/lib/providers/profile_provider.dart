import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/services/database_service.dart';
import 'package:adentweets_app/services/follow_service.dart';
import 'package:adentweets_app/services/post_service.dart';

class ProfileState {
  final UserModel? user;
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingPosts;
  final bool isFollowing;
  final String? error;

  const ProfileState({
    this.user,
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingPosts = false,
    this.isFollowing = false,
    this.error,
  });

  ProfileState copyWith({
    UserModel? user,
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingPosts,
    bool? isFollowing,
    String? error,
    bool clearError = false,
  }) {
    return ProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      isFollowing: isFollowing ?? this.isFollowing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final DatabaseService _db;
  final PostService _postService;
  final FollowService _followService;
  String? _currentUserId;

  ProfileNotifier(this._db, this._postService, this._followService)
      : super(const ProfileState());

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> loadProfile(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _db.getData('${AppConstants.usersPath}/$userId');
      if (data == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'المستخدم غير موجود',
        );
        return;
      }

      final user = UserModel.fromJson(data);

      bool isFollowing = false;
      if (_currentUserId != null && _currentUserId != userId) {
        isFollowing = await _followService.isFollowing(
          _currentUserId!,
          userId,
        );
      }

      state = state.copyWith(
        user: user,
        isLoading: false,
        isFollowing: isFollowing,
      );

      loadUserPosts(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل الملف الشخصي',
      );
    }
  }

  Future<void> loadUserPosts(String userId) async {
    state = state.copyWith(isLoadingPosts: true);
    try {
      final posts = await _postService.getUserPosts(userId);
      state = state.copyWith(posts: posts, isLoadingPosts: false);
    } catch (e) {
      state = state.copyWith(isLoadingPosts: false);
    }
  }

  Future<void> toggleFollow() async {
    if (state.user == null || _currentUserId == null) return;
    try {
      if (state.isFollowing) {
        await _followService.unfollowUser(_currentUserId!, state.user!.uid);
      } else {
        await _followService.followUser(_currentUserId!, state.user!.uid);
      }
      final newIsFollowing = !state.isFollowing;
      final updatedUser = state.user!.copyWith(
        followersCount: state.user!.followersCount + (newIsFollowing ? 1 : -1),
      );
      state = state.copyWith(
        isFollowing: newIsFollowing,
        user: updatedUser,
      );
    } catch (e) {
      // Silent
    }
  }

  void updateLocalUser(UserModel user) {
    state = state.copyWith(user: user);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  final post = ref.watch(postServiceProvider);
  final follow = ref.watch(followServiceProvider);
  return ProfileNotifier(db, post, follow);
});