import 'package:dartz/dartz.dart';
import 'package:enki_finance/core/errors/failures.dart';
import 'package:enki_finance/features/maintenance/data/models/category_model.dart';
import 'package:enki_finance/features/maintenance/data/models/subcategory_model.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:enki_finance/features/maintenance/domain/repositories/maintenance_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMaintenanceRepository implements MaintenanceRepository {
  final SupabaseClient _client;

  SupabaseMaintenanceRepository(this._client);

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await _client.from('category').select().withConverter(
          (data) => data
              .map((json) => CategoryModel.fromJson(json))
              .toList()
              .cast<CategoryModel>());
      return Right(categories.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategory(String id) async {
    try {
      final category = await _client
          .from('category')
          .select()
          .eq('id', id)
          .single()
          .withConverter((data) => CategoryModel.fromJson(data));
      return Right(category.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> createCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      final json = model.toJson();
      // Remove id field to let Supabase generate it
      json.remove('id');

      final savedCategory = await _client
          .from('category')
          .insert(json)
          .select()
          .single()
          .withConverter((data) => CategoryModel.fromJson(data));
      return Right(savedCategory.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) async {
    try {
      final savedCategory = await _client
          .from('category')
          .update(CategoryModel.fromEntity(category).toJson())
          .eq('id', category.id!)
          .select()
          .single()
          .withConverter((data) => CategoryModel.fromJson(data));
      return Right(savedCategory.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Subcategory>>> getSubcategories(
      {String? categoryId}) async {
    try {
      var query = _client.from('subcategory').select();
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      final subcategories = await query.withConverter((data) => data
          .map((json) => SubcategoryModel.fromJson(json))
          .toList()
          .cast<SubcategoryModel>());
      return Right(subcategories.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subcategory>> getSubcategory(String id) async {
    try {
      final subcategory = await _client
          .from('subcategory')
          .select()
          .eq('id', id)
          .single()
          .withConverter((data) => SubcategoryModel.fromJson(data));
      return Right(subcategory.toEntity());
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

      final savedSubcategory = await _client
          .from('subcategory')
          .insert(json)
          .select()
          .single()
          .withConverter((data) => SubcategoryModel.fromJson(data));
      return Right(savedSubcategory.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subcategory>> updateSubcategory(
      Subcategory subcategory) async {
    try {
      final savedSubcategory = await _client
          .from('subcategory')
          .update(SubcategoryModel.fromEntity(subcategory).toJson())
          .eq('id', subcategory.id!)
          .select()
          .single()
          .withConverter((data) => SubcategoryModel.fromJson(data));
      return Right(savedSubcategory.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String categoryId) async {
    try {
      await _client.from('category').delete().match({'id': categoryId});

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSubcategory(String subcategoryId) async {
    try {
      await _client.from('subcategory').delete().match({'id': subcategoryId});

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> importFromCsv(String csvContent) async {
    // TODO: Implement CSV import logic
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> exportToCsv() async {
    // TODO: Implement CSV export logic
    throw UnimplementedError();
  }
}
