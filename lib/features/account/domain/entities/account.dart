import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    String? id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'account_type_id') required String accountTypeId,
    required String name,
    String? description,
    @JsonKey(name: 'currency_id') required String currencyId,
    @JsonKey(name: 'current_balance') @Default(0) double currentBalance,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'modified_at') DateTime? modifiedAt,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
