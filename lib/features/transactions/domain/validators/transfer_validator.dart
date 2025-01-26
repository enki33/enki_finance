import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Validates transfer transactions according to business rules
class TransferValidator {
  final TransactionRepository repository;

  TransferValidator(this.repository);

  /// Validates a transfer transaction
  Future<Either<Failure, Unit>> validate({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    double? exchangeRate,
  }) async {
    try {
      // Basic validation
      if (amount <= 0) {
        return Left(
            ValidationFailure('Transfer amount must be greater than zero'));
      }

      if (fromAccountId.isEmpty || toAccountId.isEmpty) {
        return Left(ValidationFailure(
            'Both source and destination accounts are required'));
      }

      if (fromAccountId == toAccountId) {
        return Left(ValidationFailure(
            'Source and destination accounts must be different'));
      }

      // Account validation
      final fromAccountValidation =
          await repository.validateAccount(fromAccountId);
      if (fromAccountValidation.isLeft()) {
        return fromAccountValidation;
      }

      final toAccountValidation = await repository.validateAccount(toAccountId);
      if (toAccountValidation.isLeft()) {
        return toAccountValidation;
      }

      // Balance validation for source account
      final balanceValidation = await repository.validateBalance(
        Transaction(
          id: '',
          userId: '',
          accountId: fromAccountId,
          amount: amount,
          transactionDate: DateTime.now(),
          transactionTypeId: 'TRANSFER',
          categoryId: '',
          description: '',
          currencyId: '',
          jarId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (balanceValidation.isLeft()) {
        return balanceValidation;
      }

      // Exchange rate validation if provided
      if (exchangeRate != null && exchangeRate <= 0) {
        return Left(
            ValidationFailure('Exchange rate must be greater than zero'));
      }

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Validates a jar transfer
  Future<Either<Failure, Unit>> validateJarTransfer({
    required String fromJarId,
    required String toJarId,
    required double amount,
  }) async {
    try {
      // Basic validation
      if (amount <= 0) {
        return Left(
            ValidationFailure('Transfer amount must be greater than zero'));
      }

      if (fromJarId.isEmpty || toJarId.isEmpty) {
        return Left(
            ValidationFailure('Both source and destination jars are required'));
      }

      if (fromJarId == toJarId) {
        return Left(
            ValidationFailure('Source and destination jars must be different'));
      }

      // Jar validation
      final fromJarValidation = await repository.validateJarRequirement(
        jarId: fromJarId,
      );
      if (fromJarValidation.isLeft()) {
        return fromJarValidation;
      }

      final toJarValidation = await repository.validateJarRequirement(
        jarId: toJarId,
      );
      if (toJarValidation.isLeft()) {
        return toJarValidation;
      }

      // Balance validation for source jar
      final balanceValidation = await repository.validateBalance(
        Transaction(
          id: '',
          userId: '',
          accountId: '',
          amount: amount,
          transactionDate: DateTime.now(),
          transactionTypeId: 'TRANSFER',
          categoryId: '',
          description: '',
          currencyId: '',
          jarId: fromJarId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (balanceValidation.isLeft()) {
        return balanceValidation;
      }

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
