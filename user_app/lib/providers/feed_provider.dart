import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/services/timeline_service.dart';

enum FeedTab { forYou, following }

class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? lastKey;
  final FeedTab currentTab;
  final String? error;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.lastKey,
    this.currentTab = FeedTab.forYou,
    this.error,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? lastKey,
    FeedTab? currentTab,
    String? error,
    bool clearError,
    bool clearPosts,
  }) {
    return FeedState(
      posts: clearPosts ? [] : (posts ?? this.posts),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastKey: lastKey ?? this.lastKey,
      currentTab: currentTab ?? this.currentTab,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final TimelineService _timelineService;
  String? _currentUserId;

  FeedNotifier(this._timelineService) : super(const FeedState());

  void setUserId(String userId) {
    _currentUserId = userId;
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearPosts: true,
      hasMore: true,
      lastKey: null,
    );

    try {
      List<PostModel> posts;
      if (state.currentTab == FeedTab.following && _currentUserId != null) {
        posts = await _timelineService.getFollowingFeed(
          userId: _currentUserId!,
        );
      } else {
        posts = await _timelineService.getForYouFeed();
      }

      final lastKey = posts.isNotEmpty ? posts.last.postId : null;

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        lastKey: lastKey,
        hasMore: posts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل في تحميل المنشورات',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      List<PostModel> morePosts;
      if (state.currentTab == FeedTab.following && _currentUserId != null) {
        morePosts = await _timelineService.getFollowingFeed(
          userId: _currentUserId!,
          lastPostKey: state.lastKey,
        );
      } else {
        morePosts = await _timelineService.getForYouFeed(
          lastPostKey: state.lastKey,
        );
      }

      final newPosts = [...state.posts, ...morePosts];
      final lastKey =
          morePosts.isNotEmpty ? morePosts.last.postId : state.lastKey;

      state = state.copyWith(
        posts: newPosts,
        isLoadingMore: false,
        lastKey: lastKey,
        hasMore: morePosts.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void switchTab(FeedTab tab) {
    state = state.copyWith(
      currentTab: tab,
      clearPosts: true,
      lastKey: null,
      hasMore: true,
    );
    refresh();
  }

  void removePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.postId != postId).toList(),
    );
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final timeline = ref.watch(timelineServiceProvider);
  return FeedNotifier(timeline);
});