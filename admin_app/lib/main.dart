import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_admin/app.dart';
import 'package:adentweets_admin/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  // Firebase init - must succeed for app to work
  bool firebaseReady = false;
  String? firebaseError;
  try {
    await FirebaseService.initialize();
    firebaseReady = true;
  } catch (e) {
    firebaseError = e.toString();
    debugPrint('Firebase init error: $e');
  }

  runApp(ProviderScope(
    child: AdenTweetsAdminApp(
      firebaseReady: firebaseReady,
      firebaseError: firebaseError,
    ),
  ));
}