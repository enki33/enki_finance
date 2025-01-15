import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/currency_repository.dart';
import 'supabase_currency_repository.dart';
import '../../../../core/providers/supabase_provider.dart';

part 'currency_repository_provider.g.dart';

@riverpod
CurrencyRepository currencyRepository(CurrencyRepositoryRef ref) {
  return SupabaseCurrencyRepository(ref.read(supabaseClientProvider));
}
