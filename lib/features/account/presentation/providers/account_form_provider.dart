import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/validators/account_form_validator.dart';

final accountFormValidatorProvider = Provider<AccountFormValidator>((ref) {
  return AccountFormValidator();
});
