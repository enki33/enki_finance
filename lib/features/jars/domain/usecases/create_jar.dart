import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/jar.dart';
import '../repositories/jar_repository.dart';

class CreateJar implements UseCase<Jar, CreateJarParams> {
  final JarRepository repository;

  const CreateJar(this.repository);

  @override
  Future<Either<Failure, Jar>> call(CreateJarParams params) {
    return repository.createJar(params.jar);
  }
}

class CreateJarParams {
  final Jar jar;

  const CreateJarParams({required this.jar});
}
