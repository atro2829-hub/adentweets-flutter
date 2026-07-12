import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/utils/date_formatter.dart';
import 'package:adentweets_app/core/widgets/verification_badge.dart';
import 'package:adentweets_app/models/trending_model.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/providers/search_provider.dart';
import 'package:adentweets_app/widgets/search_bar_widget.dart';
import 'package:adentweets_app/widgets/bottom_nav_shell.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(searchProvider.notifier).loadTrending();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final trending = searchState.trending;

    return BottomNavShell(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SearchBarWidget(
                    controller: _searchController,
                    onSubmitted: (query) {
                      if (query.trim().isNotEmpty) {
                        context.push('/search?q=${Uri.encodeComponent(query.trim())}');
                      }
                    },
                  ),
                ),
                if (trending.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الأكثر رواجًا',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/trending'),
                          child: Text(
                            'عرض الكل',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...trending.take(5).toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final trend = entry.value;
                    return _buildTrendingItem(trend, index);
                  }),
                ],
                const Divider(color: AppColors.divider, height: 32, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'مقترح لك',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return _buildSuggestedUserCard(index)
                          .animate()
                          .fadeIn(delay: (index * 60).ms, duration: 300.ms)
                          .slideX(begin: 0.05, end: 0);
                    },
                  ),
                ),
                const Divider(color: AppColors.divider, height: 32, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'عمليات البحث الأخيرة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _buildRecentSearches(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingItem(TrendingModel trend, int index) {
    return GestureDetector(
      onTap: () => context.push('/search?q=${Uri.encodeComponent('#${trend.hashtag}')}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trend.displayHashtag,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${trend.count} منشور',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.trending_up_rounded, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideX(begin: 0.03, end: 0);
  }

  Widget _buildSuggestedUserCard(int index) {
    return Container(
      width: 140,
      margin: const EdgeInsetsDirectional.only(start: 0, end: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.surfaceVariant,
            child: Icon(Icons.person, size: 24, color: AppColors.iconTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            'مستخدم $index',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '@user_$index',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'متابعة',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    final recentSearches = ['عدن', '#يمن', 'تقنية', '#برمجة'];
    return Column(
      children: recentSearches.asMap().entries.map((entry) {
        final index = entry.key;
        final query = entry.value;
        return GestureDetector(
          onTap: () => context.push('/search?q=${Uri.encodeComponent(query)}'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, size: 18, color: AppColors.iconTertiary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    query,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                Icon(Icons.north_west_rounded, size: 16, color: AppColors.iconTertiary),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 40).ms, duration: 200.ms);
      }).toList(),
    );
  }
}