import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/auth_user.dart';

part 'auth_repository.g.dart';

abstract class AuthRepository {
  /// Returns the current authenticated user or null if not authenticated
  Future<AuthUser?> getCurrentUser();

  /// Signs in with email and password
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs up with email and password
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  });

  /// Signs out the current user
  Future<void> signOut();

  /// Sends password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Updates user profile
  Future<AuthUser> updateProfile({
    String? name,
    String? avatarUrl,
  });

  /// Verifies email
  Future<void> verifyEmail(String oobCode);

  /// Changes password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  throw UnimplementedError('authRepository not implemented');
}
