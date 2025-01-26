import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

class AccountFormValidator {
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    return null;
  }

  String? validateBalance(String? value) {
    if (value == null || value.isEmpty) {
      return 'El balance inicial es requerido';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'El balance inicial debe ser un número válido';
    }

    return null;
  }

  String? validateCurrencyId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La moneda es requerida';
    }
    return null;
  }

  String? validateAccountTypeId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El tipo de cuenta es requerido';
    }
    return null;
  }
}
