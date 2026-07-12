import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/models/trending_model.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/services/search_service.dart';

class SearchState {
  final String query;
  final List<UserModel> userResults;
  final List<PostModel> postResults;
  final List<TrendingModel> trending;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.query = '',
    this.userResults = const [],
    this.postResults = const [],
    this.trending = const [],
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    String? query,
    List<UserModel>? userResults,
    List<PostModel>? postResults,
    List<TrendingModel>? trending,
    bool? isLoading,
    String? error,
    bool clearError,
    bool clearResults,
  }) {
    return SearchState(
      query: query ?? this.query,
      userResults: clearResults ? [] : (userResults ?? this.userResults),
      postResults: clearResults ? [] : (postResults ?? this.postResults),
      trending: trending ?? this.trending,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _searchService;
  DateTime? _lastSearchTime;

  SearchNotifier(this._searchService) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(query: '', clearResults: true, clearError: true);
      return;
    }

    final now = DateTime.now();
    if (_lastSearchTime != null &&
        now.difference(_lastSearchTime!).inMilliseconds < 300) {
      return;
    }
    _lastSearchTime = now;

    state = state.copyWith(query: query, isLoading: true, clearError: true);
    try {
      final users = await _searchService.searchUsers(query);
      final posts = await _searchService.searchPosts(query);
      state = state.copyWith(
        userResults: users,
        postResults: posts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadTrending() async {
    try {
      final trending = await _searchService.getTrendingHashtags();
      state = state.copyWith(trending: trending);
    } catch (e) {
      // Silent
    }
  }

  void clearSearch() {
    state = state.copyWith(query: '', clearResults: true);
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final search = ref.watch(searchServiceProvider);
  return SearchNotifier(search);
});