import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:enki_finance/features/jars/data/repositories/jar_repository_provider.dart';
import 'package:enki_finance/features/jars/domain/services/jar_service.dart';

part 'jar_service_provider.g.dart';

@riverpod
JarService jarService(JarServiceRef ref) {
  return JarService(ref.watch(jarRepositoryProvider));
}
