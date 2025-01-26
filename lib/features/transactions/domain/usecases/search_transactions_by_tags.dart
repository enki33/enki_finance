import 'package:fpdart/fpdart.dart';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SearchTransactionsByTags
    implements UseCase<List<Transaction>, SearchTransactionsByTagsParams> {
  const SearchTransactionsByTags(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(
      SearchTransactionsByTagsParams params) {
    return _repository.searchByTags(
      userId: params.userId,
      tags: params.tags,
    );
  }
}

class SearchTransactionsByTagsParams {
  const SearchTransactionsByTagsParams({
    required this.userId,
    required this.tags,
  });

  final String userId;
  final List<String> tags;
}
