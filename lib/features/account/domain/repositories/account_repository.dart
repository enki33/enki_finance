import 'package:dartz/dartz.dart';
import 'package:enki_finance/core/error/failures.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/domain/entities/credit_card_details.dart';

abstract class AccountRepository {
  Future<Either<Failure, List<Account>>> getAccounts();
  Future<Either<Failure, Account>> getAccountById(String id);
  Future<Either<Failure, Account>> createAccount(Account account);
  Future<Either<Failure, Account>> updateAccount(Account account);
  Future<Either<Failure, void>> deleteAccount(String id);

  // Credit card specific operations
  Future<Either<Failure, CreditCardDetails>> getCreditCardDetails(
      String accountId);
  Future<Either<Failure, CreditCardDetails>> createCreditCardDetails(
      CreditCardDetails details);
  Future<Either<Failure, CreditCardDetails>> updateCreditCardDetails(
      CreditCardDetails details);
  Future<Either<Failure, void>> deleteCreditCardDetails(String id);
}
