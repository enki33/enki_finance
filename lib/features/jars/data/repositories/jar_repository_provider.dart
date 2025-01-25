import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/features/jars/data/datasources/jar_remote_data_source.dart';
import 'package:enki_finance/features/jars/data/repositories/jar_repository_impl.dart';
import 'package:enki_finance/features/jars/domain/repositories/jar_repository.dart';

part 'jar_repository_provider.g.dart';

@riverpod
JarRepository jarRepository(JarRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = JarRemoteDataSourceImpl(supabase);
  return JarRepositoryImpl(remoteDataSource);
}
