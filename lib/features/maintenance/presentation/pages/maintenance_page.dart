import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:enki_finance/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/category_form_dialog.dart';
import 'package:enki_finance/features/maintenance/presentation/widgets/subcategory_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenancePage extends ConsumerWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final subcategoriesAsync = ref.watch(
      subcategoriesProvider(selectedCategory?.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context, ref),
          ),
        ],
      ),
      body: Row(
        children: [
          // Categories list
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Categorías',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: categoriesAsync.when(
                      data: (categories) => ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected =
                              category.id == selectedCategory?.id;
                          return ListTile(
                            title: Text(category.name),
                            subtitle: Text(category.description ?? ''),
                            selected: isSelected,
                            onTap: () => ref
                                .read(selectedCategoryProvider.notifier)
                                .state = category,
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Editar'),
                                ),
                                if (!category.isSystem)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Eliminar'),
                                  ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditCategoryDialog(
                                      context, ref, category);
                                } else if (value == 'delete') {
                                  _showDeleteCategoryDialog(
                                      context, ref, category);
                                }
                              },
                            ),
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('Error: ${error.toString()}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Subcategories list
          Expanded(
            flex: 3,
            child: Card(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subcategorías',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (selectedCategory != null)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () =>
                                _showAddSubcategoryDialog(context, ref),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: selectedCategory == null
                        ? const Center(
                            child: Text('Selecciona una categoría'),
                          )
                        : subcategoriesAsync.when(
                            data: (subcategories) => ListView.builder(
                              itemCount: subcategories.length,
                              itemBuilder: (context, index) {
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
                                      if (!subcategory.isSystem)
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Eliminar'),
                                        ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showEditSubcategoryDialog(
                                          context,
                                          ref,
                                          subcategory,
                                        );
                                      } else if (value == 'delete') {
                                        _showDeleteSubcategoryDialog(
                                          context,
                                          ref,
                                          subcategory,
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            error: (error, stack) => Center(
                              child: Text('Error: ${error.toString()}'),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) async {
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

  void _showEditCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
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

  void _showDeleteCategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
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
        final result = await repository.deleteCategory(category.id);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) {
            ref.refresh(categoriesProvider);
            ref.read(selectedCategoryProvider.notifier).state = null;
          },
        );
      } finally {
        ref.read(isDeletingProvider.notifier).state = false;
      }
    }
  }

  void _showAddSubcategoryDialog(BuildContext context, WidgetRef ref) async {
    final selectedCategory = ref.read(selectedCategoryProvider);
    if (selectedCategory == null) return;

    final subcategory = await showDialog<Subcategory>(
      context: context,
      builder: (context) => SubcategoryFormDialog(
        categoryId: selectedCategory.id,
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
          (_) => ref.refresh(subcategoriesProvider(selectedCategory.id)),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showEditSubcategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Subcategory subcategory,
  ) async {
    final selectedCategory = ref.read(selectedCategoryProvider);
    if (selectedCategory == null) return;

    final updatedSubcategory = await showDialog<Subcategory>(
      context: context,
      builder: (context) => SubcategoryFormDialog(
        categoryId: selectedCategory.id,
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
          (_) => ref.refresh(subcategoriesProvider(selectedCategory.id)),
        );
      } finally {
        ref.read(isSavingProvider.notifier).state = false;
      }
    }
  }

  void _showDeleteSubcategoryDialog(
    BuildContext context,
    WidgetRef ref,
    Subcategory subcategory,
  ) async {
    final selectedCategory = ref.read(selectedCategoryProvider);
    if (selectedCategory == null) return;

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
        final result = await repository.deleteSubcategory(subcategory.id);
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
