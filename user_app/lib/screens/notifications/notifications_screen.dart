import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/utils/date_formatter.dart';
import 'package:adentweets_app/core/widgets/loading_skeleton.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String? _selectedFilter;

  final List<Map<String, String>> _filterChips = [
    {'value': null, 'label': 'الكل'},
    {'value': 'like', 'label': 'الإعجابات'},
    {'value': 'follow', 'label': 'المتابَعين'},
    {'value': 'comment', 'label': 'الردود'},
    {'value': 'mention', 'label': 'الإشارات'},
  ];

  @override
  void initState() {
    super.initState();
    final userId = ref.read(authProvider).user?.uid ?? '';
    if (userId.isNotEmpty) {
      ref.read(notificationProvider.notifier).loadNotifications(userId);
    }
  }

  String _getActionText(String type) {
    switch (type) {
      case 'like':
        return 'أعجب بمنشورك';
      case 'repost':
        return 'أعاد نشر منشورك';
      case 'comment':
        return 'علّق على منشورك';
      case 'follow':
        return 'بدأ بمتابعتك';
      case 'mention':
        return 'أشار إليك';
      case 'verification':
        return 'حسابك تم التحقق منه';
      default:
        return '';
    }
  }

  IconData _getActionIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite_rounded;
      case 'repost':
        return Icons.repeat_rounded;
      case 'comment':
        return Icons.chat_bubble_rounded;
      case 'follow':
        return Icons.person_add_rounded;
      case 'mention':
        return Icons.alternate_email_rounded;
      case 'verification':
        return Icons.verified;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getActionColor(String type) {
    switch (type) {
      case 'like':
        return AppColors.likeActive;
      case 'repost':
        return AppColors.repostActive;
      case 'comment':
        return AppColors.primaryVariant;
      case 'follow':
        return AppColors.primary;
      case 'mention':
        return AppColors.info;
      case 'verification':
        return AppColors.badgeBlue;
      default:
        return AppColors.iconTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final filteredNotifs = _selectedFilter != null
        ? notifState.notifications.where((n) => n.type == _selectedFilter).toList()
        : notifState.notifications;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        title: Text(
          'الإشعارات',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: true,
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () {
                final userId = ref.read(authProvider).user?.uid ?? '';
                ref.read(notificationProvider.notifier).markAllAsRead(userId);
              },
              child: Text(
                'تحديد الكل كمقروء',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _filterChips.length,
              itemBuilder: (context, index) {
                final chip = _filterChips[index];
                final isSelected = _selectedFilter == chip['value'];
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
                  child: FilterChip(
                    label: Text(chip['label']!),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = chip['value'];
                      });
                      ref.read(notificationProvider.notifier).setFilter(chip['value']);
                    },
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    backgroundColor: Colors.transparent,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          Expanded(
            child: notifState.isLoading
                ? LoadingSkeleton.notificationList(count: 6)
                : filteredNotifs.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.notifications_off_outlined,
                        title: 'لا توجد إشعارات',
                        subtitle: _selectedFilter != null
                            ? 'لا توجد إشعارات من هذا النوع'
                            : 'ستظهر الإشعارات هنا',
                      )
                    : ListView.builder(
                        itemCount: filteredNotifs.length,
                        itemBuilder: (context, index) {
                          final notif = filteredNotifs[index];
                          return _buildNotificationItem(notif, index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(dynamic notif, int index) {
    return GestureDetector(
      onTap: () {
        if (notif.postId != null && notif.postId.isNotEmpty) {
          context.push('/post/${notif.postId}');
        }
        final userId = ref.read(authProvider).user?.uid ?? '';
        if (!notif.isRead) {
          ref.read(notificationProvider.notifier).markAsRead(
                userId: userId,
                notificationId: notif.notificationId,
              );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.05),
          border: const Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: notif.actorAvatar != null
                      ? MemoryImage(base64Decode(notif.actorAvatar))
                      : null,
                  child: notif.actorAvatar == null
                      ? Icon(Icons.person, size: 16, color: AppColors.iconTertiary)
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.scaffoldBackground,
                    ),
                    child: Icon(
                      _getActionIcon(notif.type),
                      size: 11,
                      color: _getActionColor(notif.type),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: notif.actorUsername,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        TextSpan(
                          text: ' ${_getActionText(notif.type)}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.notificationTime(notif.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
  }
}