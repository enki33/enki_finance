import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart' show debugPrint;
import '../../domain/entities/auth_user.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/auth_service_provider.dart';
import 'package:enki_finance/core/routing/app_router.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthUser?> build() async {
    final authService = ref.read(authServiceProvider);
    return authService.repository.getCurrentUser();
  }

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.signIn(email, password));
    if (!state.hasError) {
      ref.invalidate(routerProvider);
    }
  }

  Future<void> signUp(
    String email,
    String password, {
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.signUp(
          email,
          password,
          firstName: firstName,
          lastName: lastName,
        ));
    if (!state.hasError) {
      ref.invalidate(routerProvider);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await _authService.repository.signOut();
    state = const AsyncData(null);
    ref.invalidate(routerProvider);
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    state = const AsyncLoading();
    final currentUser = await _authService.repository.getCurrentUser();
    if (currentUser == null) {
      state = const AsyncData(null);
      return;
    }

    state = await AsyncValue.guard(() => _authService.updateProfile(
          userId: currentUser.id,
          firstName: firstName,
          lastName: lastName,
        ));
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    await _authService.resetPassword(email);
    state = await AsyncValue.guard(_authService.repository.getCurrentUser);
  }

  Future<void> refreshUser() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_authService.repository.getCurrentUser);
  }
}
