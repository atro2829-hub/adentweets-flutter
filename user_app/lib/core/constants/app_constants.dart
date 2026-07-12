class AppConstants {
  AppConstants._();

  // ── Content Limits ────────────────────────────────────────
  static const int maxPostLength = 280;
  static const int maxCommentLength = 500;
  static const int maxBioLength = 160;
  static const int maxDisplayNameLength = 50;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 8;
  static const int maxUsernameSearchResults = 20;
  static const int maxPostSearchResults = 20;

  // ── Image Limits ──────────────────────────────────────────
  static const int maxImageWidthPx = 800;
  static const int maxImageHeightPx = 1200;
  static const int imageCompressionQuality = 70;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // ── Pagination ────────────────────────────────────────────
  static const int postsPerPage = 20;
  static const int usersPerPage = 30;
  static const int messagesPerPage = 50;
  static const int notificationsPerPage = 30;
  static const int searchResultsPerPage = 20;

  // ── Feed Ranking Weights ──────────────────────────────────
  static const double likeWeight = 3.0;
  static const double commentWeight = 2.0;
  static const double repostWeight = 4.0;
  static const double viewWeight = 0.1;

  // ── Verification Badge Config ─────────────────────────────
  static const String verificationBadgeBlue = 'blue';
  static const String verificationBadgeGray = 'gray';
  static const String verificationBadgeNone = 'none';

  // ── Firebase Node Paths ───────────────────────────────────
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

  // ── Firebase Config ───────────────────────────────────────
  static const String firebaseApiKey = 'AIzaSyD0lwxuEvl6ldIV0DclT5pURpN2KvqF5OI';
  static const String firebaseAuthDomain = 'adentweet.firebaseapp.com';
  static const String firebaseDatabaseUrl = 'https://adentweet-default-rtdb.firebaseio.com';
  static const String firebaseProjectId = 'adentweet';
  static const String firebaseStorageBucket = 'adentweet.firebasestorage.app';
  static const String firebaseMessagingSenderId = '325745894680';
  static const String firebaseAppId = '1:325745894680:web:abc123';

  // ── App Info ──────────────────────────────────────────────
  static const String appName = 'عدن تويتر';
  static const String appNameShort = 'AT';
  static const String appVersion = '1.0.0';

  // ── Animation Durations (ms) ──────────────────────────────
  static const int animationFastMs = 150;
  static const int animationNormalMs = 300;
  static const int animationSlowMs = 500;

  // ── Notification Types ────────────────────────────────────
  static const String notifTypeLike = 'like';
  static const String notifTypeRepost = 'repost';
  static const String notifTypeComment = 'comment';
  static const String notifTypeFollow = 'follow';
  static const String notifTypeMention = 'mention';
  static const String notifTypeVerification = 'verification';

  // ── Report Reasons ────────────────────────────────────────
  static const List<String> reportReasons = [
    'إساءة أو تحرش',
    'محتوى مخل',
    'معلومات مضللة',
    'انتحال هوية',
    'مخالفة القوانين',
    'رسائل مزعجة',
    'أخرى',
  ];

  // ── Report Status ─────────────────────────────────────────
  static const String reportStatusPending = 'pending';
  static const String reportStatusResolved = 'resolved';
  static const String reportStatusDismissed = 'dismissed';

  // ── Report Target Types ───────────────────────────────────
  static const String reportTargetUser = 'user';
  static const String reportTargetPost = 'post';
  static const String reportTargetComment = 'comment';

  // ── Message Types ─────────────────────────────────────────
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeSystem = 'system';

  // ── Conversation Types ────────────────────────────────────
  static const String conversationTypeDirect = 'direct';
  static const String conversationTypeGroup = 'group';

  // ── Default Avatar/Banner ─────────────────────────────────
  static const String defaultAvatar =
      'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAATxJREFUWEftlrENwkAMRe0TYQUYgRFghBSMIIKQQx9JaCdELoAFZV5sTO0MsFlgC3DOsmdk3fUB8fD4zO8w/8rM+ApYBkYDk4HJwMpier+/vPwHmAvkABiDz2AHIBHcASuAowBMoMnUAmkBywD2gH7AG7APWBWsA9YA+wFZwBiwB6wFywBNgC9gJzAGrAXuARsAjYBp4AS4DFwDJgE9gCzAGrAPWAXOALGAfOAesAUYA44B1wCzgADAErAHbAHLABGAQ2AOuAcsAQ4BFwB6wBmwBxgEDgPnAFGAIMBc8AKsAQ4CJwCpwBiwDzoBzYAyYBGwCGwGjgAnAMLARuADcAaOAJ2AIPAaOAJWAMWAcOARuAMWAaOAaeAEMB44BFwDDgInALHAHLAZOAKOAReAMGAfOAMcBc8AKcAUcAo4CVwBigH7AFnAHLAPGAIMBI4BNwDCgHzgC1gEjgFjgH3AFHAObAfr6BvQE/x0N4X0qsAAAAAElFTkSuQmCC';
}