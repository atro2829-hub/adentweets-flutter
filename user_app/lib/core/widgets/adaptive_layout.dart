import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/utils/responsive_utils.dart';

class AdaptiveLayout extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<Widget> screens;
  final Widget? floatingActionButton;

  const AdaptiveLayout({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.screens,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context) ||
        ResponsiveUtils.isTablet(context)) {
      return _buildTabletLayout(context);
    }
    return _buildMobileLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSideNav(context),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex.clamp(0, 4),
        onTap: (index) {
          if (index == 2) return;
          onTap(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.scaffoldBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.iconSecondary,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 26,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.search_normal),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const SizedBox(width: 0, height: 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.notification),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildSideNav(BuildContext context) {
    final navItems = [
      _NavItem(Iconsax.home, 'الرئيسية', 0),
      _NavItem(Iconsax.search_normal, 'استكشاف', 1),
      _NavItem(Iconsax.notification, 'الإشعارات', 3),
      _NavItem(Iconsax.message, 'الرسائل', 4),
      _NavItem(Iconsax.user, 'الملف الشخصي', 5),
    ];

    return Container(
      width: 72,
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'AT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const Divider(color: AppColors.divider),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: navItems.map((item) {
                final isSelected = currentIndex == item.index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Tooltip(
                    message: item.label,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onTap(item.index),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.iconSecondary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  const _NavItem(this.icon, this.label, this.index);
}