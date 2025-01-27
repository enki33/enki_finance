import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/validators/maintenance_validators.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  final Category? category;

  const CategoryFormDialog({
    super.key,
    this.category,
  });

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late bool _isActive;
  String? _selectedTransactionTypeId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController = TextEditingController(
      text: widget.category?.description,
    );
    _isActive = widget.category?.isActive ?? true;
    _selectedTransactionTypeId = widget.category?.transactionTypeId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final isSaving = ref.watch(isSavingProvider);
    final validator = ref.watch(categoryFormValidatorProvider);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Categoría' : 'Nueva Categoría'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ingresa el nombre de la categoría',
                    isDense: true,
                  ),
                  validator: (value) => validator.validateName(value).fold(
                        (failure) => failure.message,
                        (_) => null,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  enabled: !isSaving,
                  minLines: 1,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Ingresa una descripción (opcional)',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final transactionTypesAsync =
                        ref.watch(transactionTypesProvider);

                    return transactionTypesAsync.when(
                      data: (transactionTypes) =>
                          DropdownButtonFormField<String>(
                        value: _selectedTransactionTypeId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Transacción',
                          hintText: 'Selecciona el tipo de transacción',
                          isDense: true,
                        ),
                        items: transactionTypes.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.value,
                            child: Text(
                              entry.key,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: isSaving
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedTransactionTypeId = value;
                                });
                              },
                        validator: (value) =>
                            validator.validateTransactionType(value).fold(
                                  (failure) => failure.message,
                                  (_) => null,
                                ),
                      ),
                      loading: () => TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Transacción',
                          hintText: 'Cargando...',
                          isDense: true,
                          suffixIcon: Transform.scale(
                            scale: 0.5,
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      error: (error, stack) => TextFormField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Tipo de Transacción',
                          errorText: 'Error: $error',
                          isDense: true,
                        ),
                      ),
                    );
                  },
                ),
                if (isEditing) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Activo:'),
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
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
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
      final category = Category(
        id: widget.category?.id,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        isActive: _isActive,
        transactionTypeId: _selectedTransactionTypeId!,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      Navigator.of(context).pop(category);
    }
  }
}
