import 'package:enki_finance/features/maintenance/domain/entities/subcategory.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subcategory_model.freezed.dart';
part 'subcategory_model.g.dart';

@freezed
class SubcategoryModel with _$SubcategoryModel {
  const factory SubcategoryModel({
    required String id,
    required String code,
    required String name,
    String? description,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'jar_id') required String jarId,
    @Default(false) bool isSystem,
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
        categoryId: subcategory.categoryId,
        jarId: subcategory.jarId,
        isSystem: subcategory.isSystem,
        createdAt: subcategory.createdAt,
        modifiedAt: subcategory.modifiedAt,
      );

  Subcategory toEntity() => Subcategory(
        id: id,
        code: code,
        name: name,
        description: description,
        categoryId: categoryId,
        jarId: jarId,
        isSystem: isSystem,
        createdAt: createdAt,
        modifiedAt: modifiedAt,
      );
}
