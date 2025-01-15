import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:enki_finance/core/utils/form_validators.dart';

class TransactionForm extends ConsumerStatefulWidget {
  final Transaction? transaction;
  final String userId;

  const TransactionForm({
    super.key,
    this.transaction,
    required this.userId,
  });

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _transactionDate;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  String? _selectedTransactionType;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedAccount;
  String? _selectedJar;
  String? _selectedMedium;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _transactionDate = widget.transaction?.transactionDate ?? DateTime.now();
    _descriptionController =
        TextEditingController(text: widget.transaction?.description);
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString(),
    );
    _selectedTransactionType = widget.transaction?.transactionTypeId;
    _selectedCategory = widget.transaction?.categoryId;
    _selectedSubcategory = widget.transaction?.subcategoryId;
    _selectedAccount = widget.transaction?.accountId;
    _selectedJar = widget.transaction?.jarId;
    _selectedMedium = widget.transaction?.transactionMediumId;
    _notesController = TextEditingController(text: widget.transaction?.notes);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = Transaction(
      id: widget.transaction?.id ?? '',
      userId: widget.userId,
      transactionDate: _transactionDate,
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      transactionTypeId: _selectedTransactionType!,
      categoryId: _selectedCategory!,
      subcategoryId: _selectedSubcategory!,
      accountId: _selectedAccount!,
      jarId: _selectedJar,
      transactionMediumId: _selectedMedium,
      currencyId: 'MXN', // Default currency
      notes: _notesController.text,
      createdAt: DateTime.now(),
    );

    final notifier = ref.read(transactionNotifierProvider.notifier);

    if (widget.transaction != null) {
      await notifier.updateTransaction(transaction);
    } else {
      await notifier.createTransaction(transaction);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Date Picker
          ListTile(
            title: const Text('Fecha'),
            subtitle: Text(
              '${_transactionDate.day}/${_transactionDate.month}/${_transactionDate.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _transactionDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _transactionDate = date);
              }
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              border: OutlineInputBorder(),
            ),
            validator: FormValidators.required,
          ),
          const SizedBox(height: 16),

          // Amount
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Monto',
              border: OutlineInputBorder(),
              prefixText: '\$',
            ),
            keyboardType: TextInputType.number,
            validator: FormValidators.amount,
          ),
          const SizedBox(height: 16),

          // Transaction Type
          DropdownButtonFormField<String>(
            value: _selectedTransactionType,
            decoration: const InputDecoration(
              labelText: 'Tipo de Transacción',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'INCOME',
                child: Text('Ingreso'),
              ),
              DropdownMenuItem(
                value: 'EXPENSE',
                child: Text('Gasto'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTransactionType = value;
                // Reset category and subcategory when type changes
                _selectedCategory = null;
                _selectedSubcategory = null;
              });
            },
            validator: FormValidators.required,
          ),
          const SizedBox(height: 16),

          // Category
          if (_selectedTransactionType != null) ...[
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: const [], // TODO: Load categories based on transaction type
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedSubcategory = null;
                });
              },
              validator: FormValidators.required,
            ),
            const SizedBox(height: 16),
          ],

          // Subcategory
          if (_selectedCategory != null) ...[
            DropdownButtonFormField<String>(
              value: _selectedSubcategory,
              decoration: const InputDecoration(
                labelText: 'Subcategoría',
                border: OutlineInputBorder(),
              ),
              items: const [], // TODO: Load subcategories based on category
              onChanged: (value) =>
                  setState(() => _selectedSubcategory = value),
              validator: FormValidators.required,
            ),
            const SizedBox(height: 16),
          ],

          // Account
          DropdownButtonFormField<String>(
            value: _selectedAccount,
            decoration: const InputDecoration(
              labelText: 'Cuenta',
              border: OutlineInputBorder(),
            ),
            items: const [], // TODO: Load accounts
            onChanged: (value) => setState(() => _selectedAccount = value),
            validator: FormValidators.required,
          ),
          const SizedBox(height: 16),

          // Jar (only for expenses)
          if (_selectedTransactionType == 'EXPENSE') ...[
            DropdownButtonFormField<String>(
              value: _selectedJar,
              decoration: const InputDecoration(
                labelText: 'Jarra',
                border: OutlineInputBorder(),
              ),
              items: const [], // TODO: Load jars
              onChanged: (value) => setState(() => _selectedJar = value),
              validator: FormValidators.required,
            ),
            const SizedBox(height: 16),
          ],

          // Transaction Medium
          DropdownButtonFormField<String>(
            value: _selectedMedium,
            decoration: const InputDecoration(
              labelText: 'Medio de Pago',
              border: OutlineInputBorder(),
            ),
            items: const [], // TODO: Load transaction mediums
            onChanged: (value) => setState(() => _selectedMedium = value),
          ),
          const SizedBox(height: 16),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notas',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _submitForm,
            child: Text(
              widget.transaction != null ? 'Actualizar' : 'Crear',
            ),
          ),
        ],
      ),
    );
  }
}
