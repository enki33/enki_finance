//import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/auth_user.dart';

//part 'auth_repository.g.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;
  Future<AuthUser?> getCurrentUser();
  Future<AuthUser?> signInWithEmailAndPassword(String email, String password);
  Future<AuthUser?> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<AuthUser?> get onAuthStateChanged;

  /// Updates user profile
  Future<AuthUser> updateProfile({
    String? name,
    String? firstName,
    String? lastName,
    String? avatarUrl,
  });

  Future<void> updateUserProfile({
    required String userId,
    required String firstName,
    required String lastName,
  });
}
