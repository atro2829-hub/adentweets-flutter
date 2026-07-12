import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/providers/settings_provider.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

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
          'الخصوصية',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildToggleTile(
            context,
            icon: Icons.lock_rounded,
            title: 'حساب خاص',
            subtitle: 'فقط المتابعون يمكنهم رؤية منشوراتك',
            value: settingsState.isPrivateAccount,
            onChanged: (_) => ref.read(settingsProvider.notifier).togglePrivateAccount(),
          ),
          _buildToggleTile(
            context,
            icon: Icons.visibility_off_outlined,
            title: 'إخفاء النشاط',
            subtitle: 'إخفاء نشاطك عن الآخرين',
            value: !settingsState.showOnlineStatus,
            onChanged: (_) => ref.read(settingsProvider.notifier).toggleOnlineStatus(),
          ),
          _buildToggleTile(
            context,
            icon: Icons.alternate_email_rounded,
            title: 'السماح بالإشارات',
            subtitle: 'السماح لأي شخص بالإشارة إليك',
            value: true,
            onChanged: (_) {},
          ),
          _buildToggleTile(
            context,
            icon: Icons.message_outlined,
            title: 'السماح بالرسائل من أي شخص',
            subtitle: 'يمكن لأي شخص إرسال رسائل إليك',
            value: settingsState.allowMessagesFromAnyone,
            onChanged: (_) => ref.read(settingsProvider.notifier).toggleMessagePermissions(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required IconData icon,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        secondary: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: Icon(icon, size: 22, color: AppColors.iconSecondary),
        ),
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