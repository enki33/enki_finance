import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enki_finance/core/error/failures.dart';
import 'package:enki_finance/features/jars/data/datasources/jar_remote_data_source.dart';
import 'package:enki_finance/features/jars/domain/entities/jar_distribution.dart';
import 'package:enki_finance/features/jars/domain/repositories/jar_repository.dart';

class JarRepositoryImpl implements JarRepository {
  const JarRepositoryImpl(this._remoteDataSource);

  final JarRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<JarDistribution>>> analyzeDistribution({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final distributions = await _remoteDataSource.analyzeDistribution(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return right(distributions);
    } on PostgrestException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> executeTransfer({
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
      return right(null);
    } on PostgrestException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isJarRequired(String categoryId) async {
    try {
      final isRequired = await _remoteDataSource.isJarRequired(categoryId);
      return right(isRequired);
    } on PostgrestException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getJarBalance(String jarId) async {
    try {
      final balance = await _remoteDataSource.getJarBalance(jarId);
      return right(balance);
    } on PostgrestException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getJarTargetPercentage(String jarId) async {
    try {
      final percentage = await _remoteDataSource.getJarTargetPercentage(jarId);
      return right(percentage);
    } on PostgrestException catch (e) {
      return left(DatabaseFailure(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
