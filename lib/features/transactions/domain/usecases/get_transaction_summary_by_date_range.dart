import 'package:fpdart/fpdart.dart';

import '../entities/transaction_summary.dart' as summary;
import '../repositories/transaction_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class GetTransactionSummaryByDateRange
    implements
        UseCase<List<summary.TransactionSummary>,
            GetTransactionSummaryByDateRangeParams> {
  const GetTransactionSummaryByDateRange(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<summary.TransactionSummary>>> call(
      GetTransactionSummaryByDateRangeParams params) {
    return _repository.getSummaryByDateRange(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetTransactionSummaryByDateRangeParams {
  const GetTransactionSummaryByDateRangeParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  final String userId;
  final DateTime startDate;
  final DateTime endDate;
}
