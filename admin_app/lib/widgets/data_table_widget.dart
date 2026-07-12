import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';

class DataTableWidget<T> extends StatelessWidget {
  final List<T> items;
  final List<DataColumn> columns;
  final Widget Function(BuildContext, T, int) rowBuilder;
  final bool isLoading;
  final Widget? emptyWidget;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final Widget? headerWidget;
  final double? rowHeight;

  const DataTableWidget({
    super.key,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    this.isLoading = false,
    this.emptyWidget,
    this.onLoadMore,
    this.hasMore = false,
    this.headerWidget,
    this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return _buildShimmer(context);
    }

    if (items.isEmpty) {
      return emptyWidget ?? _buildEmptyState(context);
    }

    return Column(
      children: [
        if (headerWidget != null) ...[
          headerWidget!,
          const SizedBox(height: 12),
        ],
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backgroundTertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: columns.map((col) => Expanded(
              flex: _getColumnFlex(col),
              child: (col.label as Widget),
            )).toList(),
          ),
        ),
        // Rows
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return InkWell(
            onTap: () {},
            child: Container(
              height: rowHeight ?? 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderLight,
                    width: 0.5,
                  ),
                ),
              ),
              child: rowBuilder(context, item, index),
            ),
          );
        }).toList(),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: onLoadMore,
                child: Text(
                  'تحميل المزيد',
                  style: TextStyle(color: AppColors.accentPrimary),
                ),
              ),
            ),
          ),
      ],
    );
  }

  int _getColumnFlex(DataColumn col) {
    if (col.numeric) return 1;
    return 2;
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundElevated,
      highlightColor: AppColors.backgroundCard,
      child: Column(
        children: List.generate(8, (index) => Container(
          height: 64,
          margin: EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد بيانات',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على أي عناصر',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}