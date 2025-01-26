import 'package:fpdart/fpdart.dart';
import 'package:enki_finance/core/error/failures.dart';

class DateValidator {
  Either<ValidationFailure, DateTime> validateDate(
    String? value, {
    DateTime? minDate,
    DateTime? maxDate,
  }) {
    if (value == null || value.isEmpty) {
      return left(ValidationFailure('Este campo es requerido'));
    }

    try {
      final date = DateTime.parse(value);

      if (minDate != null && date.isBefore(minDate)) {
        return left(ValidationFailure(
            'La fecha debe ser posterior a ${minDate.toString().split(' ')[0]}'));
      }

      if (maxDate != null && date.isAfter(maxDate)) {
        return left(ValidationFailure(
            'La fecha debe ser anterior a ${maxDate.toString().split(' ')[0]}'));
      }

      return right(date);
    } catch (e) {
      return left(ValidationFailure('Ingrese una fecha válida'));
    }
  }

  Either<ValidationFailure, DateTime> validateTransactionDate(String? value) {
    final now = DateTime.now();
    return validateDate(
      value,
      maxDate: DateTime(now.year, now.month, now.day),
    );
  }
}
