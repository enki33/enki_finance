import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/validators/amount_validator.dart';
import '../../features/auth/domain/validators/auth_form_validator.dart';
import '../../features/transactions/domain/validators/date_validator.dart';

final amountValidatorProvider = Provider<AmountValidator>((ref) {
  return AmountValidator();
});

final authFormValidatorProvider = Provider<AuthFormValidator>((ref) {
  return AuthFormValidator();
});

final dateValidatorProvider = Provider<DateValidator>((ref) {
  return DateValidator();
});
