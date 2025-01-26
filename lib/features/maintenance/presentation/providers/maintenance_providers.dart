import 'package:flutter/material.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/features/maintenance/data/repositories/supabase_maintenance_repository.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../data/repositories/supabase_maintenance_repository.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/subcategory.dart';
import '../../domain/services/category_service.dart';
import '../../domain/services/subcategory_service.dart';
import '../../domain/validators/category_form_validator.dart';
import '../../domain/validators/subcategory_form_validator.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/update_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';

const int itemsPerPage = 10;

// Repository Provider
final maintenanceRepositoryProvider =
    Provider<SupabaseMaintenanceRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SupabaseMaintenanceRepository(supabase);
});

// Validator Providers
final categoryFormValidatorProvider = Provider<CategoryFormValidator>((ref) {
  return CategoryFormValidator();
});

final subcategoryFormValidatorProvider =
    Provider<SubcategoryFormValidator>((ref) {
  return SubcategoryFormValidator();
});

// Service Providers
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final validator = ref.watch(categoryFormValidatorProvider);
  return CategoryService(repository, validator);
});

final subcategoryServiceProvider = Provider<SubcategoryService>((ref) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final validator = ref.watch(subcategoryFormValidatorProvider);
  return SubcategoryService(repository, validator);
});

// Use Case Providers
final createCategoryProvider = Provider<CreateCategory>((ref) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final validator = ref.watch(categoryFormValidatorProvider);
  return CreateCategory(repository, validator);
});

final updateCategoryProvider = Provider<UpdateCategory>((ref) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final validator = ref.watch(categoryFormValidatorProvider);
  return UpdateCategory(repository, validator);
});

final deleteCategoryProvider = Provider<DeleteCategory>((ref) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return DeleteCategory(repository);
});

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
final categoriesProvider =
    FutureProvider.family<List<Category>, String>((ref, userId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  final getCategories = GetCategories(repository);
  final result = await getCategories(userId);
  return result.fold(
    (failure) => throw failure,
    (categories) => categories,
  );
});

// Subcategories provider with search, filter and pagination
final subcategoriesProvider =
    FutureProvider.family<List<Subcategory>, String>((ref, categoryId) async {
  final service = ref.watch(subcategoryServiceProvider);
  final showActiveItems = ref.watch(showActiveItemsProvider);
  final result = await service.getSubcategories(
    categoryId: categoryId,
    isActive: showActiveItems,
  );
  return result.fold(
    (failure) => throw failure,
    (subcategories) => subcategories,
  );
});

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
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase.from('transaction_type').select();
  return Map.fromEntries(
    response.map<MapEntry<String, String>>(
      (type) => MapEntry(type['name'] as String, type['id'] as String),
    ),
  );
});

final accountsProvider = FutureProvider((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final response = await supabase.from('account').select();
  return response;
});
