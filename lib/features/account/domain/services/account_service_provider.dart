import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/account_repository_provider.dart';
import 'account_service.dart';

part 'account_service_provider.g.dart';

@riverpod
AccountService accountService(AccountServiceRef ref) {
  return AccountService(ref.watch(accountRepositoryProvider));
}
