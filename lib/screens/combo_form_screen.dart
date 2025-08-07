import 'package:flutter/material.dart';

import '../models/beverage.dart';
import '../models/combo.dart';
import '../models/tamale.dart';
import '../services/beverage_service.dart';
import '../services/combo_service.dart';
import '../services/tamale_service.dart';
import '../widgets/chat_button.dart';

class ComboFormScreen extends StatefulWidget {
  final Combo? combo;
  const ComboFormScreen({super.key, this.combo});

  @override
  State<ComboFormScreen> createState() => _ComboFormScreenState();
}

class _ComboFormScreenState extends State<ComboFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ComboService _service = ComboService();
  final TamaleService _tamaleService = TamaleService();
  final BeverageService _beverageService = BeverageService();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();

  bool _isActive = true;
  Season _season = Season.spring;

  List<Tamale> _tamaleOptions = [];
  List<Beverage> _beverageOptions = [];

  Tamale? _selectedTamale;
  int _tamaleQty = 1;
  Beverage? _selectedBeverage;
  int _beverageQty = 1;

  List<ComboProduct> _tamales = [];
  List<ComboProduct> _beverages = [];

  bool _loading = true;
  bool _saving = false;

  double get _total =>
      _tamales.fold<double>(0, (p, e) => p + e.price * e.quantity) +
      _beverages.fold<double>(0, (p, e) => p + e.price * e.quantity);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _tamaleService.fetchTamales(),
      _beverageService.fetchBeverages(),
    ]);

    _tamaleOptions = results[0] as List<Tamale>;
    _beverageOptions = results[1] as List<Beverage>;

    if (widget.combo != null) {
      final c = widget.combo!;
      _nameCtrl.text = c.name;
      _descriptionCtrl.text = c.description;
      _priceCtrl.text = c.price.toString();
      _isActive = c.isActive;
      _season = c.season;
      _tamales = List.from(c.tamales);
      _beverages = List.from(c.beverages);
    }

    setState(() => _loading = false);
  }

  void _addTamale() {
    if (_selectedTamale == null) return;
    setState(() {
      _tamales.add(ComboProduct(
        id: _selectedTamale!.id,
        name: '${_selectedTamale!.tamaleType} - ${_selectedTamale!.filling}',
        price: _selectedTamale!.price,
        quantity: _tamaleQty,
      ));
      _selectedTamale = null;
      _tamaleQty = 1;
    });
  }

  void _addBeverage() {
    if (_selectedBeverage == null) return;
    setState(() {
      _beverages.add(ComboProduct(
        id: _selectedBeverage!.id,
        name: '${_selectedBeverage!.beverageType} ${_selectedBeverage!.size}',
        price: _selectedBeverage!.price,
        quantity: _beverageQty,
      ));
      _selectedBeverage = null;
      _beverageQty = 1;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tamales.isEmpty && _beverages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agregue al menos un producto')),
      );
      return;
    }
    setState(() => _saving = true);

    final combo = Combo(
      id: widget.combo?.id,
      name: _nameCtrl.text,
      description: _descriptionCtrl.text,
      price: double.tryParse(_priceCtrl.text) ?? _total,
      isActive: _isActive,
      isEditable: widget.combo?.isEditable ?? true,
      season: _season,
      tamales: _tamales,
      beverages: _beverages,
    );

    final ok = widget.combo == null
        ? await _service.createCombo(combo)
        : await _service.updateCombo(combo);

    setState(() => _saving = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Combo guardado')),
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
        title: Text(widget.combo == null ? 'Nuevo Combo' : 'Editar Combo'),
      ),
      floatingActionButton: const ChatButton(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Ingrese el nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionCtrl,
                      decoration: const InputDecoration(labelText: 'Descripción'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Season>(
                      value: _season,
                      decoration:
                          const InputDecoration(labelText: 'Temporada'),
                      items: Season.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _season = v!),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Activo'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Precio del combo'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 24),
                    Text('Tamales', style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<Tamale>(
                            value: _selectedTamale,
                            hint: const Text('Seleccione tamal'),
                            items: _tamaleOptions
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                          '${e.tamaleType} - ${e.filling}'),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedTamale = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: '$_tamaleQty',
                            decoration: const InputDecoration(labelText: 'Cant'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                _tamaleQty = int.tryParse(v) ?? 1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTamale,
                        ),
                      ],
                    ),
                    ..._tamales.map((e) => ListTile(
                          title: Text('${e.name} x${e.quantity}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _tamales.remove(e)),
                          ),
                        )),
                    const SizedBox(height: 16),
                    Text('Bebidas',
                        style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<Beverage>(
                            value: _selectedBeverage,
                            hint: const Text('Seleccione bebida'),
                            items: _beverageOptions
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                          '${e.beverageType} ${e.size}'),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedBeverage = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 60,
                          child: TextFormField(
                            initialValue: '$_beverageQty',
                            decoration:
                                const InputDecoration(labelText: 'Cant'),
                            keyboardType: TextInputType.number,
                            onChanged: (v) =>
                                _beverageQty = int.tryParse(v) ?? 1,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addBeverage,
                        ),
                      ],
                    ),
                    ..._beverages.map((e) => ListTile(
                          title: Text('${e.name} x${e.quantity}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _beverages.remove(e)),
                          ),
                        )),
                    const SizedBox(height: 16),
                    Text('Total: \$${_total.toStringAsFixed(2)}'),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const CircularProgressIndicator()
                            : const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
