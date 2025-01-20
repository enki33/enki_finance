import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/features/maintenance/data/repositories/supabase_maintenance_repository.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
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
final jarSearchQueryProvider = StateProvider<String>((ref) => '');
final showActiveItemsProvider = StateProvider<bool>((ref) => true);
final showActiveSubcategoriesProvider = StateProvider<bool>((ref) => true);
final showActiveJarsProvider = StateProvider<bool>((ref) => true);

// Pagination providers
final categoryPageProvider = StateProvider<int>((ref) => 1);
final subcategoryPageProvider = StateProvider<int>((ref) => 1);
final jarPageProvider = StateProvider<int>((ref) => 1);

// Categories provider with search, filter and pagination
final categoriesProvider = FutureProvider<List<Category>>(
  (ref) async {
    final repository = ref.watch(maintenanceRepositoryProvider);
    final searchQuery = ref.watch(categorySearchQueryProvider).toLowerCase();
    final showActiveItems = ref.watch(showActiveItemsProvider);
    final page = ref.watch(categoryPageProvider);

    final result = await repository.getCategories();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (categories) {
        var filteredCategories = categories;

        // Apply active items filter
        filteredCategories = filteredCategories
            .where((category) => category.isActive == showActiveItems)
            .toList();

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          filteredCategories = filteredCategories.where((category) {
            return category.name.toLowerCase().contains(searchQuery) ||
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
    final showActiveItems = ref.watch(showActiveSubcategoriesProvider);
    final page = ref.watch(subcategoryPageProvider);

    final result = await repository.getSubcategories(categoryId: categoryId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (subcategories) {
        var filteredSubcategories = subcategories;

        // Apply active items filter
        filteredSubcategories = filteredSubcategories
            .where((subcategory) => subcategory.isActive == showActiveItems)
            .toList();

        // Apply search filter
        if (searchQuery.isNotEmpty) {
          filteredSubcategories = filteredSubcategories.where((subcategory) {
            return subcategory.name.toLowerCase().contains(searchQuery) ||
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
  final client = ref.watch(supabaseClientProvider);
  final searchQuery = ref.watch(jarSearchQueryProvider).toLowerCase();
  final showActiveItems = ref.watch(showActiveJarsProvider);
  final page = ref.watch(jarPageProvider);

  try {
    debugPrint('Fetching jars from Supabase...');
    final response = await client.from('jar').select().order('name');

    debugPrint('Supabase response: $response');

    if (response == null) {
      debugPrint('Response is null');
      ref.read(jarTotalPagesProvider.notifier).state = 1;
      return [];
    }

    final List<dynamic> jarsList = response;
    debugPrint('Found ${jarsList.length} jars');

    if (jarsList.isEmpty) {
      ref.read(jarTotalPagesProvider.notifier).state = 1;
      return [];
    }

    var filteredJars =
        jarsList.map((json) => json as Map<String, dynamic>).toList();

    // Apply active items filter
    filteredJars = filteredJars.where((jar) {
      final isActive = jar['is_active'] as bool?;
      return (isActive ?? true) == showActiveItems;
    }).toList();
    debugPrint('After active filter: ${filteredJars.length} jars');

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredJars = filteredJars.where((jar) {
        return jar['name'].toString().toLowerCase().contains(searchQuery) ||
            (jar['description']
                    ?.toString()
                    .toLowerCase()
                    .contains(searchQuery) ??
                false);
      }).toList();
      debugPrint('After search filter: ${filteredJars.length} jars');
    }

    // If no jars after filtering, return empty list
    if (filteredJars.isEmpty) {
      ref.read(jarTotalPagesProvider.notifier).state = 1;
      return [];
    }

    // Calculate total pages
    final totalItems = filteredJars.length;
    final totalPages = (totalItems / itemsPerPage).ceil();
    ref.read(jarTotalPagesProvider.notifier).state = totalPages;

    // Apply pagination
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;

    // Handle case where startIndex is beyond list bounds
    if (startIndex >= totalItems) {
      ref.read(jarPageProvider.notifier).state = 1;
      return filteredJars.sublist(0, itemsPerPage.clamp(0, totalItems));
    }

    return filteredJars.sublist(
      startIndex,
      endIndex > totalItems ? totalItems : endIndex,
    );
  } catch (e, stack) {
    debugPrint('Error fetching jars: $e');
    debugPrint('Stack trace: $stack');
    throw e;
  }
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
final jarTotalPagesProvider = StateProvider<int>((ref) => 1);

final transactionTypesProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final result = await client
      .from('transaction_type')
      .select('id, name')
      .eq('is_active', true);

  return Map.fromEntries((result as List)
      .map((type) => MapEntry(type['name'] as String, type['id'] as String)));
});
