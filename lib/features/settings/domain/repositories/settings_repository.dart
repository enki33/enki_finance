import 'package:fpdart/fpdart.dart';
import '../entities/settings.dart';
import '../../../../core/error/failures.dart';

/// Repository interface for managing user settings
abstract class SettingsRepository {
  /// Get user settings
  Future<Either<Failure, Settings>> getSettings(String userId);

  /// Update user settings
  Future<Either<Failure, Settings>> updateSettings({
    required String userId,
    required Settings settings,
  });

  /// Initialize system data (transaction types, account types, etc.)
  Future<Either<Failure, void>> initializeSystemData();

  /// Check if system data is initialized
  Future<Either<Failure, bool>> isSystemInitialized();
}
