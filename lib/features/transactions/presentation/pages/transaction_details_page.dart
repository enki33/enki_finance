import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:enki_finance/features/transactions/presentation/widgets/transaction_form.dart';
import 'package:intl/intl.dart';

class TransactionDetailsPage extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailsPage({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Transacción'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditForm(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Amount Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: transaction.transactionTypeId == 'EXPENSE'
                              ? Colors.red
                              : Colors.green,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.transactionTypeId == 'EXPENSE'
                        ? 'Gasto'
                        : 'Ingreso',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Details List
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    context,
                    'Fecha',
                    DateFormat('dd/MM/yyyy')
                        .format(transaction.transactionDate),
                  ),
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'Descripción',
                    transaction.description ?? 'Sin descripción',
                  ),
                  if (transaction.notes != null) ...[
                    const Divider(),
                    _buildDetailRow(
                      context,
                      'Notas',
                      transaction.notes!,
                    ),
                  ],
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'Cuenta',
                    'TODO: Load account name', // TODO: Load account name
                  ),
                  if (transaction.transactionTypeId == 'EXPENSE') ...[
                    const Divider(),
                    _buildDetailRow(
                      context,
                      'Jarra',
                      'TODO: Load jar name', // TODO: Load jar name
                    ),
                  ],
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'Categoría',
                    'TODO: Load category name', // TODO: Load category name
                  ),
                  const Divider(),
                  _buildDetailRow(
                    context,
                    'Subcategoría',
                    'TODO: Load subcategory name', // TODO: Load subcategory name
                  ),
                  if (transaction.transactionMediumId != null) ...[
                    const Divider(),
                    _buildDetailRow(
                      context,
                      'Medio de Pago',
                      'TODO: Load medium name', // TODO: Load medium name
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TransactionForm(
          transaction: transaction,
          userId: transaction.userId,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Transacción'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta transacción? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final notifier = ref.read(transactionNotifierProvider.notifier);
      await notifier.deleteTransaction(transaction.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
