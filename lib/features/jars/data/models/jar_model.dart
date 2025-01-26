import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:enki_finance/features/jars/domain/entities/jar.dart';

part 'jar_model.freezed.dart';
part 'jar_model.g.dart';

@freezed
class JarModel with _$JarModel {
  const factory JarModel({
    required String id,
    required String userId,
    required String name,
    required double targetPercentage,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _JarModel;

  factory JarModel.fromJson(Map<String, dynamic> json) =>
      _$JarModelFromJson(json);

  factory JarModel.fromEntity(Jar jar) => JarModel(
        id: jar.id,
        userId: jar.userId,
        name: jar.name,
        targetPercentage: jar.targetPercentage,
        createdAt: jar.createdAt,
        updatedAt: jar.updatedAt,
      );

  const JarModel._();

  Jar toEntity() => Jar(
        id: id,
        userId: userId,
        name: name,
        targetPercentage: targetPercentage,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
