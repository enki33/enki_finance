import 'package:enki_finance/features/account/data/datasources/account_remote_data_source.dart';
import 'package:enki_finance/features/account/data/repositories/account_repository_impl.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/domain/entities/credit_card_details.dart';
import 'package:enki_finance/features/account/domain/repositories/account_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import '../../domain/services/account_service.dart';
import '../../domain/services/account_service_provider.dart';

part 'account_providers.g.dart';

@riverpod
AccountRepository accountRepository(AccountRepositoryRef ref) {
  final supabase = Supabase.instance.client;
  final remoteDataSource = AccountRemoteDataSourceImpl(supabase: supabase);
  return AccountRepositoryImpl(remoteDataSource: remoteDataSource);
}

@riverpod
Future<List<Account>> accounts(AccountsRef ref) async {
  final result = await ref.watch(accountServiceProvider).getAccounts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (accounts) => accounts,
  );
}

@riverpod
Future<Account> account(AccountRef ref, String id) async {
  final result = await ref.watch(accountServiceProvider).getAccountById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (account) => account,
  );
}

@riverpod
Future<CreditCardDetails> creditCardDetails(
    CreditCardDetailsRef ref, String accountId) async {
  final result =
      await ref.watch(accountServiceProvider).getCreditCardDetails(accountId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (details) => details,
  );
}

@riverpod
class AccountNotifier extends _$AccountNotifier {
  @override
  Future<List<Account>> build() async {
    return ref.watch(accountsProvider.future);
  }

  Future<void> createAccount(Account account) async {
    final result =
        await ref.read(accountServiceProvider).createAccount(account);
    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        throw Exception(failure.message);
      },
      (newAccount) {
        final future = state.value ?? [];
        state = AsyncValue.data([...future, newAccount]);
      },
    );
  }

  Future<void> updateAccount(Account account) async {
    final result =
        await ref.read(accountServiceProvider).updateAccount(account);
    result.fold(
      (failure) => throw Exception(failure.message),
      (updatedAccount) async {
        final currentAccounts = await future;
        state = AsyncValue.data(
          currentAccounts
              .map((a) => a.id == account.id ? updatedAccount : a)
              .toList(),
        );
      },
    );
  }

  Future<void> deleteAccount(String id) async {
    final result = await ref.read(accountServiceProvider).deleteAccount(id);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) async {
        final currentAccounts = await future;
        state = AsyncValue.data(
          currentAccounts.where((a) => a.id != id).toList(),
        );
      },
    );
  }
}

@riverpod
class CreditCardNotifier extends _$CreditCardNotifier {
  @override
  Future<CreditCardDetails?> build(String accountId) async {
    try {
      return await ref.watch(creditCardDetailsProvider(accountId).future);
    } catch (e) {
      return null;
    }
  }

  Future<void> createCreditCardDetails(CreditCardDetails details) async {
    final result =
        await ref.read(accountServiceProvider).createCreditCardDetails(details);
    result.fold(
      (failure) => throw Exception(failure.message),
      (newDetails) {
        state = AsyncValue.data(newDetails);
      },
    );
  }

  Future<void> updateCreditCardDetails(CreditCardDetails details) async {
    final result =
        await ref.read(accountServiceProvider).updateCreditCardDetails(details);
    result.fold(
      (failure) => throw Exception(failure.message),
      (updatedDetails) {
        state = AsyncValue.data(updatedDetails);
      },
    );
  }

  Future<void> deleteCreditCardDetails() async {
    final currentDetails = state.value;
    if (currentDetails == null) return;

    final result = await ref
        .read(accountServiceProvider)
        .deleteCreditCardDetails(currentDetails.id!);
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {
        state = const AsyncValue.data(null);
      },
    );
  }
}

@riverpod
Future<Map<String, String>> accountTypes(AccountTypesRef ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase
      .from('account_type')
      .select('id, name')
      .eq('is_active', true)
      .order('name');

  return Map.fromEntries(
    (response as List<dynamic>).map(
      (type) => MapEntry(
        type['name'] as String,
        type['id'] as String,
      ),
    ),
  );
}

@riverpod
Future<Map<String, String>> currencies(CurrenciesRef ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase
      .from('currency')
      .select('id, name, code')
      .eq('is_active', true)
      .order('code');

  return Map.fromEntries(
    (response as List<dynamic>).map(
      (currency) => MapEntry(
        '${currency['name']} (${currency['code']})',
        currency['id'] as String,
      ),
    ),
  );
}

const itemsPerPage = 10;

// Search and filter providers
final accountSearchQueryProvider = StateProvider<String>((ref) => '');
final showActiveAccountsProvider = StateProvider<bool>((ref) => true);

// Pagination providers
final accountPageProvider = StateProvider<int>((ref) => 1);
final accountTotalPagesProvider = StateProvider<int>((ref) => 1);

// Loading states
final isSavingProvider = StateProvider<bool>((ref) => false);
final isDeletingProvider = StateProvider<bool>((ref) => false);

// Accounts provider with search, filter and pagination
final filteredAccountsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    debugPrint('Fetching accounts...');
    final client = ref.read(supabaseClientProvider);
    final showActiveItems = ref.watch(showActiveAccountsProvider);
    final searchQuery = ref.watch(accountSearchQueryProvider).toLowerCase();
    final page = ref.watch(accountPageProvider);
    const itemsPerPage = 10;

    final response = await client.from('account').select().order('name');

    debugPrint('Raw response: $response');
    final accountsList = response as List<dynamic>;
    debugPrint('Found ${accountsList.length} accounts');

    if (accountsList.isEmpty) {
      ref.read(accountTotalPagesProvider.notifier).state = 1;
      return [];
    }

    var filteredAccounts =
        accountsList.map((json) => json as Map<String, dynamic>).toList();

    // Apply active items filter
    filteredAccounts = filteredAccounts.where((account) {
      final isActive = account['is_active'] as bool?;
      return (isActive ?? true) == showActiveItems;
    }).toList();
    debugPrint('After active filter: ${filteredAccounts.length} accounts');

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredAccounts = filteredAccounts.where((account) {
        return account['name'].toString().toLowerCase().contains(searchQuery) ||
            (account['description']
                    ?.toString()
                    .toLowerCase()
                    .contains(searchQuery) ??
                false);
      }).toList();
      debugPrint('After search filter: ${filteredAccounts.length} accounts');
    }

    // If no accounts after filtering, return empty list
    if (filteredAccounts.isEmpty) {
      ref.read(accountTotalPagesProvider.notifier).state = 1;
      return [];
    }

    // Calculate total pages
    final totalItems = filteredAccounts.length;
    final totalPages = (totalItems / itemsPerPage).ceil();
    ref.read(accountTotalPagesProvider.notifier).state = totalPages;

    // Apply pagination
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    // Handle case where startIndex is beyond list bounds
    if (startIndex >= totalItems) {
      ref.read(accountPageProvider.notifier).state = 1;
      return filteredAccounts.sublist(0, itemsPerPage.clamp(0, totalItems));
    }

    return filteredAccounts.sublist(
      startIndex,
      endIndex > totalItems ? totalItems : endIndex,
    );
  } catch (e, stack) {
    debugPrint('Error fetching accounts: $e');
    debugPrint('Stack trace: $stack');
    throw e;
  }
});
