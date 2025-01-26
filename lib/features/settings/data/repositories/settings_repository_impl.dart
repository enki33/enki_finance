import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._remoteDataSource);

  final SettingsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Settings>> getSettings(String userId) async {
    try {
      final settingsModel = await _remoteDataSource.getSettings(userId);
      return Right(Settings(
        notificationsEnabled: settingsModel.notificationsEnabled,
        notificationAdvanceDays: settingsModel.notificationAdvanceDays,
        defaultCurrencyId: settingsModel.defaultCurrencyId,
        multiCurrencyEnabled: settingsModel.multiCurrencyEnabled,
        recurringTransactionsEnabled:
            settingsModel.recurringTransactionsEnabled,
        exportToExcelEnabled: settingsModel.exportToExcelEnabled,
      ));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Settings>> updateSettings({
    required String userId,
    required Settings settings,
  }) async {
    try {
      final settingsModel = SettingsModel.fromDomain(settings);
      final updatedModel =
          await _remoteDataSource.updateSettings(userId, settingsModel);
      return Right(Settings(
        notificationsEnabled: updatedModel.notificationsEnabled,
        notificationAdvanceDays: updatedModel.notificationAdvanceDays,
        defaultCurrencyId: updatedModel.defaultCurrencyId,
        multiCurrencyEnabled: updatedModel.multiCurrencyEnabled,
        recurringTransactionsEnabled: updatedModel.recurringTransactionsEnabled,
        exportToExcelEnabled: updatedModel.exportToExcelEnabled,
      ));
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> initializeSystemData() async {
    try {
      await _remoteDataSource.initializeSystemData();
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isSystemInitialized() async {
    try {
      final isInitialized = await _remoteDataSource.isSystemInitialized();
      return Right(isInitialized);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
