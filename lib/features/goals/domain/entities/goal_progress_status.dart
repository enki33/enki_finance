import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_progress_status.freezed.dart';
part 'goal_progress_status.g.dart';

@freezed
class GoalProgressStatus with _$GoalProgressStatus {
  const factory GoalProgressStatus({
    required double percentageComplete,
    required double amountRemaining,
    required int daysRemaining,
    required bool isOnTrack,
    required double requiredDailyAmount,
  }) = _GoalProgressStatus;

  factory GoalProgressStatus.fromJson(Map<String, dynamic> json) =>
      _$GoalProgressStatusFromJson(json);
}
