import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/category_analysis.dart';
import '../../domain/entities/daily_total.dart';
import '../../domain/entities/balance_history.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/entities/transaction_summary.dart' as summary;
import '../datasources/transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _dataSource;

  const TransactionRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
    String? categoryId,
    String? subcategoryId,
    String? accountId,
    String? jarId,
  }) async {
    try {
      final transactions = await _dataSource.getTransactionsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        transactionTypeId: transactionTypeId,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        accountId: accountId,
        jarId: jarId,
      );
      return right(transactions);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryAnalysis>>> analyzeByCategory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
  }) async {
    try {
      final result = await _dataSource.analyzeByCategory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        transactionType: transactionType,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> calculateAccountBalance({
    required String accountId,
    DateTime? asOf,
  }) async {
    try {
      final result = await _dataSource.calculateAccountBalance(
        accountId: accountId,
        asOf: asOf,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> calculateJarBalance({
    required String jarId,
    DateTime? asOf,
  }) async {
    try {
      final result = await _dataSource.calculateJarBalance(
        jarId: jarId,
        asOf: asOf,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> createTransaction(
      Transaction transaction) async {
    try {
      final result = await _dataSource.createTransaction(transaction);
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String transactionId) async {
    try {
      await _dataSource.deleteTransaction(transactionId);
      return right(unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyTotal>>> getDailyTotals({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
  }) async {
    try {
      final result = await _dataSource.getDailyTotals(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        transactionTypeId: transactionTypeId,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    TransactionFilter? filter,
  }) async {
    try {
      final transactions = await _dataSource.getTransactions(
        userId: userId,
        filter: filter,
      );
      return right(transactions);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction) async {
    try {
      final result = await _dataSource.updateTransaction(transaction);
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getTransactionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _dataSource.getTransactionSummary(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<summary.TransactionSummary>>>
      getSummaryByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _dataSource.getSummaryByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> searchByTags({
    required String userId,
    required List<String> tags,
  }) async {
    try {
      final result = await _dataSource.searchByTags(
        userId: userId,
        tags: tags,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> searchByNotes({
    required String userId,
    required String searchText,
  }) async {
    try {
      final result = await _dataSource.searchByNotes(
        userId: userId,
        searchText: searchText,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> validateTransaction({
    required Transaction transaction,
    required bool isUpdate,
  }) async {
    try {
      final result = await _dataSource.validateTransaction(
        transaction: transaction,
        isUpdate: isUpdate,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BalanceHistory>>> getAccountBalanceHistory({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _dataSource.getAccountBalanceHistory(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BalanceHistory>>> getJarBalanceHistory({
    required String jarId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _dataSource.getJarBalanceHistory(
        jarId: jarId,
        startDate: startDate,
        endDate: endDate,
      );
      return right(result);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> recordBalanceHistory(
      BalanceHistory history) async {
    try {
      await _dataSource.recordBalanceHistory(history);
      return right(unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> validateAccount(String accountId) async {
    try {
      final result = await _dataSource.validateTransaction(
        transaction: Transaction(
          id: '',
          userId: '',
          transactionTypeId: '',
          categoryId: '',
          categoryName: 'Validation',
          accountId: accountId,
          amount: 0,
          currencyId: '',
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        isUpdate: false,
      );
      return result ? right(unit) : left(ValidationFailure('Invalid account'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> validateCategory({
    required String categoryId,
    String? subcategoryId,
  }) async {
    try {
      final result = await _dataSource.validateTransaction(
        transaction: Transaction(
          id: '',
          userId: '',
          transactionTypeId: '',
          categoryId: categoryId,
          categoryName: 'Validation',
          subcategoryId: subcategoryId,
          accountId: '',
          amount: 0,
          currencyId: '',
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        isUpdate: false,
      );
      return result ? right(unit) : left(ValidationFailure('Invalid category'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> validateCreditLimit({
    required String accountId,
    required double amount,
  }) async {
    try {
      final result = await _dataSource.validateTransaction(
        transaction: Transaction(
          id: '',
          userId: '',
          transactionTypeId: '',
          categoryId: '',
          categoryName: 'Validation',
          accountId: accountId,
          amount: amount,
          currencyId: '',
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        isUpdate: false,
      );
      return result
          ? right(unit)
          : left(ValidationFailure('Credit limit exceeded'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> validateCurrency(String currencyId) async {
    try {
      final result = await _dataSource.validateTransaction(
        transaction: Transaction(
          id: '',
          userId: '',
          transactionTypeId: '',
          categoryId: '',
          categoryName: 'Validation',
          accountId: '',
          amount: 0,
          currencyId: currencyId,
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        isUpdate: false,
      );
      return result ? right(unit) : left(ValidationFailure('Invalid currency'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> validateBalance(Transaction transaction) async {
    try {
      final result = await _dataSource.validateTransaction(
        transaction: transaction,
        isUpdate: false,
      );
      return result
          ? right(unit)
          : left(ValidationFailure('Insufficient balance'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> validateJarRequirement({
    String? jarId,
    String? subcategoryId,
  }) async {
    try {
      final result = await _dataSource.validateTransaction(
        transaction: Transaction(
          id: '',
          userId: '',
          transactionTypeId: '',
          categoryId: '',
          categoryName: 'Validation',
          subcategoryId: subcategoryId,
          accountId: '',
          amount: 0,
          currencyId: '',
          jarId: jarId,
          transactionDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        isUpdate: false,
      );
      return result
          ? right(unit)
          : left(ValidationFailure('Jar is required for this category'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
