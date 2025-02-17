import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_trend.freezed.dart';
part 'expense_trend.g.dart';

@freezed
class ExpenseTrend with _$ExpenseTrend {
  const factory ExpenseTrend({
    required String categoryName,
    String? subcategoryName,
    required double currentAmount,
    required double previousAmount,
    required double percentageChange,
    required int transactionCount,
    required double averageAmount,
    required DateTime periodStart,
    required DateTime periodEnd,
    required bool isIncreasing,
  }) = _ExpenseTrend;

  factory ExpenseTrend.fromJson(Map<String, dynamic> json) =>
      _$ExpenseTrendFromJson(json);
}
