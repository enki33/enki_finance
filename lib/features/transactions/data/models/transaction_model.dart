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
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      transactionTypeId: transaction.transactionTypeId,
      categoryId: transaction.categoryId,
      categoryName: transaction.categoryName,
      subcategoryId: transaction.subcategoryId,
      accountId: transaction.accountId,
      jarId: transaction.jarId,
      amount: transaction.amount,
      currencyId: transaction.currencyId,
      transactionDate: transaction.transactionDate,
      description: transaction.description,
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
      categoryName: categoryName,
      subcategoryId: subcategoryId,
      accountId: accountId,
      jarId: jarId,
      amount: amount,
      currencyId: currencyId,
      transactionDate: transactionDate,
      description: description,
      notes: notes,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
