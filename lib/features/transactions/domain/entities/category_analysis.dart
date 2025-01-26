import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_analysis.freezed.dart';
part 'category_analysis.g.dart';

@freezed
class CategoryAnalysis with _$CategoryAnalysis {
  const factory CategoryAnalysis({
    required String categoryName,
    String? subcategoryName,
    required int transactionCount,
    required double totalAmount,
    required double percentageOfTotal,
    required double averageAmount,
    required double minAmount,
    required double maxAmount,
  }) = _CategoryAnalysis;

  factory CategoryAnalysis.fromJson(Map<String, dynamic> json) =>
      _$CategoryAnalysisFromJson(json);
}
