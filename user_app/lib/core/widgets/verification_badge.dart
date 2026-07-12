import 'package:flutter/material.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/models/user_model.dart';

class VerificationBadgeWidget extends StatelessWidget {
  final VerificationBadge badge;
  final double size;
  final bool showBackground;

  const VerificationBadgeWidget({
    super.key,
    required this.badge,
    this.size = 18,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    if (badge == VerificationBadge.none) return const SizedBox.shrink();

    final Color color;
    final Color bgColor;

    switch (badge) {
      case VerificationBadge.blue:
        color = AppColors.badgeBlue;
        bgColor = AppColors.badgeBlue.withValues(alpha: 0.15);
        break;
      case VerificationBadge.gray:
        color = AppColors.badgeGray;
        bgColor = AppColors.badgeGray.withValues(alpha: 0.15);
        break;
      case VerificationBadge.none:
        return const SizedBox.shrink();
    }

    final icon = Icon(
      Icons.verified,
      color: color,
      size: size,
    );

    if (!showBackground) return icon;

    return Container(
      width: size + 4,
      height: size + 4,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(child: icon),
    );
  }
}

class StandaloneBadge extends StatelessWidget {
  final VerificationBadge badge;
  final double size;

  const StandaloneBadge({
    super.key,
    required this.badge,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (badge == VerificationBadge.none) return const SizedBox.shrink();

    final Color color;
    switch (badge) {
      case VerificationBadge.blue:
        color = AppColors.badgeBlue;
        break;
      case VerificationBadge.gray:
        color = AppColors.badgeGray;
        break;
      case VerificationBadge.none:
        return const SizedBox.shrink();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.verified,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}