import 'package:fpdart/fpdart.dart';
import 'package:enki_finance/core/error/failures.dart';
import 'package:enki_finance/features/jars/domain/entities/jar.dart';
import 'package:enki_finance/features/jars/domain/entities/jar_distribution.dart';
import 'package:enki_finance/features/jars/domain/repositories/jar_repository.dart';
import 'package:enki_finance/features/jars/data/datasources/jar_remote_data_source.dart';

class JarRepositoryImpl implements JarRepository {
  final JarRemoteDataSource _remoteDataSource;

  const JarRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Jar>> createJar(Jar jar) async {
    try {
      final result = await _remoteDataSource.createJar(jar);
      return right(result);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteJar(String jarId) async {
    try {
      await _remoteDataSource.deleteJar(jarId);
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Jar>> getJar(String jarId) async {
    try {
      final result = await _remoteDataSource.getJar(jarId);
      return right(result);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Jar>>> getJars(String userId) async {
    try {
      final result = await _remoteDataSource.getJars(userId);
      return right(result);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Jar>> updateJar(Jar jar) async {
    try {
      final result = await _remoteDataSource.updateJar(jar);
      return right(result);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JarDistribution>>> analyzeDistribution({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _remoteDataSource.analyzeDistribution(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return right(result);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> executeTransfer({
    required String userId,
    required String fromJarId,
    required String toJarId,
    required double amount,
    String? description,
    bool isRollover = false,
  }) async {
    try {
      await _remoteDataSource.executeTransfer(
        userId: userId,
        fromJarId: fromJarId,
        toJarId: toJarId,
        amount: amount,
        description: description,
        isRollover: isRollover,
      );
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isJarRequired(String categoryId) async {
    try {
      final result = await _remoteDataSource.isJarRequired(categoryId);
      return right(result);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getJarBalance(String jarId) async {
    try {
      final result = await _remoteDataSource.getJarBalance(jarId);
      return right(result);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getJarTargetPercentage(String jarId) async {
    try {
      final result = await _remoteDataSource.getJarTargetPercentage(jarId);
      return right(result);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
