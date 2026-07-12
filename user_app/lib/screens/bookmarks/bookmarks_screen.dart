import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/core/widgets/loading_skeleton.dart';
import 'package:adentweets_app/models/post_model.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/services/post_service.dart';
import 'package:adentweets_app/widgets/post_card.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(authProvider).user?.uid ?? '';
      if (userId.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final postService = ref.read(postServiceProvider);
      final posts = await postService.getBookmarkedPosts(userId);
      if (mounted) setState(() => _posts = posts);
    } catch (e) {
      // silent
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await _loadBookmarks();
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
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
          'المرجعية',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? LoadingSkeleton.postCardList(count: 4)
          : _posts.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.bookmark_outline_rounded,
                  title: 'لا توجد منشورات مرجعية',
                  subtitle: 'عندما تحفظ منشورًا، سيظهر هنا',
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceElevated,
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(post: _posts[index]);
                    },
                  ),
                ),
    );
  }
}