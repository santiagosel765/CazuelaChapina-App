import 'package:flutter/material.dart';

import '../models/branch.dart';
import '../models/combo.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../services/beverage_service.dart';
import '../services/branch_service.dart';
import '../services/combo_service.dart';
import '../services/sales_service.dart';
import '../services/tamale_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_button.dart';

/// Pantalla para registrar nuevas ventas.
class NewSaleScreen extends StatefulWidget {
  const NewSaleScreen({super.key});

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  final _formKey = GlobalKey<FormState>();

  final SalesService _salesService = SalesService();
  final TamaleService _tamaleService = TamaleService();
  final BeverageService _beverageService = BeverageService();
  final ComboService _comboService = ComboService();
  final BranchService _branchService = BranchService();

  final TextEditingController _quantityCtrl = TextEditingController(text: '1');

  final List<SaleItem> _items = [];
  final Map<int, Combo> _comboMap = {};
  List<_ProductOption> _products = [];
  _ProductOption? _selected;

  List<Branch> _branches = [];
  Branch? _selectedBranch;
  String _payment = 'Efectivo';

  double get _total =>
      _items.fold(0, (p, e) => p + e.price * e.quantity);

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadBranches();
  }

  /// Carga tamales, bebidas y combos disponibles.
  Future<void> _loadProducts() async {
    final tamales = await _tamaleService.fetchTamales();
    final beverages = await _beverageService.fetchBeverages();
    final combos = await _comboService.fetchCombos();
    setState(() {
      _products = [
        ...tamales.map((e) => _ProductOption(
            id: e.id,
            name: e.tamaleType,
            price: e.price,
            type: _ProductType.tamale)),
        ...beverages.map((e) => _ProductOption(
            id: e.id,
            name: e.beverageType,
            price: e.price,
            type: _ProductType.beverage)),
        ...combos.map((e) {
          if (e.id != null) {
            _comboMap[e.id!] = e;
          }
          return _ProductOption(
              id: e.id ?? 0,
              name: e.name,
              price: e.price,
              type: _ProductType.combo);
        }),
      ];
    });
  }

  /// Carga las sucursales disponibles para seleccionar.
  Future<void> _loadBranches() async {
    final branches = await _branchService.getAllBranches();
    setState(() {
      _branches = branches;
      if (branches.isNotEmpty) {
        _selectedBranch = branches.first;
      }
    });
  }

  /// Agrega un producto a la venta, incluyendo los hijos si es un combo.
  void _addItem() {
    if (_selected == null) return;
    final qty = int.tryParse(_quantityCtrl.text) ?? 1;
    final opt = _selected!;
    switch (opt.type) {
      case _ProductType.tamale:
        _items.add(SaleItem(
          id: 'tamale_${opt.id}',
          name: opt.name,
          quantity: qty,
          price: opt.price,
          type: 'Tamale',
        ));
        break;
      case _ProductType.beverage:
        _items.add(SaleItem(
          id: 'beverage_${opt.id}',
          name: opt.name,
          quantity: qty,
          price: opt.price,
          type: 'Beverage',
        ));
        break;
      case _ProductType.combo:
        final combo = _comboMap[opt.id];
        if (combo != null) {
          _items.add(SaleItem(
            id: 'combo_${combo.id}',
            name: combo.name,
            quantity: qty,
            price: combo.price,
            type: 'Combo',
          ));
          for (final t in combo.tamales) {
            _items.add(SaleItem(
              id: 'tamale_${t.id}',
              name: t.name,
              quantity: t.quantity * qty,
              price: 0,
              type: 'Tamale',
            ));
          }
          for (final b in combo.beverages) {
            _items.add(SaleItem(
              id: 'beverage_${b.id}',
              name: b.name,
              quantity: b.quantity * qty,
              price: 0,
              type: 'Beverage',
            ));
          }
        }
        break;
    }
    setState(() {
      _selected = null;
      _quantityCtrl.text = '1';
    });
  }

  /// Elimina un item de la lista.
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  /// Envía la venta al backend o la guarda offline si falla.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _items.isEmpty ||
        _selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revisa la información antes de guardar')));
      return;
    }
    final sale = Sale(
      date: DateTime.now(),
      total: _total,
      paymentMethod: _payment,
      user: 'current_user',
      branchId: _selectedBranch!.id.toString(),
      items: _items,
      synced: true,
    );
    final ok = await _salesService.registerSale(sale);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta creada correctamente')));
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venta guardada offline')));
    }
  }

  /// Sincroniza las ventas almacenadas offline.
  Future<void> _syncOffline() async {
    await _salesService.syncPendingSales();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Sincronización completada')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nueva Venta'),
      ),
      floatingActionButton: const ChatButton(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<Branch>(
                value: _selectedBranch,
                decoration: const InputDecoration(labelText: 'Sucursal'),
                items: _branches
                    .map((b) => DropdownMenuItem(value: b, child: Text(b.name)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBranch = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<_ProductOption>(
                value: _selected,
                decoration: const InputDecoration(labelText: 'Producto'),
                items: _products
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child:
                              Text('${p.name} - Q${p.price.toStringAsFixed(2)}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selected = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                      onPressed: _addItem, child: const Text('Agregar')),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final it = _items[i];
                    return Card(
                      child: ListTile(
                        title: Text('${it.name} x${it.quantity}'),
                        subtitle: Text(it.type),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'Q${(it.price * it.quantity).toStringAsFixed(2)}'),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeItem(i),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _payment,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items: const [
                  DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                ],
                onChanged: (v) => setState(() => _payment = v ?? 'Efectivo'),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              Text('Total: Q${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: _submit, child: const Text('Guardar')),
                  ),
                ],
              ),
              TextButton(
                  onPressed: _syncOffline,
                  child: const Text('Sincronizar ventas offline')),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ProductType { tamale, beverage, combo }

/// Modelo interno para opciones de productos en el formulario.
class _ProductOption {
  final int id;
  final String name;
  final double price;
  final _ProductType type;
  _ProductOption(
      {required this.id,
      required this.name,
      required this.price,
      required this.type});
}

