import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';

class LineChartWidget extends StatelessWidget {
  final Map<DateTime, int> data;
  final String title;
  final Color lineColor;
  final Color? fillColor;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.lineColor = AppColors.accentPrimary,
    this.fillColor,
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

    final spots = sortedKeys.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (data[entry.value] ?? 0).toDouble(),
      );
    }).toList();

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
          child: LineChart(
            LineChartData(
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
                        if (value.toInt() % 2 == 0) {
                          return const SizedBox.shrink();
                        }
                        return const SizedBox.shrink();
                      }
                      final date = sortedKeys[idx];
                      if (idx % 2 != 0 && sortedKeys.length > 7) {
                        return const SizedBox.shrink();
                      }
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
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: lineColor,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: sortedKeys.length <= 14,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.backgroundCard,
                        strokeWidth: 2,
                        strokeColor: lineColor,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: fillColor != null,
                    color: (fillColor ?? lineColor).withValues(alpha: 0.1),
                    applyCutOffY: true,
                    cutOffY: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}