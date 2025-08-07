import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Cazuela Chapina',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          _buildItem(context, Icons.dashboard, 'Dashboard', '/dashboard'),
          _buildItem(context, Icons.inventory, 'Inventario', '/inventory'),
          _buildItem(context, Icons.restaurant_menu, 'Tamales', '/tamales'),
          _buildItem(context, Icons.local_drink, 'Bebidas', '/beverages'),
          _buildItem(context, Icons.fastfood, 'Combos', '/combos'),
          _buildItem(context, Icons.point_of_sale, 'Ventas', '/sales'),
          _buildItem(context, Icons.people, 'Usuarios', '/users'),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () async {
              final auth = AuthService();
              await auth.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}

