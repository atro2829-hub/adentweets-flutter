import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isConnectivityError;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.isConnectivityError = false,
    this.icon,
  }) : assert(
          !(isConnectivityError && icon != null),
          'Use isConnectivityError for connectivity errors, or icon for custom icon',
        );

  @override
  Widget build(BuildContext context) {
    final displayIcon = isConnectivityError
        ? Icons.wifi_off_rounded
        : (icon ?? Icons.error_outline_rounded);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isConnectivityError
                    ? AppColors.warningContainer
                    : AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                displayIcon,
                size: 32,
                color: isConnectivityError
                    ? AppColors.warning
                    : AppColors.error,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .shake(hz: 3, delay: 300.ms),
            const SizedBox(height: 20),
            Text(
              isConnectivityError ? 'لا يوجد اتصال بالإنترنت' : 'حدث خطأ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 250.ms, duration: 300.ms),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة المحاولة'),
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}