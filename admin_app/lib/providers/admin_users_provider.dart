import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_admin/models/user_model.dart';
import 'package:adentweets_admin/services/admin_user_service.dart';

enum UserFilter { all, verified, suspended, admin }

class AdminUsersState {
  final bool isLoading;
  final List<UserModel> users;
  final String searchQuery;
  final UserFilter filter;
  final String? error;
  final String? actionMessage;

  const AdminUsersState({
    this.isLoading = false,
    this.users = const [],
    this.searchQuery = '',
    this.filter = UserFilter.all,
    this.error,
    this.actionMessage,
  });

  AdminUsersState copyWith({
    bool? isLoading,
    List<UserModel>? users,
    String? searchQuery,
    UserFilter? filter,
    String? error,
    String? actionMessage,
  }) {
    return AdminUsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      error: error,
      actionMessage: actionMessage,
    );
  }

  List<UserModel> get filteredUsers {
    var filtered = users;

    switch (filter) {
      case UserFilter.verified:
        filtered = filtered.where((u) => u.isVerified).toList();
        break;
      case UserFilter.suspended:
        filtered = filtered.where((u) => u.isSuspended).toList();
        break;
      case UserFilter.admin:
        filtered = filtered.where((u) => u.isAdmin).toList();
        break;
      case UserFilter.all:
        break;
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      filtered = filtered.where((u) =>
        u.displayName.toLowerCase().contains(q) ||
        u.username.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q)
      ).toList();
    }

    return filtered;
  }
}

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  AdminUsersNotifier() : super(const AdminUsersState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await AdminUserService.fetchUsers();
      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilter(UserFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> suspendUser(String userId) async {
    try {
      await AdminUserService.suspendUser(userId);
      final updated = state.users.map((u) {
        if (u.uid == userId) return u.copyWith(isSuspended: true);
        return u;
      }).toList();
      state = state.copyWith(users: updated, actionMessage: 'تم تعليق المستخدم بنجاح');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unsuspendUser(String userId) async {
    try {
      await AdminUserService.unsuspendUser(userId);
      final updated = state.users.map((u) {
        if (u.uid == userId) return u.copyWith(isSuspended: false);
        return u;
      }).toList();
      state = state.copyWith(users: updated, actionMessage: 'تم إلغاء تعليق المستخدم');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> verifyUser(String userId, String verificationType) async {
    try {
      await AdminUserService.verifyUser(userId, verificationType);
      final updated = state.users.map((u) {
        if (u.uid == userId) {
          return u.copyWith(
            isVerified: verificationType != 'none',
            verificationType: verificationType,
          );
        }
        return u;
      }).toList();
      state = state.copyWith(users: updated, actionMessage: 'تم تحديث التوثيق');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await AdminUserService.deleteUser(userId);
      final updated = state.users.where((u) => u.uid != userId).toList();
      state = state.copyWith(users: updated, actionMessage: 'تم حذف المستخدم');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearActionMessage() {
    state = state.copyWith(actionMessage: null);
  }
}

final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AdminUsersState>(
  (ref) => AdminUsersNotifier(),
);