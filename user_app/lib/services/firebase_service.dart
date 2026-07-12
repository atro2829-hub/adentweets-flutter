import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  static FirebaseApp? _app;
  static bool _initialized = false;

  static Future<FirebaseApp> initialize() async {
    if (_initialized && _app != null) return _app!;
    _app = await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyD0lwxuEvl6ldIV0DclT5pURpN2KvqF5OI',
        authDomain: 'adentweet.firebaseapp.com',
        databaseURL: 'https://adentweet-default-rtdb.firebaseio.com',
        projectId: 'adentweet',
        storageBucket: 'adentweet.firebasestorage.app',
        messagingSenderId: '325745894680',
        appId: '1:325745894680:web:abc123',
      ),
    );
    _initialized = true;
    return _app!;
  }

  static FirebaseDatabase get database => FirebaseDatabase.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static DatabaseReference get ref => FirebaseDatabase.instance.ref();
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});