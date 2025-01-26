import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_history.freezed.dart';
part 'balance_history.g.dart';

/// Represents a change in balance for an account or jar
@freezed
class BalanceHistory with _$BalanceHistory {
  const factory BalanceHistory({
    required String id,
    required String userId,
    String? accountId,
    String? jarId,
    required double oldBalance,
    required double newBalance,
    required double changeAmount,
    required String changeType,
    required String referenceType,
    required String referenceId,
    required DateTime createdAt,
  }) = _BalanceHistory;

  factory BalanceHistory.fromJson(Map<String, dynamic> json) =>
      _$BalanceHistoryFromJson(json);
}

/// Represents the type of balance change
enum BalanceChangeType {
  @JsonValue('TRANSACTION')
  transaction,
  @JsonValue('TRANSFER')
  transfer,
  @JsonValue('ADJUSTMENT')
  adjustment,
  @JsonValue('ROLLOVER')
  rollover,
}

/// Represents the type of entity referenced in the balance history
enum BalanceReferenceType {
  @JsonValue('transaction')
  transaction,
  @JsonValue('transfer')
  transfer,
  @JsonValue('adjustment')
  adjustment,
}
