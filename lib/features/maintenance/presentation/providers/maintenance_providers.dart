import 'package:enki_finance/features/maintenance/data/repositories/supabase_maintenance_repository.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const int itemsPerPage = 10;

final maintenanceRepositoryProvider = Provider<SupabaseMaintenanceRepository>(
  (ref) => SupabaseMaintenanceRepository(
    Supabase.instance.client,
  ),
);

// Search and filter providers
final categorySearchQueryProvider = StateProvider<String>((ref) => '');
final subcategorySearchQueryProvider = StateProvider<String>((ref) => '');
final showSystemItemsProvider = StateProvider<bool>((ref) => true);

// Pagination providers
final categoryPageProvider = StateProvider<int>((ref) => 1);
final subcategoryPageProvider = StateProvider<int>((ref) => 1);

// Categories provider with search, filter and pagination
final categoriesProvider = FutureProvider<List<Category>>(
  (ref) async {
    final repository = ref.watch(maintenanceRepositoryProvider);
    final searchQuery = ref.watch(categorySearchQueryProvider).toLowerCase();
    final showSystemItems = ref.watch(showSystemItemsProvider);
    final page = ref.watch(categoryPageProvider);

    final result = await repository.getCategories();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (categories) {
        var filteredCategories = categories;

        // Apply system items filter
        if (!showSystemItems) {
          filteredCategories = filteredCategories
              .where((category) => !category.isSystem)
              .toList();
        }

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          filteredCategories = filteredCategories.where((category) {
            return category.code.toLowerCase().contains(searchQuery) ||
                category.name.toLowerCase().contains(searchQuery) ||
                (category.description?.toLowerCase().contains(searchQuery) ??
                    false);
          }).toList();
        }

        // Sort by name
        filteredCategories.sort((a, b) => a.name.compareTo(b.name));

        // Calculate total pages
        final totalItems = filteredCategories.length;
        final totalPages = (totalItems / itemsPerPage).ceil();
        ref.read(categoryTotalPagesProvider.notifier).state = totalPages;

        // Apply pagination
        final startIndex = (page - 1) * itemsPerPage;
        final endIndex = startIndex + itemsPerPage;
        return filteredCategories.sublist(
          startIndex,
          endIndex > totalItems ? totalItems : endIndex,
        );
      },
    );
  },
);

// Subcategories provider with search, filter and pagination
final subcategoriesProvider = FutureProvider.family<List<Subcategory>, String?>(
  (ref, categoryId) async {
    final repository = ref.watch(maintenanceRepositoryProvider);
    final searchQuery = ref.watch(subcategorySearchQueryProvider).toLowerCase();
    final showSystemItems = ref.watch(showSystemItemsProvider);
    final page = ref.watch(subcategoryPageProvider);

    final result = await repository.getSubcategories(categoryId: categoryId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (subcategories) {
        var filteredSubcategories = subcategories;

        // Apply system items filter
        if (!showSystemItems) {
          filteredSubcategories = filteredSubcategories
              .where((subcategory) => !subcategory.isSystem)
              .toList();
        }

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          filteredSubcategories = filteredSubcategories.where((subcategory) {
            return subcategory.code.toLowerCase().contains(searchQuery) ||
                subcategory.name.toLowerCase().contains(searchQuery) ||
                (subcategory.description?.toLowerCase().contains(searchQuery) ??
                    false);
          }).toList();
        }

        // Sort by name
        filteredSubcategories.sort((a, b) => a.name.compareTo(b.name));

        // Calculate total pages
        final totalItems = filteredSubcategories.length;
        final totalPages = (totalItems / itemsPerPage).ceil();
        ref.read(subcategoryTotalPagesProvider.notifier).state = totalPages;

        // Apply pagination
        final startIndex = (page - 1) * itemsPerPage;
        final endIndex = startIndex + itemsPerPage;
        return filteredSubcategories.sublist(
          startIndex,
          endIndex > totalItems ? totalItems : endIndex,
        );
      },
    );
  },
);

final jarsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('jars')
      .select()
      .order('name') as List<dynamic>;

  return response.map((json) => json as Map<String, dynamic>).toList();
});

// Selection providers
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);
final selectedSubcategoryProvider = StateProvider<Subcategory?>((ref) => null);

// Loading states
final isSavingProvider = StateProvider<bool>((ref) => false);
final isDeletingProvider = StateProvider<bool>((ref) => false);

// Pagination info providers
final categoryTotalPagesProvider = StateProvider<int>((ref) => 1);
final subcategoryTotalPagesProvider = StateProvider<int>((ref) => 1);
