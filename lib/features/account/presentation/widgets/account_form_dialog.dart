import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:enki_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/presentation/providers/account_providers.dart';
import 'package:enki_finance/core/providers/validator_providers.dart';
import 'package:enki_finance/features/account/domain/validators/account_form_validator.dart';
import '../providers/account_form_provider.dart';

class AccountFormDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? account;

  const AccountFormDialog({super.key, this.account});

  @override
  ConsumerState<AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends ConsumerState<AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _currentBalanceController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.account?['name'] as String?);
    _descriptionController =
        TextEditingController(text: widget.account?['description'] as String?);
    _currentBalanceController = TextEditingController(
        text: widget.account?['current_balance']?.toString() ?? '0');
    _isActive = widget.account?['is_active'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _currentBalanceController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.account != null;

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(isSavingProvider);
    final validator = ref.watch(accountFormValidatorProvider);
    final amountValidator = ref.watch(amountValidatorProvider);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Cuenta' : 'Nueva Cuenta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                enabled: !isSaving,
                validator: (value) => validator.validateName(value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                enabled: !isSaving,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentBalanceController,
                decoration: const InputDecoration(
                  labelText: 'Balance Inicial',
                  border: OutlineInputBorder(),
                ),
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    amountValidator.validateAmount(value).fold(
                          (failure) => failure.message,
                          (_) => null,
                        ),
              ),
              if (isEditing) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Activo'),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isActive,
                      onChanged: isSaving
                          ? null
                          : (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : _submit,
          child: Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(authProvider);
      final currentUser = authState.valueOrNull;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No hay un usuario autenticado')),
        );
        return;
      }

      final account = {
        if (widget.account != null) 'id': widget.account!['id'],
        'user_id': currentUser.id,
        'account_type_id':
            '00000000-0000-0000-0000-000000000001', // Default type
        'name': _nameController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'currency_id':
            '00000000-0000-0000-0000-000000000001', // Default currency
        'current_balance': double.parse(_currentBalanceController.text),
        'is_active': _isActive,
        if (widget.account == null)
          'created_at': DateTime.now().toIso8601String(),
        'modified_at': DateTime.now().toIso8601String(),
      };

      Navigator.pop(context, account);
    }
  }
}
