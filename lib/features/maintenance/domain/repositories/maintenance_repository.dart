import 'package:dartz/dartz.dart';
import 'package:enki_finance/core/errors/failures.dart';
import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';

abstract class MaintenanceRepository {
  // Category operations
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, Category>> createCategory(Category category);
  Future<Either<Failure, Category>> updateCategory(Category category);
  Future<Either<Failure, Unit>> deleteCategory(String categoryId);

  // Subcategory operations
  Future<Either<Failure, List<Subcategory>>> getSubcategories(
      {String? categoryId});
  Future<Either<Failure, Subcategory>> createSubcategory(
      Subcategory subcategory);
  Future<Either<Failure, Subcategory>> updateSubcategory(
      Subcategory subcategory);
  Future<Either<Failure, Unit>> deleteSubcategory(String subcategoryId);

  // Import operations
  Future<Either<Failure, Unit>> importFromCsv(String csvContent);
  Future<Either<Failure, String>> exportToCsv();
}
