import 'package:fpdart/fpdart.dart';

import '../entities/transaction_analysis.dart';
import '../entities/category_analysis.dart';
import '../repositories/transaction_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class AnalyzeTransactionsByCategory
    implements
        UseCase<List<CategoryAnalysis>, AnalyzeTransactionsByCategoryParams> {
  const AnalyzeTransactionsByCategory(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<CategoryAnalysis>>> call(
      AnalyzeTransactionsByCategoryParams params) {
    return _repository.analyzeByCategory(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
      transactionType: params.transactionType,
    );
  }
}

class AnalyzeTransactionsByCategoryParams {
  const AnalyzeTransactionsByCategoryParams({
    required this.userId,
    this.startDate,
    this.endDate,
    this.transactionType,
  });

  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? transactionType;
}
