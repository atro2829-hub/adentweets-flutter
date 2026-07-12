class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reporterUsername;
  final String targetType;
  final String targetId;
  final String targetContent;
  final String reason;
  final String? additionalDetails;
  final String status;
  final String? resolutionNote;
  final String? resolvedBy;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reporterUsername,
    required this.targetType,
    required this.targetId,
    required this.targetContent,
    required this.reason,
    this.additionalDetails,
    this.status = 'pending',
    this.resolutionNote,
    this.resolvedBy,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map, String id) {
    return ReportModel(
      id: id,
      reporterId: map['reporterId'] as String? ?? '',
      reporterName: map['reporterName'] as String? ?? '',
      reporterUsername: map['reporterUsername'] as String? ?? map['reporterName'] as String? ?? '',
      targetType: map['targetType'] as String? ?? 'post',
      targetId: map['targetId'] as String? ?? '',
      targetContent: map['targetContent'] as String? ?? '',
      reason: map['reason'] as String? ?? '',
      additionalDetails: map['additionalDetails'] as String?,
      status: map['status'] as String? ?? 'pending',
      resolutionNote: map['resolutionNote'] as String?,
      resolvedBy: map['resolvedBy'] as String?,
      createdAt: _parseTimestamp(map['createdAt']),
      resolvedAt: _parseNullableTimestamp(map['resolvedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reporterUsername': reporterUsername,
      'targetType': targetType,
      'targetId': targetId,
      'targetContent': targetContent,
      'reason': reason,
      'additionalDetails': additionalDetails,
      'status': status,
      'resolutionNote': resolutionNote,
      'resolvedBy': resolvedBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'resolvedAt': resolvedAt?.millisecondsSinceEpoch,
    };
  }

  ReportModel copyWith({
    String? status,
    String? resolutionNote,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return ReportModel(
      id: id,
      reporterId: reporterId,
      reporterName: reporterName,
      reporterUsername: reporterUsername,
      targetType: targetType,
      targetId: targetId,
      targetContent: targetContent,
      reason: reason,
      additionalDetails: additionalDetails,
      status: status ?? this.status,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return DateTime.now();
  }

  static DateTime? _parseNullableTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }
}