import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/date_formatter.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/models/report_model.dart';
import 'package:adentweets_admin/providers/admin_reports_provider.dart';
import 'package:adentweets_admin/widgets/report_action_sheet.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminReportsProvider);
    final filteredReports = state.filteredReports;
    final padding = ResponsiveUtils.horizontalPadding(context);

    ref.listen(adminReportsProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!)),
        );
        ref.read(adminReportsProvider.notifier).clearActionMessage();
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('إدارة البلاغات'),
          actions: [
            if (state.pendingCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${state.pendingCount} معلق',
                  style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: () => ref.read(adminReportsProvider.notifier).loadReports(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Stats row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  _MiniStat(
                    label: 'معلق',
                    value: state.pendingCount,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 24),
                  _MiniStat(
                    label: 'تم الحل',
                    value: state.reports.where((r) => r.status == 'resolved').length,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 24),
                  _MiniStat(
                    label: 'مرفوض',
                    value: state.reports.where((r) => r.status == 'dismissed').length,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => ref.read(adminReportsProvider.notifier).setSearchQuery(q),
                decoration: InputDecoration(
                  hintText: 'بحث في البلاغات...',
                  prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textSecondary),
                ),
              ),
            ),
            // Filter tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ReportFilter.values.map((filter) {
                    final isActive = state.filter == filter;
                    final label = switch (filter) {
                      ReportFilter.all => 'الكل',
                      ReportFilter.pending => 'قيد المراجعة',
                      ReportFilter.resolved => 'تم الحل',
                      ReportFilter.dismissed => 'مرفوضة',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isActive,
                        onSelected: (_) => ref.read(adminReportsProvider.notifier).setFilter(filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // List
            Expanded(
              child: state.isLoading
                  ? _buildShimmer()
                  : filteredReports.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
                          itemCount: filteredReports.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return _ReportCard(
                              report: report,
                              onTap: () => ReportActionSheet.show(context, report: report),
                            ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundElevated,
      highlightColor: AppColors.backgroundCard,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.shield_cross, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('لا توجد بلاغات', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_targetIcon, size: 18, color: _statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.reason,
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'بواسطة @${report.reporterUsername}',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundTertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                report.targetContent,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  _targetTypeLabel,
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormatter.formatRelative(report.createdAt),
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
                const Spacer(),
                Text(
                  'تفاصيل',
                  style: TextStyle(color: AppColors.accentPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (report.status) {
      case 'pending': return AppColors.warning;
      case 'resolved': return AppColors.success;
      case 'dismissed': return AppColors.textTertiary;
      default: return AppColors.textTertiary;
    }
  }

  IconData get _targetIcon {
    switch (report.targetType) {
      case 'user': return Iconsax.user;
      case 'post': return Iconsax.document_text;
      case 'comment': return Iconsax.message_text;
      default: return Iconsax.flag;
    }
  }

  String get _targetTypeLabel {
    switch (report.targetType) {
      case 'user': return 'مستخدم';
      case 'post': return 'منشور';
      case 'comment': return 'تعليق';
      default: return report.targetType;
    }
  }

  Widget _buildStatusBadge() {
    final label = switch (report.status) {
      'pending' => 'قيد المراجعة',
      'resolved' => 'تم الحل',
      'dismissed' => 'مرفوض',
      _ => report.status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}