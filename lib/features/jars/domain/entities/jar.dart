import 'package:freezed_annotation/freezed_annotation.dart';

part 'jar.freezed.dart';

@freezed
class Jar with _$Jar {
  const factory Jar({
    required String id,
    required String userId,
    required String name,
    required double targetPercentage,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Jar;
}
