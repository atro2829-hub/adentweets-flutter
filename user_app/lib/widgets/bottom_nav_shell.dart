import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/providers/notification_provider.dart';
import 'package:adentweets_app/providers/chat_provider.dart';
import 'package:adentweets_app/providers/auth_provider.dart';

class BottomNavShell extends ConsumerStatefulWidget {
  final Widget child;

  const BottomNavShell({super.key, required this.child});

  @override
  ConsumerState<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends ConsumerState<BottomNavShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final chatState = ref.watch(chatProvider);
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.uid ?? '';

    if (currentUserId.isNotEmpty) {
      ref.read(notificationProvider.notifier).loadNotifications(currentUserId);
      ref.read(chatProvider.notifier).loadConversations(currentUserId);
    }

    return Scaffold(
      body: widget.child,
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: BottomAppBar(
          color: AppColors.scaffoldBackground,
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                index: 0,
                onTap: () {
                  setState(() => _currentIndex = 0);
                  context.go('/');
                },
              ),
              _navItem(
                icon: Icons.search_rounded,
                label: 'استكشاف',
                index: 1,
                badgeCount: 0,
                onTap: () {
                  setState(() => _currentIndex = 1);
                  context.go('/explore');
                },
              ),
              const SizedBox(width: 48),
              _navItem(
                icon: Icons.notifications_outlined,
                label: 'الإشعارات',
                index: 2,
                badgeCount: notifState.unreadCount,
                onTap: () {
                  setState(() => _currentIndex = 2);
                  context.go('/notifications');
                },
              ),
              _navItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'الرسائل',
                index: 3,
                badgeCount: chatState.unreadTotal,
                onTap: () {
                  setState(() => _currentIndex = 3);
                  context.go('/messages');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badgeCount > 0)
                badges.Badge(
                  badgeContent: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: AppColors.error,
                    padding: EdgeInsets.all(4),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.iconSecondary,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.iconSecondary,
                ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}