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
    final transactionTypesAsync = ref.watch(transactionTypesProvider);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Categoría' : 'Nueva Categoría'),
      content: transactionTypesAsync.when(
        data: (transactionTypes) => Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ingresa el nombre de la categoría',
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
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Ingresa una descripción (opcional)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTransactionTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Transacción',
                    hintText: 'Selecciona el tipo de transacción',
                  ),
                  items: transactionTypes.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    );
                  }).toList(),
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedTransactionTypeId = value;
                          });
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El tipo de transacción es requerido';
                    }
                    return null;
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: isSaving
              ? null
              : () => transactionTypesAsync.whenOrNull(
                    data: (transactionTypes) => _submit(transactionTypes),
                  ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }

  void _submit(Map<String, String> transactionTypes) {
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
