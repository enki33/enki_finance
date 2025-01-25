import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/core/providers/shared_preferences_provider.dart';
import 'package:enki_finance/features/transactions/data/repositories/supabase_transaction_repository.dart';
import 'package:enki_finance/features/transactions/data/services/transaction_sync_service.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/features/transactions/domain/entities/daily_total.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_filter_provider.dart';
import 'package:enki_finance/features/transactions/domain/validators/transaction_validator.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_validator_provider.dart';

final transactionSyncServiceProvider = Provider<TransactionSyncService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return TransactionSyncService(supabase, prefs);
});

final transactionRepositoryProvider =
    Provider<SupabaseTransactionRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseTransactionRepository(supabase);
});

final filteredTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, userId) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final filter = ref.watch(transactionFilterProvider);
  final result = await repository.getTransactions(
    userId: userId,
    filter: filter,
  );
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

final transactionStreamProvider =
    StreamProvider.family<List<Transaction>, String>((ref, userId) {
  final syncService = ref.watch(transactionSyncServiceProvider);
  return syncService
      .watchTransactions(userId)
      .map((transaction) => [transaction]);
});

final dailyTotalsProvider = FutureProvider.family<
    List<DailyTotal>,
    ({
      String userId,
      DateTime startDate,
      DateTime endDate,
      String? transactionTypeId
    })>((ref, params) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final result = await repository.getDailyTotals(
    userId: params.userId,
    startDate: params.startDate,
    endDate: params.endDate,
    transactionTypeId: params.transactionTypeId,
  );
  return result.fold(
    (failure) => throw failure,
    (totals) => totals,
  );
});

class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseTransactionRepository _repository;
  final TransactionSyncService _syncService;
  final TransactionValidator _validator;

  TransactionNotifier(this._repository, this._syncService, this._validator)
      : super(const AsyncValue.data(null));

  Future<void> createTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();

    // Validate transaction
    final validationResult = await _validator.validate(transaction);
    if (validationResult.isLeft()) {
      state = AsyncValue.error(
        validationResult.fold(
          (failure) => failure,
          (_) => throw Exception('Unexpected error'),
        ),
        StackTrace.current,
      );
      return;
    }

    final result = await _repository.createTransaction(transaction);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();

    // Validate transaction
    final validationResult = await _validator.validate(transaction);
    if (validationResult.isLeft()) {
      state = AsyncValue.error(
        validationResult.fold(
          (failure) => failure,
          (_) => throw Exception('Unexpected error'),
        ),
        StackTrace.current,
      );
      return;
    }

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

  Future<void> syncTransactions(String userId) async {
    state = const AsyncValue.loading();
    final result = await _syncService.syncTransactions(userId: userId);
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final syncService = ref.watch(transactionSyncServiceProvider);
  final validator = ref.watch(transactionValidatorProvider);
  return TransactionNotifier(repository, syncService, validator);
});
