import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/providers/admin_auth_provider.dart';
import 'package:adentweets_admin/providers/admin_reports_provider.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';

class AdminNavShell extends ConsumerStatefulWidget {
  final Widget child;

  const AdminNavShell({super.key, required this.child});

  @override
  ConsumerState<AdminNavShell> createState() => _AdminNavShellState();
}

class _AdminNavShellState extends ConsumerState<AdminNavShell> {
  int _selectedIndex = 0;

  static const _mainNavItems = [
    _NavItem('/dashboard', Iconsax.home_2, 'لوحة التحكم'),
    _NavItem('/users', Iconsax.user, 'المستخدمون'),
    _NavItem('/reports', Iconsax.shield_cross, 'البلاغات', showBadge: true),
    _NavItem('/analytics', Iconsax.chart_2, 'التحليلات'),
  ];

  static const _moreNavItems = [
    _NavItem('/posts', Iconsax.document_text, 'المنشورات'),
    _NavItem('/comments', Iconsax.message_text, 'التعليقات'),
    _NavItem('/verification', Iconsax.verify, 'التوثيق'),
    _NavItem('/trending', Iconsax.hashtag, 'الترندات'),
    _NavItem('/settings', Iconsax.setting_2, 'الإعدادات'),
    _NavItem('/activity-log', Iconsax.clock, 'سجل النشاط'),
  ];

  void _navigateTo(int index) {
    final allItems = [..._mainNavItems, ..._moreNavItems];
    if (index < _mainNavItems.length) {
      context.go(_mainNavItems[index].route);
      setState(() => _selectedIndex = index);
    }
  }

  void _onRouteChanged(String location) {
    final allRoutes = [..._mainNavItems, ..._moreNavItems];
    for (int i = 0; i < allRoutes.length; i++) {
      if (location == allRoutes[i].route) {
        setState(() => _selectedIndex = i < 4 ? i : 0);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(adminReportsProvider);
    final pendingCount = reportsState.pendingCount;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Row(
          children: [
            if (ResponsiveUtils.shouldShowDrawer(context))
              _buildSideDrawer(context, pendingCount),
            Expanded(
              child: widget.child,
            ),
          ],
        ),
        bottomNavigationBar: ResponsiveUtils.shouldShowBottomNav(context)
            ? _buildBottomNav(pendingCount)
            : null,
      ),
    );
  }

  Widget _buildSideDrawer(BuildContext context, int pendingCount) {
    final authState = ref.watch(adminAuthProvider);
    return Container(
      width: 260,
      color: AppColors.backgroundSecondary,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'AT',
                        style: TextStyle(
                          color: AppColors.textOnAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authState.displayName ?? 'مدير النظام',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'مدير النظام',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ..._mainNavItems.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final isActive = _isRouteActive(context, item.route);
                    return _buildDrawerItem(
                      icon: item.icon,
                      label: item.label,
                      isActive: isActive,
                      badge: item.showBadge && pendingCount > 0 ? pendingCount : null,
                      onTap: () {
                        context.go(item.route);
                        setState(() => _selectedIndex = idx);
                      },
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      'المزيد',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ..._moreNavItems.map((item) {
                    final isActive = _isRouteActive(context, item.route);
                    return _buildDrawerItem(
                      icon: item.icon,
                      label: item.label,
                      isActive: isActive,
                      onTap: () => context.go(item.route),
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildDrawerItem(
              icon: Iconsax.logout,
              label: 'تسجيل الخروج',
              iconColor: AppColors.error,
              labelColor: AppColors.error,
              onTap: () {
                ref.read(adminAuthProvider.notifier).logout();
                context.go('/admin-login');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    int? badge,
    Color? iconColor,
    Color? labelColor,
    required VoidCallback onTap,
  }) {
    final effectiveIconColor = iconColor ?? (isActive ? AppColors.accentPrimary : AppColors.textSecondary);
    final effectiveLabelColor = labelColor ?? (isActive ? AppColors.accentPrimary : AppColors.textPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.accentContainer.withValues(alpha: 0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: effectiveIconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: effectiveLabelColor,
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : badge.toString(),
                      style: TextStyle(
                        color: AppColors.textOnAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(int pendingCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _mainNavItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isActive = _selectedIndex == idx;
              return _buildBottomNavItem(
                icon: item.icon,
                label: item.label,
                isActive: isActive,
                badge: item.showBadge && pendingCount > 0 ? pendingCount : null,
                onTap: () => _navigateTo(idx),
              );
            }).toList()
              ..add(
                _buildBottomNavItem(
                  icon: Iconsax.more,
                  label: 'المزيد',
                  isActive: false,
                  onTap: () => _showMoreMenu(context),
                ),
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    int? badge,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isActive ? AppColors.accentPrimary : AppColors.textTertiary,
                ),
                if (badge != null)
                  Positioned(
                    left: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badge > 99 ? '99' : badge.toString(),
                        style: TextStyle(
                          color: AppColors.textOnAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.accentPrimary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ..._moreNavItems.map((item) => ListTile(
              leading: Icon(item.icon, color: AppColors.textSecondary),
              title: Text(item.label),
              titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              onTap: () {
                Navigator.pop(context);
                context.go(item.route);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  bool _isRouteActive(BuildContext context, String route) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    return currentRoute == route;
  }
}

class _NavItem {
  final String route;
  final IconData icon;
  final String label;
  final bool showBadge;

  const _NavItem(this.route, this.icon, this.label, {this.showBadge = false});
}