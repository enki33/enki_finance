import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:enki_finance/features/auth/presentation/providers/auth_provider.dart';
import 'package:enki_finance/features/jars/domain/entities/jar_distribution.dart';
import 'package:enki_finance/features/jars/domain/services/jar_service_provider.dart';

part 'jar_providers.g.dart';

@riverpod
Future<List<JarDistribution>> jarDistributions(
  JarDistributionsRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final authState = await ref.watch(authProvider.future);
  if (authState == null) throw Exception('User not authenticated');

  final jarService = ref.watch(jarServiceProvider);
  return jarService.analyzeDistribution(
    userId: authState.id,
    startDate: startDate,
    endDate: endDate,
  );
}

@riverpod
class JarTransferNotifier extends _$JarTransferNotifier {
  @override
  FutureOr<void> build() async {}

  Future<void> executeTransfer({
    required String fromJarId,
    required String toJarId,
    required double amount,
    String? description,
    bool isRollover = false,
  }) async {
    state = const AsyncLoading();

    try {
      final authState = await ref.read(authProvider.future);
      if (authState == null) throw Exception('User not authenticated');

      final jarService = ref.read(jarServiceProvider);

      await jarService.executeTransfer(
        userId: authState.id,
        fromJarId: fromJarId,
        toJarId: toJarId,
        amount: amount,
        description: description,
        isRollover: isRollover,
      );

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

@riverpod
Future<bool> isJarRequired(
  IsJarRequiredRef ref, {
  required String categoryId,
  String? jarId,
}) async {
  final jarService = ref.watch(jarServiceProvider);
  try {
    await jarService.validateJarRequirement(
      categoryId: categoryId,
      jarId: jarId,
    );
    return true;
  } catch (_) {
    return false;
  }
}

@riverpod
Future<double> jarBalance(
  JarBalanceRef ref,
  String jarId,
) async {
  final jarService = ref.watch(jarServiceProvider);
  return jarService.getJarTargetPercentage(jarId);
}

@riverpod
Future<double> jarTargetPercentage(
  JarTargetPercentageRef ref,
  String jarId,
) async {
  final jarService = ref.watch(jarServiceProvider);
  return jarService.getJarTargetPercentage(jarId);
}
