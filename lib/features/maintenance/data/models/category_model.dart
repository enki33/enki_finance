import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String code,
    required String name,
    String? description,
    @Default(false) bool isSystem,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'modified_at') DateTime? modifiedAt,
  }) = _CategoryModel;

  const CategoryModel._();

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromEntity(Category category) => CategoryModel(
        id: category.id,
        code: category.code,
        name: category.name,
        description: category.description,
        isSystem: category.isSystem,
        createdAt: category.createdAt,
        modifiedAt: category.modifiedAt,
      );

  Category toEntity() => Category(
        id: id,
        code: code,
        name: name,
        description: description,
        isSystem: isSystem,
        createdAt: createdAt,
        modifiedAt: modifiedAt,
      );
}
