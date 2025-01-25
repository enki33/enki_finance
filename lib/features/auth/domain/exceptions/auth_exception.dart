/// Base class for authentication exceptions
abstract class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when email is invalid
class InvalidEmailException extends AuthException {
  const InvalidEmailException() : super('El correo electrónico no es válido');
}

/// Thrown when password is invalid
class InvalidPasswordException extends AuthException {
  const InvalidPasswordException() : super('La contraseña no es válida');
}

/// Thrown when email is already in use
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('El correo electrónico ya está en uso');
}

/// Thrown when user is not found
class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('No se encontró una cuenta con ese correo electrónico');
}

/// Thrown when password is wrong
class WrongPasswordException extends AuthException {
  const WrongPasswordException() : super('La contraseña es incorrecta');
}

/// Thrown when user is not verified
class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException()
      : super('Por favor verifica tu correo electrónico');
}

/// Thrown when operation requires recent login
class RequiresRecentLoginException extends AuthException {
  const RequiresRecentLoginException()
      : super('Por favor inicia sesión nuevamente para continuar');
}

/// Thrown when network is not available
class NetworkException extends AuthException {
  const NetworkException()
      : super('No hay conexión a internet. Por favor intenta más tarde');
}

/// Thrown when input validation fails
class InvalidInputException extends AuthException {
  const InvalidInputException(String message) : super(message);
}

/// Thrown for any other authentication error
class UnknownAuthException extends AuthException {
  const UnknownAuthException([String? message])
      : super(message ?? 'Ocurrió un error inesperado');
}
