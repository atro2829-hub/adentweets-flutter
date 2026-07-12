import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/date_formatter.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/providers/dashboard_provider.dart';
import 'package:adentweets_admin/providers/admin_reports_provider.dart';
import 'package:adentweets_admin/widgets/stats_card.dart';
import 'package:adentweets_admin/widgets/charts/line_chart_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final padding = ResponsiveUtils.horizontalPadding(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        color: AppColors.accentPrimary,
        onRefresh: () => ref.read(dashboardProvider.notifier).loadData(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, state, padding)),
            SliverToBoxAdapter(child: _buildStatsGrid(context, state, padding)),
            SliverToBoxAdapter(child: _buildQuickActions(context, padding)),
            SliverToBoxAdapter(child: _buildRecentActivity(context, state, padding)),
            SliverToBoxAdapter(child: _buildMiniChart(context, state, padding)),
            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardState state, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormatter.getGreeting()}، مدير النظام',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.formatDateOnly(DateTime.now()),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardState state, double padding) {
    if (state.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Shimmer.fromColors(
          baseColor: AppColors.backgroundElevated,
          highlightColor: AppColors.backgroundCard,
          child: GridView.count(
            crossAxisCount: ResponsiveUtils.gridColumns(context),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.4 : 1.5,
            children: List.generate(6, (_) => Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(12),
              ),
            )),
          ),
        ),
      );
    }

    final stats = state.stats;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: GridView.count(
        crossAxisCount: ResponsiveUtils.gridColumns(context),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.4 : 1.5,
        children: [
          StatsCard(
            label: 'إجمالي المستخدمين',
            value: stats['totalUsers'] ?? 0,
            icon: Iconsax.user,
            iconColor: AppColors.accentPrimary,
            changePercent: 12.5,
            onTap: () => context.go('/users'),
          ),
          StatsCard(
            label: 'إجمالي المنشورات',
            value: stats['totalPosts'] ?? 0,
            icon: Iconsax.document_text,
            iconColor: AppColors.info,
            changePercent: 8.3,
            onTap: () => context.go('/posts'),
          ),
          StatsCard(
            label: 'التعليقات',
            value: stats['totalComments'] ?? 0,
            icon: Iconsax.message_text,
            iconColor: AppColors.accentTertiary,
            changePercent: 5.2,
            onTap: () => context.go('/comments'),
          ),
          StatsCard(
            label: 'بلاغات معلقة',
            value: stats['pendingReports'] ?? 0,
            icon: Iconsax.shield_warning,
            iconColor: AppColors.error,
            changePercent: -3.1,
            onTap: () => context.go('/reports'),
          ),
          StatsCard(
            label: 'حسابات موثقة',
            value: stats['verifiedCount'] ?? 0,
            icon: Iconsax.verify,
            iconColor: AppColors.badgeBlue,
            changePercent: 2.0,
            onTap: () => context.go('/verification'),
          ),
          StatsCard(
            label: 'مسجلون اليوم',
            value: stats['todayUsers'] ?? 0,
            icon: Iconsax.user_add,
            iconColor: AppColors.warning,
            changePercent: 15.0,
            onTap: () => context.go('/analytics'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _QuickActionChip(
                  icon: Iconsax.verify,
                  label: 'توثيق مستخدم',
                  color: AppColors.badgeBlue,
                  onTap: () => context.go('/verification'),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  icon: Iconsax.shield_warning,
                  label: 'عرض البلاغات',
                  color: AppColors.error,
                  onTap: () => context.go('/reports'),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  icon: Iconsax.hashtag,
                  label: 'الترندات',
                  color: AppColors.warning,
                  onTap: () => context.go('/trending'),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  icon: Iconsax.chart_2,
                  label: 'التحليلات',
                  color: AppColors.accentPrimary,
                  onTap: () => context.go('/analytics'),
                ),
                const SizedBox(width: 10),
                _QuickActionChip(
                  icon: Iconsax.setting_2,
                  label: 'الإعدادات',
                  color: AppColors.textSecondary,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, DashboardState state, double padding) {
    if (state.isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
        child: Shimmer.fromColors(
          baseColor: AppColors.backgroundElevated,
          highlightColor: AppColors.backgroundCard,
          child: Column(
            children: List.generate(5, (_) => Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(8),
              ),
            )),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'النشاط الأخير',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/activity-log'),
                child: Text('عرض الكل', style: TextStyle(color: AppColors.accentPrimary, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.recentActivity.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'لا يوجد نشاط حديث',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                ),
              ),
            )
          else
            ...state.recentActivity.take(5).map((log) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Iconsax.clock, size: 14, color: AppColors.accentPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.actionLabel,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          log.details,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormatter.formatRelative(log.timestamp),
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildMiniChart(BuildContext context, DashboardState state, double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: state.isLoading
            ? Shimmer.fromColors(
                baseColor: AppColors.backgroundElevated,
                highlightColor: AppColors.backgroundCard,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
            : LineChartWidget(
                data: state.weekRegistrations,
                title: 'تسجيلات هذا الأسبوع',
                lineColor: AppColors.accentPrimary,
                fillColor: AppColors.accentPrimary,
              ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}