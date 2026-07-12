import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_admin/models/report_model.dart';
import 'package:adentweets_admin/services/admin_report_service.dart';

enum ReportFilter { all, pending, resolved, dismissed }

class AdminReportsState {
  final bool isLoading;
  final List<ReportModel> reports;
  final ReportFilter filter;
  final String searchQuery;
  final int pendingCount;
  final String? error;
  final String? actionMessage;

  const AdminReportsState({
    this.isLoading = false,
    this.reports = const [],
    this.filter = ReportFilter.pending,
    this.searchQuery = '',
    this.pendingCount = 0,
    this.error,
    this.actionMessage,
  });

  AdminReportsState copyWith({
    bool? isLoading,
    List<ReportModel>? reports,
    ReportFilter? filter,
    String? searchQuery,
    int? pendingCount,
    String? error,
    String? actionMessage,
  }) {
    return AdminReportsState(
      isLoading: isLoading ?? this.isLoading,
      reports: reports ?? this.reports,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      pendingCount: pendingCount ?? this.pendingCount,
      error: error,
      actionMessage: actionMessage,
    );
  }

  List<ReportModel> get filteredReports {
    var filtered = reports;

    if (filter != ReportFilter.all) {
      final statusStr = filter.name;
      filtered = filtered.where((r) => r.status == statusStr).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((r) =>
        r.reason.toLowerCase().contains(q) ||
        r.reporterName.toLowerCase().contains(q) ||
        r.targetContent.toLowerCase().contains(q)
      ).toList();
    }

    return filtered;
  }
}

class AdminReportsNotifier extends StateNotifier<AdminReportsState> {
  AdminReportsNotifier() : super(const AdminReportsState()) {
    loadReports();
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reports = await AdminReportService.fetchReports();
      final pendingCount = await AdminReportService.getPendingCount();
      state = state.copyWith(
        isLoading: false,
        reports: reports,
        pendingCount: pendingCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(ReportFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> resolveReport(String reportId, String note) async {
    try {
      await AdminReportService.resolveReport(
        reportId,
        note: note,
        adminId: 'admin',
        adminName: 'مدير',
      );
      final updated = state.reports.map((r) {
        if (r.id == reportId) {
          return r.copyWith(
            status: 'resolved',
            resolutionNote: note,
            resolvedAt: DateTime.now(),
          );
        }
        return r;
      }).toList();
      final pendingCount = state.pendingCount - 1;
      state = state.copyWith(
        reports: updated,
        pendingCount: pendingCount < 0 ? 0 : pendingCount,
        actionMessage: 'تم حل البلاغ',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> dismissReport(String reportId) async {
    try {
      await AdminReportService.dismissReport(
        reportId,
        adminId: 'admin',
        adminName: 'مدير',
      );
      final updated = state.reports.map((r) {
        if (r.id == reportId) {
          return r.copyWith(
            status: 'dismissed',
            resolvedAt: DateTime.now(),
          );
        }
        return r;
      }).toList();
      final pendingCount = state.pendingCount - 1;
      state = state.copyWith(
        reports: updated,
        pendingCount: pendingCount < 0 ? 0 : pendingCount,
        actionMessage: 'تم رفض البلاغ',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearActionMessage() {
    state = state.copyWith(actionMessage: null);
  }
}

final adminReportsProvider = StateNotifierProvider<AdminReportsNotifier, AdminReportsState>(
  (ref) => AdminReportsNotifier(),
);