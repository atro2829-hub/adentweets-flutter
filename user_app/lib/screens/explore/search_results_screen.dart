import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/core/widgets/loading_skeleton.dart';
import 'package:adentweets_app/core/widgets/verification_badge.dart';
import 'package:adentweets_app/providers/search_provider.dart';
import 'package:adentweets_app/widgets/post_card.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchProvider.notifier).search(widget.query);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

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
          'نتائج البحث',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textTertiary,
          dividerColor: AppColors.divider,
          tabs: const [
            Tab(text: 'المنشورات'),
            Tab(text: 'المستخدمون'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(searchState),
          _buildUsersTab(searchState),
        ],
      ),
    );
  }

  Widget _buildPostsTab(SearchState searchState) {
    if (searchState.isLoading) {
      return LoadingSkeleton.postCardList(count: 4);
    }

    if (searchState.postResults.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'لا توجد نتائج',
        subtitle: 'لم يتم العثور على منشورات تطابق "${widget.query}"',
      );
    }

    return ListView.builder(
      itemCount: searchState.postResults.length,
      itemBuilder: (context, index) {
        return PostCard(post: searchState.postResults[index])
            .animate()
            .fadeIn(delay: (index * 30).ms, duration: 300.ms);
      },
    );
  }

  Widget _buildUsersTab(SearchState searchState) {
    if (searchState.isLoading) {
      return LoadingSkeleton.conversationList(count: 4);
    }

    if (searchState.userResults.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.person_search_rounded,
        title: 'لا يوجد مستخدمون',
        subtitle: 'لم يتم العثور على مستخدمين تطابق "${widget.query}"',
      );
    }

    return ListView.builder(
      itemCount: searchState.userResults.length,
      itemBuilder: (context, index) {
        final user = searchState.userResults[index];
        return _buildUserItem(user, index);
      },
    );
  }

  Widget _buildUserItem(dynamic user, int index) {
    final name = user.fullName as String? ?? '';
    final username = user.username as String? ?? '';
    final avatar = user.avatarBase64 as String?;
    final badge = user.verificationBadge;

    return GestureDetector(
      onTap: () => context.push('/profile/${user.uid}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceVariant,
              child: Icon(Icons.person, size: 18, color: AppColors.iconTertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@$username',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 32,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: Size.zero,
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
      ),
    ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
  }
}