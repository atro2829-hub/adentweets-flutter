import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_admin/models/post_model.dart';
import 'package:adentweets_admin/services/admin_post_service.dart';

enum PostFilter { all, withImages, reported }

class AdminPostsState {
  final bool isLoading;
  final List<PostModel> posts;
  final String searchQuery;
  final PostFilter filter;
  final String? error;
  final String? actionMessage;

  const AdminPostsState({
    this.isLoading = false,
    this.posts = const [],
    this.searchQuery = '',
    this.filter = PostFilter.all,
    this.error,
    this.actionMessage,
  });

  AdminPostsState copyWith({
    bool? isLoading,
    List<PostModel>? posts,
    String? searchQuery,
    PostFilter? filter,
    String? error,
    String? actionMessage,
  }) {
    return AdminPostsState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      error: error,
      actionMessage: actionMessage,
    );
  }

  List<PostModel> get filteredPosts {
    var filtered = posts;

    switch (filter) {
      case PostFilter.withImages:
        filtered = filtered.where((p) => p.hasImages).toList();
        break;
      case PostFilter.reported:
        filtered = filtered.where((p) => p.isReported).toList();
        break;
      case PostFilter.all:
        break;
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
        p.content.toLowerCase().contains(q) ||
        p.authorName.toLowerCase().contains(q)
      ).toList();
    }

    return filtered;
  }
}

class AdminPostsNotifier extends StateNotifier<AdminPostsState> {
  AdminPostsNotifier() : super(const AdminPostsState()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final posts = await AdminPostService.fetchPosts();
      state = state.copyWith(isLoading: false, posts: posts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilter(PostFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> deletePost(String postId) async {
    try {
      await AdminPostService.deletePost(postId);
      final updated = state.posts.where((p) => p.id != postId).toList();
      state = state.copyWith(posts: updated, actionMessage: 'تم حذف المنشور');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearActionMessage() {
    state = state.copyWith(actionMessage: null);
  }
}

final adminPostsProvider = StateNotifierProvider<AdminPostsNotifier, AdminPostsState>(
  (ref) => AdminPostsNotifier(),
);