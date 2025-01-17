import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subcategory_model.freezed.dart';
part 'subcategory_model.g.dart';

@freezed
class SubcategoryModel with _$SubcategoryModel {
  const factory SubcategoryModel({
    String? id,
    required String code,
    required String name,
    String? description,
    @JsonKey(name: 'is_system') @Default(true) bool isSystem,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'jar_id') String? jarId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'modified_at') DateTime? modifiedAt,
  }) = _SubcategoryModel;

  const SubcategoryModel._();

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryModelFromJson(json);

  factory SubcategoryModel.fromEntity(Subcategory subcategory) =>
      SubcategoryModel(
        id: subcategory.id,
        code: subcategory.code,
        name: subcategory.name,
        description: subcategory.description,
        isSystem: subcategory.isSystem,
        isActive: subcategory.isActive,
        categoryId: subcategory.categoryId,
        jarId: subcategory.jarId,
        createdAt: subcategory.createdAt,
        modifiedAt: subcategory.modifiedAt,
      );

  Subcategory toEntity() => Subcategory(
        id: id,
        code: code,
        name: name,
        description: description,
        isSystem: isSystem,
        isActive: isActive,
        categoryId: categoryId,
        jarId: jarId,
        createdAt: createdAt,
        modifiedAt: modifiedAt,
      );
}
