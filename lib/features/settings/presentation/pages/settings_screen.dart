import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('User Information'),
            subtitle: const Text('View and edit your account details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.pushNamed('user-info'),
          ),
          const Divider(),
          // Add more settings options here
        ],
      ),
    );
  }
}
