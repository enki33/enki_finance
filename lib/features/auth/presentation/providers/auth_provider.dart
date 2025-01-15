import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart' show debugPrint;
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/core/routing/app_router.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../data/repositories/auth_repository_provider.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthUser?> build() async {
    final user = await _authRepository.getCurrentUser();
    debugPrint('To login debug: Auth Provider - Current user: $user');
    return user;
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  Future<void> handleAuthResponse(supabase.AuthResponse response) async {
    debugPrint('Handling auth response: ${response.user?.email}');
    state = const AsyncLoading();
    if (response.user != null) {
      debugPrint('User is not null, getting current user');
      final user = await _authRepository.getCurrentUser();
      debugPrint('Current user: $user');
      state = AsyncData(user);
      ref.invalidate(routerProvider);
    } else {
      debugPrint('User is null, setting state to null');
      state = const AsyncData(null);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await _authRepository.signOut();
    state = const AsyncData(null);
  }

  Future<void> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.updateProfile(
          name: name,
          avatarUrl: avatarUrl,
        ));
  }

  Future<void> refreshUser() async {
    state = const AsyncLoading();
    final user = await _authRepository.getCurrentUser();
    state = AsyncData(user);
  }
}
