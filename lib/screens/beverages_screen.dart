import 'package:flutter/material.dart';

import '../models/beverage.dart';
import '../models/catalog_item.dart';
import '../services/beverage_service.dart';
import 'beverage_form_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_button.dart';

class BeveragesScreen extends StatefulWidget {
  const BeveragesScreen({super.key});

  @override
  State<BeveragesScreen> createState() => _BeveragesScreenState();
}

class _BeveragesScreenState extends State<BeveragesScreen> {
  final BeverageService _service = BeverageService();
  List<Beverage> _beverages = [];
  List<CatalogItem> _typeOptions = [];
  List<CatalogItem> _sizeOptions = [];
  CatalogItem? _typeFilter;
  CatalogItem? _sizeFilter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBeverages();
  }

  Future<void> _loadBeverages() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _service.fetchBeverages(),
      _service.getBeverageTypes(),
      _service.getBeverageSizes(),
    ]);
    setState(() {
      _beverages = results[0] as List<Beverage>;
      _typeOptions = results[1] as List<CatalogItem>;
      _sizeOptions = results[2] as List<CatalogItem>;
      _loading = false;
    });
  }

  List<Beverage> get _filteredBeverages {
    return _beverages.where((b) {
      final typeOk = _typeFilter == null || b.beverageType == _typeFilter!.name;
      final sizeOk = _sizeFilter == null || b.size == _sizeFilter!.name;
      return typeOk && sizeOk;
    }).toList();
  }

  Future<void> _deleteBeverage(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar bebida'),
        content: const Text('¿Desea eliminar esta bebida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await _service.deleteBeverage(id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bebida eliminada')),
        );
        await _loadBeverages();
      }
    }
  }

  Future<void> _openForm([Beverage? beverage]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BeverageFormScreen(beverage: beverage),
      ),
    );
    if (saved == true) {
      await _loadBeverages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredBeverages;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Bebidas'),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openForm,
            tooltip: 'Agregar bebida',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          const ChatButton(),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<CatalogItem>(
                          value: _typeFilter,
                          hint: const Text('Tipo'),
                          isExpanded: true,
                          items: _typeOptions
                              .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _typeFilter = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<CatalogItem>(
                          value: _sizeFilter,
                          hint: const Text('Tamaño'),
                          isExpanded: true,
                          items: _sizeOptions
                              .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                              .toList(),
                          onChanged: (v) => setState(() => _sizeFilter = v),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Limpiar filtros',
                        onPressed: () => setState(() {
                          _typeFilter = null;
                          _sizeFilter = null;
                        }),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final beverage = items[index];
                      return ListTile(
                        title: Text('${beverage.beverageType} - ${beverage.size}'),
                        subtitle: Text(
                            '${beverage.sweetener} | ${beverage.toppings.join(', ')} | \$${beverage.price}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar bebida',
                              onPressed: () => _openForm(beverage),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Eliminar bebida',
                              onPressed: () => _deleteBeverage(beverage.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
