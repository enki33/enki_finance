import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/goal_summary.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';
import 'goal_progress_service.dart';

class GoalSummaryService {
  final GoalRepository _repository;
  final GoalProgressService _progressService;

  const GoalSummaryService(this._repository, this._progressService);

  Future<Either<Failure, List<GoalSummary>>> generateSummary({
    required String userId,
    required DateTime asOf,
  }) async {
    try {
      final goalsResult = await _repository.getActiveGoals(userId);

      return goalsResult.fold(
        (failure) => left(failure),
        (goals) async {
          final summariesFuture = Future.wait(goals.map((goal) async {
            final progressResult =
                await _progressService.calculateProgress(goal.id);

            final percentageComplete = progressResult.fold(
              (failure) => 0.0,
              (progress) => progress,
            );

            final daysRemaining =
                goal.targetDate.difference(DateTime.now()).inDays;
            final isOnTrack = percentageComplete >=
                (DateTime.now().difference(goal.startDate).inDays /
                        goal.targetDate.difference(goal.startDate).inDays) *
                    100;

            return GoalSummary(
              goalId: goal.id,
              name: goal.name,
              targetAmount: goal.targetAmount,
              currentAmount: goal.currentAmount,
              percentageComplete: percentageComplete,
              targetDate: goal.targetDate,
              daysRemaining: daysRemaining,
              isOnTrack: isOnTrack,
              status: _determineStatus(
                percentageComplete,
                goal.targetDate,
              ),
              lastUpdated: goal.updatedAt ?? goal.createdAt,
            );
          }));

          final summaries = await summariesFuture;
          return right(summaries);
        },
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  String _determineStatus(double percentageComplete, DateTime targetDate) {
    if (percentageComplete >= 100) return 'completed';
    if (targetDate.isBefore(DateTime.now())) return 'overdue';
    return 'in_progress';
  }
}
