import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/subcategory.dart';
import '../repositories/maintenance_repository.dart';
import '../validators/subcategory_form_validator.dart';

class SubcategoryService {
  final MaintenanceRepository repository;
  final SubcategoryFormValidator validator;

  SubcategoryService(this.repository, this.validator);

  Future<Either<Failure, Subcategory>> createSubcategory(
      Subcategory subcategory) async {
    // Validate subcategory data
    final validationResult = validator.validateAll(
      name: subcategory.name,
      categoryId: subcategory.categoryId,
      description: subcategory.description,
      jarId: subcategory.jarId,
    );

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected validation result'),
      );
    }

    // Create subcategory if validation passes
    return repository.createSubcategory(subcategory);
  }

  Future<Either<Failure, Subcategory>> updateSubcategory(
      Subcategory subcategory) async {
    // Validate subcategory data
    final validationResult = validator.validateAll(
      name: subcategory.name,
      categoryId: subcategory.categoryId,
      description: subcategory.description,
      jarId: subcategory.jarId,
    );

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected validation result'),
      );
    }

    // Update subcategory if validation passes
    return repository.updateSubcategory(subcategory);
  }

  Future<Either<Failure, Unit>> deleteSubcategory(String subcategoryId) {
    return repository.deleteSubcategory(subcategoryId);
  }

  Future<Either<Failure, List<Subcategory>>> getSubcategories({
    required String categoryId,
    bool? isActive,
  }) {
    return repository.getSubcategories(
        categoryId: categoryId, isActive: isActive);
  }

  Future<Either<Failure, Subcategory>> getSubcategory(String subcategoryId) {
    return repository.getSubcategory(subcategoryId);
  }
}
