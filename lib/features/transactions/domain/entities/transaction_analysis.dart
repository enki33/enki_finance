import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_analysis.freezed.dart';

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
