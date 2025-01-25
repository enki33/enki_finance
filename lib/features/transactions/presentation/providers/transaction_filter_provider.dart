import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? transactionTypeId;
  final String? categoryId;
  final String? subcategoryId;
  final String? jarId;
  final String? accountId;
  final double? minAmount;
  final double? maxAmount;

  const TransactionFilter({
    this.startDate,
    this.endDate,
    this.transactionTypeId,
    this.categoryId,
    this.subcategoryId,
    this.jarId,
    this.accountId,
    this.minAmount,
    this.maxAmount,
  });

  TransactionFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? transactionTypeId,
    String? categoryId,
    String? subcategoryId,
    String? jarId,
    String? accountId,
    double? minAmount,
    double? maxAmount,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearTransactionTypeId = false,
    bool clearCategoryId = false,
    bool clearSubcategoryId = false,
    bool clearJarId = false,
    bool clearAccountId = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return TransactionFilter(
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      transactionTypeId: clearTransactionTypeId
          ? null
          : transactionTypeId ?? this.transactionTypeId,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      subcategoryId:
          clearSubcategoryId ? null : subcategoryId ?? this.subcategoryId,
      jarId: clearJarId ? null : jarId ?? this.jarId,
      accountId: clearAccountId ? null : accountId ?? this.accountId,
      minAmount: clearMinAmount ? null : minAmount ?? this.minAmount,
      maxAmount: clearMaxAmount ? null : maxAmount ?? this.maxAmount,
    );
  }

  bool get hasFilters =>
      startDate != null ||
      endDate != null ||
      transactionTypeId != null ||
      categoryId != null ||
      subcategoryId != null ||
      jarId != null ||
      accountId != null ||
      minAmount != null ||
      maxAmount != null;
}

class TransactionFilterNotifier extends StateNotifier<TransactionFilter> {
  TransactionFilterNotifier() : super(const TransactionFilter());

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
      clearStartDate: start == null,
      clearEndDate: end == null,
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
      clearTransactionTypeId: typeId == null,
      clearCategoryId: true,
      clearSubcategoryId: true,
    );
  }

  void setCategory(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
      clearSubcategoryId: true,
    );
  }

  void setSubcategory(String? subcategoryId) {
    state = state.copyWith(
      subcategoryId: subcategoryId,
      clearSubcategoryId: subcategoryId == null,
    );
  }

  void setJar(String? jarId) {
    state = state.copyWith(
      jarId: jarId,
      clearJarId: jarId == null,
    );
  }

  void setAccount(String? accountId) {
    state = state.copyWith(
      accountId: accountId,
      clearAccountId: accountId == null,
    );
  }

  void setAmountRange(double? min, double? max) {
    state = state.copyWith(
      minAmount: min,
      maxAmount: max,
      clearMinAmount: min == null,
      clearMaxAmount: max == null,
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
