import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/jar.dart';
import '../repositories/jar_repository.dart';

class UpdateJar implements UseCase<Jar, UpdateJarParams> {
  final JarRepository repository;

  const UpdateJar(this.repository);

  @override
  Future<Either<Failure, Jar>> call(UpdateJarParams params) {
    return repository.updateJar(params.jar);
  }
}

class UpdateJarParams {
  final Jar jar;

  const UpdateJarParams({required this.jar});
}
