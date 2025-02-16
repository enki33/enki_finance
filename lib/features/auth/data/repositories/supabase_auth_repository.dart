import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._client);

  final supabase.SupabaseClient _client;

  AuthUser? _mapUserToAuthUser(supabase.User? user) {
    if (user == null) return null;

    return AuthUser(
      id: user.id,
      email: user.email ?? '',
      firstName: user.userMetadata?['first_name'] ?? '',
      lastName: user.userMetadata?['last_name'] ?? '',
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: user.updatedAt != null
          ? DateTime.parse(user.updatedAt!)
          : DateTime.parse(user.createdAt),
    );
  }

  @override
  AuthUser? get currentUser => _mapUserToAuthUser(_client.auth.currentUser);

  @override
  Stream<AuthUser?> get onAuthStateChanged => _client.auth.onAuthStateChange
      .map((event) => _mapUserToAuthUser(event.session?.user));

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      return _mapUserToAuthUser(user);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _mapUserToAuthUser(response.user);
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return _mapUserToAuthUser(response.user);
    } catch (e) {
      if (e is AuthException) {
        debugPrint('Auth Error Details:');
        debugPrint('  Message: ${e.message}');
        debugPrint('  Status: ${e.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Update app_user table
      await _client.from('app_user').update({
        'first_name': firstName,
        'last_name': lastName,
      }).eq('id', userId);

      // Update auth user metadata
      await _client.auth.updateUser(
        supabase.UserAttributes(
          data: {
            'first_name': firstName,
            'last_name': lastName,
          },
        ),
      );

      debugPrint('User profile updated successfully');
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      if (e is supabase.PostgrestException) {
        debugPrint('PostgreSQL Error Details:');
        debugPrint('  Message: ${e.message}');
        debugPrint('  Code: ${e.code}');
        debugPrint('  Details: ${e.details}');
        debugPrint('  Hint: ${e.hint}');
      }
      rethrow;
    }
  }

  @override
  Future<AuthUser> updateProfile({
    String? name,
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    await _client.auth.updateUser(
      supabase.UserAttributes(
        data: {
          if (name != null) 'name': name,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      ),
    );
    return getCurrentUser().then((user) => user!);
  }
}
