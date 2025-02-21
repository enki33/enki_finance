/// Base class for transaction-related exceptions
class TransactionException implements Exception {
  final String message;

  const TransactionException(this.message);

  @override
  String toString() => message;
}

/// Thrown when transaction analysis fails
class TransactionAnalysisException extends TransactionException {
  TransactionAnalysisException(String message) : super(message);
}

/// Thrown when transaction search fails
class TransactionSearchException extends TransactionException {
  TransactionSearchException(String message) : super(message);
}

/// Thrown when transaction validation fails
class TransactionValidationException implements Exception {
  final List<String> errors;

  TransactionValidationException(this.errors);

  @override
  String toString() => errors.join(', ');
}

/// Thrown when transaction creation fails
class TransactionCreationException extends TransactionException {
  TransactionCreationException(String message) : super(message);
}

/// Thrown when transaction update fails
class TransactionUpdateException extends TransactionException {
  TransactionUpdateException(String message) : super(message);
}

/// Thrown when transaction deletion fails
class TransactionDeletionException extends TransactionException {
  TransactionDeletionException(String message) : super(message);
}
