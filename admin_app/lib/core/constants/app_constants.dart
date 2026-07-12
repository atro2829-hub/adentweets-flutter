class AppConstants {
  AppConstants._();

  static const String appName = 'أدن تويترز';
  static const String adminPanelName = 'مركز إدارة أدن تويترز';
  static const String appVersion = '1.0.0';

  // Firebase
  static const String firebaseApiKey = 'AIzaSyD0lwxuEvl6ldIV0DclT5pURpN2KvqF5OI';
  static const String firebaseAuthDomain = 'adentweet.firebaseapp.com';
  static const String firebaseDatabaseUrl = 'https://adentweet-default-rtdb.firebaseio.com';
  static const String firebaseProjectId = 'adentweet';
  static const String firebaseStorageBucket = 'adentweet.firebasestorage.app';
  static const String firebaseMessagingSenderId = '325745894680';
  static const String firebaseAppId = '1:325745894680:web:abc123';

  // Database paths
  static const String usersPath = 'users';
  static const String postsPath = 'posts';
  static const String commentsPath = 'comments';
  static const String likesPath = 'likes';
  static const String bookmarksPath = 'bookmarks';
  static const String followsPath = 'follows';
  static const String conversationsPath = 'conversations';
  static const String messagesPath = 'messages';
  static const String notificationsPath = 'notifications';
  static const String reportsPath = 'reports';
  static const String trendingPath = 'trending';
  static const String settingsPath = 'settings';
  static const String activityLogPath = 'activity_log';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Verification types
  static const String verificationNone = 'none';
  static const String verificationBlue = 'blue';
  static const String verificationGray = 'gray';
  static const String verificationGold = 'gold';

  // Report status
  static const String reportPending = 'pending';
  static const String reportResolved = 'resolved';
  static const String reportDismissed = 'dismissed';

  // Report reasons
  static const List<String> reportReasons = [
    'محتوى مزعج',
    'إساءة',
    'تنمر',
    'معلومات مضللة',
    'محتوى حساس',
    'انتحال هوية',
    'بريد مزعج',
    'أخرى',
  ];

  // User roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // Activity log actions
  static const String actionSuspendUser = 'suspend_user';
  static const String actionUnsuspendUser = 'unsuspend_user';
  static const String actionVerifyUser = 'verify_user';
  static const String actionDeleteUser = 'delete_user';
  static const String actionDeletePost = 'delete_post';
  static const String actionDeleteComment = 'delete_comment';
  static const String actionResolveReport = 'resolve_report';
  static const String actionDismissReport = 'dismiss_report';
  static const String actionUpdateSettings = 'update_settings';
  static const String actionPinTrending = 'pin_trending';
  static const String actionResetTrending = 'reset_trending';

  // Settings keys
  static const String settingMaintenanceMode = 'maintenance_mode';
  static const String settingMaxPostLength = 'max_post_length';
  static const String settingContentFilter = 'content_filter_keywords';
  static const String settingAutoVerify = 'auto_verify';

  // Date ranges
  static const int range7Days = 7;
  static const int range30Days = 30;
  static const int range90Days = 90;

  // Animation durations
  static const Duration splashMinDuration = Duration(seconds: 2);
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Default avatar placeholder (base64 1x1 transparent pixel)
  static const String defaultAvatarBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
}