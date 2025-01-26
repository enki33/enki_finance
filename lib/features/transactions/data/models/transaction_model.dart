import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/transaction.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String userId,
    required String transactionTypeId,
    required String categoryId,
    String? subcategoryId,
    required String accountId,
    String? jarId,
    required double amount,
    required String currencyId,
    required DateTime transactionDate,
    String? notes,
    List<String>? tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      transactionTypeId: transaction.transactionTypeId,
      categoryId: transaction.categoryId,
      subcategoryId: transaction.subcategoryId,
      accountId: transaction.accountId,
      jarId: transaction.jarId,
      amount: transaction.amount,
      currencyId: transaction.currencyId,
      transactionDate: transaction.transactionDate,
      notes: transaction.notes,
      tags: transaction.tags,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }
}

extension TransactionModelX on TransactionModel {
  Transaction toEntity() {
    return Transaction(
      id: id,
      userId: userId,
      transactionTypeId: transactionTypeId,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      accountId: accountId,
      jarId: jarId,
      amount: amount,
      currencyId: currencyId,
      transactionDate: transactionDate,
      notes: notes,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
