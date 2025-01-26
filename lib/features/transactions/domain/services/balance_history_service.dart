import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/balance_history.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Service for managing balance history and calculations
class BalanceHistoryService {
  final TransactionRepository repository;

  BalanceHistoryService(this.repository);

  /// Gets the balance history for an account
  Future<Either<Failure, List<BalanceHistory>>> getAccountHistory({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await repository.getAccountBalanceHistory(
        accountId: accountId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Gets the balance history for a jar
  Future<Either<Failure, List<BalanceHistory>>> getJarHistory({
    required String jarId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await repository.getJarBalanceHistory(
        jarId: jarId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Calculates the current balance for an account based on its history
  Future<Either<Failure, double>> calculateAccountBalance({
    required String accountId,
    DateTime? asOf,
  }) async {
    try {
      return await repository.calculateAccountBalance(
        accountId: accountId,
        asOf: asOf,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Calculates the current balance for a jar based on its history
  Future<Either<Failure, double>> calculateJarBalance({
    required String jarId,
    DateTime? asOf,
  }) async {
    try {
      return await repository.calculateJarBalance(
        jarId: jarId,
        asOf: asOf,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Records a balance change for a transaction
  Future<Either<Failure, Unit>> recordTransactionBalanceChange({
    required Transaction transaction,
    required double oldBalance,
    required double newBalance,
  }) async {
    try {
      final balanceHistory = BalanceHistory(
        id: '',
        userId: transaction.userId,
        accountId: transaction.accountId,
        jarId: transaction.jarId,
        oldBalance: oldBalance,
        newBalance: newBalance,
        changeAmount: transaction.amount,
        changeType: BalanceChangeType.transaction.name,
        referenceType: BalanceReferenceType.transaction.name,
        referenceId: transaction.id,
        createdAt: DateTime.now(),
      );

      return await repository.recordBalanceHistory(balanceHistory);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Records a balance change for a transfer
  Future<Either<Failure, Unit>> recordTransferBalanceChange({
    required String userId,
    required String transferId,
    String? fromAccountId,
    String? toAccountId,
    String? fromJarId,
    String? toJarId,
    required double amount,
    double? exchangeRate,
    required double fromOldBalance,
    required double fromNewBalance,
    required double toOldBalance,
    required double toNewBalance,
  }) async {
    try {
      // Record source balance change
      final sourceHistory = BalanceHistory(
        id: '',
        userId: userId,
        accountId: fromAccountId,
        jarId: fromJarId,
        oldBalance: fromOldBalance,
        newBalance: fromNewBalance,
        changeAmount: -amount,
        changeType: BalanceChangeType.transfer.name,
        referenceType: BalanceReferenceType.transfer.name,
        referenceId: transferId,
        createdAt: DateTime.now(),
      );

      final sourceResult = await repository.recordBalanceHistory(sourceHistory);
      if (sourceResult.isLeft()) {
        return sourceResult;
      }

      // Record destination balance change
      final destinationHistory = BalanceHistory(
        id: '',
        userId: userId,
        accountId: toAccountId,
        jarId: toJarId,
        oldBalance: toOldBalance,
        newBalance: toNewBalance,
        changeAmount: amount * (exchangeRate ?? 1),
        changeType: BalanceChangeType.transfer.name,
        referenceType: BalanceReferenceType.transfer.name,
        referenceId: transferId,
        createdAt: DateTime.now(),
      );

      return await repository.recordBalanceHistory(destinationHistory);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Records a balance adjustment
  Future<Either<Failure, Unit>> recordBalanceAdjustment({
    required String userId,
    String? accountId,
    String? jarId,
    required double oldBalance,
    required double newBalance,
    required String adjustmentId,
  }) async {
    try {
      final balanceHistory = BalanceHistory(
        id: '',
        userId: userId,
        accountId: accountId,
        jarId: jarId,
        oldBalance: oldBalance,
        newBalance: newBalance,
        changeAmount: newBalance - oldBalance,
        changeType: BalanceChangeType.adjustment.name,
        referenceType: BalanceReferenceType.adjustment.name,
        referenceId: adjustmentId,
        createdAt: DateTime.now(),
      );

      return await repository.recordBalanceHistory(balanceHistory);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
