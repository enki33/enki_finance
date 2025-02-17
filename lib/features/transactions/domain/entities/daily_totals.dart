import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_totals.freezed.dart';
part 'daily_totals.g.dart';

@freezed
class DailyTotals with _$DailyTotals {
  const factory DailyTotals({
    required DateTime transactionDate,
    required double totalAmount,
    required int transactionCount,
  }) = _DailyTotals;

  factory DailyTotals.fromJson(Map<String, dynamic> json) =>
      _$DailyTotalsFromJson(json);
}
