import 'package:flutter/material.dart';

import '../models/beverage.dart';
import '../models/catalog_item.dart';
import '../services/beverage_service.dart';
import '../widgets/chat_button.dart';

class BeverageFormScreen extends StatefulWidget {
  final Beverage? beverage;
  const BeverageFormScreen({super.key, this.beverage});

  @override
  State<BeverageFormScreen> createState() => _BeverageFormScreenState();
}

class _BeverageFormScreenState extends State<BeverageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final BeverageService _service = BeverageService();

  List<CatalogItem> _types = [];
  List<CatalogItem> _sizes = [];
  List<CatalogItem> _sweeteners = [];
  List<CatalogItem> _toppings = [];

  CatalogItem? _type;
  CatalogItem? _size;
  CatalogItem? _sweetener;
  final List<CatalogItem> _selectedToppings = [];

  final TextEditingController _priceController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
  }

  Future<void> _loadCatalogs() async {
    final results = await Future.wait([
      _service.getBeverageTypes(),
      _service.getBeverageSizes(),
      _service.getSweeteners(),
      _service.getToppings(),
    ]);

    _types = results[0];
    _sizes = results[1];
    _sweeteners = results[2];
    _toppings = results[3];

    if (widget.beverage != null) {
      _type = _types.firstWhere(
          (e) => e.name == widget.beverage!.beverageType,
          orElse: () =>
              _types.isNotEmpty ? _types.first : CatalogItem(id: 0, name: ''));
      _size = _sizes.firstWhere(
          (e) => e.name == widget.beverage!.size,
          orElse: () =>
              _sizes.isNotEmpty ? _sizes.first : CatalogItem(id: 0, name: ''));
      _sweetener = _sweeteners.firstWhere(
          (e) => e.name == widget.beverage!.sweetener,
          orElse: () => _sweeteners.isNotEmpty
              ? _sweeteners.first
              : CatalogItem(id: 0, name: ''));
      _selectedToppings.addAll(
        _toppings.where((e) => widget.beverage!.toppings.contains(e.name)),
      );
      _priceController.text = widget.beverage!.price.toString();
    }

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final beverage = Beverage(
      id: widget.beverage?.id ?? 0,
      beverageType: _type!.name,
      size: _size!.name,
      sweetener: _sweetener!.name,
      toppings: _selectedToppings.map((e) => e.name).toList(),
      price: double.parse(_priceController.text),
    );

    final ok = widget.beverage == null
        ? await _service.createBeverage(beverage)
        : await _service.updateBeverage(beverage);

    setState(() => _saving = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bebida guardada')),
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
        title: Text(widget.beverage == null ? 'Nueva Bebida' : 'Editar Bebida'),
      ),
      floatingActionButton: const ChatButton(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<CatalogItem>(
                      value: _type,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: _types
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _type = v),
                      validator: (v) => v == null ? 'Seleccione el tipo' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CatalogItem>(
                      value: _size,
                      decoration: const InputDecoration(labelText: 'Tamaño'),
                      items: _sizes
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _size = v),
                      validator: (v) => v == null ? 'Seleccione el tamaño' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CatalogItem>(
                      value: _sweetener,
                      decoration: const InputDecoration(labelText: 'Endulzante'),
                      items: _sweeteners
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _sweetener = v),
                      validator: (v) =>
                          v == null ? 'Seleccione el endulzante' : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Toppings',
                        style: Theme.of(context).textTheme.labelLarge),
                    Wrap(
                      spacing: 8,
                      children: _toppings.map((e) {
                        final selected =
                            _selectedToppings.any((t) => t.id == e.id);
                        return FilterChip(
                          label: Text(e.name),
                          selected: selected,
                          onSelected: (v) {
                            setState(() {
                              if (v) {
                                _selectedToppings.add(e);
                              } else {
                                _selectedToppings
                                    .removeWhere((t) => t.id == e.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingrese el precio';
                        }
                        return double.tryParse(v) == null
                            ? 'Precio inválido'
                            : null;
                      },
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
