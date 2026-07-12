import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/date_formatter.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/models/activity_log_model.dart';
import 'package:adentweets_admin/services/activity_log_service.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  List<ActivityLogModel> _logs = [];
  List<ActivityLogModel> _filteredLogs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _actionFilter = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final logs = await ActivityLogService.fetchLogs(limit: 100);
      if (mounted) {
        setState(() {
          _logs = logs;
          _filteredLogs = logs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter() {
    var filtered = _logs;

    if (_actionFilter != 'all') {
      filtered = filtered.where((l) => l.action == _actionFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((l) =>
        l.details.toLowerCase().contains(q) ||
        l.adminName.toLowerCase().contains(q) ||
        l.actionLabel.toLowerCase().contains(q)
      ).toList();
    }

    setState(() => _filteredLogs = filtered);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.horizontalPadding(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('سجل النشاط'),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: _loadLogs,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (q) {
                  _searchQuery = q.toLowerCase();
                  _filter();
                },
                decoration: InputDecoration(
                  hintText: 'بحث في السجل...',
                  prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textSecondary),
                ),
              ),
            ),
            // Action filter
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('الكل', 'all'),
                    const SizedBox(width: 8),
                    _filterChip('تعليق', 'suspend_user'),
                    const SizedBox(width: 8),
                    _filterChip('توثيق', 'verify_user'),
                    const SizedBox(width: 8),
                    _filterChip('حذف منشور', 'delete_post'),
                    const SizedBox(width: 8),
                    _filterChip('بلاغات', 'resolve_report'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // List
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : _filteredLogs.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
                          itemCount: _filteredLogs.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            return _LogItem(log: log)
                                .animate()
                                .fadeIn(delay: (index * 20).ms, duration: 300.ms);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isActive = _actionFilter == value;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      selected: isActive,
      onSelected: (_) {
        setState(() => _actionFilter = value);
        _filter();
      },
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundElevated,
      highlightColor: AppColors.backgroundCard,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(8),
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
          Icon(Iconsax.clock, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('لا يوجد سجل نشاط', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final ActivityLogModel log;

  const _LogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _actionColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_actionIcon, size: 16, color: _actionColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      log.actionLabel,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatter.formatRelative(log.timestamp),
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  log.details,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'بواسطة ${log.adminName}',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _actionColor {
    switch (log.action) {
      case 'suspend_user': return AppColors.warning;
      case 'delete_user':
      case 'delete_post':
      case 'delete_comment': return AppColors.error;
      case 'verify_user': return AppColors.badgeBlue;
      case 'resolve_report': return AppColors.success;
      case 'dismiss_report': return AppColors.textTertiary;
      default: return AppColors.info;
    }
  }

  IconData get _actionIcon {
    switch (log.action) {
      case 'suspend_user': return Iconsax.slash;
      case 'unsuspend_user': return Iconsax.tick_circle;
      case 'verify_user': return Iconsax.verify;
      case 'delete_user':
      case 'delete_post':
      case 'delete_comment': return Iconsax.trash;
      case 'resolve_report': return Iconsax.shield_tick;
      case 'dismiss_report': return Iconsax.close_circle;
      default: return Iconsax.clock;
    }
  }
}