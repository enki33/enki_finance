import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_total.freezed.dart';
part 'daily_total.g.dart';

@freezed
class DailyTotal with _$DailyTotal {
  const factory DailyTotal({
    required DateTime date,
    required double amount,
    required int count,
  }) = _DailyTotal;

  factory DailyTotal.fromJson(Map<String, dynamic> json) =>
      _$DailyTotalFromJson(json);
}
