import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/jar_repository.dart';

class DeleteJar implements UseCase<Unit, DeleteJarParams> {
  final JarRepository repository;

  const DeleteJar(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteJarParams params) {
    return repository.deleteJar(params.jarId);
  }
}

class DeleteJarParams {
  final String jarId;

  const DeleteJarParams({required this.jarId});
}
