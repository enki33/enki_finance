import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/currency.dart';
import '../../domain/repositories/currency_repository.dart';

class SupabaseCurrencyRepository implements CurrencyRepository {
  const SupabaseCurrencyRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Currency>> getCurrencies() async {
    try {
      final response = await _client
          .from('enki_finance.currency')
          .select('id, code, name, symbol, is_active')
          .eq('is_active', true)
          .order('code');

      debugPrint('Currencies response: $response');
      return (response as List<dynamic>)
          .map((json) => Currency.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting currencies: $e');
      if (e is PostgrestException) {
        debugPrint('PostgreSQL Error Details:');
        debugPrint('  Message: ${e.message}');
        debugPrint('  Code: ${e.code}');
        debugPrint('  Details: ${e.details}');
        debugPrint('  Hint: ${e.hint}');
      }
      rethrow;
    }
  }

  @override
  Future<Currency?> getCurrencyById({required String id}) async {
    try {
      final response = await _client
          .from('enki_finance.currency')
          .select()
          .eq('id', id)
          .single();

      return response == null ? null : Currency.fromJson(response);
    } catch (e) {
      debugPrint('Error getting currency by ID: $e');
      rethrow;
    }
  }

  @override
  Future<Currency?> getUserDefaultCurrency({required String userId}) async {
    try {
      final response = await _client
          .from('enki_finance.app_user')
          .select(
              'default_currency_id, currency:default_currency_id(id, code, name, symbol, is_active)')
          .eq('id', userId)
          .single();

      debugPrint('User default currency response: $response');
      return response == null || response['currency'] == null
          ? null
          : Currency.fromJson(response['currency']);
    } catch (e) {
      debugPrint('Error getting user default currency: $e');
      if (e is PostgrestException) {
        debugPrint('PostgreSQL Error Details:');
        debugPrint('  Message: ${e.message}');
        debugPrint('  Code: ${e.code}');
        debugPrint('  Details: ${e.details}');
        debugPrint('  Hint: ${e.hint}');
      }
      rethrow;
    }
  }

  @override
  Future<void> updateUserDefaultCurrency({
    required String userId,
    required String currencyId,
  }) async {
    try {
      await _client
          .from('enki_finance.app_user')
          .update({'default_currency_id': currencyId}).eq('id', userId);
    } catch (e) {
      debugPrint('Error updating user default currency: $e');
      if (e is PostgrestException) {
        debugPrint('PostgreSQL Error Details:');
        debugPrint('  Message: ${e.message}');
        debugPrint('  Code: ${e.code}');
        debugPrint('  Details: ${e.details}');
        debugPrint('  Hint: ${e.hint}');
      }
      rethrow;
    }
  }
}
