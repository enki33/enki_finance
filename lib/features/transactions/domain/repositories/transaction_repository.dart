import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/daily_total.dart';
import '../../presentation/providers/transaction_filter_provider.dart';

abstract class TransactionRepository {
  Future<Either<Failure, Transaction>> createTransaction(
      Transaction transaction);

  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    TransactionFilter? filter,
  });

  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction);

  Future<Either<Failure, Unit>> deleteTransaction(String transactionId);

  Future<Either<Failure, Map<String, double>>> getTransactionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, List<DailyTotal>>> getDailyTotals({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
  });
}
