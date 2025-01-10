import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/auth_user.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] using Supabase as backend
class SupabaseAuthRepository implements AuthRepository {
  /// Creates a new [SupabaseAuthRepository] instance
  const SupabaseAuthRepository(this._supabase);

  final supabase.SupabaseClient _supabase;

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      return _mapToAuthUser(user);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const UnknownAuthException(
          'No se pudo iniciar sesión. Por favor intenta más tarde.',
        );
      }

      return _mapToAuthUser(response.user!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (name != null) 'name': name,
        },
      );

      if (response.user == null) {
        throw const UnknownAuthException(
          'No se pudo crear la cuenta. Por favor intenta más tarde.',
        );
      }

      return _mapToAuthUser(response.user!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<AuthUser> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const UnknownAuthException('No hay usuario autenticado.');
      }

      final response = await _supabase.auth.updateUser(
        supabase.UserAttributes(
          data: {
            if (name != null) 'name': name,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          },
        ),
      );

      if (response.user == null) {
        throw const UnknownAuthException(
          'No se pudo actualizar el perfil. Por favor intenta más tarde.',
        );
      }

      return _mapToAuthUser(response.user!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _supabase.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> verifyEmail(String oobCode) async {
    // Email verification disabled - no implementation needed
    return;
  }

  /// Maps a Supabase [User] to our domain [AuthUser]
  AuthUser _mapToAuthUser(supabase.User user) {
    return AuthUser(
      id: user.id,
      email: user.email!,
      name: user.userMetadata?['name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      emailVerified: true,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
    );
  }

  /// Handles authentication errors and maps them to our domain exceptions
  AuthException _handleError(dynamic error) {
    if (error is supabase.AuthException) {
      switch (error.statusCode) {
        case '400':
          if (error.message.contains('email')) {
            return const InvalidEmailException();
          }
          if (error.message.contains('password')) {
            return const InvalidPasswordException();
          }
          return UnknownAuthException(error.message);
        case '401':
          return const WrongPasswordException();
        case '404':
          return const UserNotFoundException();
        case '409':
          return const EmailAlreadyInUseException();
        case '422':
          return const InvalidPasswordException();
        case '429':
          return const UnknownAuthException(
            'Demasiados intentos. Por favor intenta más tarde.',
          );
        default:
          return UnknownAuthException(error.message);
      }
    }

    return const UnknownAuthException();
  }
}
