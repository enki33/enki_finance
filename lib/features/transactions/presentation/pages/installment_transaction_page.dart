import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/installment_purchase.dart';
import '../providers/transaction_provider.dart';

class InstallmentTransactionPage extends ConsumerStatefulWidget {
  const InstallmentTransactionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InstallmentTransactionPage> createState() =>
      _InstallmentTransactionPageState();
}

class _InstallmentTransactionPageState
    extends ConsumerState<InstallmentTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedTransactionType;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedAccount;
  String? _selectedCurrency;
  int _installments = 3; // Default number of installments
  DateTime _startDate = DateTime.now();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final transactionTypesAsync = ref.watch(transactionTypesProvider);
    final categoriesAsync =
        ref.watch(categoriesProvider(ref.read(currentUserIdProvider)));
    final accountsAsync = ref.watch(accountsProvider);
    final isSubmitting = ref.watch(transactionNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compra en Meses sin Intereses'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monto Total',
                prefixText: '\$',
                helperText: 'Ingresa el monto total de la compra',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) => ref
                  .read(amountValidatorProvider)
                  .validatePositiveAmount(value)
                  .fold(
                    (failure) => failure.message,
                    (_) => null,
                  ),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // Number of installments
            DropdownButtonFormField<int>(
              value: _installments,
              decoration: const InputDecoration(
                labelText: 'Número de Meses',
                helperText: 'Selecciona el número de meses sin intereses',
              ),
              items: [3, 6, 9, 12, 18, 24].map((months) {
                return DropdownMenuItem(
                  value: months,
                  child: Text('$months meses'),
                );
              }).toList(),
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _installments = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Start Date
            ListTile(
              title: const Text('Fecha de inicio'),
              subtitle: Text(
                DateFormat('dd/MM/yyyy').format(_startDate),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: isSubmitting
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Account
            accountsAsync.when(
              data: (accounts) => DropdownButtonFormField<String>(
                value: _selectedAccount,
                decoration: const InputDecoration(
                  labelText: 'Cuenta',
                  helperText: 'Selecciona la cuenta',
                ),
                items: accounts
                    .where((account) =>
                        account['type'] == 'CREDIT_CARD') // Only credit cards
                    .map((account) {
                  return DropdownMenuItem(
                    value: account['id'] as String,
                    child: Text(account['name'] as String),
                  );
                }).toList(),
                validator: (value) =>
                    _validateRequiredField(value, 'una cuenta'),
                onChanged: isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _selectedAccount = value;
                        });
                      },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                helperText: 'Describe la compra',
              ),
              validator: (value) =>
                  _validateRequiredField(value, 'una descripción'),
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas',
                helperText: 'Agrega notas adicionales (opcional)',
              ),
              maxLines: 3,
              enabled: !isSubmitting,
            ),
            const SizedBox(height: 24),

            // Submit Button
            FilledButton.icon(
              onPressed: isSubmitting ? null : _submit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text('Crear Compra en MSI'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa $fieldName';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final amount = double.parse(_amountController.text);
        final installmentAmount = amount / _installments;

        final installmentPurchase = InstallmentPurchase(
          id: '',
          userId: ref.read(currentUserIdProvider),
          totalAmount: amount,
          installmentAmount: installmentAmount,
          numberOfInstallments: _installments,
          remainingInstallments: _installments,
          startDate: _startDate,
          description: _descriptionController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          accountId: _selectedAccount!,
          status: 'ACTIVE',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final notifier = ref.read(transactionNotifierProvider.notifier);
        await notifier.createInstallmentPurchase(installmentPurchase);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compra en MSI creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        setState(() {
          if (e is ValidationFailure) {
            _errorMessage = e.message;
          } else if (e is ServerFailure) {
            _errorMessage = 'Error del servidor: ${e.message}';
          } else {
            _errorMessage = e.toString();
          }
        });
      }
    }
  }
}
