import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/services/firebase_service.dart';
import 'package:adentweets_app/services/database_service.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';

class AuthException implements Exception {
  final String message;
  final String code;
  AuthException(this.message, {this.code = ''});
  @override
  String toString() => message;
}

class AuthService {
  final DatabaseService _db;
  final FirebaseAuth _auth;

  AuthService(this._db) : _auth = FirebaseService.auth;

  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw AuthException('فشل إنشاء الحساب');
      }

      final userData = {
        'uid': user.uid,
        'username': username,
        'email': email,
        'fullName': fullName,
        'bio': '',
        'avatarBase64': null,
        'bannerBase64': null,
        'followersCount': 0,
        'followingCount': 0,
        'postsCount': 0,
        'isVerified': false,
        'verificationBadge': AppConstants.verificationBadgeNone,
        'isPrivate': false,
        'isSuspended': false,
        'isAdmin': false,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastActive': DateTime.now().millisecondsSinceEpoch,
        'isOnline': true,
      };

      await _db.setData(
        '${AppConstants.usersPath}/${user.uid}',
        userData,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw AuthException('حدث خطأ غير متوقع');
    }
  }

  Future<UserCredential> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _db.updateData(
          '${AppConstants.usersPath}/${credential.user!.uid}',
          {
            'isOnline': true,
            'lastActive': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw AuthException('حدث خطأ غير متوقع');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw AuthException('تم إلغاء تسجيل الدخول');
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw AuthException('فشل تسجيل الدخول');
      }

      final existingUser = await _db.getData('${AppConstants.usersPath}/${user.uid}');

      if (existingUser == null) {
        final username = user.email?.split('@').first ?? 'user_${user.uid.substring(0, 6)}';
        final cleanUsername = username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();

        final userData = {
          'uid': user.uid,
          'username': cleanUsername,
          'email': user.email ?? '',
          'fullName': user.displayName ?? cleanUsername,
          'bio': '',
          'avatarBase64': null,
          'bannerBase64': null,
          'followersCount': 0,
          'followingCount': 0,
          'postsCount': 0,
          'isVerified': false,
          'verificationBadge': AppConstants.verificationBadgeNone,
          'isPrivate': false,
          'isSuspended': false,
          'isAdmin': false,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'lastActive': DateTime.now().millisecondsSinceEpoch,
          'isOnline': true,
        };

        await _db.setData(
          '${AppConstants.usersPath}/${user.uid}',
          userData,
        );
      } else {
        await _db.updateData(
          '${AppConstants.usersPath}/${user.uid}',
          {
            'isOnline': true,
            'lastActive': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('حدث خطأ في تسجيل الدخول بجوجل');
    }
  }

  Future<void> logout() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _db.updateData(
          '${AppConstants.usersPath}/${user.uid}',
          {
            'isOnline': false,
            'lastActive': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      throw AuthException('حدث خطأ في تسجيل الخروج');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw AuthException('حدث خطأ في إرسال رابط إعادة تعيين كلمة المرور');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw AuthException('حدث خطأ في تحديث كلمة المرور');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _db.deleteData('${AppConstants.usersPath}/${user.uid}');
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw AuthException('حدث خطأ في حذف الحساب');
    }
  }

  AuthException _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('لا يوجد حساب بهذا البريد الإلكتروني', code: e.code);
      case 'wrong-password':
        return AuthException('كلمة المرور غير صحيحة', code: e.code);
      case 'email-already-in-use':
        return AuthException('البريد الإلكتروني مستخدم مسبقًا', code: e.code);
      case 'weak-password':
        return AuthException('كلمة المرور ضعيفة جدًا', code: e.code);
      case 'invalid-email':
        return AuthException('البريد الإلكتروني غير صالح', code: e.code);
      case 'too-many-requests':
        return AuthException('محاولات كثيرة، حاول لاحقًا', code: e.code);
      case 'network-request-failed':
        return AuthException('خطأ في الاتصال بالإنترنت', code: e.code);
      case 'invalid-credential':
        return AuthException('بيانات الدخول غير صحيحة', code: e.code);
      default:
        return AuthException('حدث خطأ في المصادقة: ${e.message}', code: e.code);
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return AuthService(db);
});