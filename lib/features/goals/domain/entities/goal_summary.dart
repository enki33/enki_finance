import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_summary.freezed.dart';
part 'goal_summary.g.dart';

@freezed
class GoalSummary with _$GoalSummary {
  const factory GoalSummary({
    required String goalId,
    required String name,
    required double targetAmount,
    required double currentAmount,
    required double percentageComplete,
    required DateTime targetDate,
    required int daysRemaining,
    required bool isOnTrack,
    required String status,
    required DateTime lastUpdated,
  }) = _GoalSummary;

  factory GoalSummary.fromJson(Map<String, dynamic> json) =>
      _$GoalSummaryFromJson(json);
}
