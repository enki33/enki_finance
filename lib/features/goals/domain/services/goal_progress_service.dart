import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/goal_repository.dart';
import '../entities/goal.dart';

class GoalProgressService {
  final GoalRepository _repository;

  const GoalProgressService(this._repository);

  Future<Either<Failure, double>> calculateProgress(String goalId) async {
    try {
      final goalResult = await _repository.getGoal(goalId);

      return goalResult.fold(
        (failure) => left(failure),
        (goal) {
          if (goal.targetAmount <= 0) {
            return left(ValidationFailure('Invalid target amount'));
          }
          final progress = (goal.currentAmount / goal.targetAmount) * 100;
          return right(progress);
        },
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
