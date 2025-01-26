import 'package:fpdart/fpdart.dart';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetTransactionsByDateRange
    implements UseCase<List<Transaction>, GetTransactionsByDateRangeParams> {
  const GetTransactionsByDateRange(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(
      GetTransactionsByDateRangeParams params) {
    return _repository.getTransactionsByDateRange(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
      transactionTypeId: params.transactionTypeId,
      categoryId: params.categoryId,
      subcategoryId: params.subcategoryId,
      accountId: params.accountId,
      jarId: params.jarId,
    );
  }
}

class GetTransactionsByDateRangeParams {
  const GetTransactionsByDateRangeParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.transactionTypeId,
    this.categoryId,
    this.subcategoryId,
    this.accountId,
    this.jarId,
  });

  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String? transactionTypeId;
  final String? categoryId;
  final String? subcategoryId;
  final String? accountId;
  final String? jarId;
}
