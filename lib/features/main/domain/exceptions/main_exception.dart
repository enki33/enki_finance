/// Base class for main feature related exceptions
class MainException implements Exception {
  const MainException(this.message);
  final String message;

  @override
  String toString() => message;
}
