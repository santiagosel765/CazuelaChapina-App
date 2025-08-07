import 'package:flutter/material.dart';

import '../models/inventory_item.dart';
import '../models/inventory_movement_dto.dart';
import '../services/inventory_service.dart';
import 'inventory_form_screen.dart';
import 'inventory_movement_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_button.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final InventoryService _service = InventoryService();
  List<InventoryItem> _items = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _loading = true);
    final items = await _service.fetchItems();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  List<InventoryItem> get _filteredItems {
    if (_query.isEmpty) return _items;
    return _items
        .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  Future<void> _openForm([InventoryItem? item]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryFormScreen(item: item),
      ),
    );
    if (saved == true) {
      await _loadItems();
    }
  }

  Future<void> _deleteItem(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar insumo'),
        content: const Text('¿Desea eliminar este insumo?'),
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
      final ok = await _service.deleteItem(id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insumo eliminado')),
        );
        await _loadItems();
      }
    }
  }

  Future<void> _moveStock(InventoryItem item, String action) async {
    final dto = await showDialog<InventoryMovementDto>(
      context: context,
      builder: (_) => InventoryMovementDialog(action: action),
    );
    if (dto == null) return;
    if (action != 'entry' && item.isCritical && item.stock < dto.quantity) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock insuficiente para movimiento')),
        );
      }
      return;
    }
    bool ok = false;
    switch (action) {
      case 'entry':
        ok = await _service.registerEntry(item.id, dto);
        break;
      case 'exit':
        ok = await _service.registerExit(item.id, dto);
        break;
      case 'waste':
        ok = await _service.registerWaste(item.id, dto);
        break;
    }
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movimiento registrado')),
      );
      await _loadItems();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar movimiento')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openForm,
            tooltip: 'Agregar artículo',
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
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar',
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          leading: item.isCritical
                              ? const Icon(Icons.warning, color: Colors.red)
                              : null,
                          title: Text(item.name),
                          subtitle:
                              Text('${item.type} | Stock: ${item.stock}'),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_box),
                                tooltip: 'Entrada',
                                onPressed: () => _moveStock(item, 'entry'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.indeterminate_check_box),
                                tooltip: 'Salida',
                                onPressed: () => _moveStock(item, 'exit'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever),
                                tooltip: 'Merma',
                                onPressed: () => _moveStock(item, 'waste'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _openForm(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteItem(item.id),
                              ),
                            ],
                          ),
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
