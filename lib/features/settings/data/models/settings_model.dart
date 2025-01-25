import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/settings.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    @JsonKey(name: 'notifications_enabled') required bool notificationsEnabled,
    @JsonKey(name: 'notification_advance_days')
    required int notificationAdvanceDays,
    @JsonKey(name: 'default_currency_id') required String defaultCurrencyId,
    @JsonKey(name: 'multi_currency_enabled') required bool multiCurrencyEnabled,
    @JsonKey(name: 'recurring_transactions_enabled')
    required bool recurringTransactionsEnabled,
    @JsonKey(name: 'export_to_excel_enabled')
    required bool exportToExcelEnabled,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  factory SettingsModel.fromDomain(Settings settings) => SettingsModel(
        notificationsEnabled: settings.notificationsEnabled,
        notificationAdvanceDays: settings.notificationAdvanceDays,
        defaultCurrencyId: settings.defaultCurrencyId,
        multiCurrencyEnabled: settings.multiCurrencyEnabled,
        recurringTransactionsEnabled: settings.recurringTransactionsEnabled,
        exportToExcelEnabled: settings.exportToExcelEnabled,
      );
}
