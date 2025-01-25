import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/settings_remote_data_source.dart';
import 'settings_repository_impl.dart';

part 'settings_repository_provider.g.dart';

@riverpod
SettingsRepositoryImpl settingsRepository(SettingsRepositoryRef ref) {
  return SettingsRepositoryImpl(
    SettingsRemoteDataSourceImpl(Supabase.instance.client),
  );
}
