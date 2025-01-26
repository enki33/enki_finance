import 'package:fpdart/fpdart.dart';
import 'package:enki_finance/core/error/failures.dart';

class AuthFormValidator {
  Either<ValidationFailure, String> validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return left(ValidationFailure('Este campo es requerido'));
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return left(ValidationFailure('Ingrese un correo electrónico válido'));
    }

    return right(value);
  }

  Either<ValidationFailure, String> validatePassword(
    String? value, {
    int minLength = 8,
    bool requireSpecialChars = true,
  }) {
    if (value == null || value.isEmpty) {
      return left(ValidationFailure('Este campo es requerido'));
    }

    if (value.length < minLength) {
      return left(ValidationFailure(
          'La contraseña debe tener al menos $minLength caracteres'));
    }

    if (requireSpecialChars &&
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return left(ValidationFailure(
          'La contraseña debe contener al menos un carácter especial'));
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return left(ValidationFailure(
          'La contraseña debe contener al menos una letra mayúscula'));
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return left(
          ValidationFailure('La contraseña debe contener al menos un número'));
    }

    return right(value);
  }

  Either<ValidationFailure, String> validatePhone(
    String? value, {
    String countryCode = 'MX',
  }) {
    if (value == null || value.isEmpty) {
      return left(ValidationFailure('Este campo es requerido'));
    }

    final cleanNumber = value.replaceAll(RegExp(r'[^0-9]'), '');

    switch (countryCode) {
      case 'MX':
        if (!RegExp(r'^\d{10}$').hasMatch(cleanNumber)) {
          return left(ValidationFailure(
              'Ingrese un número de teléfono válido (10 dígitos)'));
        }
        break;
      case 'US':
        if (!RegExp(r'^\d{10}$').hasMatch(cleanNumber)) {
          return left(
              ValidationFailure('Enter a valid phone number (10 digits)'));
        }
        break;
      default:
        if (!RegExp(r'^\d{10,}$').hasMatch(cleanNumber)) {
          return left(
              ValidationFailure('Ingrese un número de teléfono válido'));
        }
    }

    return right(cleanNumber);
  }
}
