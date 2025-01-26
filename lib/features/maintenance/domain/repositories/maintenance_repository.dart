import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../entities/subcategory.dart';

abstract class MaintenanceRepository {
  // Category operations
  Future<Either<Failure, Category>> createCategory(Category category);
  Future<Either<Failure, Category>> updateCategory(Category category);
  Future<Either<Failure, Unit>> deleteCategory(String categoryId);
  Future<Either<Failure, List<Category>>> getCategories({
    required String userId,
    bool? isActive,
  });
  Future<Either<Failure, Category>> getCategory(String categoryId);

  // Subcategory operations
  Future<Either<Failure, Subcategory>> createSubcategory(
      Subcategory subcategory);
  Future<Either<Failure, Subcategory>> updateSubcategory(
      Subcategory subcategory);
  Future<Either<Failure, Unit>> deleteSubcategory(String subcategoryId);
  Future<Either<Failure, List<Subcategory>>> getSubcategories({
    required String categoryId,
    bool? isActive,
  });
  Future<Either<Failure, Subcategory>> getSubcategory(String subcategoryId);

  // Import operations
  Future<Either<Failure, Unit>> importFromCsv(String csvContent);
  Future<Either<Failure, String>> exportToCsv();
}
