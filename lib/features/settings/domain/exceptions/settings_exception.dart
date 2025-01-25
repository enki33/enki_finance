/// Base class for settings-related exceptions
class SettingsException implements Exception {
  const SettingsException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when a setting cannot be found
class SettingNotFoundException extends SettingsException {
  const SettingNotFoundException(String settingName)
      : super('Setting not found: $settingName');
}

/// Thrown when a setting value is invalid
class InvalidSettingValueException extends SettingsException {
  const InvalidSettingValueException(String settingName, dynamic value)
      : super('Invalid value for setting $settingName: $value');
}

/// Thrown when system initialization fails
class SystemInitializationException extends SettingsException {
  const SystemInitializationException(String reason)
      : super('System initialization failed: $reason');
}
