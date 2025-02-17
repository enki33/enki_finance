import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'goal_progress_service.dart';
import '../../data/repositories/goal_repository_provider.dart';

part 'goal_progress_service_provider.g.dart';

@riverpod
GoalProgressService goalProgressService(GoalProgressServiceRef ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return GoalProgressService(repository);
}
