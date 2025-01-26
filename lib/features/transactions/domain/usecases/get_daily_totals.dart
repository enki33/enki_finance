import 'package:fpdart/fpdart.dart';

import '../entities/transaction_analysis.dart';
import '../repositories/transaction_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetDailyTotals
    implements UseCase<List<DailyTotals>, GetDailyTotalsParams> {
  const GetDailyTotals(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<DailyTotals>>> call(GetDailyTotalsParams params) {
    return _repository.getDailyTotals(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
      transactionTypeId: params.transactionTypeId,
    );
  }
}

class GetDailyTotalsParams {
  const GetDailyTotalsParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.transactionTypeId,
  });

  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String? transactionTypeId;
}
