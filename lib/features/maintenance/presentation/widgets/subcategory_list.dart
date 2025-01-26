import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/subcategory_form_dialog.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/pagination_controls.dart';

class SubcategoryList extends ConsumerWidget {
  final String categoryId;

  const SubcategoryList({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subcategoriesAsync = ref.watch(subcategoriesProvider(categoryId));
    final showActiveItems = ref.watch(showActiveSubcategoriesProvider);

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
                    ref.read(showActiveSubcategoriesProvider.notifier).state =
                        value;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: subcategoriesAsync.when(
              data: (subcategories) => ListView.builder(
                itemCount: subcategories.length + 1,
                itemBuilder: (context, index) {
                  if (index == subcategories.length) {
                    return const SizedBox(height: 80);
                  }
                  final subcategory = subcategories[index];
                  return ListTile(
                    title: Text(subcategory.name),
                    subtitle: Text(subcategory.description ?? ''),
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
                          _showEditDialog(context, ref, subcategory);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, ref, subcategory);
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
    final subcategory = await showDialog<Subcategory>(
      context: context,
      builder: (context) => SubcategoryFormDialog(categoryId: categoryId),
    );

    if (subcategory != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final service = ref.read(subcategoryServiceProvider);
        final result = await service.createSubcategory(subcategory);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(subcategoriesProvider(categoryId)),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, Subcategory subcategory) async {
    final updatedSubcategory = await showDialog<Subcategory>(
      context: context,
      builder: (context) => SubcategoryFormDialog(
        categoryId: categoryId,
        subcategory: subcategory,
      ),
    );

    if (updatedSubcategory != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final service = ref.read(subcategoryServiceProvider);
        final result = await service.updateSubcategory(updatedSubcategory);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(subcategoriesProvider(categoryId)),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Subcategory subcategory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Subcategoría'),
        content: Text(
          '¿Estás seguro que deseas eliminar la subcategoría "${subcategory.name}"?',
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
        final service = ref.read(subcategoryServiceProvider);
        final result = await service.deleteSubcategory(subcategory.id ?? '');
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(subcategoriesProvider(categoryId)),
        );
      } finally {
        ref.read(isDeletingProvider.notifier).state = false;
      }
    }
  }
}
