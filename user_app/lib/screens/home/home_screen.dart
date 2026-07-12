import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/providers/feed_provider.dart';
import 'package:adentweets_app/widgets/bottom_nav_shell.dart';
import 'package:adentweets_app/widgets/story_bar.dart';
import 'package:adentweets_app/screens/home/feed_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initFeed();
  }

  void _initFeed() {
    final userId = ref.read(authProvider).user?.uid;
    if (userId != null) {
      ref.read(feedProvider.notifier).setUserId(userId);
      ref.read(feedProvider.notifier).refresh();
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final tab = _tabController.index == 0 ? FeedTab.forYou : FeedTab.following;
    ref.read(feedProvider.notifier).switchTab(tab);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavShell(
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Text(
                    'AT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'الرئيسية',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => context.push('/profile/${ref.read(authProvider).user?.uid ?? ''}'),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.surfaceElevated,
                  backgroundImage: ref.read(authProvider).userData?.avatarBase64 != null
                      ? MemoryImage(
                          _decodeBase64(ref.read(authProvider).userData!.avatarBase64!),
                        )
                      : null,
                  child: ref.read(authProvider).userData?.avatarBase64 == null
                      ? Icon(Icons.person, size: 18, color: AppColors.iconTertiary)
                      : null,
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 32),
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textTertiary,
            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            unselectedLabelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            dividerColor: AppColors.divider,
            tabs: const [
              Tab(text: 'لك'),
              Tab(text: 'متابَعين'),
            ],
          ),
        ),
        body: Column(
          children: [
            const StoryBar(),
            const Divider(color: AppColors.divider, height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  FeedTabWidget(feedType: FeedTab.forYou),
                  FeedTabWidget(feedType: FeedTab.following),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: SizedBox(
          width: 52,
          height: 52,
          child: FloatingActionButton(
            onPressed: () => context.push('/create-post'),
            backgroundColor: AppColors.primary,
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Uint8List _decodeBase64(String str) {
    try {
      return base64Decode(str);
    } catch (_) {
      return base64Decode(AppConstants.defaultAvatar);
    }
  }
}