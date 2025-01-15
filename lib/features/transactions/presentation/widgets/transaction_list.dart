import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class TransactionList extends ConsumerWidget {
  final String userId;

  const TransactionList({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider(userId));

    return transactionsAsync.when(
      data: (transactions) => _buildList(context, transactions),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: ${error.toString()}'),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No hay transacciones registradas'),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
    );

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isExpense = transaction.transactionTypeId == 'EXPENSE';

        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isExpense ? Colors.red : Colors.green,
              child: Icon(
                isExpense ? Icons.remove : Icons.add,
                color: Colors.white,
              ),
            ),
            title: Text(
              transaction.description ?? 'Sin descripción',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(transaction.transactionDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Text(
              currencyFormat.format(transaction.amount),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isExpense ? Colors.red : Colors.green,
                  ),
            ),
            onTap: () {
              // TODO: Navigate to transaction details
            },
          ),
        );
      },
    );
  }
}
