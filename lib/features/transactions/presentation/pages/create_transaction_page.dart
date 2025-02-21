import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/transaction_form.dart';

class CreateTransactionPage extends ConsumerWidget {
  final Transaction? initialTransaction;

  const CreateTransactionPage({
    Key? key,
    this.initialTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(initialTransaction == null
            ? 'Nueva Transacción'
            : 'Editar Transacción'),
        actions: [
          // Add MSI button
          if (initialTransaction == null)
            IconButton(
              icon: const Icon(Icons.payment),
              tooltip: 'Meses sin intereses',
              onPressed: () {
                Navigator.pushNamed(context, '/transactions/installment');
              },
            ),
          // Add recurring transaction button
          if (initialTransaction == null)
            IconButton(
              icon: const Icon(Icons.repeat),
              tooltip: 'Transacción recurrente',
              onPressed: () {
                Navigator.pushNamed(context, '/transactions/recurring');
              },
            ),
        ],
      ),
      body: TransactionForm(
        initialTransaction: initialTransaction,
        onSubmit: (transaction) {
          // Handle submission
          Navigator.pop(context);
        },
      ),
    );
  }
}
