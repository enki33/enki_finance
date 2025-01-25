import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/settings.dart';
import '../../domain/services/settings_service_provider.dart';
import '../../domain/exceptions/settings_exception.dart';
import '../../../auth/auth.dart';

part 'settings_providers.g.dart';

@riverpod
Future<Settings> settings(SettingsRef ref) async {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) async {
      if (user == null) {
        throw const SettingsException('User not authenticated');
      }
      return ref.watch(settingsServiceProvider).getSettings(user.id);
    },
    loading: () =>
        throw const SettingsException('Loading authentication state'),
    error: (error, _) => throw SettingsException(error.toString()),
  );
}

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<Settings> build() async {
    final authState = ref.watch(authProvider);
    return authState.when(
      data: (user) async {
        if (user == null) {
          throw const SettingsException('User not authenticated');
        }
        return ref.watch(settingsServiceProvider).getSettings(user.id);
      },
      loading: () =>
          throw const SettingsException('Loading authentication state'),
      error: (error, _) => throw SettingsException(error.toString()),
    );
  }

  Future<void> updateSettings(Settings settings) async {
    final authState = ref.read(authProvider);
    await authState.when(
      data: (user) async {
        if (user == null) {
          throw const SettingsException('User not authenticated');
        }
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(
            () => ref.read(settingsServiceProvider).updateSettings(
                  userId: user.id,
                  settings: settings,
                ));
      },
      loading: () =>
          throw const SettingsException('Loading authentication state'),
      error: (error, _) => throw SettingsException(error.toString()),
    );
  }
}
