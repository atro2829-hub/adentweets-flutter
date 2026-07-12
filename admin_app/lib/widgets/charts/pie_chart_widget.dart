import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final String title;
  final Map<String, Color>? colorMap;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.colorMap,
  });

  static const _defaultColors = [
    AppColors.accentPrimary,
    AppColors.badgeBlue,
    AppColors.badgeGray,
    AppColors.warning,
    AppColors.error,
    AppColors.info,
    AppColors.badgeGold,
    Color(0xFFEC4899),
  ];

  static const _defaultLabels = {
    'blue': 'الأزرق',
    'gray': 'الرمادي',
    'none': 'غير موثق',
  };

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.values.every((v) => v == 0)) {
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

    final total = data.values.fold(0, (a, b) => a + b);
    final entries = data.entries.where((e) => e.value > 0).toList();
    final colors = colorMap ?? {};

    final sections = List.generate(entries.length, (index) {
      final entry = entries[index];
      final percentage = total > 0 ? entry.value / total : 0;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${(percentage * 100).toStringAsFixed(1)}%',
        titleStyle: TextStyle(
          color: AppColors.textOnAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        color: colors[entry.key] ?? _defaultColors[index % _defaultColors.length],
        radius: 60,
        titlePositionPercentageOffset: 0.55,
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
          height: 220,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(enabled: true),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final e = entry.value;
                    final color = colors[e.key] ?? _defaultColors[index % _defaultColors.length];
                    final label = _defaultLabels[e.key] ?? e.key;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${e.value} (${(e.value / total * 100).toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}