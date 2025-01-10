import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/auth.dart';
//import '../utils/app_config.dart';

part 'supabase_provider.g.dart';

@riverpod
SupabaseClient supabase(Ref ref) {
  return Supabase.instance.client;
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  return SupabaseAuthRepository(supabase);
}
