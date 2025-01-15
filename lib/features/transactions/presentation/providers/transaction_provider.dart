import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/features/transactions/data/repositories/supabase_transaction_repository.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';

final transactionRepositoryProvider =
    Provider<SupabaseTransactionRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseTransactionRepository(supabase);
});

final transactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, userId) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final result = await repository.getTransactions(userId: userId);
  return result.fold(
    (failure) => throw failure,
    (transactions) => transactions,
  );
});

final transactionSummaryProvider = FutureProvider.family<
    Map<String, double>,
    ({
      String userId,
      DateTime startDate,
      DateTime endDate
    })>((ref, params) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final result = await repository.getTransactionSummary(
    userId: params.userId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
  return result.fold(
    (failure) => throw failure,
    (summary) => summary,
  );
});

class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseTransactionRepository _repository;

  TransactionNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    final result = await _repository.createTransaction(transaction);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
    final result = await _repository.updateTransaction(transaction);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> deleteTransaction(String transactionId) async {
    state = const AsyncValue.loading();
    final result = await _repository.deleteTransaction(transactionId);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});
