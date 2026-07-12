import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/models/user_model.dart';
import 'package:adentweets_app/services/auth_service.dart';
import 'package:adentweets_app/services/database_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final UserModel? userData;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.loading,
    this.user,
    this.userData,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserModel? userData,
    String? errorMessage,
    bool clearError,
    bool clearUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      userData: clearUser ? null : (userData ?? this.userData),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final DatabaseService _db;

  AuthNotifier(this._authService, this._db) : super(const AuthState()) {
    _initAuth();
  }

  void _initAuth() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          final data = await _db.getData(
            '${AppConstants.usersPath}/${user.uid}',
          );
          if (data != null) {
            final userModel = UserModel.fromJson(data);
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              userData: userModel,
              clearError: true,
            );
          } else {
            state = state.copyWith(
              status: AuthStatus.unauthenticated,
              clearUser: true,
              clearError: true,
            );
          }
        } catch (e) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        }
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _authService.loginWithEmailPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _authService.signInWithGoogle();
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'حدث خطأ في تسجيل الدخول',
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'حدث خطأ في إرسال رابط إعادة التعيين',
      );
    }
  }

  Future<void> updateUserData(UserModel userData) async {
    state = state.copyWith(userData: userData);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = ref.watch(authServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return AuthNotifier(auth, db);
});