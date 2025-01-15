import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String userId,
    required DateTime transactionDate,
    String? description,
    required double amount,
    required String transactionTypeId,
    required String categoryId,
    required String subcategoryId,
    required String accountId,
    String? jarId,
    String? transactionMediumId,
    required String currencyId,
    @Default(1.0) double exchangeRate,
    String? notes,
    Map<String, dynamic>? tags,
    @Default(false) bool isRecurring,
    String? parentRecurringId,
    @Default('PENDING') String syncStatus,
    required DateTime createdAt,
    DateTime? modifiedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
