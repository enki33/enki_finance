import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/daily_total.dart';
import '../entities/transaction_analysis.dart';
import '../entities/transaction_filter.dart';
import '../entities/transaction_summary.dart' as summary;
import '../entities/balance_history.dart';
import '../entities/category_analysis.dart';

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

  Future<Either<Failure, List<CategoryAnalysis>>> analyzeByCategory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
  });

  Future<Either<Failure, List<summary.TransactionSummary>>>
      getSummaryByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, List<Transaction>>> searchByTags({
    required String userId,
    required List<String> tags,
  });

  Future<Either<Failure, List<Transaction>>> searchByNotes({
    required String userId,
    required String searchText,
  });

  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
    String? categoryId,
    String? subcategoryId,
    String? accountId,
    String? jarId,
  });

  Future<Either<Failure, bool>> validateTransaction({
    required Transaction transaction,
    required bool isUpdate,
  });

  Future<Either<Failure, List<DailyTotal>>> getDailyTotals({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
  });

  // Validation methods
  Future<Either<Failure, Unit>> validateAccount(String accountId);
  Future<Either<Failure, Unit>> validateCreditLimit({
    required String accountId,
    required double amount,
  });
  Future<Either<Failure, Unit>> validateCategory({
    required String categoryId,
    String? subcategoryId,
  });
  Future<Either<Failure, Unit>> validateJarRequirement({
    String? subcategoryId,
    String? jarId,
  });
  Future<Either<Failure, Unit>> validateBalance(Transaction transaction);
  Future<Either<Failure, Unit>> validateCurrency(String currencyId);

  // Balance history methods
  Future<Either<Failure, List<BalanceHistory>>> getAccountBalanceHistory({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, List<BalanceHistory>>> getJarBalanceHistory({
    required String jarId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, double>> calculateAccountBalance({
    required String accountId,
    DateTime? asOf,
  });

  Future<Either<Failure, double>> calculateJarBalance({
    required String jarId,
    DateTime? asOf,
  });

  Future<Either<Failure, Unit>> recordBalanceHistory(BalanceHistory history);
}
