import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/maintenance_repository.dart';
import '../validators/category_form_validator.dart';

class CategoryService {
  final MaintenanceRepository repository;
  final CategoryFormValidator validator;

  CategoryService(this.repository, this.validator);

  Future<Either<Failure, Category>> createCategory(Category category) async {
    // Validate category data
    final validationResult = validator.validateAll(
      name: category.name,
      transactionTypeId: category.transactionTypeId,
      description: category.description,
    );

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected validation result'),
      );
    }

    // Create category if validation passes
    return repository.createCategory(category);
  }

  Future<Either<Failure, Category>> updateCategory(Category category) async {
    // Validate category data
    final validationResult = validator.validateAll(
      name: category.name,
      transactionTypeId: category.transactionTypeId,
      description: category.description,
    );

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected validation result'),
      );
    }

    // Update category if validation passes
    return repository.updateCategory(category);
  }

  Future<Either<Failure, Unit>> deleteCategory(String categoryId) {
    return repository.deleteCategory(categoryId);
  }

  Future<Either<Failure, List<Category>>> getCategories({
    required String userId,
    bool? isActive,
  }) {
    return repository.getCategories(userId: userId, isActive: isActive);
  }

  Future<Either<Failure, Category>> getCategory(String categoryId) {
    return repository.getCategory(categoryId);
  }
}
