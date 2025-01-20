import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';

class JarFormDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic>? jar;

  const JarFormDialog({super.key, this.jar});

  @override
  ConsumerState<JarFormDialog> createState() => _JarFormDialogState();
}

class _JarFormDialogState extends ConsumerState<JarFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _percentageController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.jar?['name'] as String?);
    _descriptionController =
        TextEditingController(text: widget.jar?['description'] as String?);
    _percentageController = TextEditingController(
        text: widget.jar?['target_percentage']?.toString() ?? '0');
    _isActive = widget.jar?['is_active'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.jar != null;

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(isSavingProvider);

    return AlertDialog(
      title: Text(isEditing ? 'Editar Jarra' : 'Nueva Jarra'),
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
                  border: OutlineInputBorder(),
                ),
                enabled: !isSaving,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _percentageController,
                decoration: const InputDecoration(
                  labelText: 'Porcentaje objetivo',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                enabled: !isSaving,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El porcentaje es requerido';
                  }
                  final percentage = double.tryParse(value);
                  if (percentage == null) {
                    return 'Ingrese un número válido';
                  }
                  if (percentage < 0 || percentage > 100) {
                    return 'El porcentaje debe estar entre 0 y 100';
                  }
                  return null;
                },
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
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: isSaving ? null : _submit,
          child: Text(isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final jar = {
        if (widget.jar != null) 'id': widget.jar!['id'],
        'name': _nameController.text,
        'description': _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        'target_percentage': double.parse(_percentageController.text),
        'is_active': _isActive,
        if (widget.jar == null) 'created_at': DateTime.now().toIso8601String(),
        'modified_at': DateTime.now().toIso8601String(),
      };

      Navigator.pop(context, jar);
    }
  }
}
