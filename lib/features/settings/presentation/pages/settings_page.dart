import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          // User Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Usuario',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Información Personal'),
            onTap: () {
              // TODO: Navigate to user profile
            },
          ),
          const Divider(),

          // Maintenance Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Mantenimiento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías y Subcategorías'),
            subtitle: const Text('Administrar categorías y subcategorías'),
            onTap: () => context.go('/settings/maintenance'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Cuentas'),
            subtitle: const Text('Administrar cuentas y tarjetas'),
            onTap: () => context.go('/settings/accounts'),
          ),
          ListTile(
            leading: const Icon(Icons.savings),
            title: const Text('Jarras'),
            subtitle: const Text('Administrar jarras de ahorro'),
            onTap: () => context.go('/settings/jars'),
          ),
          const Divider(),

          // App Settings Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Aplicación',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            onTap: () {
              // TODO: Navigate to notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Tema'),
            onTap: () {
              // TODO: Navigate to theme settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            onTap: () {
              // TODO: Navigate to language settings
            },
          ),
        ],
      ),
    );
  }
}
