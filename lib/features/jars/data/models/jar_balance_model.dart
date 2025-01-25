import 'package:freezed_annotation/freezed_annotation.dart';

part 'jar_balance_model.freezed.dart';
part 'jar_balance_model.g.dart';

@freezed
class JarBalanceModel with _$JarBalanceModel {
  const factory JarBalanceModel({
    required String jarId,
    required double currentBalance,
    required DateTime lastUpdated,
  }) = _JarBalanceModel;

  factory JarBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$JarBalanceModelFromJson(json);
}
