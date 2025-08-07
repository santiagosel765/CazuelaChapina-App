import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../services/inventory_service.dart';
import '../widgets/chat_button.dart';

class InventoryFormScreen extends StatefulWidget {
  final InventoryItem? item;
  const InventoryFormScreen({super.key, this.item});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final InventoryService _service = InventoryService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _unitCostController = TextEditingController();

  final List<String> _types = ['Sólido', 'Líquido', 'Empaque'];
  String? _type;
  bool _isCritical = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _stockController.text = widget.item!.stock.toString();
      _unitCostController.text = widget.item!.unitCost.toString();
      _type = widget.item!.type;
      _isCritical = widget.item!.isCritical;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final item = InventoryItem(
      id: widget.item?.id ?? 0,
      name: _nameController.text,
      type: _type ?? '',
      stock: double.parse(_stockController.text),
      unitCost: double.parse(_unitCostController.text),
      isCritical: _isCritical,
    );

    final ok = widget.item == null
        ? await _service.createItem(item)
        : await _service.updateItem(item);

    setState(() => _saving = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insumo guardado')),
      );
      Navigator.pop(context, true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Nuevo Insumo' : 'Editar Insumo'),
      ),
      floatingActionButton: const ChatButton(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: _types
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v),
                validator: (v) => v == null ? 'Seleccione el tipo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingrese el stock';
                  }
                  return double.tryParse(v) == null ? 'Valor inválido' : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitCostController,
                decoration: const InputDecoration(labelText: 'Costo unitario'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingrese el costo unitario';
                  }
                  return double.tryParse(v) == null ? 'Valor inválido' : null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Es crítico'),
                value: _isCritical,
                onChanged: (v) => setState(() => _isCritical = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
