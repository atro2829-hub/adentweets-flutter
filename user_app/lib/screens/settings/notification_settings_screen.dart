import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/providers/settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.iconPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'إعدادات الإشعارات',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSectionTitle(context, 'الإشعارات'),
          _buildToggleTile(
            context,
            title: 'إشعارات الإعجابات',
            subtitle: 'عندما يعجب شخص بمنشورك',
            value: settingsState.likeNotifications,
            onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotificationType('like'),
          ),
          _buildToggleTile(
            context,
            title: 'إشعارات المتابَعين',
            subtitle: 'عندما يبدأ شخص بمتابعتك',
            value: settingsState.followNotifications,
            onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotificationType('follow'),
          ),
          _buildToggleTile(
            context,
            title: 'إشعارات الردود',
            subtitle: 'عندما يعلّق شخص على منشورك',
            value: settingsState.commentNotifications,
            onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotificationType('comment'),
          ),
          _buildToggleTile(
            context,
            title: 'إشعارات الرسائل',
            subtitle: 'عندما تستلم رسالة جديدة',
            value: settingsState.repostNotifications,
            onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotificationType('repost'),
          ),
          _buildToggleTile(
            context,
            title: 'إشعارات النظام',
            subtitle: 'تحديثات وإعلانات التطبيق',
            value: settingsState.mentionNotifications,
            onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotificationType('mention'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
      ),
    );
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        activeTrackColor: AppColors.primaryContainer,
        inactiveTrackColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
        ),
      ),
    );
  }
}