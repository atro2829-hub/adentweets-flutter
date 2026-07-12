import 'package:adentweets_admin/models/activity_log_model.dart';
import 'package:adentweets_admin/services/database_service.dart';
import 'package:adentweets_admin/services/auth_service.dart';

class ActivityLogService {
  ActivityLogService._();

  static Future<void> logAction({
    required String action,
    required String targetType,
    required String targetId,
    required String details,
  }) async {
    final admin = AuthService.currentUser;
    if (admin == null) return;

    final log = ActivityLogModel(
      logId: '',
      action: action,
      targetType: targetType,
      targetId: targetId,
      adminId: admin.uid,
      adminName: 'مدير',
      details: details,
      timestamp: DateTime.now(),
    );

    await DatabaseService.push('activity_log', log.toMap());
  }

  static Future<List<ActivityLogModel>> fetchLogs({int limit = 50}) async {
    final items = await DatabaseService.getList(
      'activity_log',
      limit: limit,
      orderBy: 'timestamp',
    );

    return items.map((item) {
      final id = item.remove('id') as String;
      return ActivityLogModel.fromMap(item, id);
    }).toList();
  }
}