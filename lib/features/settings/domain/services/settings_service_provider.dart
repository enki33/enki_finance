import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/settings_repository_provider.dart';
import 'settings_service.dart';

part 'settings_service_provider.g.dart';

@riverpod
SettingsService settingsService(SettingsServiceRef ref) {
  return SettingsService(ref.watch(settingsRepositoryProvider));
}
