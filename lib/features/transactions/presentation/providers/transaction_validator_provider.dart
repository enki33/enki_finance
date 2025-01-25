import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/validators/transaction_validator.dart';

final transactionValidatorProvider = Provider<TransactionValidator>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return TransactionValidator(supabase);
});
