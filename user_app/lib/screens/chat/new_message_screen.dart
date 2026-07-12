import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/services/chat_service.dart';
import 'package:adentweets_app/services/search_service.dart';
import 'package:adentweets_app/widgets/search_bar_widget.dart';

class NewMessageScreen extends ConsumerStatefulWidget {
  const NewMessageScreen({super.key});

  @override
  ConsumerState<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends ConsumerState<NewMessageScreen> {
  final _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final searchService = ref.read(searchServiceProvider);
      final currentUserId = ref.read(authProvider).user?.uid ?? '';
      final users = await searchService.searchUsers(query);
      final filtered = users.where((u) => u.uid != currentUserId).toList();
      if (mounted) setState(() => _searchResults = filtered);
    } catch (e) {
      // silent
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _startConversation(UserModel otherUser) async {
    final authState = ref.read(authProvider);
    final currentUserId = authState.user?.uid ?? '';
    final currentUser = authState.userData;
    if (currentUserId.isEmpty || currentUser == null) return;

    try {
      final chatService = ref.read(chatServiceProvider);
      final conv = await chatService.getOrCreateConversation(
        currentUserId: currentUserId,
        otherUserId: otherUser.uid,
        currentUsername: currentUser.username,
        otherUsername: otherUser.username,
        currentAvatar: currentUser.avatarBase64,
        otherAvatar: otherUser.avatarBase64,
      );

      if (mounted) {
        context.push('/chat/${conv.conversationId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في بدء المحادثة'), backgroundColor: AppColors.error),
        );
      }
    }
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
          'رسالة جديدة',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'ابحث عن مستخدم',
              autoFocus: true,
              onChanged: (_) {},
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _searchResults.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.person_search_rounded,
                        title: 'ابحث عن شخص',
                        subtitle: 'ابحث بالاسم أو اسم المستخدم لبدء محادثة',
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return _buildUserItem(user, index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserModel user, int index) {
    return GestureDetector(
      onTap: () => _startConversation(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: user.avatarBase64 != null
                  ? MemoryImage(base64Decode(user.avatarBase64!))
                  : null,
              child: user.avatarBase64 == null
                  ? Icon(Icons.person, size: 18, color: AppColors.iconTertiary)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.bio,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.message_outlined, size: 20, color: AppColors.iconTertiary),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
  }
}