export '../repositories/transaction_repository_impl.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../repositories/transaction_repository_impl.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../../../../core/providers/supabase_provider.dart';

part 'transaction_repository_provider.g.dart';

@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final remoteDataSource = TransactionRemoteDataSourceImpl(supabase);
  return TransactionRepositoryImpl(remoteDataSource);
}
