import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adentweets_admin/widgets/admin_nav_shell.dart';
import 'package:adentweets_admin/screens/auth/splash_screen.dart';
import 'package:adentweets_admin/screens/auth/login_screen.dart';
import 'package:adentweets_admin/screens/dashboard/dashboard_screen.dart';
import 'package:adentweets_admin/screens/users/users_screen.dart';
import 'package:adentweets_admin/screens/users/user_detail_screen.dart';
import 'package:adentweets_admin/screens/posts/posts_screen.dart';
import 'package:adentweets_admin/screens/comments/comments_screen.dart';
import 'package:adentweets_admin/screens/reports/reports_screen.dart';
import 'package:adentweets_admin/screens/verification/verification_screen.dart';
import 'package:adentweets_admin/screens/trending/trending_management_screen.dart';
import 'package:adentweets_admin/screens/analytics/analytics_screen.dart';
import 'package:adentweets_admin/screens/settings/system_settings_screen.dart';
import 'package:adentweets_admin/screens/activity/activity_log_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AdminNavShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/users',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UsersScreen(),
            ),
          ),
          GoRoute(
            path: '/users/:userId',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return UserDetailScreen(userId: userId);
            },
          ),
          GoRoute(
            path: '/posts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PostsScreen(),
            ),
          ),
          GoRoute(
            path: '/comments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommentsScreen(),
            ),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsScreen(),
            ),
          ),
          GoRoute(
            path: '/verification',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VerificationScreen(),
            ),
          ),
          GoRoute(
            path: '/trending',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TrendingManagementScreen(),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SystemSettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/activity-log',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ActivityLogScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}