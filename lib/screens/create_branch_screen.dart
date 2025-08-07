import 'package:flutter/material.dart';

import '../models/branch.dart';
import '../services/branch_service.dart';
import '../widgets/chat_button.dart';

class CreateBranchScreen extends StatefulWidget {
  const CreateBranchScreen({super.key});

  @override
  State<CreateBranchScreen> createState() => _CreateBranchScreenState();
}

class _CreateBranchScreenState extends State<CreateBranchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _managerCtrl = TextEditingController();
  final BranchService _service = BranchService();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _managerCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final branch = Branch(
      name: _nameCtrl.text,
      address: _addressCtrl.text,
      manager: _managerCtrl.text,
    );
    final ok = await _service.createBranch(branch);
    setState(() => _saving = false);

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sucursal creada correctamente')),
      );
      Navigator.pop(context, true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear la sucursal')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Sucursal')),
      floatingActionButton: const ChatButton(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese la dirección' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _managerCtrl,
                decoration: const InputDecoration(labelText: 'Encargado'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese el encargado' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _create,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
