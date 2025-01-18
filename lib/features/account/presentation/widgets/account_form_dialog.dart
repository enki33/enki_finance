import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/presentation/providers/account_providers.dart';
import 'package:enki_finance/features/auth/presentation/providers/auth_provider.dart';

class AccountFormDialog extends ConsumerStatefulWidget {
  final Account? account;

  const AccountFormDialog({super.key, this.account});

  @override
  ConsumerState<AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends ConsumerState<AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _selectedAccountTypeId;
  String? _selectedCurrencyId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name);
    _descriptionController = TextEditingController(
      text: widget.account?.description,
    );
    _selectedAccountTypeId = widget.account?.accountTypeId;
    _selectedCurrencyId = widget.account?.currencyId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;
    final accountTypesAsync = ref.watch(accountTypesProvider);
    final currenciesAsync = ref.watch(currenciesProvider);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Cuenta' : 'Nueva Cuenta'),
      content: accountTypesAsync.when(
        data: (accountTypes) => currenciesAsync.when(
          data: (currencies) => Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      hintText: 'Ingresa el nombre de la cuenta',
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
                  DropdownButtonFormField<String>(
                    value: _selectedAccountTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Cuenta',
                    ),
                    items: accountTypes.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccountTypeId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El tipo de cuenta es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrencyId,
                    decoration: const InputDecoration(
                      labelText: 'Moneda',
                    ),
                    items: currencies.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrencyId = value;
                      });
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: ${error.toString()}'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => accountTypesAsync.whenOrNull(
            data: (accountTypes) => currenciesAsync.whenOrNull(
              data: (currencies) => _submit(accountTypes, currencies),
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  void _submit(
      Map<String, String> accountTypes, Map<String, String> currencies) {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authProvider);
      final currentUser = authState.valueOrNull;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No hay un usuario autenticado'),
          ),
        );
        return;
      }

      final account = Account(
        id: widget.account?.id,
        userId: currentUser.id,
        accountTypeId: _selectedAccountTypeId!,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        currencyId: _selectedCurrencyId!,
        currentBalance: widget.account?.currentBalance ?? 0,
        isActive: true,
        createdAt: widget.account?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
      );
      Navigator.pop(context, account);
    }
  }
}
