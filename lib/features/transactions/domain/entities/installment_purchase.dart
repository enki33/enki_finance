import 'package:freezed_annotation/freezed_annotation.dart';

part 'installment_purchase.freezed.dart';
part 'installment_purchase.g.dart';

@freezed
class InstallmentPurchase with _$InstallmentPurchase {
  const factory InstallmentPurchase({
    required String id,
    required String userId,
    required double totalAmount,
    required double installmentAmount,
    required int numberOfInstallments,
    required int remainingInstallments,
    required DateTime startDate,
    required String description,
    String? notes,
    required String accountId,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _InstallmentPurchase;

  factory InstallmentPurchase.fromJson(Map<String, dynamic> json) =>
      _$InstallmentPurchaseFromJson(json);
}
