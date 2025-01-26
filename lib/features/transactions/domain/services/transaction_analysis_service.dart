import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/transaction_analysis.dart';
import '../entities/transaction_summary.dart' as summary;
import '../entities/daily_total.dart';
import '../repositories/transaction_repository.dart';
import '../exceptions/transaction_exception.dart';

class TransactionAnalysisService {
  const TransactionAnalysisService(this._repository);

  final TransactionRepository _repository;

  Future<Either<Failure, List<CategoryAnalysis>>> analyzeByCategory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
  }) async {
    try {
      final result = await _repository.analyzeByCategory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        transactionType: transactionType,
      );
      return result;
    } on TransactionException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<DailyTotals>>> getDailyTotals({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
  }) async {
    try {
      final result = await _repository.getDailyTotals(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        transactionTypeId: transactionTypeId,
      );
      return result;
    } on TransactionException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<summary.TransactionSummary>>>
      getSummaryByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _repository.getSummaryByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return result;
    } on TransactionException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Transaction>>> searchByTags({
    required String userId,
    required List<String> tags,
  }) async {
    try {
      final result = await _repository.searchByTags(
        userId: userId,
        tags: tags,
      );
      return result;
    } on TransactionException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Transaction>>> searchByNotes({
    required String userId,
    required String searchText,
  }) async {
    try {
      final result = await _repository.searchByNotes(
        userId: userId,
        searchText: searchText,
      );
      return result;
    } on TransactionException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Transaction>>> getByDateRange({
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
      final result = await _repository.getTransactionsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        transactionTypeId: transactionTypeId,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        accountId: accountId,
        jarId: jarId,
      );
      return result;
    } on TransactionException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> validateTransactionData({
    required Transaction transaction,
    required bool isUpdate,
  }) async {
    try {
      final result = await _repository.validateTransaction(
        transaction: transaction,
        isUpdate: isUpdate,
      );
      return result;
    } on TransactionException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
