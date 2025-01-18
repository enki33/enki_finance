import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/domain/entities/credit_card_details.dart';

class CreditCardFormDialog extends ConsumerStatefulWidget {
  final Account? account;

  const CreditCardFormDialog({super.key, this.account});

  @override
  ConsumerState<CreditCardFormDialog> createState() =>
      _CreditCardFormDialogState();
}

class _CreditCardFormDialogState extends ConsumerState<CreditCardFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _interestRateController;
  late int _cutOffDay;
  late int _paymentDueDay;
  late String _currencyId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name);
    _descriptionController =
        TextEditingController(text: widget.account?.description);
    _creditLimitController = TextEditingController();
    _interestRateController = TextEditingController();
    _cutOffDay = 1;
    _paymentDueDay = 20;
    _currencyId = widget.account?.currencyId ?? 'MXN';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _creditLimitController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.account == null ? 'Nueva Tarjeta' : 'Editar Tarjeta'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ingresa el nombre de la tarjeta',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ingresa una descripción (opcional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _creditLimitController,
                decoration: const InputDecoration(
                  labelText: 'Límite de Crédito',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El límite de crédito es requerido';
                  }
                  final limit = double.tryParse(value);
                  if (limit == null || limit <= 0) {
                    return 'Ingresa un valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _interestRateController,
                decoration: const InputDecoration(
                  labelText: 'Tasa de Interés',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La tasa de interés es requerida';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0) {
                    return 'Ingresa un valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _cutOffDay,
                decoration: const InputDecoration(
                  labelText: 'Día de Corte',
                ),
                items: List.generate(28, (index) => index + 1)
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text('Día $day'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _cutOffDay = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _paymentDueDay,
                decoration: const InputDecoration(
                  labelText: 'Día Límite de Pago',
                ),
                items: List.generate(28, (index) => index + 1)
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text('Día $day'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _paymentDueDay = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _currencyId,
                decoration: const InputDecoration(
                  labelText: 'Moneda',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'MXN',
                    child: Text('Peso Mexicano (MXN)'),
                  ),
                  DropdownMenuItem(
                    value: 'USD',
                    child: Text('Dólar Estadounidense (USD)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _currencyId = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La moneda es requerida';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final account = Account(
        id: widget.account?.id,
        userId: widget.account?.userId ?? '', // This should come from auth
        accountTypeId: 'CREDIT_CARD',
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        currencyId: _currencyId,
        currentBalance: widget.account?.currentBalance ?? 0,
        isActive: true,
        createdAt: widget.account?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      final details = CreditCardDetails(
        id: null, // This will be generated by the database
        accountId:
            account.id ?? '', // This will be updated after account creation
        creditLimit: double.parse(_creditLimitController.text),
        currentInterestRate: double.parse(_interestRateController.text),
        cutOffDay: _cutOffDay,
        paymentDueDay: _paymentDueDay,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      Navigator.pop(context, (account, details));
    }
  }
}
