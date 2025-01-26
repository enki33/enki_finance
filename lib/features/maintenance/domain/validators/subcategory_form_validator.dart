import 'package:fpdart/fpdart.dart';
import 'package:enki_finance/core/error/failures.dart';

class SubcategoryFormValidator {
  Either<Failure, Unit> validateName(String? name) {
    if (name == null || name.isEmpty) {
      return Left(ValidationFailure('El nombre es requerido'));
    }
    return const Right(unit);
  }

  Either<Failure, Unit> validateCategoryId(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return Left(ValidationFailure('La categoría es requerida'));
    }
    return const Right(unit);
  }

  Either<Failure, Unit> validateDescription(String? description) {
    // Description is optional, so always return Right
    return const Right(unit);
  }

  Either<Failure, Unit> validateJarId(String? jarId) {
    // Jar is optional, so always return Right
    return const Right(unit);
  }

  Either<Failure, Unit> validateAll({
    required String? name,
    required String? categoryId,
    String? description,
    String? jarId,
  }) {
    return validateName(name).fold(
      (failure) => Left(failure),
      (_) => validateCategoryId(categoryId).fold(
        (failure) => Left(failure),
        (_) => validateDescription(description).fold(
          (failure) => Left(failure),
          (_) => validateJarId(jarId),
        ),
      ),
    );
  }
}
