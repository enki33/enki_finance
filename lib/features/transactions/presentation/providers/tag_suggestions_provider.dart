import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/transaction_repository.dart';

final tagSuggestionsProvider =
    FutureProvider.family<List<String>, String>((ref, userId) async {
  final repository = ref.watch(transactionRepositoryProvider);

  // Get recent transactions
  final transactions = await repository.getTransactions(
    TransactionFilter(
      userId: userId,
      limit: 100,
      orderBy: 'transaction_date',
      orderDirection: 'desc',
    ),
  );

  // Extract unique tags
  final tags = transactions.expand((t) => t.tags ?? []).toSet().toList();

  return tags;
});
