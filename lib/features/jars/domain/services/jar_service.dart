import 'package:enki_finance/features/jars/domain/entities/jar_distribution.dart';
import 'package:enki_finance/features/jars/domain/exceptions/jar_exception.dart';
import 'package:enki_finance/features/jars/domain/repositories/jar_repository.dart';

/// Service class for jar-related business logic
class JarService {
  const JarService(this._repository);

  final JarRepository _repository;

  /// Analyzes the distribution of funds across jars
  Future<List<JarDistribution>> analyzeDistribution({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = await _repository.analyzeDistribution(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return result.fold(
      (failure) => throw JarDistributionException(failure.message),
      (distributions) => distributions,
    );
  }

  /// Executes a transfer between jars with validation
  Future<void> executeTransfer({
    required String userId,
    required String fromJarId,
    required String toJarId,
    required double amount,
    String? description,
    bool isRollover = false,
  }) async {
    // Validate source jar balance
    final balanceResult = await _repository.getJarBalance(fromJarId);
    final balance = balanceResult.fold(
      (failure) => throw JarTransferException(failure.message),
      (balance) => balance,
    );

    if (balance < amount) {
      throw const JarTransferException(
        'Insufficient balance in source jar for transfer',
      );
    }

    // Execute transfer
    final result = await _repository.executeTransfer(
      userId: userId,
      fromJarId: fromJarId,
      toJarId: toJarId,
      amount: amount,
      description: description,
      isRollover: isRollover,
    );

    result.fold(
      (failure) => throw JarTransferException(failure.message),
      (_) => null,
    );
  }

  /// Validates jar requirements for a category
  Future<void> validateJarRequirement({
    required String categoryId,
    String? jarId,
  }) async {
    final result = await _repository.isJarRequired(categoryId);
    final isRequired = result.fold(
      (failure) => throw JarRequirementException(failure.message),
      (isRequired) => isRequired,
    );

    if (isRequired && jarId == null) {
      throw const JarRequirementException(
        'Jar is required for this category',
      );
    }

    if (!isRequired && jarId != null) {
      throw const JarRequirementException(
        'Jar is not allowed for this category',
      );
    }
  }

  /// Gets the target percentage for a jar
  Future<double> getJarTargetPercentage(String jarId) async {
    final result = await _repository.getJarTargetPercentage(jarId);
    return result.fold(
      (failure) => throw JarException(failure.message),
      (percentage) => percentage,
    );
  }
}
