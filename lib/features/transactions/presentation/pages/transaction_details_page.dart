import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:enki_finance/features/transactions/presentation/widgets/transaction_form.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
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

    final transactionTypesAsync = ref.watch(transactionTypesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final subcategoriesAsync =
        ref.watch(subcategoriesProvider(transaction.categoryId));
    final jarsAsync = ref.watch(jarsProvider);
    final accountsAsync = ref.watch(accountsProvider);

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
                  transactionTypesAsync.when(
                    data: (types) => Text(
                      types.entries
                          .firstWhere(
                            (e) => e.value == transaction.transactionTypeId,
                            orElse: () => const MapEntry('', ''),
                          )
                          .key,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
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
                  accountsAsync.when(
                    data: (accounts) => _buildDetailRow(
                      context,
                      'Cuenta',
                      accounts.firstWhere(
                        (a) => a['id'] == transaction.accountId,
                        orElse: () => {'name': 'No encontrada'},
                      )['name'] as String,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                  if (transaction.transactionTypeId == 'EXPENSE') ...[
                    const Divider(),
                    jarsAsync.when(
                      data: (jars) => _buildDetailRow(
                        context,
                        'Jarra',
                        jars.firstWhere(
                          (j) => j['id'] == transaction.jarId,
                          orElse: () => {'name': 'No encontrada'},
                        )['name'] as String,
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error: $error'),
                    ),
                  ],
                  const Divider(),
                  categoriesAsync.when(
                    data: (categories) => _buildDetailRow(
                      context,
                      'Categoría',
                      categories
                          .firstWhere(
                            (c) => c.id == transaction.categoryId,
                            orElse: () => Category(
                              id: '',
                              name: 'No encontrada',
                              transactionTypeId: '',
                              createdAt: DateTime.now(),
                            ),
                          )
                          .name,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                  const Divider(),
                  subcategoriesAsync.when(
                    data: (subcategories) => _buildDetailRow(
                      context,
                      'Subcategoría',
                      subcategories
                          .firstWhere(
                            (s) => s.id == transaction.subcategoryId,
                            orElse: () => Subcategory(
                              id: '',
                              name: 'No encontrada',
                              categoryId: '',
                              jarId: null,
                              createdAt: DateTime.now(),
                            ),
                          )
                          .name,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  ),
                  if (transaction.transactionMediumId != null) ...[
                    const Divider(),
                    _buildDetailRow(
                      context,
                      'Medio de Pago',
                      'TODO: Load medium name', // TODO: Add transaction mediums provider
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
