import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/maintenance_repository.dart';
import '../validators/category_form_validator.dart';

class CreateCategory implements UseCase<Category, CreateCategoryParams> {
  final MaintenanceRepository repository;
  final CategoryFormValidator validator;

  const CreateCategory(this.repository, this.validator);

  @override
  Future<Either<Failure, Category>> call(CreateCategoryParams params) async {
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

    // Create category if validation passes
    return repository.createCategory(params.category);
  }
}

class CreateCategoryParams {
  final Category category;

  const CreateCategoryParams({required this.category});
}
