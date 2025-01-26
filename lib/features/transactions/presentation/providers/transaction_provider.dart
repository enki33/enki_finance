import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:enki_finance/core/error/failures.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/core/providers/shared_preferences_provider.dart';
import 'package:enki_finance/features/transactions/data/repositories/supabase_transaction_repository.dart';
import 'package:enki_finance/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:enki_finance/features/transactions/data/services/transaction_sync_service_impl.dart';
import 'package:enki_finance/features/transactions/domain/services/transaction_sync_service.dart';
import 'package:enki_finance/features/transactions/domain/services/transaction_analysis_service.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/features/transactions/domain/entities/daily_total.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction_filter.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction_analysis.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction_summary.dart'
    as summary;
import 'package:enki_finance/features/transactions/domain/usecases/analyze_transactions_by_category.dart';
import 'package:enki_finance/features/transactions/domain/usecases/get_daily_totals.dart';
import 'package:enki_finance/features/transactions/domain/usecases/get_transaction_summary_by_date_range.dart';
import 'package:enki_finance/features/transactions/domain/usecases/search_transactions_by_notes.dart';
import 'package:enki_finance/features/transactions/domain/usecases/search_transactions_by_tags.dart';
import 'package:enki_finance/features/transactions/domain/usecases/get_transactions_by_date_range.dart';
import 'package:enki_finance/features/transactions/domain/usecases/validate_transaction.dart';
import 'package:enki_finance/features/transactions/domain/validators/transaction_validator.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_filter_provider.dart'
    as filter;

// Data Source Provider
final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>((ref) {
  return TransactionRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
});

// Repository Providers
final transactionRepositoryProvider =
    Provider<SupabaseTransactionRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = TransactionRemoteDataSourceImpl(supabase);
  return SupabaseTransactionRepository(supabase, remoteDataSource);
});

// Use Case Providers
final analyzeTransactionsByCategoryProvider =
    Provider<AnalyzeTransactionsByCategory>((ref) {
  return AnalyzeTransactionsByCategory(
      ref.watch(transactionRepositoryProvider));
});

final getDailyTotalsProvider = Provider<GetDailyTotals>((ref) {
  return GetDailyTotals(ref.watch(transactionRepositoryProvider));
});

final getTransactionSummaryByDateRangeProvider =
    Provider<GetTransactionSummaryByDateRange>((ref) {
  return GetTransactionSummaryByDateRange(
      ref.watch(transactionRepositoryProvider));
});

final searchTransactionsByTagsProvider =
    Provider<SearchTransactionsByTags>((ref) {
  return SearchTransactionsByTags(ref.watch(transactionRepositoryProvider));
});

final searchTransactionsByNotesProvider =
    Provider<SearchTransactionsByNotes>((ref) {
  return SearchTransactionsByNotes(ref.watch(transactionRepositoryProvider));
});

final getTransactionsByDateRangeProvider =
    Provider<GetTransactionsByDateRange>((ref) {
  return GetTransactionsByDateRange(ref.watch(transactionRepositoryProvider));
});

final validateTransactionProvider = Provider<ValidateTransaction>((ref) {
  return ValidateTransaction(ref.watch(transactionRepositoryProvider));
});

// Service Providers
final transactionSyncServiceProvider = Provider<TransactionSyncService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return TransactionSyncServiceImpl(supabase, prefs);
});

final transactionAnalysisServiceProvider =
    Provider<TransactionAnalysisService>((ref) {
  return TransactionAnalysisService(ref.watch(transactionRepositoryProvider));
});

// Validator Provider
final transactionValidatorProvider = Provider<TransactionValidator>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionValidator(repository);
});

// UI State Providers
final filteredTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, userId) async {
  final analysisService = ref.watch(transactionAnalysisServiceProvider);
  final transactionFilter = ref.watch(filter.transactionFilterProvider);

  final result = await analysisService.getByDateRange(
    userId: userId,
    startDate: transactionFilter.startDate ?? DateTime.now(),
    endDate: transactionFilter.endDate ?? DateTime.now(),
    transactionTypeId: transactionFilter.transactionTypeId,
    categoryId: transactionFilter.categoryId,
    subcategoryId: transactionFilter.subcategoryId,
    jarId: transactionFilter.jarId,
    accountId: transactionFilter.accountId,
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
  final analysisService = ref.watch(transactionAnalysisServiceProvider);
  final result = await analysisService.getDailyTotals(
    userId: params.userId,
    startDate: params.startDate,
    endDate: params.endDate,
    transactionTypeId: params.transactionTypeId,
  );
  return result.fold(
    (failure) => throw failure,
    (totals) => totals
        .map((t) => DailyTotal(
              date: t.transactionDate,
              amount: t.totalAmount,
              count: t.transactionCount,
            ))
        .toList(),
  );
});

// State Notifier
class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseTransactionRepository _repository;
  final TransactionSyncService _syncService;
  final TransactionValidator _validator;

  TransactionNotifier(this._repository, this._syncService, this._validator)
      : super(const AsyncValue.data(null));

  Future<void> createTransaction(Transaction transaction) async {
    state = const AsyncValue.loading();
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
