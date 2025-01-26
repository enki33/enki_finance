import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/validators/credit_card_form_validator.dart';

final creditCardFormValidatorProvider =
    Provider<CreditCardFormValidator>((ref) {
  return CreditCardFormValidator();
});
