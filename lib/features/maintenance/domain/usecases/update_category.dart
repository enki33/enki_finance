import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/maintenance_repository.dart';
import '../validators/category_form_validator.dart';

class UpdateCategory implements UseCase<Category, UpdateCategoryParams> {
  final MaintenanceRepository repository;
  final CategoryFormValidator validator;

  const UpdateCategory(this.repository, this.validator);

  @override
  Future<Either<Failure, Category>> call(UpdateCategoryParams params) async {
    // Validate category data
    final validationResult = validator.validateAll(
      name: params.category.name,
      transactionTypeId: params.category.transactionTypeId,
      description: params.category.description,
    );

    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => throw Exception('Unexpected validation result'),
      );
    }

    // Update category if validation passes
    return repository.updateCategory(params.category);
  }
}

class UpdateCategoryParams {
  final Category category;

  const UpdateCategoryParams({required this.category});
}
