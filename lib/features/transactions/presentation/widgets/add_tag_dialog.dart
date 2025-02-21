import 'package:flutter/material.dart';

class AddTagDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  AddTagDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Etiqueta'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Nombre de la etiqueta',
          helperText: 'Ingresa el nombre de la nueva etiqueta',
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final tag = _controller.text.trim();
            if (tag.isNotEmpty) {
              Navigator.pop(context, tag);
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
