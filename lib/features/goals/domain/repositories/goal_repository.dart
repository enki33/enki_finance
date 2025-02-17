import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/goal.dart';

abstract class GoalRepository {
  Future<Either<Failure, List<Goal>>> getActiveGoals(String userId);
  Future<Either<Failure, Goal>> getGoal(String goalId);
  Future<Either<Failure, Goal>> createGoal(Goal goal);
  Future<Either<Failure, Goal>> updateGoal(Goal goal);
  Future<Either<Failure, Unit>> deleteGoal(String goalId);
}
