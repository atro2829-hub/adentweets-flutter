import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/constants/app_constants.dart';
import 'package:adentweets_admin/models/user_model.dart';
import 'package:adentweets_admin/providers/admin_users_provider.dart';

class UserActionDialog extends ConsumerWidget {
  final UserModel user;

  const UserActionDialog({super.key, required this.user});

  static Future<void> show(BuildContext context, {required UserModel user}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => UserActionDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '@${user.username}',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!user.isSuspended)
              _ActionItem(
                icon: Iconsax.slash,
                label: 'تعليق الحساب',
                color: AppColors.warning,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(adminUsersProvider.notifier).suspendUser(user.uid);
                },
              )
            else
              _ActionItem(
                icon: Iconsax.tick_circle,
                label: 'إلغاء التعليق',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(adminUsersProvider.notifier).unsuspendUser(user.uid);
                },
              ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            _ActionItem(
              icon: Iconsax.verify,
              label: 'توثيق أزرق',
              color: AppColors.badgeBlue,
              onTap: () {
                Navigator.pop(context);
                ref.read(adminUsersProvider.notifier).verifyUser(user.uid, AppConstants.verificationBlue);
              },
            ),
            _ActionItem(
              icon: Iconsax.shield_tick,
              label: 'توثيق رمادي',
              color: AppColors.badgeGray,
              onTap: () {
                Navigator.pop(context);
                ref.read(adminUsersProvider.notifier).verifyUser(user.uid, AppConstants.verificationGray);
              },
            ),
            _ActionItem(
              icon: Iconsax.close_circle,
              label: 'إزالة التوثيق',
              color: AppColors.textSecondary,
              onTap: () {
                Navigator.pop(context);
                ref.read(adminUsersProvider.notifier).verifyUser(user.uid, AppConstants.verificationNone);
              },
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            _ActionItem(
              icon: Iconsax.trash,
              label: 'حذف الحساب',
              color: AppColors.error,
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('حذف المستخدم'),
                    content: Text('هل أنت متأكد من حذف @${user.username}؟ هذا الإجراء لا يمكن التراجع عنه.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(adminUsersProvider.notifier).deleteUser(user.uid);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}