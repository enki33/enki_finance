import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/category_form_dialog.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final showActiveItems = ref.watch(showActiveItemsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Mostrar activos:'),
                const SizedBox(width: 8),
                Switch(
                  value: showActiveItems,
                  onChanged: (value) {
                    ref.read(showActiveItemsProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => ListView.builder(
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == categories.length) {
                    return const SizedBox(height: 80);
                  }
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    subtitle: Text(category.description ?? ''),
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
                          _showEditDialog(context, ref, category);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, ref, category);
                        }
                      },
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) async {
    final category = await showDialog<Category>(
      context: context,
      builder: (context) => const CategoryFormDialog(),
    );

    if (category != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final repository = ref.read(maintenanceRepositoryProvider);
        final result = await repository.createCategory(category);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(categoriesProvider),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, Category category) async {
    final updatedCategory = await showDialog<Category>(
      context: context,
      builder: (context) => CategoryFormDialog(category: category),
    );

    if (updatedCategory != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final repository = ref.read(maintenanceRepositoryProvider);
        final result = await repository.updateCategory(updatedCategory);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(categoriesProvider),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text(
          '¿Estás seguro que deseas eliminar la categoría "${category.name}"?',
        ),
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
        final repository = ref.read(maintenanceRepositoryProvider);
        final result = await repository.deleteCategory(category.id ?? '');
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(categoriesProvider),
        );
      } finally {
        ref.read(isDeletingProvider.notifier).state = false;
      }
    }
  }
}
