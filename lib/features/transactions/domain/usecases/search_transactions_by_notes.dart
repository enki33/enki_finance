import 'package:fpdart/fpdart.dart';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SearchTransactionsByNotes
    implements UseCase<List<Transaction>, SearchTransactionsByNotesParams> {
  const SearchTransactionsByNotes(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(
      SearchTransactionsByNotesParams params) {
    return _repository.searchByNotes(
      userId: params.userId,
      searchText: params.searchText,
    );
  }
}

class SearchTransactionsByNotesParams {
  const SearchTransactionsByNotesParams({
    required this.userId,
    required this.searchText,
  });

  final String userId;
  final String searchText;
}
