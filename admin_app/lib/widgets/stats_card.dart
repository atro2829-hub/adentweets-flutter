import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final double? changePercent;
  final VoidCallback? onTap;
  final Color? color;
  final Color? iconColor;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.changePercent,
    this.onTap,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? color ?? AppColors.accentPrimary;
    final isPositive = (changePercent ?? 0) >= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 20, color: effectiveColor),
                  ),
                  if (changePercent != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 12,
                            color: isPositive ? AppColors.success : AppColors.error,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${changePercent!.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: isPositive ? AppColors.success : AppColors.error,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, animVal, _) {
                  return Text(
                    animVal >= 1000
                        ? '${(animVal / 1000).toStringAsFixed(1)}ك'
                        : animVal.toInt().toString(),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: ResponsiveUtils.isMobile(context) ? 22 : 26,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
    );
  }
}