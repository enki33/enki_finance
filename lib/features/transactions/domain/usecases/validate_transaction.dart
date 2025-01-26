import 'package:fpdart/fpdart.dart';

import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

class ValidateTransaction implements UseCase<bool, ValidateTransactionParams> {
  const ValidateTransaction(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, bool>> call(ValidateTransactionParams params) {
    return _repository.validateTransaction(
      transaction: params.transaction,
      isUpdate: params.isUpdate,
    );
  }
}

class ValidateTransactionParams {
  const ValidateTransactionParams({
    required this.transaction,
    required this.isUpdate,
  });

  final Transaction transaction;
  final bool isUpdate;
}
