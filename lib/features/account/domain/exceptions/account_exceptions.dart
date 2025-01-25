/// Base class for account-related exceptions
class AccountException implements Exception {
  const AccountException(this.message);
  final String message;

  @override
  String toString() => message;
}
