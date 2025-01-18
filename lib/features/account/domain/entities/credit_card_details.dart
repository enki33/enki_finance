import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_card_details.freezed.dart';
part 'credit_card_details.g.dart';

@freezed
class CreditCardDetails with _$CreditCardDetails {
  const factory CreditCardDetails({
    String? id,
    @JsonKey(name: 'account_id') required String accountId,
    @JsonKey(name: 'credit_limit') required double creditLimit,
    @JsonKey(name: 'current_interest_rate') required double currentInterestRate,
    @JsonKey(name: 'cut_off_day') required int cutOffDay,
    @JsonKey(name: 'payment_due_day') required int paymentDueDay,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'modified_at') DateTime? modifiedAt,
  }) = _CreditCardDetails;

  factory CreditCardDetails.fromJson(Map<String, dynamic> json) =>
      _$CreditCardDetailsFromJson(json);
}
