import 'package:enki_finance/features/account/domain/entities/credit_card_details.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_card_details_model.freezed.dart';
part 'credit_card_details_model.g.dart';

@freezed
class CreditCardDetailsModel with _$CreditCardDetailsModel {
  const factory CreditCardDetailsModel({
    String? id,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'credit_limit') required double creditLimit,
    @JsonKey(name: 'current_interest_rate') required double currentInterestRate,
    @JsonKey(name: 'cut_off_day') required int cutOffDay,
    @JsonKey(name: 'payment_due_day') required int paymentDueDay,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'modified_at') DateTime? modifiedAt,
  }) = _CreditCardDetailsModel;

  const CreditCardDetailsModel._();

  factory CreditCardDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$CreditCardDetailsModelFromJson(json);

  factory CreditCardDetailsModel.fromEntity(CreditCardDetails details) =>
      CreditCardDetailsModel(
        id: details.id,
        accountId: details.accountId,
        creditLimit: details.creditLimit,
        currentInterestRate: details.currentInterestRate,
        cutOffDay: details.cutOffDay,
        paymentDueDay: details.paymentDueDay,
        createdAt: details.createdAt,
        modifiedAt: details.modifiedAt,
      );

  CreditCardDetails toEntity() => CreditCardDetails(
        id: id,
        accountId: accountId,
        creditLimit: creditLimit,
        currentInterestRate: currentInterestRate,
        cutOffDay: cutOffDay,
        paymentDueDay: paymentDueDay,
        createdAt: createdAt,
        modifiedAt: modifiedAt,
      );
}
