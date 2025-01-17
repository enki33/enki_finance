import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:enki_finance/features/maintenance/domain/validators/maintenance_validators.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubcategoryFormDialog extends ConsumerStatefulWidget {
  final String categoryId;
  final Subcategory? subcategory;

  const SubcategoryFormDialog({
    super.key,
    required this.categoryId,
    this.subcategory,
  });

  @override
  ConsumerState<SubcategoryFormDialog> createState() =>
      _SubcategoryFormDialogState();
}

class _SubcategoryFormDialogState extends ConsumerState<SubcategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _selectedJarId;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.subcategory?.code);
    _nameController = TextEditingController(text: widget.subcategory?.name);
    _descriptionController = TextEditingController(
      text: widget.subcategory?.description,
    );
    _selectedJarId = widget.subcategory?.jarId;
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
    final isEditing = widget.subcategory != null;
    final isSaving = ref.watch(isSavingProvider);
    final jarsAsync = ref.watch(jarsProvider);
    final subcategoriesAsync =
        ref.watch(subcategoriesProvider(widget.categoryId));

    return AlertDialog(
      title: Text(isEditing ? 'Editar Subcategoría' : 'Nueva Subcategoría'),
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
                  hintText: 'Ingresa el código de la subcategoría',
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
                  return subcategoriesAsync.whenOrNull(
                    data: (subcategories) =>
                        MaintenanceValidators.validateSubcategoryCodeUniqueness(
                      value!,
                      widget.categoryId,
                      subcategories,
                      excludeId: widget.subcategory?.id,
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
                  hintText: 'Ingresa el nombre de la subcategoría',
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
              jarsAsync.when(
                data: (jars) => DropdownButtonFormField<String>(
                  value: _selectedJarId,
                  decoration: const InputDecoration(
                    labelText: 'Jar',
                    hintText: 'Selecciona el jar asociado',
                  ),
                  items: jars.map((jar) {
                    return DropdownMenuItem(
                      value: jar['id'] as String,
                      child: Text(jar['name'] as String),
                    );
                  }).toList(),
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedJarId = value;
                          });
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El jar es requerido';
                    }
                    return null;
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
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
      final subcategory = Subcategory(
        id: widget.subcategory?.id,
        code: _codeController.text,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        categoryId: widget.categoryId,
        jarId: _selectedJarId,
        isSystem: widget.subcategory?.isSystem ?? false,
        isActive: widget.subcategory?.isActive ?? true,
        createdAt: widget.subcategory?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      Navigator.of(context).pop(subcategory);
    }
  }
}
