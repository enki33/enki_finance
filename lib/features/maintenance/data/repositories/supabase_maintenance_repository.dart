import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/subcategory.dart';
import '../../domain/repositories/maintenance_repository.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';

class SupabaseMaintenanceRepository implements MaintenanceRepository {
  final SupabaseClient _client;

  const SupabaseMaintenanceRepository(this._client);

  @override
  Future<Either<Failure, Category>> createCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final json = model.toJson();
      // Remove id field to let Supabase generate it
      json.remove('id');

      final data =
          await _client.from('category').insert(json).select().single();
      final savedCategory = CategoryModel.fromJson(data);
      return Right(savedCategory.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    try {
      if (category.id == null) {
        return Left(ValidationFailure('Category ID cannot be null'));
      }
      final model = CategoryModel.fromEntity(category);
      final data = await _client
          .from('category')
          .update(model.toJson())
          .eq('id', category.id!)
          .select()
          .single();
      final savedCategory = CategoryModel.fromJson(data);
      return Right(savedCategory.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String categoryId) async {
    try {
      await _client.from('category').delete().eq('id', categoryId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories({
    required String userId,
    bool? isActive,
  }) async {
    try {
      final query = _client.from('category').select();
      final filteredQuery =
          isActive != null ? query.eq('is_active', isActive) : query;
      final data = await filteredQuery.order('name');

      final categories = data
          .map((json) => CategoryModel.fromJson(json))
          .map((model) => model.toEntity())
          .toList();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategory(String categoryId) async {
    try {
      final data =
          await _client.from('category').select().eq('id', categoryId).single();
      final category = CategoryModel.fromJson(data);
      return Right(category.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subcategory>> createSubcategory(
      Subcategory subcategory) async {
    try {
      final model = SubcategoryModel.fromEntity(subcategory);
      final json = model.toJson();
      // Remove id field to let Supabase generate it
      json.remove('id');

      final data =
          await _client.from('subcategory').insert(json).select().single();
      final savedSubcategory = SubcategoryModel.fromJson(data);
      return Right(savedSubcategory.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subcategory>> updateSubcategory(
      Subcategory subcategory) async {
    try {
      if (subcategory.id == null) {
        return Left(ValidationFailure('Subcategory ID cannot be null'));
      }
      final model = SubcategoryModel.fromEntity(subcategory);
      final data = await _client
          .from('subcategory')
          .update(model.toJson())
          .eq('id', subcategory.id!)
          .select()
          .single();
      final savedSubcategory = SubcategoryModel.fromJson(data);
      return Right(savedSubcategory.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSubcategory(String subcategoryId) async {
    try {
      await _client.from('subcategory').delete().eq('id', subcategoryId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Subcategory>>> getSubcategories({
    required String categoryId,
    bool? isActive,
  }) async {
    try {
      var query =
          _client.from('subcategory').select().eq('category_id', categoryId);
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final data = await query;
      final subcategories = data
          .map((json) => SubcategoryModel.fromJson(json))
          .map((model) => model.toEntity())
          .toList();
      return Right(subcategories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subcategory>> getSubcategory(
      String subcategoryId) async {
    try {
      final data = await _client
          .from('subcategory')
          .select()
          .eq('id', subcategoryId)
          .single();
      final subcategory = SubcategoryModel.fromJson(data);
      return Right(subcategory.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> importFromCsv(String csvContent) async {
    try {
      // TODO: Implement CSV import
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportToCsv() async {
    try {
      // TODO: Implement CSV export
      return const Right('');
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
