import '../entities/auth_user.dart';
import '../exceptions/auth_exception.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  const AuthService(this._authRepository);

  final AuthRepository _authRepository;

  // Expose repository for direct access when needed
  AuthRepository get repository => _authRepository;

  Future<AuthUser?> signIn(String email, String password) async {
    _validateEmail(email);
    _validatePassword(password);

    try {
      return await _authRepository.signInWithEmailAndPassword(email, password);
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<AuthUser?> signUp(
    String email,
    String password, {
    required String firstName,
    required String lastName,
  }) async {
    _validateEmail(email);
    _validatePassword(password);
    _validateName(firstName, 'First name');
    _validateName(lastName, 'Last name');

    try {
      final user =
          await _authRepository.signUpWithEmailAndPassword(email, password);
      if (user != null) {
        await _authRepository.updateUserProfile(
          userId: user.id,
          firstName: firstName,
          lastName: lastName,
        );
      }
      return user;
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<void> resetPassword(String email) async {
    _validateEmail(email);
    try {
      await _authRepository.resetPassword(email);
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  Future<AuthUser> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
  }) async {
    if (firstName != null) _validateName(firstName, 'First name');
    if (lastName != null) _validateName(lastName, 'Last name');

    try {
      if (firstName != null || lastName != null) {
        await _authRepository.updateUserProfile(
          userId: userId,
          firstName: firstName ??
              (await _authRepository.getCurrentUser())?.firstName ??
              '',
          lastName: lastName ??
              (await _authRepository.getCurrentUser())?.lastName ??
              '',
        );
      }
      final updatedUser = await _authRepository.getCurrentUser();
      if (updatedUser == null) throw const UserNotFoundException();
      return updatedUser;
    } catch (e) {
      throw _mapAuthError(e);
    }
  }

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw const InvalidEmailException();
    }
  }

  void _validatePassword(String password) {
    if (password.length < 6) {
      throw const InvalidPasswordException();
    }
  }

  void _validateName(String name, String fieldName) {
    if (name.trim().isEmpty) {
      throw InvalidInputException('$fieldName cannot be empty');
    }
  }

  AuthException _mapAuthError(dynamic error) {
    // Add specific error mapping logic here
    if (error is AuthException) return error;
    return UnknownAuthException(error.toString());
  }
}
