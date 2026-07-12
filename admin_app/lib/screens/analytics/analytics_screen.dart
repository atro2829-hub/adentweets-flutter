import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/providers/analytics_provider.dart';
import 'package:adentweets_admin/widgets/charts/line_chart_widget.dart';
import 'package:adentweets_admin/widgets/charts/bar_chart_widget.dart';
import 'package:adentweets_admin/widgets/charts/pie_chart_widget.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);
    final padding = ResponsiveUtils.horizontalPadding(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('التحليلات'),
        ),
        body: state.isLoading
            ? _buildShimmer()
            : RefreshIndicator(
                color: AppColors.accentPrimary,
                onRefresh: () => ref.read(analyticsProvider.notifier).loadAnalytics(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
                        child: _DateRangeSelector(
                          selectedDays: state.selectedDays,
                          onSelect: (days) => ref.read(analyticsProvider.notifier).setDateRange(days),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryCard(
                                label: 'مسجلون جدد',
                                value: state.totalNewUsers,
                                icon: Iconsax.user_add,
                                color: AppColors.accentPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                label: 'منشورات جديدة',
                                value: state.totalNewPosts,
                                icon: Iconsax.document_text,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: LineChartWidget(
                            data: state.registrationTrends,
                            title: 'تسجيلات المستخدمين',
                            lineColor: AppColors.accentPrimary,
                            fillColor: AppColors.accentPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: BarChartWidget(
                            data: state.postActivity,
                            title: 'المنشورات اليومية',
                            barColor: AppColors.info,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: PieChartWidget(
                            data: state.verificationDistribution,
                            title: 'توزيع التوثيق',
                            colorMap: {
                              'blue': AppColors.badgeBlue,
                              'gray': AppColors.badgeGray,
                              'none': AppColors.textTertiary,
                            },
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'أكثر المستخدمين نشاطاً',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (state.topActiveUsers.isEmpty)
                                Center(
                                  child: Text('لا توجد بيانات', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                                )
                              else
                                ...state.topActiveUsers.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final user = entry.value;
                                  final maxCount = state.topActiveUsers.first['postCount'] as int? ?? 1;
                                  final count = user['postCount'] as int? ?? 0;
                                  final percentage = maxCount > 0 ? count / maxCount : 0.0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: index < 3 ? AppColors.accentPrimary : AppColors.textTertiary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user['userId'] as String? ?? '',
                                                style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              LinearProgressIndicator(
                                                value: percentage,
                                                backgroundColor: AppColors.backgroundElevated,
                                                color: AppColors.accentPrimary,
                                                borderRadius: BorderRadius.circular(4),
                                                minHeight: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '$count منشور',
                                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundElevated,
      highlightColor: AppColors.backgroundCard,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(6, (_) => Container(
          height: 240,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(12),
          ),
        )),
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final int selectedDays;
  final Function(int) onSelect;

  const _DateRangeSelector({required this.selectedDays, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('الفترة:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 12),
        _RangeChip(label: '7 أيام', days: 7, selected: selectedDays == 7, onTap: onSelect),
        const SizedBox(width: 8),
        _RangeChip(label: '30 يوم', days: 30, selected: selectedDays == 30, onTap: onSelect),
        const SizedBox(width: 8),
        _RangeChip(label: '90 يوم', days: 90, selected: selectedDays == 90, onTap: onSelect),
      ],
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final int days;
  final bool selected;
  final Function(int) onTap;

  const _RangeChip({
    required this.label,
    required this.days,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(days),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value.toDouble()),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, _) => Text(
                    val.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}