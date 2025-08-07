import 'package:flutter/material.dart';

import '../models/catalog_item.dart';
import '../models/tamale.dart';
import '../services/tamale_service.dart';
import '../widgets/chat_button.dart';

class TamaleFormScreen extends StatefulWidget {
  final Tamale? tamale;
  const TamaleFormScreen({super.key, this.tamale});

  @override
  State<TamaleFormScreen> createState() => _TamaleFormScreenState();
}

class _TamaleFormScreenState extends State<TamaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TamaleService _service = TamaleService();

  List<CatalogItem> _types = [];
  List<CatalogItem> _fillings = [];
  List<CatalogItem> _wrappers = [];
  List<CatalogItem> _spiceLevels = [];

  CatalogItem? _type;
  CatalogItem? _filling;
  CatalogItem? _wrapper;
  CatalogItem? _spiceLevel;

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
      _service.getTamaleTypes(),
      _service.getFillings(),
      _service.getWrappers(),
      _service.getSpiceLevels(),
    ]);

    _types = results[0];
    _fillings = results[1];
    _wrappers = results[2];
    _spiceLevels = results[3];

    if (widget.tamale != null) {
      _type = _types.firstWhere(
          (e) => e.name == widget.tamale!.tamaleType,
          orElse: () => _types.isNotEmpty ? _types.first : CatalogItem(id: 0, name: ''));
      _filling = _fillings.firstWhere(
          (e) => e.name == widget.tamale!.filling,
          orElse: () => _fillings.isNotEmpty ? _fillings.first : CatalogItem(id: 0, name: ''));
      _wrapper = _wrappers.firstWhere(
          (e) => e.name == widget.tamale!.wrapper,
          orElse: () => _wrappers.isNotEmpty ? _wrappers.first : CatalogItem(id: 0, name: ''));
      _spiceLevel = _spiceLevels.firstWhere(
          (e) => e.name == widget.tamale!.spiceLevel,
          orElse: () => _spiceLevels.isNotEmpty ? _spiceLevels.first : CatalogItem(id: 0, name: ''));
      _priceController.text = widget.tamale!.price.toString();
    }

    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final tamale = Tamale(
      id: widget.tamale?.id ?? 0,
      tamaleType: _type!.name,
      filling: _filling!.name,
      wrapper: _wrapper!.name,
      spiceLevel: _spiceLevel!.name,
      price: double.parse(_priceController.text),
    );

    final ok = widget.tamale == null
        ? await _service.createTamale(tamale)
        : await _service.updateTamale(tamale);

    setState(() => _saving = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tamal guardado')), 
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
        title: Text(widget.tamale == null ? 'Nuevo Tamal' : 'Editar Tamal'),
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
                      decoration: const InputDecoration(labelText: 'Tipo de masa'),
                      items: _types
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _type = v),
                      validator: (v) => v == null ? 'Seleccione el tipo de masa' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CatalogItem>(
                      value: _filling,
                      decoration: const InputDecoration(labelText: 'Relleno'),
                      items: _fillings
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _filling = v),
                      validator: (v) => v == null ? 'Seleccione el relleno' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CatalogItem>(
                      value: _wrapper,
                      decoration: const InputDecoration(labelText: 'Envoltura'),
                      items: _wrappers
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _wrapper = v),
                      validator: (v) => v == null ? 'Seleccione la envoltura' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CatalogItem>(
                      value: _spiceLevel,
                      decoration: const InputDecoration(labelText: 'Nivel de picante'),
                      items: _spiceLevels
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _spiceLevel = v),
                      validator: (v) => v == null ? 'Seleccione el nivel de picante' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Precio'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingrese el precio';
                        return double.tryParse(v) == null ? 'Precio inválido' : null;
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
