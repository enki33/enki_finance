import '../entities/transaction.dart';
import '../entities/transaction_filter.dart';
import '../entities/installment_purchase.dart';
import '../entities/recurring_transaction.dart';

abstract class ITransactionRepository {
  Future<List<Transaction>> getTransactions(TransactionFilter filter);
  Future<Transaction> createTransaction(Transaction transaction);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<Transaction> getTransactionById(String id);

  // MSI methods
  Future<InstallmentPurchase> createInstallmentPurchase(
      InstallmentPurchase purchase);
  Future<List<InstallmentPurchase>> getInstallmentPurchases(String userId);
  Future<void> updateInstallmentPurchase(InstallmentPurchase purchase);

  // Recurring transaction methods
  Future<RecurringTransaction> createRecurringTransaction(
      RecurringTransaction transaction);
  Future<List<RecurringTransaction>> getRecurringTransactions(String userId);
  Future<void> updateRecurringTransaction(RecurringTransaction transaction);
}
