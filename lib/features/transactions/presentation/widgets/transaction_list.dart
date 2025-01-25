import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_filter_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionList extends ConsumerWidget {
  final String userId;
  final TransactionFilter filter;
  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
  );

  const TransactionList({
    super.key,
    required this.userId,
    required this.filter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(filteredTransactionsProvider(userId));

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

    return ListView.builder(
      itemCount: transactions.length,
      addAutomaticKeepAlives: true,
      cacheExtent: 100,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _TransactionTile(
          key: ValueKey(transaction.id),
          transaction: transaction,
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
  );

  const _TransactionTile({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          _dateFormat.format(transaction.transactionDate),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          _currencyFormat.format(transaction.amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isExpense ? Colors.red : Colors.green,
              ),
        ),
        onTap: () {
          context.pushNamed(
            'transaction-details',
            extra: transaction,
          );
        },
      ),
    );
  }
}
