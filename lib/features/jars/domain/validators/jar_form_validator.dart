import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

class JarFormValidator {
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    return null;
  }

  String? validatePercentage(String? value) {
    if (value == null || value.isEmpty) {
      return 'El porcentaje objetivo es requerido';
    }

    final percentage = double.tryParse(value);
    if (percentage == null) {
      return 'Ingresa un porcentaje válido';
    }

    if (percentage < 0 || percentage > 100) {
      return 'El porcentaje debe estar entre 0 y 100';
    }

    return null;
  }

  Future<Either<Failure, Unit>> validateTotalPercentage(
    List<double> existingPercentages,
    double newPercentage,
  ) async {
    final total = existingPercentages.fold<double>(
      0,
      (sum, percentage) => sum + percentage,
    );

    if (total + newPercentage > 100) {
      return Left(ValidationFailure(
        'La suma de los porcentajes no puede exceder 100%',
      ));
    }

    return const Right(unit);
  }
}
