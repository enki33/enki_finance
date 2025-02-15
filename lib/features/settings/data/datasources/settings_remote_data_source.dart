import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<SettingsModel> getSettings(String userId);
  Future<SettingsModel> updateSettings(String userId, SettingsModel settings);
  Future<void> initializeSystemData();
  Future<bool> isSystemInitialized();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  const SettingsRemoteDataSourceImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<SettingsModel> getSettings(String userId) async {
    final response = await _client
        .from('enki_finance.app_user')
        .select()
        .eq('id', userId)
        .single();

    return SettingsModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<SettingsModel> updateSettings(
      String userId, SettingsModel settings) async {
    final response = await _client
        .from('enki_finance.app_user')
        .update(settings.toJson())
        .eq('id', userId)
        .select()
        .single();

    return SettingsModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> initializeSystemData() async {
    await _client.rpc('initialize_system_data');
  }

  @override
  Future<bool> isSystemInitialized() async {
    final response = await _client
        .from('enki_finance.transaction_type')
        .select('id')
        .limit(1);

    return (response as List).isNotEmpty;
  }
}
