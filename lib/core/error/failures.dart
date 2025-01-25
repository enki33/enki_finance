import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({required String message, String? code})
      : super(message: message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message, String? code})
      : super(message: message, code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message, String? code})
      : super(message: message, code: code);
}

class ValidationFailure extends Failure {
  const ValidationFailure({required String message, String? code})
      : super(message: message, code: code);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required String message, String? code})
      : super(message: message, code: code);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message, String? code})
      : super(message: message, code: code);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(String message)
      : super(message: message, code: 'DATABASE_ERROR');
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message)
      : super(message: message, code: 'UNEXPECTED_ERROR');
}
