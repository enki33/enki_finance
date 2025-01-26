import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

class CreditCardFormValidator {
  String? validateCreditLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'El límite de crédito es requerido';
    }

    final limit = double.tryParse(value);
    if (limit == null || limit <= 0) {
      return 'Ingresa un valor válido';
    }

    return null;
  }

  String? validateInterestRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'La tasa de interés es requerida';
    }

    final rate = double.tryParse(value);
    if (rate == null || rate < 0 || rate > 100) {
      return 'Ingresa una tasa de interés válida (0-100)';
    }

    return null;
  }

  String? validateCutOffDay(int? value) {
    if (value == null) {
      return 'El día de corte es requerido';
    }

    if (value < 1 || value > 31) {
      return 'El día de corte debe estar entre 1 y 31';
    }

    return null;
  }

  String? validatePaymentDueDay(int? value, int cutOffDay) {
    if (value == null) {
      return 'El día de pago es requerido';
    }

    if (value < 1 || value > 31) {
      return 'El día de pago debe estar entre 1 y 31';
    }

    if (value <= cutOffDay) {
      return 'El día de pago debe ser posterior al día de corte';
    }

    return null;
  }

  String? validateMinimumPayment(String? value) {
    if (value == null || value.isEmpty) {
      return 'El pago mínimo es requerido';
    }

    final payment = double.tryParse(value);
    if (payment == null || payment < 0 || payment > 100) {
      return 'Ingresa un porcentaje válido (0-100)';
    }

    return null;
  }
}
