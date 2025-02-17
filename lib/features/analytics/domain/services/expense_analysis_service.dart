import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense_trend.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../transactions/domain/entities/transaction.dart';

class ExpenseAnalysisService {
  final TransactionRepository _repository;

  const ExpenseAnalysisService(this._repository);

  Future<Either<Failure, List<ExpenseTrend>>> analyzeExpenseTrends({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final currentPeriodResult = await _repository.getTransactionsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final previousPeriodLength = endDate.difference(startDate).inDays;
      final previousPeriodStart =
          startDate.subtract(Duration(days: previousPeriodLength));
      final previousPeriodResult = await _repository.getTransactionsByDateRange(
        userId: userId,
        startDate: previousPeriodStart,
        endDate: startDate,
      );

      return currentPeriodResult.fold(
        (failure) => left(failure),
        (currentTransactions) => previousPeriodResult.fold(
          (failure) => left(failure),
          (previousTransactions) {
            final currentByCategory =
                _groupTransactionsByCategory(currentTransactions);
            final previousByCategory =
                _groupTransactionsByCategory(previousTransactions);

            // Calculate trends
            final trends = currentByCategory.entries.map((entry) {
              final categoryName = entry.key;
              final currentData = entry.value;
              final previousData = previousByCategory[categoryName];

              final currentAmount = currentData.totalAmount;
              final previousAmount = previousData?.totalAmount ?? 0;
              final percentageChange = previousAmount > 0
                  ? ((currentAmount - previousAmount) / previousAmount) * 100
                  : 100;

              return ExpenseTrend(
                categoryName: categoryName,
                currentAmount: currentAmount,
                previousAmount: previousAmount,
                percentageChange: percentageChange.toDouble(),
                transactionCount: currentData.count,
                averageAmount: currentAmount / currentData.count,
                periodStart: startDate,
                periodEnd: endDate,
                isIncreasing: currentAmount > previousAmount,
              );
            }).toList();

            return right(trends);
          },
        ),
      );
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Map<String, CategoryData> _groupTransactionsByCategory(
      List<Transaction> transactions) {
    final groupedData = <String, CategoryData>{};

    for (final transaction in transactions) {
      final categoryName = transaction.categoryName;
      final data = groupedData.putIfAbsent(
        categoryName,
        () => CategoryData(totalAmount: 0, count: 0),
      );

      data.totalAmount += transaction.amount;
      data.count++;
    }

    return groupedData;
  }
}

class CategoryData {
  double totalAmount;
  int count;

  CategoryData({
    required this.totalAmount,
    required this.count,
  });
}
