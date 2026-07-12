class ActivityLogModel {
  final String logId;
  final String action;
  final String targetType;
  final String targetId;
  final String adminId;
  final String adminName;
  final String details;
  final DateTime timestamp;

  ActivityLogModel({
    required this.logId,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.adminId,
    required this.adminName,
    required this.details,
    required this.timestamp,
  });

  factory ActivityLogModel.fromMap(Map<String, dynamic> map, String logId) {
    return ActivityLogModel(
      logId: logId,
      action: map['action'] as String? ?? '',
      targetType: map['targetType'] as String? ?? '',
      targetId: map['targetId'] as String? ?? '',
      adminId: map['adminId'] as String? ?? '',
      adminName: map['adminName'] as String? ?? '',
      details: map['details'] as String? ?? '',
      timestamp: _parseTimestamp(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'targetType': targetType,
      'targetId': targetId,
      'adminId': adminId,
      'adminName': adminName,
      'details': details,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.now();
  }

  String get actionLabel {
    switch (action) {
      case 'suspend_user': return 'تعليق مستخدم';
      case 'unsuspend_user': return 'إلغاء تعليق مستخدم';
      case 'verify_user': return 'توثيق مستخدم';
      case 'delete_user': return 'حذف مستخدم';
      case 'delete_post': return 'حذف منشور';
      case 'delete_comment': return 'حذف تعليق';
      case 'resolve_report': return 'حل بلاغ';
      case 'dismiss_report': return 'رفض بلاغ';
      case 'update_settings': return 'تحديث الإعدادات';
      case 'pin_trending': return 'تثبيت ترند';
      case 'reset_trending': return 'إعادة تعيين ترند';
      default: return action;
    }
  }
}