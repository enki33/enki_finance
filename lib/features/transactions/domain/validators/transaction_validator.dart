import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionValidator {
  final TransactionRepository repository;

  TransactionValidator(this.repository);

  Future<Either<Failure, Unit>> validate(Transaction transaction) async {
    try {
      // Basic validation
      if (transaction.amount <= 0) {
        return Left(
            ValidationFailure('Transaction amount must be greater than zero'));
      }

      if (transaction.transactionDate.isAfter(DateTime.now())) {
        return Left(
            ValidationFailure('Transaction date cannot be in the future'));
      }

      // Account validation
      if (transaction.accountId.isNotEmpty) {
        final accountValidation =
            await repository.validateAccount(transaction.accountId);
        if (accountValidation.isLeft()) {
          return accountValidation;
        }

        // Credit card validation
        final creditCardValidation = await repository.validateCreditLimit(
          accountId: transaction.accountId,
          amount: transaction.amount,
        );
        if (creditCardValidation.isLeft()) {
          return creditCardValidation;
        }
      }

      // Category validation
      final categoryValidation = await repository.validateCategory(
        categoryId: transaction.categoryId,
        subcategoryId: transaction.subcategoryId,
      );
      if (categoryValidation.isLeft()) {
        return categoryValidation;
      }

      // Jar validation for expenses
      if (transaction.transactionTypeId == 'EXPENSE') {
        final jarValidation = await repository.validateJarRequirement(
          subcategoryId: transaction.subcategoryId,
          jarId: transaction.jarId,
        );
        if (jarValidation.isLeft()) {
          return jarValidation;
        }

        // Balance validation for expenses
        final balanceValidation = await repository.validateBalance(transaction);
        if (balanceValidation.isLeft()) {
          return balanceValidation;
        }
      }

      // Currency validation
      if (transaction.currencyId.isNotEmpty) {
        final currencyValidation =
            await repository.validateCurrency(transaction.currencyId);
        if (currencyValidation.isLeft()) {
          return currencyValidation;
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Either<Failure, Unit> validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return left(ValidationFailure('Por favor ingresa un monto'));
    }

    final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    if (amount == null) {
      return left(ValidationFailure('Por favor ingresa un monto válido'));
    }

    if (amount <= 0) {
      return left(ValidationFailure('El monto debe ser mayor a cero'));
    }

    return right(unit);
  }

  Either<Failure, Unit> validateDate(DateTime? date) {
    if (date == null) {
      return left(ValidationFailure('Por favor selecciona una fecha'));
    }
    return right(unit);
  }

  Either<Failure, Unit> validateTransaction(Transaction transaction) {
    // Add your transaction validation logic here
    return right(unit);
  }
}
