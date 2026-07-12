import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/core/widgets/loading_skeleton.dart';
import 'package:adentweets_app/core/widgets/empty_state_widget.dart';
import 'package:adentweets_app/core/widgets/verification_badge.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/services/follow_service.dart';
import 'package:adentweets_app/services/database_service.dart';
import 'package:adentweets_app/widgets/search_bar_widget.dart';

class UserListScreen extends ConsumerStatefulWidget {
  final String userId;
  final String listType;

  const UserListScreen({super.key, required this.userId, required this.listType});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _filteredUsers = _users);
    } else {
      setState(() {
        _filteredUsers = _users.where((u) {
          return u.fullName.toLowerCase().contains(query) ||
              u.username.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final followService = ref.read(followServiceProvider);
      List<UserModel> users;
      if (widget.listType == 'followers') {
        users = await followService.getFollowers(widget.userId);
      } else {
        users = await followService.getFollowing(widget.userId);
      }
      if (mounted) {
        setState(() {
          _users = users;
          _filteredUsers = users;
        });
      }
    } catch (e) {
      // silent
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFollowers = widget.listType == 'followers';

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
          isFollowers ? 'المتابعون' : 'متابَعين',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'ابحث في القائمة',
              onChanged: (_) {},
            ),
          ),
          Expanded(
            child: _isLoading
                ? LoadingSkeleton.conversationList(count: 5)
                : _filteredUsers.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.people_outline_rounded,
                        title: isFollowers ? 'لا يوجد متابعون' : 'لا يوجد متابَعين',
                        subtitle: 'ستظهر الأشخاص هنا عندما يتابعونك أو تتابعهم',
                      )
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return _buildUserItem(user, index);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserModel user, int index) {
    final currentUserId = ref.read(authProvider).user?.uid ?? '';
    final isOwnProfile = user.uid == currentUserId;

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
              backgroundImage: user.avatarBase64 != null
                  ? MemoryImage(base64Decode(user.avatarBase64!))
                  : null,
              child: user.avatarBase64 == null
                  ? Icon(Icons.person, size: 16, color: AppColors.iconTertiary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.verificationBadge != VerificationBadge.none) ...[
                        const SizedBox(width: 4),
                        VerificationBadgeWidget(badge: user.verificationBadge, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
            if (!isOwnProfile)
              _FollowButton(userId: currentUserId, otherUserId: user.uid),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
  }
}

class _FollowButton extends ConsumerStatefulWidget {
  final String userId;
  final String otherUserId;

  const _FollowButton({required this.userId, required this.otherUserId});

  @override
  ConsumerState<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<_FollowButton> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final followService = ref.read(followServiceProvider);
    final isFollowing = await followService.isFollowing(widget.userId, widget.otherUserId);
    if (mounted) setState(() => _isFollowing = isFollowing);
  }

  Future<void> _toggleFollow() async {
    setState(() => _isLoading = true);
    try {
      final followService = ref.read(followServiceProvider);
      if (_isFollowing) {
        await followService.unfollowUser(widget.userId, widget.otherUserId);
      } else {
        await followService.followUser(widget.userId, widget.otherUserId);
      }
      if (mounted) setState(() => _isFollowing = !_isFollowing);
    } catch (e) {
      // silent
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: _isLoading
          ? const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            )
          : _isFollowing
              ? OutlinedButton(
                  onPressed: _toggleFollow,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'إلغاء',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                )
              : ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    'متابعة',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
    );
  }
}