import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_model.freezed.dart';
part 'account_model.g.dart';

@freezed
class AccountModel with _$AccountModel {
  const factory AccountModel({
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
  }) = _AccountModel;

  const AccountModel._();

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  factory AccountModel.fromEntity(Account account) => AccountModel(
        id: account.id,
        userId: account.userId,
        accountTypeId: account.accountTypeId,
        name: account.name,
        description: account.description,
        currencyId: account.currencyId,
        currentBalance: account.currentBalance,
        isActive: account.isActive,
        createdAt: account.createdAt,
        modifiedAt: account.modifiedAt,
      );

  Account toEntity() => Account(
        id: id,
        userId: userId,
        accountTypeId: accountTypeId,
        name: name,
        description: description,
        currencyId: currencyId,
        currentBalance: currentBalance,
        isActive: isActive,
        createdAt: createdAt,
        modifiedAt: modifiedAt,
      );
}
