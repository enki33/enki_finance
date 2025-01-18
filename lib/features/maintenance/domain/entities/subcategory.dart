import 'package:freezed_annotation/freezed_annotation.dart';

part 'subcategory.freezed.dart';
part 'subcategory.g.dart';

@freezed
class Subcategory with _$Subcategory {
  const factory Subcategory({
    String? id,
    required String name,
    String? description,
    @Default(true) bool isActive,
    required String categoryId,
    String? jarId,
    required DateTime createdAt,
    DateTime? modifiedAt,
  }) = _Subcategory;

  factory Subcategory.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryFromJson(json);
}
