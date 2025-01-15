import 'package:dartz/dartz.dart';
import 'package:enki_finance/core/errors/failures.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, Transaction>> createTransaction(
      Transaction transaction);
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
    String? categoryId,
    String? accountId,
    String? jarId,
  });
  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction);
  Future<Either<Failure, Unit>> deleteTransaction(String transactionId);
  Future<Either<Failure, Map<String, double>>> getTransactionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
