import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_admin/services/admin_analytics_service.dart';
import 'package:adentweets_admin/core/constants/app_constants.dart';

class AnalyticsState {
  final bool isLoading;
  final int selectedDays;
  final Map<DateTime, int> registrationTrends;
  final Map<DateTime, int> postActivity;
  final Map<String, int> verificationDistribution;
  final List<Map<String, dynamic>> topActiveUsers;
  final int totalNewUsers;
  final int totalNewPosts;
  final String? error;

  const AnalyticsState({
    this.isLoading = false,
    this.selectedDays = 7,
    this.registrationTrends = const {},
    this.postActivity = const {},
    this.verificationDistribution = const {},
    this.topActiveUsers = const [],
    this.totalNewUsers = 0,
    this.totalNewPosts = 0,
    this.error,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    int? selectedDays,
    Map<DateTime, int>? registrationTrends,
    Map<DateTime, int>? postActivity,
    Map<String, int>? verificationDistribution,
    List<Map<String, dynamic>>? topActiveUsers,
    int? totalNewUsers,
    int? totalNewPosts,
    String? error,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      selectedDays: selectedDays ?? this.selectedDays,
      registrationTrends: registrationTrends ?? this.registrationTrends,
      postActivity: postActivity ?? this.postActivity,
      verificationDistribution: verificationDistribution ?? this.verificationDistribution,
      topActiveUsers: topActiveUsers ?? this.topActiveUsers,
      totalNewUsers: totalNewUsers ?? this.totalNewUsers,
      totalNewPosts: totalNewPosts ?? this.totalNewPosts,
      error: error,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsState()) {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await AdminAnalyticsService.fetchAnalytics(days: state.selectedDays);
      state = state.copyWith(
        isLoading: false,
        registrationTrends: Map<DateTime, int>.from(data['registrationTrends'] as Map? ?? {}),
        postActivity: Map<DateTime, int>.from(data['postActivity'] as Map? ?? {}),
        verificationDistribution: Map<String, int>.from(data['verificationDistribution'] as Map? ?? {}),
        topActiveUsers: List<Map<String, dynamic>>.from(data['topActiveUsers'] as List? ?? []),
        totalNewUsers: data['totalNewUsers'] as int? ?? 0,
        totalNewPosts: data['totalNewPosts'] as int? ?? 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setDateRange(int days) {
    state = state.copyWith(selectedDays: days);
    loadAnalytics();
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>(
  (ref) => AnalyticsNotifier(),
);