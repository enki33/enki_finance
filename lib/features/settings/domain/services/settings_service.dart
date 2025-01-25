import 'package:fpdart/fpdart.dart';
import '../entities/settings.dart';
import '../exceptions/settings_exception.dart';
import '../repositories/settings_repository.dart';

/// Service class for managing settings and system initialization
class SettingsService {
  const SettingsService(this._repository);

  final SettingsRepository _repository;

  /// Get user settings, throws [SettingNotFoundException] if not found
  Future<Settings> getSettings(String userId) async {
    final result = await _repository.getSettings(userId);
    return result.fold(
      (failure) => throw SettingNotFoundException(userId),
      (settings) => settings,
    );
  }

  /// Update user settings, throws [InvalidSettingValueException] if validation fails
  Future<Settings> updateSettings({
    required String userId,
    required Settings settings,
  }) async {
    // Validate settings
    if (settings.notificationAdvanceDays < 1) {
      throw InvalidSettingValueException(
        'notificationAdvanceDays',
        settings.notificationAdvanceDays,
      );
    }

    final result = await _repository.updateSettings(
      userId: userId,
      settings: settings,
    );

    return result.fold(
      (failure) => throw SettingsException(failure.message),
      (settings) => settings,
    );
  }

  /// Initialize system data, throws [SystemInitializationException] if fails
  Future<void> initializeSystemData() async {
    final result = await _repository.initializeSystemData();
    return result.fold(
      (failure) => throw SystemInitializationException(failure.message),
      (r) => r,
    );
  }

  /// Check if system is initialized
  Future<bool> isSystemInitialized() async {
    final result = await _repository.isSystemInitialized();
    return result.fold(
      (failure) => throw SystemInitializationException(failure.message),
      (isInitialized) => isInitialized,
    );
  }
}
