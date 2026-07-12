import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:adentweets_admin/services/firebase_service.dart';

class AuthService {
  AuthService._();

  static final _auth = FirebaseService.auth;
  static final _db = FirebaseService.db;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  static Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final snapshot = await _db.child('users/${user.uid}/isAdmin').get();
      return snapshot.value as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<({bool success, String? error, String? displayName})> adminLogin(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return (success: false, error: 'فشل تسجيل الدخول', displayName: null);
      }

      final snapshot = await _db.child('users/${user.uid}').get();
      if (!snapshot.exists) {
        await _auth.signOut();
        return (success: false, error: 'المستخدم غير موجود في قاعدة البيانات', displayName: null);
      }

      final isAdmin = snapshot.child('isAdmin').value as bool? ?? false;
      if (!isAdmin) {
        await _auth.signOut();
        return (success: false, error: 'ليس لديك صلاحيات المدير', displayName: null);
      }

      final displayName = snapshot.child('displayName').value as String? ??
          snapshot.child('name').value as String? ?? 'مدير';

      return (success: true, error: null, displayName: displayName);
    } on FirebaseAuthException catch (e) {
      String error;
      switch (e.code) {
        case 'user-not-found':
          error = 'البريد الإلكتروني غير مسجل';
          break;
        case 'wrong-password':
          error = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          error = 'بريد إلكتروني غير صالح';
          break;
        case 'user-disabled':
          error = 'الحساب معطل';
          break;
        case 'too-many-requests':
          error = 'محاولات كثيرة، حاول لاحقاً';
          break;
        default:
          error = 'حدث خطأ في تسجيل الدخول';
      }
      return (success: false, error: error, displayName: null);
    } catch (e) {
      return (success: false, error: 'حدث خطأ غير متوقع', displayName: null);
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}