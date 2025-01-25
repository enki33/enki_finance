import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/account.dart';
import '../entities/credit_card_details.dart';
import '../repositories/account_repository.dart';
import '../exceptions/account_exceptions.dart';

class AccountService {
  const AccountService(this._accountRepository);

  final AccountRepository _accountRepository;

  // Expose repository for direct access when needed
  AccountRepository get repository => _accountRepository;

  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      return await _accountRepository.getAccounts();
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Account>> getAccountById(String id) async {
    try {
      return await _accountRepository.getAccountById(id);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Account>> createAccount(Account account) async {
    try {
      _validateAccountData(account);
      return await _accountRepository.createAccount(account);
    } on AccountException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Account>> updateAccount(Account account) async {
    try {
      if (account.id == null) {
        return Left(
            ValidationFailure(message: 'Account ID is required for updates'));
      }
      _validateAccountData(account);
      return await _accountRepository.updateAccount(account);
    } on AccountException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      // Check if account has any transactions before deletion
      final hasTransactions = await _accountRepository.hasTransactions(id);
      if (hasTransactions) {
        return Left(ValidationFailure(
          message: 'Cannot delete account with existing transactions',
        ));
      }
      return await _accountRepository.deleteAccount(id);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, CreditCardDetails>> getCreditCardDetails(
      String accountId) async {
    try {
      return await _accountRepository.getCreditCardDetails(accountId);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, CreditCardDetails>> createCreditCardDetails(
    CreditCardDetails details,
  ) async {
    try {
      _validateCreditCardDetails(details);
      return await _accountRepository.createCreditCardDetails(details);
    } on AccountException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, CreditCardDetails>> updateCreditCardDetails(
    CreditCardDetails details,
  ) async {
    try {
      if (details.id == null) {
        return Left(ValidationFailure(
          message: 'Credit card details ID is required for updates',
        ));
      }
      _validateCreditCardDetails(details);
      return await _accountRepository.updateCreditCardDetails(details);
    } on AccountException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteCreditCardDetails(String id) async {
    try {
      return await _accountRepository.deleteCreditCardDetails(id);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  void _validateAccountData(Account account) {
    if (account.name.trim().isEmpty) {
      throw const AccountException('Account name cannot be empty');
    }

    if (account.userId.trim().isEmpty) {
      throw const AccountException('User ID is required');
    }

    if (account.accountTypeId.trim().isEmpty) {
      throw const AccountException('Account type is required');
    }

    if (account.currencyId.trim().isEmpty) {
      throw const AccountException('Currency is required');
    }
  }

  void _validateCreditCardDetails(CreditCardDetails details) {
    if (details.accountId.trim().isEmpty) {
      throw const AccountException('Account ID is required');
    }

    if (details.creditLimit < 0) {
      throw const AccountException('Credit limit cannot be negative');
    }

    if (details.currentInterestRate < 0) {
      throw const AccountException('Interest rate cannot be negative');
    }

    if (details.cutOffDay < 1 || details.cutOffDay > 31) {
      throw const AccountException('Cut-off day must be between 1 and 31');
    }

    if (details.paymentDueDay < 1 || details.paymentDueDay > 31) {
      throw const AccountException('Payment due day must be between 1 and 31');
    }

    if (details.paymentDueDay <= details.cutOffDay) {
      throw const AccountException('Payment due day must be after cut-off day');
    }
  }
}
