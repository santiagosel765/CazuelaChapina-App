import 'package:flutter/material.dart';

import '../models/module.dart';
import '../models/permission.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_button.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen>
    with SingleTickerProviderStateMixin {
  final UserService _service = UserService();
  bool _loading = true;
  List<User> _users = [];
  List<Role> _roles = [];
  List<Module> _modules = [];

  // filters
  final TextEditingController _nameFilter = TextEditingController();
  Role? _roleFilter;
  String? _statusFilter;

  // permissions
  Role? _permRole;
  List<Permission> _permissions = [];
  bool _savingPermissions = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.fetchUsers(),
        _service.fetchRoles(),
        _service.fetchModules(),
      ]);
      setState(() {
        _users = results[0] as List<User>;
        _roles = results[1] as List<Role>;
        _modules = results[2] as List<Module>;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar datos')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<User> get _filteredUsers {
    return _users.where((u) {
      final nameOk = _nameFilter.text.isEmpty ||
          u.fullName.toLowerCase().contains(_nameFilter.text.toLowerCase());
      final roleOk = _roleFilter == null || u.roleId == _roleFilter?.id;
      final statusOk =
          _statusFilter == null || u.status.toLowerCase() == _statusFilter;
      return nameOk && roleOk && statusOk;
    }).toList();
  }

  Future<void> _openUserDialog([User? user]) async {
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final passCtrl = TextEditingController();
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    String status = user?.status ?? 'Activo';
    Role? role;
    if (user != null) {
      try {
        role = _roles.firstWhere((r) => r.id == user.roleId);
      } catch (_) {
        role = null;
      }
    }

    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Nuevo usuario' : 'Editar usuario'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  enabled: user == null,
                ),
                if (user == null)
                  TextFormField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: const [
                    DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                    DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                  ],
                  onChanged: (v) => status = v ?? 'Activo',
                ),
                DropdownButtonFormField<Role>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                      .toList(),
                  onChanged: (v) => role = v,
                  validator: (v) => v == null ? 'Seleccione un rol' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (saved == true) {
      bool ok = false;
      if (user == null) {
        if (role == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Seleccione un rol')),
            );
          }
          return;
        }
        ok = await _service.createUser(
          fullName: nameCtrl.text,
          username: usernameCtrl.text,
          password: passCtrl.text,
          email: emailCtrl.text,
          phone: phoneCtrl.text,
          status: status,
          roleId: role!.id,
        );
      } else {
        ok = await _service.updateUser(user.id, {
          'fullName': nameCtrl.text,
          'email': emailCtrl.text,
          'phone': phoneCtrl.text,
          'status': status,
        });
        if (ok && role != null && role!.id != user.roleId) {
          await _service.assignRole(user.id, role!.id);
        }
      }
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user == null
                ? 'Usuario creado'
                : 'Usuario actualizado'),
          ),
        );
        await _loadAll();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar usuario')),
        );
      }
    }
  }

  Future<void> _changePassword(User user) async {
    final passCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Nueva contraseña'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final success = await _service.changePassword(user.id, passCtrl.text);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cambiar contraseña')),
        );
      }
    }
  }

  Future<void> _assignRole(User user) async {
    if (_roles.isEmpty) return;
    Role? role = _roles.firstWhere((r) => r.id == user.roleId, orElse: () => _roles.first);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar rol'),
        content: DropdownButton<Role>(
          value: role,
          isExpanded: true,
          items: _roles
              .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
              .toList(),
          onChanged: (v) => role = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok == true && role != null) {
      final success = await _service.assignRole(user.id, role!.id);
      if (success) {
        await _loadAll();
      }
    }
  }

  Future<void> _loadPermissions(int roleId) async {
    try {
      final perms = await _service.fetchPermissionsByRole(roleId);
      final map = {for (var p in perms) p.moduleId: p};
      _permissions = _modules
          .map((m) => map[m.id] ?? Permission(moduleId: m.id))
          .toList();
    } catch (_) {
      _permissions =
          _modules.map((m) => Permission(moduleId: m.id)).toList();
    }
    if (mounted) setState(() {});
  }

  Future<void> _savePermissions() async {
    final roleId = _permRole?.id;
    if (roleId == null) return;
    setState(() => _savingPermissions = true);
    final ok = await _service.updatePermissions(roleId, _permissions);
    if (mounted) {
      setState(() => _savingPermissions = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Permisos actualizados' : 'Error al actualizar'),
        ),
      );
    }
  }

  Widget _buildUsersTab() {
    final items = _filteredUsers;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameFilter,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<Role>(
                  value: _roleFilter,
                  hint: const Text('Rol'),
                  isExpanded: true,
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _roleFilter = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _statusFilter,
                  hint: const Text('Estado'),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'activo', child: Text('Activo')),
                    DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                  ],
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Limpiar',
                onPressed: () => setState(() {
                  _nameFilter.clear();
                  _roleFilter = null;
                  _statusFilter = null;
                }),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Usuario')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Teléfono')),
                DataColumn(label: Text('Estado')),
                DataColumn(label: Text('Rol')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: items
                  .map(
                    (u) => DataRow(cells: [
                      DataCell(Text(u.id.toString())),
                      DataCell(Text(u.fullName)),
                      DataCell(Text(u.username)),
                      DataCell(Text(u.email)),
                      DataCell(Text(u.phone)),
                      DataCell(Text(u.status)),
                      DataCell(Text(u.role)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openUserDialog(u),
                          ),
                          IconButton(
                            icon: const Icon(Icons.lock),
                            onPressed: () => _changePassword(u),
                          ),
                          IconButton(
                            icon: const Icon(Icons.security),
                            onPressed: () => _assignRole(u),
                          ),
                        ],
                      )),
                    ]),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRolesTab() {
    return ListView.builder(
      itemCount: _roles.length,
      itemBuilder: (context, index) {
        final role = _roles[index];
        return ListTile(
          title: Text(role.name),
          subtitle: Text(role.description),
          trailing: Icon(
            role.isActive ? Icons.check_circle : Icons.cancel,
            color: role.isActive ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }

  Widget _buildModulesTab() {
    return ListView.builder(
      itemCount: _modules.length,
      itemBuilder: (context, index) {
        final module = _modules[index];
        return ListTile(
          title: Text(module.name),
          subtitle: Text('ID: ${module.id}'),
        );
      },
    );
  }

  Widget _buildPermissionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: DropdownButton<Role>(
            value: _permRole,
            hint: const Text('Seleccione un rol'),
            isExpanded: true,
            items: _roles
                .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                .toList(),
            onChanged: (v) {
              setState(() => _permRole = v);
              if (v != null) {
                _loadPermissions(v.id);
              }
            },
          ),
        ),
        if (_permRole != null)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Módulo')),
                  DataColumn(label: Text('Ver')),
                  DataColumn(label: Text('Crear')),
                  DataColumn(label: Text('Actualizar')),
                  DataColumn(label: Text('Eliminar')),
                ],
                rows: _permissions
                    .map((p) {
                      final moduleName = _modules
                          .firstWhere(
                            (m) => m.id == p.moduleId,
                            orElse: () => Module(id: p.moduleId, name: ''),
                          )
                          .name;
                      return DataRow(cells: [
                        DataCell(Text(moduleName)),
                        DataCell(Checkbox(
                          value: p.canView,
                          onChanged: (v) => setState(() => p.canView = v ?? false),
                        )),
                        DataCell(Checkbox(
                          value: p.canCreate,
                          onChanged: (v) =>
                              setState(() => p.canCreate = v ?? false),
                        )),
                        DataCell(Checkbox(
                          value: p.canUpdate,
                          onChanged: (v) =>
                              setState(() => p.canUpdate = v ?? false),
                        )),
                        DataCell(Checkbox(
                          value: p.canDelete,
                          onChanged: (v) =>
                              setState(() => p.canDelete = v ?? false),
                        )),
                      ]);
                    })
                    .toList(),
              ),
            ),
          ),
        if (_permRole != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: _savingPermissions ? null : _savePermissions,
              child: _savingPermissions
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Builder(builder: (context) {
        final controller = DefaultTabController.of(context)!;
        return AnimatedBuilder(
          animation: controller.animation!,
          builder: (context, _) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Usuarios'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Usuarios'),
                    Tab(text: 'Roles'),
                    Tab(text: 'Módulos'),
                    Tab(text: 'Permisos'),
                  ],
                ),
              ),
              drawer: const AppDrawer(),
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (controller.index == 0) ...[
                    FloatingActionButton(
                      onPressed: () => _openUserDialog(),
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const ChatButton(),
                ],
              ),
              body: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : const TabBarView(
                      children: [
                        _UsersTab(),
                        _RolesTab(),
                        _ModulesTab(),
                        _PermissionsTab(),
                      ],
                    ),
            );
          },
        );
      }),
    );
  }
}

// We need to reference the build methods in TabBarView, but since we cannot pass
// instance methods directly to const TabBarView, we will use Builder widget.

class _UsersTab extends StatelessWidget {
  const _UsersTab();
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_UsersScreenState>()!;
    return state._buildUsersTab();
  }
}

class _RolesTab extends StatelessWidget {
  const _RolesTab();
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_UsersScreenState>()!;
    return state._buildRolesTab();
  }
}

class _ModulesTab extends StatelessWidget {
  const _ModulesTab();
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_UsersScreenState>()!;
    return state._buildModulesTab();
  }
}

class _PermissionsTab extends StatelessWidget {
  const _PermissionsTab();
  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_UsersScreenState>()!;
    return state._buildPermissionsTab();
  }
}
