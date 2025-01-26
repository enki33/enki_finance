import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_analysis.freezed.dart';

@freezed
class CategoryAnalysis with _$CategoryAnalysis {
  const factory CategoryAnalysis({
    required String categoryName,
    required String? subcategoryName,
    required int transactionCount,
    required double totalAmount,
    required double percentageOfTotal,
    required double averageAmount,
    required double minAmount,
    required double maxAmount,
  }) = _CategoryAnalysis;
}

@freezed
class DailyTotals with _$DailyTotals {
  const factory DailyTotals({
    required DateTime transactionDate,
    required double totalAmount,
    required int transactionCount,
  }) = _DailyTotals;
}

@freezed
class TransactionSummary with _$TransactionSummary {
  const factory TransactionSummary({
    required String transactionType,
    required double totalAmount,
    required String currencyId,
    required int transactionCount,
  }) = _TransactionSummary;
}
