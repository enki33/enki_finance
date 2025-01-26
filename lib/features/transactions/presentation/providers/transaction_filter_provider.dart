import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_filter.dart';

class TransactionFilterNotifier extends StateNotifier<TransactionFilter> {
  TransactionFilterNotifier() : super(const TransactionFilter());

  void setUserId(String userId) {
    state = state.copyWith(
      userId: userId,
    );
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
    );
  }

  void setToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    setDateRange(start, end);
  }

  void setThisWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    setDateRange(
      DateTime(start.year, start.month, start.day),
      end,
    );
  }

  void setThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    setDateRange(start, end);
  }

  void clearDateRange() {
    setDateRange(null, null);
  }

  void setTransactionType(String? typeId) {
    state = state.copyWith(
      transactionTypeId: typeId,
    );
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      subcategoryId: null,
    );
  }

  void setSubcategory(String? subcategoryId) {
    state = state.copyWith(
      subcategoryId: subcategoryId,
    );
  }

  void setJar(String? jarId) {
    state = state.copyWith(
      jarId: jarId,
    );
  }

  void setAccount(String? accountId) {
    state = state.copyWith(
      accountId: accountId,
    );
  }

  void setAmountRange(double? min, double? max) {
    state = state.copyWith(
      minAmount: min,
      maxAmount: max,
    );
  }

  void clearFilters() {
    state = const TransactionFilter();
  }
}

final transactionFilterProvider =
    StateNotifierProvider<TransactionFilterNotifier, TransactionFilter>((ref) {
  return TransactionFilterNotifier();
});
