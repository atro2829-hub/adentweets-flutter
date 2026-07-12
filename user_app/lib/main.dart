import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/app.dart';
import 'package:adentweets_app/core/utils/date_formatter.dart';
import 'package:adentweets_app/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    await FirebaseService.initialize();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  DateFormatter.init();

  runApp(const ProviderScope(child: App()));
}