import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/providers/auth_provider.dart';

// ── Auth Screens ────────────────────────────────────────────
import 'package:adentweets_app/screens/auth/splash_screen.dart';
import 'package:adentweets_app/screens/auth/onboarding_screen.dart';
import 'package:adentweets_app/screens/auth/login_screen.dart';
import 'package:adentweets_app/screens/auth/signup_screen.dart';
import 'package:adentweets_app/screens/auth/forgot_password_screen.dart';

// ── Home Screens ────────────────────────────────────────────
import 'package:adentweets_app/screens/home/home_screen.dart';

// ── Post Screens ────────────────────────────────────────────
import 'package:adentweets_app/screens/post/create_post_screen.dart';
import 'package:adentweets_app/screens/post/post_detail_screen.dart';

// ── Profile Screens ─────────────────────────────────────────
import 'package:adentweets_app/screens/profile/other_profile_screen.dart';
import 'package:adentweets_app/screens/profile/edit_profile_screen.dart';
import 'package:adentweets_app/screens/profile/user_list_screen.dart';

// ── Explore Screens ─────────────────────────────────────────
import 'package:adentweets_app/screens/explore/explore_screen.dart';
import 'package:adentweets_app/screens/explore/search_results_screen.dart';
import 'package:adentweets_app/screens/explore/trending_screen.dart';

// ── Notifications Screen ────────────────────────────────────
import 'package:adentweets_app/screens/notifications/notifications_screen.dart';

// ── Chat Screens ────────────────────────────────────────────
import 'package:adentweets_app/screens/chat/conversations_screen.dart';
import 'package:adentweets_app/screens/chat/chat_screen.dart';
import 'package:adentweets_app/screens/chat/new_message_screen.dart';

// ── Bookmarks Screen ────────────────────────────────────────
import 'package:adentweets_app/screens/bookmarks/bookmarks_screen.dart';

// ── Settings Screens ────────────────────────────────────────
import 'package:adentweets_app/screens/settings/settings_screen.dart';
import 'package:adentweets_app/screens/settings/account_settings_screen.dart';
import 'package:adentweets_app/screens/settings/privacy_settings_screen.dart';
import 'package:adentweets_app/screens/settings/notification_settings_screen.dart';
import 'package:adentweets_app/screens/settings/about_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isSplash = state.matchedLocation == '/splash';
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/onboarding';

      if (isSplash) return null;

      if (!isAuth && !isLoginRoute) return '/login';
      if (isAuth && isLoginRoute) return '/';
      return null;
    },
    routes: [
      // ── Auth Routes ─────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Main Shell ──────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/post/:id',
            builder: (context, state) {
              final postId = state.pathParameters['id']!;
              return PostDetailScreen(postId: postId);
            },
          ),
          GoRoute(
            path: '/create-post',
            builder: (context, state) => const CreatePostScreen(),
          ),
          GoRoute(
            path: '/profile/:userId',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              final currentUserId = ref.read(authProvider).user?.uid ?? '';
              if (userId == currentUserId) {
                return const HomeScreen();
              }
              return OtherProfileScreen(userId: userId);
            },
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) {
              final type = state.uri.queryParameters['type'] ?? 'followers';
              final userId = state.uri.queryParameters['userId'] ?? '';
              return UserListScreen(userId: userId, listType: type);
            },
          ),
        ],
      ),

      // ── Explore & Search ────────────────────────────────────
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ExploreScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchResultsScreen(query: query);
        },
      ),
      GoRoute(
        path: '/trending',
        builder: (context, state) => const TrendingScreen(),
      ),

      // ── Notifications ───────────────────────────────────────
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // ── Messages ────────────────────────────────────────────
      GoRoute(
        path: '/messages',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:conversationId',
        builder: (context, state) {
          final convId = state.pathParameters['conversationId']!;
          return ChatScreen(conversationId: convId);
        },
      ),
      GoRoute(
        path: '/new-message',
        builder: (context, state) => const NewMessageScreen(),
      ),

      // ── Bookmarks ───────────────────────────────────────────
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),

      // ── Settings ────────────────────────────────────────────
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/account',
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/help',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
});