import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'main_service.dart';

part 'main_service_provider.g.dart';

@riverpod
MainService mainService(MainServiceRef ref) {
  return const MainService();
}
