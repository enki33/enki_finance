import 'package:fpdart/fpdart.dart';
import 'package:enki_finance/core/error/failures.dart';
import 'package:enki_finance/features/jars/domain/entities/jar_distribution.dart';

/// Repository interface for jar operations
abstract class JarRepository {
  /// Analyzes the distribution of funds across jars for a given period
  Future<Either<Failure, List<JarDistribution>>> analyzeDistribution({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Validates and executes a transfer between jars
  Future<Either<Failure, void>> executeTransfer({
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
