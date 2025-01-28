import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category.dart';
import '../providers/maintenance_providers.dart';
import 'category_form_dialog.dart';

class CategoryList extends ConsumerWidget {
  final String userId;
  final void Function(Category category)? onCategorySelected;

  const CategoryList({
    super.key,
    required this.userId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('DEBUG: Building CategoryList');
    final categoriesAsync = ref.watch(categoriesProvider(userId));
    final showActiveItems = ref.watch(showActiveItemsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

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
              data: (categories) {
                print('DEBUG: Loaded ${categories.length} categories');
                return ListView.builder(
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == categories.length) {
                      return const SizedBox(height: 80);
                    }
                    final category = categories[index];
                    final isSelected = selectedCategory?.id == category.id;

                    return Material(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: InkWell(
                        onTap: () {
                          print('DEBUG: Category tapped: ${category.id}');
                          if (onCategorySelected != null) {
                            print(
                                'DEBUG: Calling onCategorySelected with category: ${category.name}');
                            onCategorySelected!(category);
                          }
                        },
                        child: ListTile(
                          title: Text(
                            category.name,
                            style: isSelected
                                ? TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  )
                                : null,
                          ),
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
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudieron cargar las categorías',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.refresh(categoriesProvider(userId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
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
        final service = ref.read(categoryServiceProvider);
        final result = await service.createCategory(category);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(categoriesProvider(userId)),
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
        final service = ref.read(categoryServiceProvider);
        final result = await service.updateCategory(updatedCategory);
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(categoriesProvider(userId)),
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
        final service = ref.read(categoryServiceProvider);
        final result = await service.deleteCategory(category.id ?? '');
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          ),
          (_) => ref.refresh(categoriesProvider(userId)),
        );
      } finally {
        ref.read(isDeletingProvider.notifier).state = false;
      }
    }
  }
}
