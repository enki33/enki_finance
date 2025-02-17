import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/goal_summary.dart';
import '../../domain/services/goal_summary_service.dart';
import '../../domain/services/goal_progress_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/goal_repository_provider.dart';
import '../../domain/services/goal_progress_service_provider.dart';

part 'goal_summary_provider.g.dart';

@riverpod
GoalSummaryService goalSummary(GoalSummaryRef ref) {
  return GoalSummaryService(
    ref.watch(goalRepositoryProvider),
    ref.watch(goalProgressServiceProvider),
  );
}

@riverpod
Future<List<GoalSummary>> goalSummaries(
  GoalSummariesRef ref, {
  DateTime? asOf,
}) async {
  final authState = await ref.watch(authProvider.future);
  if (authState == null) throw Exception('User not authenticated');

  final service = ref.watch(goalSummaryProvider);
  final result = await service.generateSummary(
    userId: authState.id,
    asOf: asOf ?? DateTime.now(),
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (summaries) => summaries,
  );
}
