import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/core/providers/theme_provider.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema'),
      ),
      body: ListView(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Sistema'),
            subtitle: const Text('Usar el tema del sistema'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Claro'),
            subtitle: const Text('Usar tema claro'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Oscuro'),
            subtitle: const Text('Usar tema oscuro'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
