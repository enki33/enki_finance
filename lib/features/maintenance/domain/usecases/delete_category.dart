import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/maintenance_repository.dart';

class DeleteCategory implements UseCase<Unit, DeleteCategoryParams> {
  final MaintenanceRepository repository;

  const DeleteCategory(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteCategoryParams params) {
    return repository.deleteCategory(params.categoryId);
  }
}

class DeleteCategoryParams {
  final String categoryId;

  const DeleteCategoryParams({required this.categoryId});
}
