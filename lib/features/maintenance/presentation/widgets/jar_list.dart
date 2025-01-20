import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/jar_form_dialog.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/pagination_controls.dart';

class JarList extends ConsumerStatefulWidget {
  const JarList({super.key});

  @override
  ConsumerState<JarList> createState() => _JarListState();
}

class _JarListState extends ConsumerState<JarList> {
  @override
  void initState() {
    super.initState();
    print('DEBUG: JarList initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('DEBUG: JarList post frame callback');
      ref.invalidate(jarsProvider);
    });
  }

  @override
  void dispose() {
    print('DEBUG: JarList dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: JarList build start');
    final jarsAsync = ref.watch(jarsProvider);
    print('DEBUG: JarList provider state: $jarsAsync');
    final showActiveItems = ref.watch(showActiveJarsProvider);

    print('JarList - Current state: ${jarsAsync.toString()}');

    return Stack(
      children: [
        Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Buscar jarras',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        print('JarList - Search query changed: $value');
                        ref.read(jarSearchQueryProvider.notifier).state = value;
                        ref.read(jarPageProvider.notifier).state = 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Mostrar activos'),
                      Switch(
                        value: showActiveItems,
                        onChanged: (value) {
                          print('JarList - Active filter changed: $value');
                          ref.read(showActiveJarsProvider.notifier).state =
                              value;
                          ref.read(jarPageProvider.notifier).state = 1;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Jar list
            Expanded(
              child: jarsAsync.when(
                data: (jars) {
                  print('JarList - Received ${jars.length} jars');
                  return jars.isEmpty
                      ? const Center(
                          child: Text('No hay jarras disponibles'),
                        )
                      : ListView.builder(
                          itemCount: jars.length + 1,
                          itemBuilder: (context, index) {
                            if (index == jars.length) {
                              return const SizedBox(height: 80);
                            }
                            final jar = jars[index];
                            print(
                                'JarList - Building jar item: ${jar['name']}');
                            return ListTile(
                              leading: const Icon(Icons.savings),
                              title: Text(jar['name'] as String),
                              subtitle: jar['description'] != null
                                  ? Text(jar['description'] as String)
                                  : null,
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Eliminar'),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditDialog(context, ref, jar);
                                  } else if (value == 'delete') {
                                    _showDeleteDialog(context, ref, jar);
                                  }
                                },
                              ),
                            );
                          },
                        );
                },
                loading: () {
                  print('JarList - In loading state');
                  return const Center(child: CircularProgressIndicator());
                },
                error: (error, stack) {
                  print('JarList - Error: $error');
                  print('JarList - Stack trace: $stack');
                  return Center(
                    child: Text('Error: ${error.toString()}'),
                  );
                },
              ),
            ),
            // Pagination controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PaginationControls(
                pageProvider: jarPageProvider,
                totalPagesProvider: jarTotalPagesProvider,
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddDialog(context, ref),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) async {
    final jar = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const JarFormDialog(),
    );

    if (jar != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final client = ref.read(supabaseClientProvider);
        await client.from('jar').insert(jar);
        ref.invalidate(jarsProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, Map<String, dynamic> jar) async {
    final updatedJar = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => JarFormDialog(jar: jar),
    );

    if (updatedJar != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final client = ref.read(supabaseClientProvider);
        await client
            .from('jar')
            .update(updatedJar)
            .eq('id', jar['id'] as String);
        ref.invalidate(jarsProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Map<String, dynamic> jar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Jarra'),
        content: Text(
            '¿Estás seguro que deseas eliminar la jarra "${jar['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(isDeletingProvider.notifier).state = true;
      try {
        final client = ref.read(supabaseClientProvider);
        await client.from('jar').delete().eq('id', jar['id'] as String);
        ref.invalidate(jarsProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        ref.read(isDeletingProvider.notifier).state = false;
      }
    }
  }
}
