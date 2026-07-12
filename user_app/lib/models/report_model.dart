class ReportModel {
  final String reportId;
  final String reporterId;
  final String reporterUsername;
  final String targetType; // 'user', 'post', 'comment'
  final String targetId;
  final String? targetContent;
  final String reason;
  final String status; // 'pending', 'resolved', 'dismissed'
  final DateTime createdAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolutionNote;

  const ReportModel({
    required this.reportId,
    required this.reporterId,
    required this.reporterUsername,
    required this.targetType,
    required this.targetId,
    this.targetContent,
    required this.reason,
    this.status = 'pending',
    required this.createdAt,
    this.resolvedBy,
    this.resolvedAt,
    this.resolutionNote,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportId: json['reportId'] as String? ?? '',
      reporterId: json['reporterId'] as String? ?? '',
      reporterUsername: json['reporterUsername'] as String? ?? '',
      targetType: json['targetType'] as String? ?? '',
      targetId: json['targetId'] as String? ?? '',
      targetContent: json['targetContent'] as String?,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: _parseDate(json['createdAt']),
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['resolvedAt'] as int)
          : null,
      resolutionNote: json['resolutionNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'reporterId': reporterId,
      'reporterUsername': reporterUsername,
      'targetType': targetType,
      'targetId': targetId,
      'targetContent': targetContent,
      'reason': reason,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.millisecondsSinceEpoch,
      'resolutionNote': resolutionNote,
    };
  }

  ReportModel copyWith({
    String? reportId,
    String? reporterId,
    String? reporterUsername,
    String? targetType,
    String? targetId,
    String? targetContent,
    String? reason,
    String? status,
    DateTime? createdAt,
    String? resolvedBy,
    DateTime? resolvedAt,
    String? resolutionNote,
  }) {
    return ReportModel(
      reportId: reportId ?? this.reportId,
      reporterId: reporterId ?? this.reporterId,
      reporterUsername: reporterUsername ?? this.reporterUsername,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetContent: targetContent ?? this.targetContent,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNote: resolutionNote ?? this.resolutionNote,
    );
  }

  bool get isPending => status == 'pending';
  bool get isResolved => status == 'resolved';
  bool get isDismissed => status == 'dismissed';

  static DateTime _parseDate(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}