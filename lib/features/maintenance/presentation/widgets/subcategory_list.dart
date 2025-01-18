import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/subcategory_form_dialog.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/pagination_controls.dart';

class SubcategoryList extends ConsumerWidget {
  const SubcategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final subcategoriesAsync =
        ref.watch(subcategoriesProvider(selectedCategory?.id));
    final showActiveItems = ref.watch(showActiveSubcategoriesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      floatingActionButton: selectedCategory == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddDialog(context, ref, selectedCategory),
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          // Category selector and active/inactive filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: categoriesAsync.when(
                    data: (categories) {
                      if (categories.isEmpty) {
                        return const Center(
                          child: Text('No hay categorías disponibles'),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Seleccionar Categoría',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedCategory?.id,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final category =
                                categories.firstWhere((c) => c.id == value);
                            ref.read(selectedCategoryProvider.notifier).state =
                                category;
                          }
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Error: ${error.toString()}'),
                    ),
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
                        ref
                            .read(showActiveSubcategoriesProvider.notifier)
                            .state = value;
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (selectedCategory == null)
            const Expanded(
              child: Center(
                child:
                    Text('Selecciona una categoría para ver sus subcategorías'),
              ),
            )
          else ...[
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar subcategorías',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ref.read(subcategorySearchQueryProvider.notifier).state =
                      value;
                  ref.read(subcategoryPageProvider.notifier).state = 1;
                },
              ),
            ),
            const SizedBox(height: 16),
            // List of subcategories
            Expanded(
              child: subcategoriesAsync.when(
                data: (subcategories) => subcategories.isEmpty
                    ? const Center(
                        child: Text('No hay subcategorías disponibles'),
                      )
                    : ListView.builder(
                        itemCount: subcategories.length +
                            1, // Add one for bottom padding
                        itemBuilder: (context, index) {
                          if (index == subcategories.length) {
                            return const SizedBox(height: 80); // Bottom padding
                          }
                          final subcategory = subcategories[index];
                          return ListTile(
                            title: Text(subcategory.name),
                            subtitle: subcategory.description != null
                                ? Text(subcategory.description!)
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
            // Pagination controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PaginationControls(
                pageProvider: subcategoryPageProvider,
                totalPagesProvider: subcategoryTotalPagesProvider,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddDialog(
      BuildContext context, WidgetRef ref, Category category) async {
    final subcategory = await showDialog<Subcategory>(
      context: context,
      builder: (context) => SubcategoryFormDialog(
        categoryId: category.id!,
      ),
    );

    if (subcategory != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final repository = ref.read(maintenanceRepositoryProvider);
        final result = await repository.createSubcategory(subcategory);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(subcategoriesProvider(category.id)),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, Subcategory subcategory) async {
    if (subcategory.categoryId == null) return;

    final updatedSubcategory = await showDialog<Subcategory>(
      context: context,
      builder: (context) => SubcategoryFormDialog(
        categoryId: subcategory.categoryId!,
        subcategory: subcategory,
      ),
    );

    if (updatedSubcategory != null) {
      ref.read(isSavingProvider.notifier).state = true;
      try {
        final repository = ref.read(maintenanceRepositoryProvider);
        final result = await repository.updateSubcategory(updatedSubcategory);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(subcategoriesProvider(subcategory.categoryId)),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, Subcategory subcategory) async {
    final selectedCategory = ref.read(selectedCategoryProvider);
    if (selectedCategory == null || subcategory.id == null) return;

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
        final repository = ref.read(maintenanceRepositoryProvider);
        final result = await repository.deleteSubcategory(subcategory.id!);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(subcategoriesProvider(selectedCategory.id)),
        );
      } finally {
        ref.read(isDeletingProvider.notifier).state = false;
      }
    }
  }
}
