/// Base class for jar-related exceptions
class JarException implements Exception {
  const JarException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when a jar transfer validation fails
class JarTransferException extends JarException {
  const JarTransferException(String message) : super(message);
}

/// Thrown when jar requirements are not met
class JarRequirementException extends JarException {
  const JarRequirementException(String message) : super(message);
}

/// Thrown when jar distribution analysis fails
class JarDistributionException extends JarException {
  const JarDistributionException(String message) : super(message);
}
