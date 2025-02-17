import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_analysis.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../../domain/entities/transaction_summary.dart' as summary;
import '../../domain/entities/daily_total.dart';
import '../../domain/entities/balance_history.dart';
import '../../domain/entities/category_analysis.dart';

class SupabaseTransactionRepository implements TransactionRepository {
  final SupabaseClient supabase;
  final TransactionRemoteDataSource _remoteDataSource;

  const SupabaseTransactionRepository(this.supabase, this._remoteDataSource);

  @override
  Future<Either<Failure, Transaction>> createTransaction(
      Transaction transaction) async {
    try {
      final result = await _remoteDataSource.createTransaction(transaction);
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('foreign key constraint')) {
        return left(ValidationFailure('Invalid foreign key reference'));
      }
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
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
      final result = await _remoteDataSource.getTransactions(
        userId: userId,
        filter: filter,
      );
      return right(result);
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException details:');
      debugPrint('  Message: ${e.message}');
      debugPrint('  Code: ${e.code}');
      debugPrint('  Details: ${e.details}');
      debugPrint('  Hint: ${e.hint}');
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction) async {
    try {
      final result = await _remoteDataSource.updateTransaction(transaction);
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String transactionId) async {
    try {
      await _remoteDataSource.deleteTransaction(transactionId);
      return right(unit);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
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
      final result = await _remoteDataSource.getTransactionSummary(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
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
      final result = await _remoteDataSource.analyzeByCategory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        transactionType: transactionType,
      );
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
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
      final result = await _remoteDataSource.getDailyTotals(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        transactionTypeId: transactionTypeId,
      );
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
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
      final result = await _remoteDataSource.getSummaryByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
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
      final result = await _remoteDataSource.searchByTags(
        userId: userId,
        tags: tags,
      );
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
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
      final result = await _remoteDataSource.searchByNotes(
        userId: userId,
        searchText: searchText,
      );
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

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
      final result = await _remoteDataSource.getTransactionsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        transactionTypeId: transactionTypeId,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        accountId: accountId,
        jarId: jarId,
      );
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
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
      final result = await _remoteDataSource.validateTransaction(
        transaction: transaction,
        isUpdate: isUpdate,
      );
      return right(result);
    } on PostgrestException catch (e) {
      if (e.toString().contains('permission denied')) {
        return left(AuthorizationFailure('Permission denied'));
      }
      return left(ServerFailure(e.toString()));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> validateAccount(String accountId) async {
    final result = await _remoteDataSource.validateTransaction(
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
    return result
        ? const Right(unit)
        : Left(ValidationFailure('Invalid account'));
  }

  @override
  Future<Either<Failure, Unit>> validateBalance(Transaction transaction) async {
    final result = await _remoteDataSource.validateTransaction(
      transaction: transaction,
      isUpdate: false,
    );
    return result
        ? const Right(unit)
        : Left(ValidationFailure('Insufficient balance'));
  }

  @override
  Future<Either<Failure, Unit>> validateCategory({
    required String categoryId,
    String? subcategoryId,
  }) async {
    final result = await _remoteDataSource.validateTransaction(
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
    return result
        ? const Right(unit)
        : Left(ValidationFailure('Invalid category'));
  }

  @override
  Future<Either<Failure, Unit>> validateCreditLimit({
    required String accountId,
    required double amount,
  }) async {
    final result = await _remoteDataSource.validateTransaction(
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
        ? const Right(unit)
        : Left(ValidationFailure('Credit limit exceeded'));
  }

  @override
  Future<Either<Failure, Unit>> validateCurrency(String currencyId) async {
    final result = await _remoteDataSource.validateTransaction(
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
    return result
        ? const Right(unit)
        : Left(ValidationFailure('Invalid currency'));
  }

  @override
  Future<Either<Failure, Unit>> validateJarRequirement({
    String? jarId,
    String? subcategoryId,
  }) async {
    final result = await _remoteDataSource.validateTransaction(
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
        ? const Right(unit)
        : Left(ValidationFailure('Jar is required for this category'));
  }

  @override
  Future<Either<Failure, List<BalanceHistory>>> getAccountBalanceHistory({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _remoteDataSource.getAccountBalanceHistory(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BalanceHistory>>> getJarBalanceHistory({
    required String jarId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _remoteDataSource.getJarBalanceHistory(
        jarId: jarId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> calculateAccountBalance({
    required String accountId,
    DateTime? asOf,
  }) async {
    try {
      final result = await _remoteDataSource.calculateAccountBalance(
        accountId: accountId,
        asOf: asOf,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> calculateJarBalance({
    required String jarId,
    DateTime? asOf,
  }) async {
    try {
      final result = await _remoteDataSource.calculateJarBalance(
        jarId: jarId,
        asOf: asOf,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> recordBalanceHistory(
      BalanceHistory history) async {
    try {
      await _remoteDataSource.recordBalanceHistory(history);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
