import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';

@freezed
class Settings with _$Settings {
  const factory Settings({
    required bool notificationsEnabled,
    required int notificationAdvanceDays,
    required String defaultCurrencyId,
    required bool multiCurrencyEnabled,
    required bool recurringTransactionsEnabled,
    required bool exportToExcelEnabled,
  }) = _Settings;
}
