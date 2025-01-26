import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_summary.freezed.dart';
part 'transaction_summary.g.dart';

@freezed
class TransactionSummary with _$TransactionSummary {
  const factory TransactionSummary({
    required String transactionType,
    required double totalAmount,
    required String currencyId,
    required int transactionCount,
  }) = _TransactionSummary;

  factory TransactionSummary.fromJson(Map<String, dynamic> json) =>
      _$TransactionSummaryFromJson(json);
}
