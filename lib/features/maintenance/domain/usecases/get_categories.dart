import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category.dart';
import '../repositories/maintenance_repository.dart';

class GetCategories implements UseCase<List<Category>, String> {
  final MaintenanceRepository repository;

  GetCategories(this.repository);

  @override
  Future<Either<Failure, List<Category>>> call(String userId) async {
    return repository.getCategories(userId: userId);
  }
}
