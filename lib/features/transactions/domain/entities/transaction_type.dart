import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_type.freezed.dart';
part 'transaction_type.g.dart';

@freezed
class TransactionType with _$TransactionType {
  const factory TransactionType({
    required String id,
    required String name,
    required String code,
    required bool isIncome,
    required bool isActive,
    String? description,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TransactionType;

  factory TransactionType.fromJson(Map<String, dynamic> json) =>
      _$TransactionTypeFromJson(json);
}

enum TransactionTypeCode {
  @JsonValue('INCOME')
  income,
  @JsonValue('EXPENSE')
  expense,
  @JsonValue('TRANSFER')
  transfer,
  @JsonValue('ADJUSTMENT')
  adjustment,
}
