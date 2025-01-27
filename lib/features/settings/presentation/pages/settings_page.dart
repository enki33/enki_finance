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
            subtitle: const Text('Ver y editar información de usuario'),
            onTap: () => context.go('/settings/user-info'),
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
            onTap: () => context.go('/settings/categories'),
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
            subtitle: const Text('Configurar notificaciones'),
            onTap: () => context.go('/settings/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Tema'),
            subtitle: const Text('Personalizar apariencia'),
            onTap: () => context.go('/settings/theme'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: const Text('Cambiar idioma'),
            onTap: () => context.go('/settings/language'),
          ),
        ],
      ),
    );
  }
}
