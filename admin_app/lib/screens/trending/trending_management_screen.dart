import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/date_formatter.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/models/trending_model.dart';
import 'package:adentweets_admin/services/admin_trending_service.dart';

class TrendingManagementScreen extends StatefulWidget {
  const TrendingManagementScreen({super.key});

  @override
  State<TrendingManagementScreen> createState() => _TrendingManagementScreenState();
}

class _TrendingManagementScreenState extends State<TrendingManagementScreen> {
  List<TrendingModel> _trending = [];
  bool _isLoading = true;
  final _addController = TextEditingController();
  String _sortBy = 'count';

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    setState(() => _isLoading = true);
    try {
      final trending = await AdminTrendingService.fetchTrending();
      if (mounted) {
        setState(() {
          _trending = trending;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TrendingModel> get _sorted {
    var items = List<TrendingModel>.from(_trending);
    switch (_sortBy) {
      case 'count': items.sort((a, b) => b.postCount.compareTo(a.postCount)); break;
      case 'name': items.sort((a, b) => a.hashtag.compareTo(b.hashtag)); break;
      case 'pinned': items.sort((a, b) => (b.isPinned ? 1 : 0).compareTo(a.isPinned ? 1 : 0)); break;
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.horizontalPadding(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('إدارة الترندات'),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: _loadTrending,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog,
          backgroundColor: AppColors.accentPrimary,
          child: const Icon(Iconsax.add, color: AppColors.textOnAccent),
        ),
        body: Column(
          children: [
            // Sort
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
              child: Row(
                children: [
                  Text('ترتيب:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('العدد', style: TextStyle(fontSize: 12)),
                    selected: _sortBy == 'count',
                    onSelected: (_) => setState(() => _sortBy = 'count'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: Text('الاسم', style: TextStyle(fontSize: 12)),
                    selected: _sortBy == 'name',
                    onSelected: (_) => setState(() => _sortBy = 'name'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: Text('مثبت', style: TextStyle(fontSize: 12)),
                    selected: _sortBy == 'pinned',
                    onSelected: (_) => setState(() => _sortBy = 'pinned'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _isLoading
                  ? _buildShimmer()
                  : _sorted.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
                          itemCount: _sorted.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final item = _sorted[index];
                            return _TrendingItem(
                              item: item,
                              onPin: () async {
                                await AdminTrendingService.pinTrending(item.hashtag);
                                _loadTrending();
                              },
                              onUnpin: () async {
                                await AdminTrendingService.unpinTrending(item.hashtag);
                                _loadTrending();
                              },
                              onReset: () async {
                                await AdminTrendingService.resetCount(item.hashtag);
                                _loadTrending();
                              },
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('حذف الترند'),
                                    content: Text('هل تريد حذف ${item.displayHashtag}؟'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx, true),
                                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await AdminTrendingService.deleteTrending(item.hashtag);
                                  _loadTrending();
                                }
                              },
                            ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة ترند'),
        content: TextField(
          controller: _addController,
          decoration: InputDecoration(
            hintText: '#هاشتاج',
            prefixIcon: Icon(Iconsax.hashtag, color: AppColors.textSecondary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () async {
              if (_addController.text.trim().isNotEmpty) {
                await AdminTrendingService.addTrending(_addController.text.trim());
                _addController.clear();
                if (mounted) Navigator.pop(ctx);
                _loadTrending();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundElevated,
      highlightColor: AppColors.backgroundCard,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.hashtag, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('لا توجد ترندات', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _TrendingItem extends StatelessWidget {
  final TrendingModel item;
  final VoidCallback onPin;
  final VoidCallback onUnpin;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  const _TrendingItem({
    required this.item,
    required this.onPin,
    required this.onUnpin,
    required this.onReset,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (item.isPinned)
            Icon(Icons.push_pin, size: 16, color: AppColors.accentPrimary)
          else
            Icon(Iconsax.hashtag, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayHashtag,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.postCount} منشور' +
                  (item.lastUpdated != null ? ' · ${DateFormatter.formatRelative(item.lastUpdated!)}' : ''),
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              switch (action) {
                case 'pin': onPin();
                case 'unpin': onUnpin();
                case 'reset': onReset();
                case 'delete': onDelete();
              }
            },
            itemBuilder: (context) => [
              if (item.isPinned)
                PopupMenuItem(value: 'unpin', child: Text('إلغاء التثبيت'))
              else
                PopupMenuItem(value: 'pin', child: Text('تثبيت')),
              PopupMenuItem(value: 'reset', child: Text('إعادة تعيين العدد')),
              PopupMenuItem(value: 'delete', child: Text('حذف', style: TextStyle(color: AppColors.error))),
            ],
          ),
        ],
      ),
    );
  }
}