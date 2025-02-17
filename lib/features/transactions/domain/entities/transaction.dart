import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String userId,
    required String transactionTypeId,
    required String categoryId,
    required String categoryName,
    String? subcategoryId,
    required String accountId,
    String? jarId,
    required double amount,
    required String currencyId,
    required DateTime transactionDate,
    String? description,
    String? notes,
    List<String>? tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
