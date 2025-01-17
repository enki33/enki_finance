import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  const factory Category({
    String? id,
    required String code,
    required String name,
    String? description,
    @Default(true) bool isSystem,
    @Default(true) bool isActive,
    required String transactionTypeId,
    required DateTime createdAt,
    DateTime? modifiedAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
