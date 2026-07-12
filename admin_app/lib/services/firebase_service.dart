import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:adentweets_admin/core/constants/app_constants.dart';

class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: AppConstants.firebaseApiKey,
        authDomain: AppConstants.firebaseAuthDomain,
        databaseURL: AppConstants.firebaseDatabaseUrl,
        projectId: AppConstants.firebaseProjectId,
        storageBucket: AppConstants.firebaseStorageBucket,
        messagingSenderId: AppConstants.firebaseMessagingSenderId,
        appId: AppConstants.firebaseAppId,
      ),
    );
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseDatabase get database => FirebaseDatabase.instance;
  static DatabaseReference get db => FirebaseDatabase.instance.ref();
}