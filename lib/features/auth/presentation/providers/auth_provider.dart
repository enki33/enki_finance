import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthUser?> build() async {
    return _authRepository.getCurrentUser();
  }

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => _authRepository.signInWithEmailAndPassword(
              email: email,
              password: password,
            ));
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => _authRepository.signUpWithEmailAndPassword(
              email: email,
              password: password,
              name: name,
            ));
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await _authRepository.signOut();
    state = const AsyncData(null);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authRepository.sendPasswordResetEmail(email);
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

  Future<void> verifyEmail(String oobCode) async {
    await _authRepository.verifyEmail(oobCode);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
