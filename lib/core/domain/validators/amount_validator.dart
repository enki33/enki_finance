import 'package:fpdart/fpdart.dart';
import 'package:enki_finance/core/error/failures.dart';

class AmountValidator {
  Either<ValidationFailure, double> validateAmount(
    String? value, {
    double? min,
    double? max,
  }) {
    if (value == null || value.isEmpty) {
      return left(ValidationFailure('Este campo es requerido'));
    }

    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null) {
      return left(ValidationFailure('Ingrese un número válido'));
    }

    if (min != null && number < min) {
      return left(ValidationFailure(
          'El valor debe ser mayor a ${min.toStringAsFixed(2)}'));
    }

    if (max != null && number > max) {
      return left(ValidationFailure(
          'El valor debe ser menor a ${max.toStringAsFixed(2)}'));
    }

    return right(number);
  }

  Either<ValidationFailure, double> validatePositiveAmount(String? value) {
    return validateAmount(value, min: 0);
  }

  Either<ValidationFailure, double> validateNonZeroAmount(String? value) {
    return validateAmount(value, min: 0.01);
  }

  Either<ValidationFailure, double> validatePercentage(String? value) {
    return validateAmount(value, min: 0, max: 100);
  }
}
