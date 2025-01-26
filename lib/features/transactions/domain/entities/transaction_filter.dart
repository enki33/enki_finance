import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_filter.freezed.dart';
part 'transaction_filter.g.dart';

mixin TransactionFilterMixin {
  String? get userId;
  DateTime? get startDate;
  DateTime? get endDate;
  String? get transactionTypeId;
  String? get categoryId;
  String? get subcategoryId;
  String? get accountId;
  String? get jarId;
  String? get searchText;
  List<String>? get tags;
  double? get minAmount;
  double? get maxAmount;

  bool get hasFilters =>
      startDate != null ||
      endDate != null ||
      transactionTypeId != null ||
      categoryId != null ||
      subcategoryId != null ||
      accountId != null ||
      jarId != null ||
      searchText != null ||
      minAmount != null ||
      maxAmount != null ||
      (tags?.isNotEmpty ?? false);
}

@freezed
class TransactionFilter with _$TransactionFilter, TransactionFilterMixin {
  const TransactionFilter._();

  const factory TransactionFilter({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionTypeId,
    String? categoryId,
    String? subcategoryId,
    String? accountId,
    String? jarId,
    String? searchText,
    List<String>? tags,
    double? minAmount,
    double? maxAmount,
    @Default(10) int limit,
    @Default(0) int offset,
    @Default('transaction_date') String orderBy,
    @Default('desc') String orderDirection,
  }) = _TransactionFilter;

  factory TransactionFilter.fromJson(Map<String, dynamic> json) =>
      _$TransactionFilterFromJson(json);
}
