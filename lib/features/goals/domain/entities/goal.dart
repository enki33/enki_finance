import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';
part 'goal.g.dart';

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String userId,
    required String name,
    required double targetAmount,
    required double currentAmount,
    required DateTime startDate,
    required DateTime targetDate,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(true) bool isActive,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
