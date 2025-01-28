import 'package:enki_finance/features/maintenance/domain/entities/category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    String? id,
    required String name,
    String? description,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'transaction_type_id') required String transactionTypeId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'modified_at') DateTime? modifiedAt,
  }) = _CategoryModel;

  const CategoryModel._();

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromEntity(Category category) => CategoryModel(
        id: category.id,
        name: category.name,
        description: category.description,
        isActive: category.isActive,
        transactionTypeId: category.transactionTypeId,
        createdAt: category.createdAt,
        modifiedAt: category.modifiedAt,
      );

  Category toEntity() => Category(
        id: id ?? '',
        name: name,
        description: description,
        isActive: isActive,
        transactionTypeId: transactionTypeId,
        createdAt: createdAt,
        modifiedAt: modifiedAt,
      );
}
