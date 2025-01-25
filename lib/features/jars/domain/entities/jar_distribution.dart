import 'package:freezed_annotation/freezed_annotation.dart';

part 'jar_distribution.freezed.dart';

/// Represents the distribution analysis of a jar
@freezed
class JarDistribution with _$JarDistribution {
  const factory JarDistribution({
    required String jarName,
    required double currentPercentage,
    required double targetPercentage,
    required double difference,
    required bool isCompliant,
  }) = _JarDistribution;
}
