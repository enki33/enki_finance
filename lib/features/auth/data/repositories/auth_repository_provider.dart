import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'supabase_auth_repository.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_repository_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return SupabaseAuthRepository(ref.read(supabaseClientProvider));
}
