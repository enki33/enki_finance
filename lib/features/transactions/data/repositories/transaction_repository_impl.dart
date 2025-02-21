import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_filter.dart';
import '../../domain/entities/installment_purchase.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../../domain/exceptions/transaction_exception.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  const TransactionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Transaction>> getTransactions(TransactionFilter filter) async {
    try {
      final transactions = await _remoteDataSource.getTransactions(
        userId: filter.userId,
        filter: filter,
      );
      return transactions;
    } catch (e) {
      throw TransactionException('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final result = await _remoteDataSource.createTransaction(transaction);
      return result;
    } catch (e) {
      throw TransactionCreationException('Failed to create transaction: $e');
    }
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final result = await _remoteDataSource.updateTransaction(transaction);
      return result;
    } catch (e) {
      throw TransactionUpdateException('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _remoteDataSource.deleteTransaction(id);
    } catch (e) {
      throw TransactionDeletionException('Failed to delete transaction: $e');
    }
  }

  @override
  Future<Transaction> getTransactionById(String id) async {
    try {
      final transactions = await _remoteDataSource.getTransactions(
        userId: '', // We'll filter by ID in the query
        filter: TransactionFilter(
          transactionId: id,
        ),
      );
      if (transactions.isEmpty) {
        throw TransactionException('Transaction not found');
      }
      return transactions.first;
    } catch (e) {
      throw TransactionException('Failed to fetch transaction: $e');
    }
  }

  @override
  Future<InstallmentPurchase> createInstallmentPurchase(
      InstallmentPurchase purchase) async {
    try {
      // Create the installment purchase record
      final createdPurchase =
          await _remoteDataSource.createInstallmentPurchase(purchase);

      // Create the initial transaction
      final initialTransaction = Transaction(
        id: '',
        userId: createdPurchase.userId,
        transactionTypeId: 'EXPENSE', // Assuming it's always an expense
        categoryId: 'INSTALLMENT_PURCHASE', // Special category for installments
        categoryName: 'Compra en MSI',
        accountId: createdPurchase.accountId,
        amount: createdPurchase.installmentAmount,
        currencyId: 'MXN', // Default to MXN, could be parameterized
        transactionDate: createdPurchase.startDate,
        description:
            '${createdPurchase.description} (1/${createdPurchase.numberOfInstallments} MSI)',
        notes: createdPurchase.notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _remoteDataSource.createTransaction(initialTransaction);

      return createdPurchase;
    } catch (e) {
      throw TransactionException('Failed to create installment purchase: $e');
    }
  }

  @override
  Future<List<InstallmentPurchase>> getInstallmentPurchases(
      String userId) async {
    try {
      return await _remoteDataSource.getInstallmentPurchases(userId);
    } catch (e) {
      throw TransactionException('Failed to fetch installment purchases: $e');
    }
  }

  @override
  Future<void> updateInstallmentPurchase(InstallmentPurchase purchase) async {
    try {
      await _remoteDataSource.updateInstallmentPurchase(purchase);
    } catch (e) {
      throw TransactionException('Failed to update installment purchase: $e');
    }
  }

  @override
  Future<RecurringTransaction> createRecurringTransaction(
      RecurringTransaction transaction) async {
    try {
      // Create the recurring transaction record
      final createdTransaction =
          await _remoteDataSource.createRecurringTransaction(transaction);

      // Create the first occurrence if the start date is today
      if (transaction.startDate.isAtSameMomentAs(DateTime.now())) {
        final initialTransaction = Transaction(
          id: '',
          userId: createdTransaction.userId,
          transactionTypeId: createdTransaction.transactionTypeId,
          categoryId: createdTransaction.categoryId,
          categoryName: createdTransaction.name,
          subcategoryId: createdTransaction.subcategoryId,
          accountId: createdTransaction.accountId,
          jarId: createdTransaction.jarId,
          amount: createdTransaction.amount,
          currencyId: createdTransaction.currencyId,
          transactionDate: createdTransaction.startDate,
          description:
              createdTransaction.description ?? createdTransaction.name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _remoteDataSource.createTransaction(initialTransaction);
      }

      return createdTransaction;
    } catch (e) {
      throw TransactionException('Failed to create recurring transaction: $e');
    }
  }

  @override
  Future<List<RecurringTransaction>> getRecurringTransactions(
      String userId) async {
    try {
      return await _remoteDataSource.getRecurringTransactions(userId);
    } catch (e) {
      throw TransactionException('Failed to fetch recurring transactions: $e');
    }
  }

  @override
  Future<void> updateRecurringTransaction(
      RecurringTransaction transaction) async {
    try {
      await _remoteDataSource.updateRecurringTransaction(transaction);
    } catch (e) {
      throw TransactionException('Failed to update recurring transaction: $e');
    }
  }
}
