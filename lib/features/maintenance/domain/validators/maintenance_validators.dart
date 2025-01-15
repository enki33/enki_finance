import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';

class MaintenanceValidators {
  static String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'El código es requerido';
    }

    // Format validation: only alphanumeric characters and underscores, 2-20 chars
    final codeRegex = RegExp(r'^[a-zA-Z0-9_]{2,20}$');
    if (!codeRegex.hasMatch(value)) {
      return 'El código debe tener entre 2 y 20 caracteres alfanuméricos o guiones bajos';
    }

    return null;
  }

  static String? validateCodeUniqueness(
    String code,
    List<Category> existingCategories, {
    String? excludeId,
  }) {
    final exists = existingCategories.any(
      (category) => category.code == code && category.id != excludeId,
    );

    if (exists) {
      return 'Ya existe una categoría con este código';
    }

    return null;
  }

  static String? validateSubcategoryCodeUniqueness(
    String code,
    String categoryId,
    List<Subcategory> existingSubcategories, {
    String? excludeId,
  }) {
    final exists = existingSubcategories.any(
      (subcategory) =>
          subcategory.code == code &&
          subcategory.categoryId == categoryId &&
          subcategory.id != excludeId,
    );

    if (exists) {
      return 'Ya existe una subcategoría con este código en esta categoría';
    }

    return null;
  }
}
