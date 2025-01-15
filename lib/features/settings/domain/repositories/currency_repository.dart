import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/currency.dart';

part 'currency_repository.g.dart';

abstract class CurrencyRepository {
  /// Get all available currencies
  Future<List<Currency>> getCurrencies();

  /// Get a currency by its ID
  Future<Currency?> getCurrencyById({required String id});

  /// Get the default currency for a user
  Future<Currency?> getUserDefaultCurrency({required String userId});

  /// Update a user's default currency
  Future<void> updateUserDefaultCurrency({
    required String userId,
    required String currencyId,
  });
}

@riverpod
CurrencyRepository currencyRepository(CurrencyRepositoryRef ref) {
  throw UnimplementedError('currencyRepository not implemented');
}
