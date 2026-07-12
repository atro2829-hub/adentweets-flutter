import 'package:adentweets_admin/models/report_model.dart';
import 'package:adentweets_admin/services/database_service.dart';

class AdminReportService {
  AdminReportService._();

  static Future<List<ReportModel>> fetchReports({
    String? statusFilter,
    int limit = 50,
  }) async {
    final items = await DatabaseService.getList(
      'reports',
      limit: limit,
      orderBy: 'createdAt',
    );

    List<ReportModel> reports = items.map((item) {
      final id = item.remove('id') as String;
      return ReportModel.fromMap(item, id);
    }).toList();

    if (statusFilter != null && statusFilter != 'all') {
      reports = reports.where((r) => r.status == statusFilter).toList();
    }

    return reports;
  }

  static Future<void> resolveReport(
    String reportId, {
    required String note,
    required String adminId,
    required String adminName,
  }) async {
    await DatabaseService.update('reports/$reportId', {
      'status': 'resolved',
      'resolutionNote': note,
      'resolvedBy': adminId,
      'resolvedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<void> dismissReport(
    String reportId, {
    required String adminId,
    required String adminName,
  }) async {
    await DatabaseService.update('reports/$reportId', {
      'status': 'dismissed',
      'resolvedBy': adminId,
      'resolvedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  static Future<int> getPendingCount() async {
    final snapshot = await DatabaseService.get('reports');
    if (!snapshot.exists || snapshot.value == null) return 0;

    int count = 0;
    final map = snapshot.value as Map;
    for (final entry in map.entries) {
      final report = Map<String, dynamic>.from(entry.value as Map);
      if (report['status'] == 'pending') count++;
    }
    return count;
  }

  static Future<List<ReportModel>> searchReports(String query) async {
    final snapshot = await DatabaseService.get('reports');
    final List<ReportModel> reports = [];

    if (snapshot.exists && snapshot.value != null) {
      final map = snapshot.value as Map;
      final lowerQuery = query.toLowerCase();

      for (final entry in map.entries) {
        final reportMap = Map<String, dynamic>.from(entry.value as Map);
        final reason = (reportMap['reason'] as String? ?? '').toLowerCase();
        final reporter = (reportMap['reporterName'] as String? ?? reportMap['reporterUsername'] as String? ?? '').toLowerCase();
        final targetContent = (reportMap['targetContent'] as String? ?? '').toLowerCase();

        if (reason.contains(lowerQuery) ||
            reporter.contains(lowerQuery) ||
            targetContent.contains(lowerQuery)) {
          reports.add(ReportModel.fromMap(reportMap, entry.key as String));
        }
      }
    }

    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }
}