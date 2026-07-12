import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/utils/date_formatter.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/models/post_model.dart';
import 'package:adentweets_admin/providers/admin_posts_provider.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminPostsProvider);
    final filteredPosts = state.filteredPosts;
    final padding = ResponsiveUtils.horizontalPadding(context);

    ref.listen(adminPostsProvider, (prev, next) {
      if (next.actionMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.actionMessage!)),
        );
        ref.read(adminPostsProvider.notifier).clearActionMessage();
      }
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('إدارة المنشورات'),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: () => ref.read(adminPostsProvider.notifier).loadPosts(),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => ref.read(adminPostsProvider.notifier).setSearchQuery(q),
                decoration: InputDecoration(
                  hintText: 'بحث في المنشورات...',
                  prefixIcon: Icon(Iconsax.search_normal, color: AppColors.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Iconsax.close_circle, size: 18, color: AppColors.textTertiary),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(adminPostsProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: PostFilter.values.map((filter) {
                    final isActive = state.filter == filter;
                    final label = switch (filter) {
                      PostFilter.all => 'الكل',
                      PostFilter.withImages => 'بها صور',
                      PostFilter.reported => 'مبلغ عنها',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isActive,
                        onSelected: (_) => ref.read(adminPostsProvider.notifier).setFilter(filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: state.isLoading
                  ? _buildShimmer()
                  : filteredPosts.isEmpty
                      ? _buildEmpty()
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
                          itemCount: filteredPosts.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.borderLight),
                          itemBuilder: (context, index) {
                            final post = filteredPosts[index];
                            return _PostCard(
                              post: post,
                              onDelete: () => ref.read(adminPostsProvider.notifier).deletePost(post.id),
                            ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
                          },
                        ),
            ),
          ],
        ),
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
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.backgroundElevated,
            borderRadius: BorderRadius.circular(12),
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
          Icon(Iconsax.document_text, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('لا توجد منشورات', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onDelete;

  const _PostCard({required this.post, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(post.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: AppColors.error.withValues(alpha: 0.1),
        child: Icon(Iconsax.trash, color: AppColors.error, size: 22),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف المنشور'),
            content: const Text('هل تريد حذف هذا المنشور؟'),
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
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.backgroundElevated,
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0] : '?',
                    style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('@${post.authorUsername}', style: TextStyle(color: AppColors.textSecondary, fontSize: 11), textDirection: TextDirection.ltr),
                    ],
                  ),
                ),
                Text(DateFormatter.formatRelative(post.createdAt), style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),
            Text(post.content, style: TextStyle(color: AppColors.textPrimary, fontSize: 13), maxLines: 4, overflow: TextOverflow.ellipsis),
            if (post.hasImages) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: post.imageBase64List.take(3).map((b64) {
                    try {
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(base64Decode(b64), width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      );
                    } catch (_) {
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Iconsax.heart, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(DateFormatter.formatNumber(post.likesCount), style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Iconsax.message, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(DateFormatter.formatNumber(post.commentsCount), style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}