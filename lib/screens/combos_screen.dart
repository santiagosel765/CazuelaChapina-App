import 'package:flutter/material.dart';

import '../models/combo.dart';
import '../services/combo_service.dart';
import 'combo_form_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_button.dart';

class CombosScreen extends StatefulWidget {
  const CombosScreen({super.key});

  @override
  State<CombosScreen> createState() => _CombosScreenState();
}

class _CombosScreenState extends State<CombosScreen> {
  final ComboService _service = ComboService();
  List<Combo> _combos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCombos();
  }

  Future<void> _loadCombos() async {
    setState(() => _loading = true);
    final items = await _service.fetchCombos();
    setState(() {
      _combos = items;
      _loading = false;
    });
  }

  Future<void> _openForm([Combo? combo]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ComboFormScreen(combo: combo),
      ),
    );
    if (saved == true) {
      await _loadCombos();
    }
  }

  Future<void> _deleteCombo(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar combo'),
        content: const Text('¿Desea eliminar este combo?'),
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
      final ok = await _service.deleteCombo(id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Combo eliminado')),
        );
        await _loadCombos();
      }
    }
  }

  Future<void> _cloneCombo(int id) async {
    final ok = await _service.cloneCombo(id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Combo clonado')),
      );
      await _loadCombos();
    }
  }

  Future<void> _toggleActive(Combo combo) async {
    if (combo.id == null) return;
    final ok = combo.isActive
        ? await _service.deactivateCombo(combo.id!)
        : await _service.activateCombo(combo.id!);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              combo.isActive ? 'Combo desactivado' : 'Combo activado'),
        ),
      );
      await _loadCombos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combos'),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openForm,
            tooltip: 'Agregar combo',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          const ChatButton(),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _combos.length,
              itemBuilder: (context, index) {
                final combo = _combos[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              combo.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Chip(
                                  label: Text(combo.season.name),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  combo.isActive
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: combo.isActive
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (combo.description.isNotEmpty)
                          Text(combo.description),
                        const SizedBox(height: 4),
                        Text('Precio: \$${combo.price.toStringAsFixed(2)}'),
                        Text('Total: \$${combo.total.toStringAsFixed(2)}'),
                        if (combo.tamales.isNotEmpty)
                          Text(
                              'Tamales: ${combo.tamales.map((e) => '${e.name} x${e.quantity}').join(', ')}'),
                        if (combo.beverages.isNotEmpty)
                          Text(
                              'Bebidas: ${combo.beverages.map((e) => '${e.name} x${e.quantity}').join(', ')}'),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                tooltip: 'Clonar combo',
                                onPressed: () => _cloneCombo(combo.id!),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Editar combo',
                                onPressed: () => _openForm(combo),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Eliminar combo',
                                onPressed: () => _deleteCombo(combo.id!),
                              ),
                              Switch(
                                value: combo.isActive,
                                onChanged: (_) => _toggleActive(combo),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
