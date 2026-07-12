import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_admin/services/auth_service.dart';

class AdminAuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool isAdmin;
  final String? error;
  final String? displayName;

  const AdminAuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.error,
    this.displayName,
  });

  AdminAuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isAdmin,
    String? error,
    String? displayName,
  }) {
    return AdminAuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin: isAdmin ?? this.isAdmin,
      error: error,
      displayName: displayName ?? this.displayName,
    );
  }
}

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  AdminAuthNotifier() : super(const AdminAuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = AuthService.currentUser;
    if (user != null) {
      final isAdmin = await AuthService.isCurrentUserAdmin();
      state = state.copyWith(
        isAuthenticated: true,
        isAdmin: isAdmin,
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await AuthService.adminLogin(email, password);

    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isAdmin: true,
        displayName: result.displayName,
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
    }
  }

  Future<void> logout() async {
    await AuthService.signOut();
    state = const AdminAuthState();
  }
}

final adminAuthProvider = StateNotifierProvider<AdminAuthNotifier, AdminAuthState>(
  (ref) => AdminAuthNotifier(),
);