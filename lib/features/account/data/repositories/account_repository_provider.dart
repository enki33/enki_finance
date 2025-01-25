import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../datasources/account_remote_data_source.dart';
import './account_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';

part 'account_repository_provider.g.dart';

@riverpod
AccountRepository accountRepository(AccountRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = AccountRemoteDataSourceImpl(supabase: supabase);
  return AccountRepositoryImpl(remoteDataSource: remoteDataSource);
}
