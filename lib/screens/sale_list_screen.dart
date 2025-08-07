import 'package:flutter/material.dart';

import 'package:cazuela_app/screens/new_sale_screen.dart';

import '../models/sale.dart';
import '../services/sales_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_button.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  final SalesService _salesService = SalesService();
  late Future<List<Sale>> _futureSales;
  List<Sale> _pending = [];

  @override
  void initState() {
    super.initState();
    _futureSales = _load();
  }

  Future<List<Sale>> _load() async {
    _pending = await _salesService.getPendingSales();
    return _salesService.fetchSales();
  }

  Future<void> _sync() async {
    await _salesService.syncPendingSales();
    setState(() {
      _futureSales = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pantalla de ventas',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ventas'),
          actions: [
            Semantics(
              button: true,
              label: 'Sincronizar ventas',
              child: IconButton(
                onPressed: _sync,
                tooltip: 'Sincronizar ventas',
                icon: const Icon(Icons.sync),
              ),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Semantics(
              button: true,
              label: 'Nueva venta',
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NewSaleScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('+ Nueva Venta'),
              ),
            ),
            const SizedBox(height: 16),
            const ChatButton(),
          ],
        ),
        body: FutureBuilder<List<Sale>>(
          future: _futureSales,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
          final sales = [..._pending, ...snapshot.data ?? []];
          if (sales.isEmpty) {
            return const Center(child: Text('Sin ventas'));
          }
          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (_, i) {
              final sale = sales[i];
              return Card(
                child: ListTile(
                  title: Text(sale.date.toLocal().toString()),
                  subtitle: Text('Total: Q${sale.total.toStringAsFixed(2)}'),
                  trailing: sale.synced
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.sync, color: Colors.orange),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}

