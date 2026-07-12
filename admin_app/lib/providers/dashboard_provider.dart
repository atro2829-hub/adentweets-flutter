import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_admin/models/activity_log_model.dart';
import 'package:adentweets_admin/services/admin_stats_service.dart';
import 'package:adentweets_admin/services/activity_log_service.dart';
import 'package:adentweets_admin/services/admin_analytics_service.dart';

class DashboardState {
  final bool isLoading;
  final Map<String, int> stats;
  final List<ActivityLogModel> recentActivity;
  final Map<DateTime, int> weekRegistrations;
  final String? error;

  const DashboardState({
    this.isLoading = true,
    this.stats = const {},
    this.recentActivity = const [],
    this.weekRegistrations = const {},
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    Map<String, int>? stats,
    List<ActivityLogModel>? recentActivity,
    Map<DateTime, int>? weekRegistrations,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      recentActivity: recentActivity ?? this.recentActivity,
      weekRegistrations: weekRegistrations ?? this.weekRegistrations,
      error: error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final statsFuture = AdminStatsService.fetchAllStats();
      final activityFuture = ActivityLogService.fetchLogs(limit: 10);
      final analyticsFuture = AdminAnalyticsService.fetchAnalytics(days: 7);

      final results = await Future.wait([statsFuture, activityFuture, analyticsFuture]);

      final stats = results[0] as Map<String, int>;
      final recentActivity = results[1] as List<ActivityLogModel>;
      final analytics = results[2] as Map<String, dynamic>;

      final weekRegistrations = Map<DateTime, int>.from(
        analytics['registrationTrends'] as Map? ?? {},
      );

      state = state.copyWith(
        isLoading: false,
        stats: stats,
        recentActivity: recentActivity,
        weekRegistrations: weekRegistrations,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(),
);