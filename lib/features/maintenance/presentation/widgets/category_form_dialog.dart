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
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.category?.code);
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController = TextEditingController(
      text: widget.category?.description,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final isSaving = ref.watch(isSavingProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Categoría' : 'Nueva Categoría'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                enabled: !isSaving,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  hintText: 'Ingresa el código de la categoría',
                  helperText:
                      'Solo caracteres alfanuméricos y guiones bajos, 2-20 caracteres',
                ),
                validator: (value) {
                  // Format validation
                  final formatError = MaintenanceValidators.validateCode(value);
                  if (formatError != null) {
                    return formatError;
                  }

                  // Uniqueness validation
                  return categoriesAsync.whenOrNull(
                    data: (categories) =>
                        MaintenanceValidators.validateCodeUniqueness(
                      value!,
                      categories,
                      excludeId: widget.category?.id,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final category = Category(
        id: widget.category?.id ?? '',
        code: _codeController.text,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        isSystem: widget.category?.isSystem ?? false,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      Navigator.of(context).pop(category);
    }
  }
}
