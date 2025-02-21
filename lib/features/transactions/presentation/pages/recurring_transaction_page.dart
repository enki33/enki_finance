import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../providers/transaction_provider.dart';

class RecurringTransactionPage extends ConsumerStatefulWidget {
  const RecurringTransactionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RecurringTransactionPage> createState() =>
      _RecurringTransactionPageState();
}

class _RecurringTransactionPageState
    extends ConsumerState<RecurringTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedTransactionType;
  String? _selectedCategory;
  String? _selectedSubcategory;
  String? _selectedAccount;
  String? _selectedCurrency;
  String? _selectedJar;
  String _frequency = 'MONTHLY'; // Default frequency
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String? _errorMessage;
  bool _isJarRequired = false;

  @override
  Widget build(BuildContext context) {
    // ... Similar to InstallmentTransactionPage with these additions:

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacción Recurrente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ... Similar fields as InstallmentTransactionPage

            // Frequency
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frecuencia',
                helperText: 'Selecciona la frecuencia de repetición',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'WEEKLY',
                  child: Text('Semanal'),
                ),
                DropdownMenuItem(
                  value: 'MONTHLY',
                  child: Text('Mensual'),
                ),
                DropdownMenuItem(
                  value: 'YEARLY',
                  child: Text('Anual'),
                ),
              ],
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _frequency = value;
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
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
            ),
            const SizedBox(height: 16),

            // End Date (Optional)
            ListTile(
              title: const Text('Fecha de fin (opcional)'),
              subtitle: _endDate != null
                  ? Text(DateFormat('dd/MM/yyyy').format(_endDate!))
                  : const Text('Sin fecha de fin'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_endDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _endDate = null;
                              });
                            },
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: isSubmitting
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ??
                            _startDate.add(const Duration(days: 30)),
                        firstDate: _startDate,
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (date != null) {
                        setState(() {
                          _endDate = date;
                        });
                      }
                    },
            ),

            // ... Rest of the form fields

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
              label: const Text('Crear Transacción Recurrente'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final recurringTransaction = RecurringTransaction(
          id: '',
          userId: ref.read(currentUserIdProvider),
          name: _descriptionController.text,
          description:
              _notesController.text.isEmpty ? null : _notesController.text,
          amount: double.parse(_amountController.text),
          frequency: _frequency,
          startDate: _startDate,
          endDate: _endDate,
          transactionTypeId: _selectedTransactionType!,
          categoryId: _selectedCategory!,
          subcategoryId: _selectedSubcategory!,
          accountId: _selectedAccount!,
          jarId: _selectedJar,
          currencyId: _selectedCurrency ?? 'MXN',
          isActive: true,
          lastExecutionDate: null,
          nextExecutionDate: _startDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final notifier = ref.read(transactionNotifierProvider.notifier);
        await notifier.createRecurringTransaction(recurringTransaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transacción recurrente creada exitosamente'),
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
