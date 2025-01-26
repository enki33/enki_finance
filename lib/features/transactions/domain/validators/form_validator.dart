import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

class TransactionFormValidator {
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un monto';
    }

    final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    if (amount == null) {
      return 'Por favor ingresa un monto válido';
    }

    if (amount <= 0) {
      return 'El monto debe ser mayor a cero';
    }

    return null;
  }

  String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor selecciona $fieldName';
    }
    return null;
  }

  Future<Either<Failure, bool>> isJarRequired(String subcategoryId) async {
    try {
      return const Right(true); // This will be implemented by the repository
    } catch (e) {
      return Left(ValidationFailure(e.toString()));
    }
  }
}
