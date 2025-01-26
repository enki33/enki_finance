import 'package:fpdart/fpdart.dart';
import 'package:enki_finance/core/error/failures.dart';
import 'package:enki_finance/features/jars/domain/entities/jar_distribution.dart';
import 'package:enki_finance/features/jars/domain/entities/jar.dart';

/// Repository interface for jar operations
abstract class JarRepository {
  /// Creates a new jar
  Future<Either<Failure, Jar>> createJar(Jar jar);

  /// Updates an existing jar
  Future<Either<Failure, Jar>> updateJar(Jar jar);

  /// Deletes a jar
  Future<Either<Failure, Unit>> deleteJar(String jarId);

  /// Gets a jar by ID
  Future<Either<Failure, Jar>> getJar(String jarId);

  /// Gets all jars for a user
  Future<Either<Failure, List<Jar>>> getJars(String userId);

  /// Analyzes the distribution of funds across jars for a given period
  Future<Either<Failure, List<JarDistribution>>> analyzeDistribution({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Validates and executes a transfer between jars
  Future<Either<Failure, Unit>> executeTransfer({
    required String userId,
    required String fromJarId,
    required String toJarId,
    required double amount,
    String? description,
    bool isRollover = false,
  });

  /// Checks if a jar is required for a given category
  Future<Either<Failure, bool>> isJarRequired(String categoryId);

  /// Gets the current balance of a jar
  Future<Either<Failure, double>> getJarBalance(String jarId);

  /// Gets the target percentage for a jar
  Future<Either<Failure, double>> getJarTargetPercentage(String jarId);
}
