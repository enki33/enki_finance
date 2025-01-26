/// Base class for transaction-related exceptions
class TransactionException implements Exception {
  const TransactionException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when transaction analysis fails
class TransactionAnalysisException extends TransactionException {
  const TransactionAnalysisException(String message) : super(message);
}

/// Thrown when transaction search fails
class TransactionSearchException extends TransactionException {
  const TransactionSearchException(String message) : super(message);
}

/// Thrown when transaction validation fails
class TransactionValidationException extends TransactionException {
  const TransactionValidationException(String message) : super(message);
}

/// Thrown when transaction creation fails
class TransactionCreationException extends TransactionException {
  const TransactionCreationException(String message) : super(message);
}

/// Thrown when transaction update fails
class TransactionUpdateException extends TransactionException {
  const TransactionUpdateException(String message) : super(message);
}

/// Thrown when transaction deletion fails
class TransactionDeletionException extends TransactionException {
  const TransactionDeletionException(String message) : super(message);
}
