import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';

class BarChartWidget extends StatelessWidget {
  final Map<DateTime, int> data;
  final String title;
  final Color barColor;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.barColor = AppColors.accentPrimary,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'لا توجد بيانات',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
          ),
        ),
      );
    }

    final sortedKeys = data.keys.toList()..sort();
    final maxVal = data.values.fold(0, (a, b) => a > b ? a : b);
    final effectiveMax = (maxVal * 1.2).ceilToDouble();

    final barGroups = List.generate(sortedKeys.length, (index) {
      final value = (data[sortedKeys[index]] ?? 0).toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: barColor,
            width: sortedKeys.length > 14 ? 8 : 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: effectiveMax / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.borderLight,
                  strokeWidth: 0.5,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const SizedBox.shrink();
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= sortedKeys.length) {
                        return const SizedBox.shrink();
                      }
                      if (idx % 2 != 0 && sortedKeys.length > 7) {
                        return const SizedBox.shrink();
                      }
                      final date = sortedKeys[idx];
                      return Text(
                        '${date.day}/${date.month}',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: effectiveMax,
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }
}