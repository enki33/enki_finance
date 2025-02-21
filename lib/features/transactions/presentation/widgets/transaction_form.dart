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
import 'package:enki_finance/domain/validators/transaction_validator.dart';
import 'package:enki_finance/features/transactions/presentation/providers/tag_suggestions_provider.dart';
import '../widgets/add_tag_dialog.dart';

class TransactionForm extends ConsumerStatefulWidget {
  final Transaction? initialTransaction;
  final Function(Transaction) onSubmit;

  const TransactionForm({
    Key? key,
    this.initialTransaction,
    required this.onSubmit,
  }) : super(key: key);

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  String? _selectedTransactionType;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedAccount;
  String? _selectedCurrency;
  String? _selectedJar;
  List<String> _selectedTags = [];
  double _exchangeRate = 1.0;
  bool _isJarRequired = false;
  String? _errorMessage;
  late AsyncValue<List<Category>> categoriesAsync;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final transaction = widget.initialTransaction;
    _amountController = TextEditingController(
      text: transaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: transaction?.description ?? '',
    );
    _notesController = TextEditingController(
      text: transaction?.notes ?? '',
    );
    _selectedDate = transaction?.transactionDate ?? DateTime.now();
    _selectedTransactionType = transaction?.transactionTypeId;
    _selectedCategory = transaction?.categoryId;
    _selectedSubcategory = transaction?.subcategoryId;
    _selectedAccount = transaction?.accountId;
    _selectedCurrency = transaction?.currencyId;
    _selectedJar = transaction?.jarId;
    _selectedTags = transaction?.tags ?? [];
    _exchangeRate = transaction?.exchangeRate ?? 1.0;

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
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    categoriesAsync =
        ref.watch(categoriesProvider(widget.initialTransaction?.userId));
    final transactionTypesAsync = ref.watch(transactionTypesProvider);
    final subcategoriesAsync = _selectedCategory != null
        ? ref.watch(subcategoriesProvider(_selectedCategory!))
        : null;
    final accountsAsync = ref.watch(accountsProvider);
    final jarsAsync = ref.watch(jarsProvider);
    final isSubmitting = ref.watch(transactionNotifierProvider).isLoading;
    final amountValidator = ref.watch(amountValidatorProvider);
    final dateValidator = ref.watch(dateValidatorProvider);
    final categories =
        ref.read(categoriesProvider(widget.initialTransaction?.userId));

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

            // Tag Selection
            Consumer(
              builder: (context, ref, child) {
                final suggestionsAsync = ref.watch(tagSuggestionsProvider(
                    widget.initialTransaction?.userId ?? ''));

                return suggestionsAsync.when(
                  data: (suggestions) => Wrap(
                    spacing: 8.0,
                    children: [
                      ...suggestions.map((tag) {
                        final isSelected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTags.add(tag);
                              } else {
                                _selectedTags.remove(tag);
                              }
                            });
                          },
                        );
                      }),
                      // Add new tag button
                      ActionChip(
                        avatar: const Icon(Icons.add),
                        label: const Text('Agregar etiqueta'),
                        onPressed: () async {
                          final newTag = await showDialog<String>(
                            context: context,
                            builder: (context) => AddTagDialog(),
                          );
                          if (newTag != null && newTag.isNotEmpty) {
                            setState(() {
                              _selectedTags.add(newTag);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),

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
                widget.initialTransaction == null
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
    if (_formKey.currentState!.validate()) {
      try {
        final transaction = Transaction(
          id: widget.initialTransaction?.id ?? '',
          userId: widget.initialTransaction?.userId ?? '',
          transactionTypeId: _selectedTransactionType!,
          categoryId: _selectedCategory!,
          categoryName: '', // Will be filled by backend
          subcategoryId: _selectedSubcategory,
          accountId: _selectedAccount!,
          jarId: _selectedJar,
          amount: double.parse(_amountController.text),
          currencyId: _selectedCurrency ?? 'MXN',
          transactionDate: _selectedDate,
          description: _descriptionController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          tags: _selectedTags,
          createdAt: widget.initialTransaction?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        widget.onSubmit(transaction);
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }
}
