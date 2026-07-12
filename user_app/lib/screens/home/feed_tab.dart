import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/core/widgets/error_state_widget.dart';
import 'package:adentweets_app/core/widgets/loading_skeleton.dart';
import 'package:adentweets_app/providers/feed_provider.dart';
import 'package:adentweets_app/widgets/post_card.dart';

class FeedTab extends ConsumerStatefulWidget {
  final FeedTab feedType;

  const FeedTab({super.key, required this.feedType});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    if (feedState.isLoading && feedState.posts.isEmpty) {
      return LoadingSkeleton.postCardList(count: 6);
    }

    if (feedState.error != null && feedState.posts.isEmpty) {
      return ErrorStateWidget(
        message: feedState.error!,
        onRetry: () => ref.read(feedProvider.notifier).refresh(),
      );
    }

    if (feedState.posts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.article_outlined,
        title: 'لا توجد منشورات',
        subtitle: widget.feedType == FeedTab.forYou
            ? 'ابدأ بمتابعة أشخاص لرؤية منشوراتهم هنا'
            : 'لم تنشر أي منشورات بعد. اتبع أشخاصًا لتجد محتوى جديدًا.',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceElevated,
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: feedState.posts.length + (feedState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= feedState.posts.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }

          final post = feedState.posts[index];
          return PostCard(
            post: post,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }
}