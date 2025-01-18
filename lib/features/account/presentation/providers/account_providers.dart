import 'package:enki_finance/features/account/data/datasources/account_remote_data_source.dart';
import 'package:enki_finance/features/account/data/repositories/account_repository_impl.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/domain/entities/credit_card_details.dart';
import 'package:enki_finance/features/account/domain/repositories/account_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'account_providers.g.dart';

@riverpod
AccountRepository accountRepository(AccountRepositoryRef ref) {
  final supabase = Supabase.instance.client;
  final remoteDataSource = AccountRemoteDataSourceImpl(supabase: supabase);
  return AccountRepositoryImpl(remoteDataSource: remoteDataSource);
}

@riverpod
Future<List<Account>> accounts(AccountsRef ref) async {
  final repository = ref.watch(accountRepositoryProvider);
  final result = await repository.getAccounts();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (accounts) => accounts,
  );
}

@riverpod
Future<Account> account(AccountRef ref, String id) async {
  final repository = ref.watch(accountRepositoryProvider);
  final result = await repository.getAccountById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (account) => account,
  );
}

@riverpod
Future<CreditCardDetails> creditCardDetails(
    CreditCardDetailsRef ref, String accountId) async {
  final repository = ref.watch(accountRepositoryProvider);
  final result = await repository.getCreditCardDetails(accountId);
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
    final repository = ref.read(accountRepositoryProvider);
    final result = await repository.createAccount(account);
    result.fold((failure) {
      state = AsyncValue.error(failure.message, StackTrace.current);
      throw Exception(failure.message);
    }, (newAccount) {
      final future = state.value ?? [];
      state = AsyncValue.data([...future, newAccount]);
    });
  }

  Future<void> updateAccount(Account account) async {
    final repository = ref.read(accountRepositoryProvider);
    final result = await repository.updateAccount(account);
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
    final repository = ref.read(accountRepositoryProvider);
    final result = await repository.deleteAccount(id);
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
    final repository = ref.read(accountRepositoryProvider);
    final result = await repository.createCreditCardDetails(details);
    result.fold(
      (failure) => throw Exception(failure.message),
      (newDetails) {
        state = AsyncValue.data(newDetails);
      },
    );
  }

  Future<void> updateCreditCardDetails(CreditCardDetails details) async {
    final repository = ref.read(accountRepositoryProvider);
    final result = await repository.updateCreditCardDetails(details);
    result.fold(
      (failure) => throw Exception(failure.message),
      (updatedDetails) {
        state = AsyncValue.data(updatedDetails);
      },
    );
  }

  Future<void> deleteCreditCardDetails() async {
    final repository = ref.read(accountRepositoryProvider);
    final currentDetails = state.value;
    if (currentDetails == null) return;

    final result = await repository.deleteCreditCardDetails(currentDetails.id!);
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
  final supabase = Supabase.instance.client;
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
  final supabase = Supabase.instance.client;
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
