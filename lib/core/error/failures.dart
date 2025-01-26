import 'package:equatable/equatable.dart';

abstract class Failure {
  const Failure([this.message = '']);

  final String message;
}

class ServerFailure extends Failure {
  const ServerFailure([String message = '']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = '']) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = '']) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String message = '']) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure([String message = '']) : super(message);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure([String message = '']) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = '']) : super(message);
}

class ConflictFailure extends Failure {
  const ConflictFailure([String message = '']) : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([String message = '']) : super(message);
}
