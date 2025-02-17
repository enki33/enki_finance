import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_remote_data_source.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource _dataSource;

  const GoalRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Goal>>> getActiveGoals(String userId) async {
    try {
      final goals = await _dataSource.getActiveGoals(userId);
      return right(goals);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Goal>> getGoal(String goalId) async {
    try {
      final goal = await _dataSource.getGoal(goalId);
      return right(goal);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Goal>> createGoal(Goal goal) async {
    try {
      final createdGoal = await _dataSource.createGoal(goal);
      return right(createdGoal);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Goal>> updateGoal(Goal goal) async {
    try {
      final updatedGoal = await _dataSource.updateGoal(goal);
      return right(updatedGoal);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteGoal(String goalId) async {
    try {
      await _dataSource.deleteGoal(goalId);
      return right(unit);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
