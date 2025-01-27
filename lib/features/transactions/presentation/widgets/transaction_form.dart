import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:enki_finance/core/utils/form_validators.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/core/error/failures.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:enki_finance/core/providers/validator_providers.dart';

class TransactionForm extends ConsumerStatefulWidget {
  final String userId;
  final Transaction? transaction;

  const TransactionForm({
    super.key,
    required this.userId,
    this.transaction,
  });

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final TextEditingController _dateController;
  late DateTime _transactionDate;
  String? _selectedTransactionType;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedAccount;
  String? _selectedJar;
  String? _selectedMedium;
  Map<String, dynamic>? _tags;
  bool _isJarRequired = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.transaction?.description);
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.transaction?.notes);
    _dateController = TextEditingController();
    _transactionDate = widget.transaction?.transactionDate ?? DateTime.now();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_transactionDate);
    _selectedTransactionType = widget.transaction?.transactionTypeId;
    _selectedCategory = widget.transaction?.categoryId;
    _selectedSubcategory = widget.transaction?.subcategoryId;
    _selectedAccount = widget.transaction?.accountId;
    _selectedJar = widget.transaction?.jarId;
    _selectedMedium = widget.transaction?.transactionMediumId;
    _tags = widget.transaction?.tags
        ?.asMap()
        .map((k, v) => MapEntry(k.toString(), v));

    // Check if jar is required for initial subcategory
    if (_selectedSubcategory != null) {
      _checkJarRequirement(_selectedSubcategory!);
    }
  }

  Future<void> _checkJarRequirement(String subcategoryId) async {
    try {
      final response = await ref
          .read(supabaseClientProvider)
          .from('subcategory')
          .select('jar_id')
          .eq('id', subcategoryId)
          .single();
      setState(() {
        _isJarRequired = response['jar_id'] != null;
      });
    } catch (e) {
      debugPrint('Error checking jar requirement: $e');
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un monto';
    }

    final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    if (amount == null) {
      return 'Por favor ingresa un monto válido';
    }

    if (amount <= 0) {
      return 'El monto debe ser mayor a cero';
    }

    return null;
  }

  String? _validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor selecciona $fieldName';
    }
    return null;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionTypesAsync = ref.watch(transactionTypesProvider);
    final categoriesAsync = ref.watch(categoriesProvider(widget.userId));
    final subcategoriesAsync = _selectedCategory != null
        ? ref.watch(subcategoriesProvider(_selectedCategory!))
        : null;
    final accountsAsync = ref.watch(accountsProvider);
    final jarsAsync = ref.watch(jarsProvider);
    final isSubmitting = ref.watch(transactionNotifierProvider).isLoading;
    final amountValidator = ref.watch(amountValidatorProvider);
    final dateValidator = ref.watch(dateValidatorProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
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

            // Transaction Date
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              validator: (value) =>
                  dateValidator.validateTransactionDate(value).fold(
                        (failure) => failure.message,
                        (_) => null,
                      ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _transactionDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _transactionDate = date;
                    _dateController.text =
                        DateFormat('dd/MM/yyyy').format(date);
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: '\$',
                helperText: 'Ingresa el monto sin símbolos',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) =>
                  amountValidator.validatePositiveAmount(value).fold(
                        (failure) => failure.message,
                        (_) => null,
                      ),
              enabled: !isSubmitting,
              onChanged: (value) {
                // Format the input to show only valid decimal numbers
                final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
                if (cleanValue != value) {
                  _amountController.value = TextEditingValue(
                    text: cleanValue,
                    selection:
                        TextSelection.collapsed(offset: cleanValue.length),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Transaction Type
            transactionTypesAsync.when(
              data: (types) => DropdownButtonFormField<String>(
                value: _selectedTransactionType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Transacción',
                  helperText: 'Selecciona el tipo de transacción',
                ),
                items: types.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                validator: (value) =>
                    _validateRequiredField(value, 'un tipo de transacción'),
                onChanged: isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _selectedTransactionType = value;
                          _selectedCategory = null;
                          _selectedSubcategory = null;
                          _isJarRequired = false;
                        });
                      },
              ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
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
                items: accounts.map((account) {
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

            // Category
            if (_selectedTransactionType != null)
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    helperText: 'Selecciona la categoría',
                  ),
                  items: categories
                      .where((category) =>
                          category.transactionTypeId ==
                          _selectedTransactionType)
                      .map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  validator: (value) =>
                      _validateRequiredField(value, 'una categoría'),
                  onChanged: isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategory = value;
                            _selectedSubcategory = null;
                            _isJarRequired = false;
                          });
                        },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
            const SizedBox(height: 16),

            // Subcategory
            if (_selectedCategory != null)
              subcategoriesAsync!.when(
                data: (subcategories) => DropdownButtonFormField<String>(
                  value: _selectedSubcategory,
                  decoration: const InputDecoration(
                    labelText: 'Subcategoría',
                    helperText: 'Selecciona la subcategoría',
                  ),
                  items: subcategories.map((subcategory) {
                    return DropdownMenuItem(
                      value: subcategory.id,
                      child: Text(subcategory.name),
                    );
                  }).toList(),
                  validator: (value) =>
                      _validateRequiredField(value, 'una subcategoría'),
                  onChanged: isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedSubcategory = value;
                            if (value != null) {
                              _checkJarRequirement(value);
                            }
                          });
                        },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
            const SizedBox(height: 16),

            // Jar (only for expenses and if required)
            if (_selectedTransactionType == 'EXPENSE' &&
                (_isJarRequired || _selectedJar != null))
              jarsAsync.when(
                data: (jars) => DropdownButtonFormField<String>(
                  value: _selectedJar,
                  decoration: InputDecoration(
                    labelText: 'Jarra',
                    helperText: _isJarRequired
                        ? 'Esta categoría requiere seleccionar una jarra'
                        : 'Selecciona una jarra (opcional)',
                  ),
                  items: jars.map((jar) {
                    return DropdownMenuItem(
                      value: jar['id'] as String,
                      child: Text(jar['name'] as String),
                    );
                  }).toList(),
                  validator: _isJarRequired
                      ? (value) => _validateRequiredField(value, 'una jarra')
                      : null,
                  onChanged: isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedJar = value;
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
                helperText: 'Agrega una descripción (opcional)',
              ),
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
              label: Text(
                widget.transaction == null
                    ? 'Crear Transacción'
                    : 'Guardar Cambios',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final transaction = Transaction(
          id: widget.transaction?.id ?? '',
          userId: widget.userId,
          transactionDate: _transactionDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          amount: double.parse(_amountController.text),
          transactionTypeId: _selectedTransactionType!,
          categoryId: _selectedCategory!,
          subcategoryId: _selectedSubcategory!,
          accountId: _selectedAccount!,
          jarId: _selectedJar,
          transactionMediumId: _selectedMedium,
          currencyId: 'MXN', // TODO: Implement currency selection
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          tags: _tags?.values.map((v) => v.toString()).toList(),
          createdAt: widget.transaction?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final notifier = ref.read(transactionNotifierProvider.notifier);

        if (widget.transaction == null) {
          await notifier.createTransaction(transaction);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transacción creada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        } else {
          await notifier.updateTransaction(transaction);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transacción actualizada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
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

        // Show error in a dialog for better visibility
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(_errorMessage!),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      }
    }
  }
}
