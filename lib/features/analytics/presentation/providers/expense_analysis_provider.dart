import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../transactions/data/repositories/transaction_repository_provider.dart';
import '../../domain/entities/expense_trend.dart';
import '../../domain/services/expense_analysis_service.dart';

part 'expense_analysis_provider.g.dart';

@riverpod
ExpenseAnalysisService expenseAnalysisService(ExpenseAnalysisServiceRef ref) {
  return ExpenseAnalysisService(ref.watch(transactionRepositoryProvider));
}

@riverpod
Future<List<ExpenseTrend>> expenseTrends(
  ExpenseTrendsRef ref, {
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final authState = await ref.watch(authProvider.future);
  if (authState == null) throw Exception('User not authenticated');

  final service = ref.watch(expenseAnalysisServiceProvider);
  final result = await service.analyzeExpenseTrends(
    userId: authState.id,
    startDate: startDate,
    endDate: endDate,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (trends) => trends,
  );
}
