import 'package:flutter/material.dart';
import 'package:adentweets_admin/core/router/app_router.dart';
import 'package:adentweets_admin/core/theme/app_theme.dart';

class AdenTweetsAdminApp extends StatelessWidget {
  const AdenTweetsAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'مركز إدارة أدن تويترز',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}