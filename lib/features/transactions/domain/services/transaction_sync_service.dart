import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionSyncService {
  Future<Either<Failure, List<Transaction>>> syncTransactions({
    required String userId,
    DateTime? lastSyncTimestamp,
  });

  Future<DateTime?> getLastSyncTimestamp();
  Future<void> addPendingChange(Transaction transaction);
  Future<void> removePendingChange(String transactionId);
  Stream<Transaction> watchTransactions(String userId);
}
