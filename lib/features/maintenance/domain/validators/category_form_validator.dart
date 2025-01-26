import 'package:fpdart/fpdart.dart';
import 'package:enki_finance/core/error/failures.dart';

class CategoryFormValidator {
  Either<Failure, Unit> validateName(String? name) {
    if (name == null || name.isEmpty) {
      return Left(ValidationFailure('El nombre es requerido'));
    }
    return const Right(unit);
  }

  Either<Failure, Unit> validateTransactionType(String? transactionTypeId) {
    if (transactionTypeId == null || transactionTypeId.isEmpty) {
      return Left(ValidationFailure('El tipo de transacción es requerido'));
    }
    return const Right(unit);
  }

  Either<Failure, Unit> validateDescription(String? description) {
    // Description is optional, so always return Right
    return const Right(unit);
  }

  Either<Failure, Unit> validateAll({
    required String? name,
    required String? transactionTypeId,
    String? description,
  }) {
    return validateName(name).fold(
      (failure) => Left(failure),
      (_) => validateTransactionType(transactionTypeId).fold(
        (failure) => Left(failure),
        (_) => validateDescription(description),
      ),
    );
  }
}
