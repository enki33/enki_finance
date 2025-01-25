class FormValidators {
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName es requerido'
          : 'Este campo es requerido';
    }
    return null;
  }

  static String? amount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }

    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null) {
      return 'Ingrese un número válido';
    }

    if (min != null && number < min) {
      return 'El valor debe ser mayor a ${min.toStringAsFixed(2)}';
    }

    if (max != null && number > max) {
      return 'El valor debe ser menor a ${max.toStringAsFixed(2)}';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }

    return null;
  }

  static String? password(String? value,
      {int minLength = 8, bool requireSpecialChars = true}) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }

    if (value.length < minLength) {
      return 'La contraseña debe tener al menos $minLength caracteres';
    }

    if (requireSpecialChars &&
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'La contraseña debe contener al menos un carácter especial';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'La contraseña debe contener al menos un número';
    }

    return null;
  }

  static String? phone(String? value, {String countryCode = 'MX'}) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }

    final cleanNumber = value.replaceAll(RegExp(r'[^0-9]'), '');

    switch (countryCode) {
      case 'MX':
        if (!RegExp(r'^\d{10}$').hasMatch(cleanNumber)) {
          return 'Ingrese un número de teléfono válido (10 dígitos)';
        }
        break;
      case 'US':
        if (!RegExp(r'^\d{10}$').hasMatch(cleanNumber)) {
          return 'Enter a valid phone number (10 digits)';
        }
        break;
      default:
        if (!RegExp(r'^\d{10,}$').hasMatch(cleanNumber)) {
          return 'Ingrese un número de teléfono válido';
        }
    }

    return null;
  }

  static String? date(String? value, {DateTime? minDate, DateTime? maxDate}) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }

    try {
      final date = DateTime.parse(value);

      if (minDate != null && date.isBefore(minDate)) {
        return 'La fecha debe ser posterior a ${minDate.toString().split(' ')[0]}';
      }

      if (maxDate != null && date.isAfter(maxDate)) {
        return 'La fecha debe ser anterior a ${maxDate.toString().split(' ')[0]}';
      }

      return null;
    } catch (e) {
      return 'Ingrese una fecha válida';
    }
  }
}
