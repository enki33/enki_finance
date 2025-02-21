import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_transaction.freezed.dart';
part 'recurring_transaction.g.dart';

@freezed
class RecurringTransaction with _$RecurringTransaction {
  const factory RecurringTransaction({
    required String id,
    required String userId,
    required String name,
    String? description,
    required double amount,
    required String frequency,
    required DateTime startDate,
    DateTime? endDate,
    required String transactionTypeId,
    required String categoryId,
    required String subcategoryId,
    required String accountId,
    String? jarId,
    required String currencyId,
    required bool isActive,
    DateTime? lastExecutionDate,
    required DateTime nextExecutionDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RecurringTransaction;

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) =>
      _$RecurringTransactionFromJson(json);
}
