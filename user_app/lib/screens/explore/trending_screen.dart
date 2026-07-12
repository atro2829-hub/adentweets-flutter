import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/core/widgets/loading_skeleton.dart';
import 'package:adentweets_app/models/trending_model.dart';
import 'package:adentweets_app/providers/search_provider.dart';

class TrendingScreen extends ConsumerStatefulWidget {
  const TrendingScreen({super.key});

  @override
  ConsumerState<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends ConsumerState<TrendingScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(searchProvider.notifier).loadTrending();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final trending = searchState.trending;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.iconPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'الأكثر رواجًا',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: trending.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.trending_down_rounded,
              title: 'لا توجد مواضيع رائجة',
              subtitle: 'ستظهر المواضيع الأكثر رواجًا هنا',
            )
          : ListView.separated(
              itemCount: trending.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.divider, height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                return _buildTrendingItem(trending[index], index);
              },
            ),
    );
  }

  Widget _buildTrendingItem(TrendingModel trend, int index) {
    return GestureDetector(
      onTap: () => context.push('/search?q=${Uri.encodeComponent('#${trend.hashtag}')}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trend.displayHashtag,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trend.count} منشور',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${trend.count}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideX(begin: 0.03, end: 0);
  }
}