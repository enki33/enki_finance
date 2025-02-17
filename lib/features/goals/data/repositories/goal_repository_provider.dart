import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/goal_repository.dart';
import '../repositories/goal_repository_impl.dart';
import '../datasources/goal_remote_data_source.dart';
import '../../../../core/providers/supabase_provider.dart';

part 'goal_repository_provider.g.dart';

@riverpod
GoalRepository goalRepository(GoalRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = GoalRemoteDataSourceImpl(supabase);
  return GoalRepositoryImpl(remoteDataSource);
}
