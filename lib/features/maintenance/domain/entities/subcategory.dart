import 'package:freezed_annotation/freezed_annotation.dart';

part 'subcategory.freezed.dart';
part 'subcategory.g.dart';

@freezed
class Subcategory with _$Subcategory {
  const factory Subcategory({
    required String id,
    required String code,
    required String name,
    String? description,
    required String categoryId,
    required String jarId,
    @Default(false) bool isSystem,
    required DateTime createdAt,
    DateTime? modifiedAt,
  }) = _Subcategory;

  factory Subcategory.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryFromJson(json);
}
