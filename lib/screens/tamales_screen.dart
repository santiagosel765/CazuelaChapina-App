import 'package:flutter/material.dart';

import '../models/tamale.dart';
import '../services/tamale_service.dart';
import 'tamale_form_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_button.dart';

class TamalesScreen extends StatefulWidget {
  const TamalesScreen({super.key});

  @override
  State<TamalesScreen> createState() => _TamalesScreenState();
}

class _TamalesScreenState extends State<TamalesScreen> {
  final TamaleService _service = TamaleService();
  List<Tamale> _tamales = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTamales();
  }

  Future<void> _loadTamales() async {
    setState(() => _loading = true);
    final items = await _service.fetchTamales();
    setState(() {
      _tamales = items;
      _loading = false;
    });
  }

  Future<void> _deleteTamale(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tamal'),
        content: const Text('¿Desea eliminar este tamal?'),
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
      final ok = await _service.deleteTamale(id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tamal eliminado')),
        );
        await _loadTamales();
      }
    }
  }

  Future<void> _openForm([Tamale? tamale]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TamaleFormScreen(tamale: tamale),
      ),
    );
    if (saved == true) {
      await _loadTamales();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Tamales'),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openForm,
            tooltip: 'Agregar tamal',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          const ChatButton(),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tamales.length,
              itemBuilder: (context, index) {
                final tamale = _tamales[index];
                return ListTile(
                  title: Text('${tamale.tamaleType} - ${tamale.filling}'),
                  subtitle: Text(
                      '${tamale.wrapper} | ${tamale.spiceLevel} | \$${tamale.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Editar tamal',
                        onPressed: () => _openForm(tamale),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Eliminar tamal',
                        onPressed: () => _deleteTamale(tamale.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
