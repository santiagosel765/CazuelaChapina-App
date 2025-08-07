import 'package:flutter/material.dart';

import '../models/inventory_movement_dto.dart';

class InventoryMovementDialog extends StatefulWidget {
  final String action;
  const InventoryMovementDialog({super.key, required this.action});

  @override
  State<InventoryMovementDialog> createState() => _InventoryMovementDialogState();
}

class _InventoryMovementDialogState extends State<InventoryMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final dto = InventoryMovementDto(
      quantity: double.parse(_quantityController.text),
      reason: _reasonController.text,
    );
    Navigator.pop(context, dto);
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Registrar ${widget.action}';
    return AlertDialog(
      title: Text(title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Ingrese la cantidad';
                }
                return double.tryParse(v) == null
                    ? 'Cantidad inválida'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Motivo'),
              validator: (v) => v == null || v.isEmpty ? 'Ingrese el motivo' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
