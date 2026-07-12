import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/models/report_model.dart';
import 'package:adentweets_admin/providers/admin_reports_provider.dart';

class ReportActionSheet extends ConsumerStatefulWidget {
  final ReportModel report;

  const ReportActionSheet({super.key, required this.report});

  static Future<void> show(BuildContext context, {required ReportModel report}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReportActionSheet(report: report),
    );
  }

  @override
  ConsumerState<ReportActionSheet> createState() => _ReportActionSheetState();
}

class _ReportActionSheetState extends ConsumerState<ReportActionSheet> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _resolve() {
    final note = _noteController.text.trim();
    ref.read(adminReportsProvider.notifier).resolveReport(widget.report.id, note);
    Navigator.pop(context);
  }

  void _dismiss() {
    ref.read(adminReportsProvider.notifier).dismissReport(widget.report.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة البلاغ',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'السبب', value: widget.report.reason),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'المُبلّغ',
                      value: '@${widget.report.reporterUsername}',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'نوع الهدف',
                      value: _targetTypeLabel(widget.report.targetType),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'المحتوى المُبلَّغ عنه:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundTertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.report.targetContent,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ملاحظة الحل (اختياري)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'أضف ملاحظة حول الحل...',
                        hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, left: 6, bottom: 16),
                      child: OutlinedButton.icon(
                        onPressed: _dismiss,
                        icon: Icon(Iconsax.close_circle, size: 18),
                        label: const Text('رفض'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 6, bottom: 16),
                      child: FilledButton.icon(
                        onPressed: _resolve,
                        icon: Icon(Iconsax.tick_circle, size: 18),
                        label: const Text('حل البلاغ'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.textOnAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _targetTypeLabel(String type) {
    switch (type) {
      case 'post': return 'منشور';
      case 'comment': return 'تعليق';
      case 'user': return 'مستخدم';
      default: return type;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}