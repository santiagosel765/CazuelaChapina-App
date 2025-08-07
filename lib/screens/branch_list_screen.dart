import 'package:flutter/material.dart';

import '../models/branch.dart';
import '../services/branch_service.dart';
import 'branch_report_screen.dart';
import 'create_branch_screen.dart';
import '../widgets/chat_button.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final BranchService _service = BranchService();
  List<Branch> _branches = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() => _loading = true);
    final branches = await _service.getAllBranches();
    setState(() {
      _branches = branches;
      _loading = false;
    });
  }

  List<Branch> get _filtered {
    if (_query.isEmpty) return _branches;
    return _branches.where((b) {
      final q = _query.toLowerCase();
      return b.name.toLowerCase().contains(q) || b.address.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateBranchScreen()),
    );
    if (created == true) {
      await _loadBranches();
    }
  }

  void _openReport(Branch branch) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BranchReportScreen(branch: branch)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branches = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Sucursales')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openCreate,
            tooltip: 'Agregar sucursal',
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
                      hintText: 'Buscar por nombre o dirección',
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: branches.length,
                    itemBuilder: (_, i) {
                      final b = branches[i];
                      return Card(
                        child: ListTile(
                          title: Text('🏢 ${b.name}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📍 ${b.address}'),
                              Text('👤 ${b.manager}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: TextButton(
                            onPressed: () => _openReport(b),
                            child: const Text('Ver Reporte'),
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
