import 'package:dartz/dartz.dart';
import 'package:enki_finance/core/error/failures.dart';
import 'package:enki_finance/features/account/data/datasources/account_remote_data_source.dart';
import 'package:enki_finance/features/account/data/models/account_model.dart';
import 'package:enki_finance/features/account/data/models/credit_card_details_model.dart';
import 'package:enki_finance/features/account/domain/entities/account.dart';
import 'package:enki_finance/features/account/domain/entities/credit_card_details.dart';
import 'package:enki_finance/features/account/domain/repositories/account_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    try {
      final accounts = await remoteDataSource.getAccounts();
      return Right(accounts.map((model) => model.toEntity()).toList());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> getAccountById(String id) async {
    try {
      final account = await remoteDataSource.getAccountById(id);
      return Right(account.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> createAccount(Account account) async {
    try {
      final accountModel = AccountModel.fromEntity(account);
      final createdAccount = await remoteDataSource.createAccount(accountModel);
      return Right(createdAccount.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> updateAccount(Account account) async {
    try {
      final accountModel = AccountModel.fromEntity(account);
      final updatedAccount = await remoteDataSource.updateAccount(accountModel);
      return Right(updatedAccount.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    try {
      await remoteDataSource.deleteAccount(id);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreditCardDetails>> getCreditCardDetails(
      String accountId) async {
    try {
      final details = await remoteDataSource.getCreditCardDetails(accountId);
      return Right(details.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreditCardDetails>> createCreditCardDetails(
      CreditCardDetails details) async {
    try {
      final detailsModel = CreditCardDetailsModel.fromEntity(details);
      final createdDetails =
          await remoteDataSource.createCreditCardDetails(detailsModel);
      return Right(createdDetails.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreditCardDetails>> updateCreditCardDetails(
      CreditCardDetails details) async {
    try {
      final detailsModel = CreditCardDetailsModel.fromEntity(details);
      final updatedDetails =
          await remoteDataSource.updateCreditCardDetails(detailsModel);
      return Right(updatedDetails.toEntity());
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCreditCardDetails(String id) async {
    try {
      await remoteDataSource.deleteCreditCardDetails(id);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
