import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionValidator {
  final SupabaseClient supabase;

  TransactionValidator(this.supabase);

  Future<Either<Failure, Unit>> validate(Transaction transaction) async {
    try {
      // Basic validation
      if (transaction.amount <= 0) {
        return Left(ValidationFailure(
            message: 'Transaction amount must be greater than zero'));
      }

      if (transaction.transactionDate.isAfter(DateTime.now())) {
        return Left(ValidationFailure(
            message: 'Transaction date cannot be in the future'));
      }

      // Account validation
      if (transaction.accountId.isNotEmpty) {
        final accountExists = await _validateAccount(transaction.accountId);
        if (!accountExists) {
          return Left(ValidationFailure(message: 'Invalid account'));
        }

        final isCreditCard = await _isCreditCardAccount(transaction.accountId);
        if (isCreditCard) {
          // Validate credit limit
          final isValid = await supabase.rpc(
            'validate_credit_limit',
            params: {
              'p_account_id': transaction.accountId,
              'p_amount': transaction.amount,
            },
          );

          if (!isValid) {
            return Left(ValidationFailure(
                message: 'Transaction exceeds available credit limit'));
          }
        }
      }

      // Category validation
      final categoryExists = await _validateCategory(
          transaction.categoryId, transaction.subcategoryId);
      if (!categoryExists) {
        return Left(
            ValidationFailure(message: 'Invalid category or subcategory'));
      }

      // Jar validation for expenses
      if (transaction.transactionTypeId == 'EXPENSE') {
        final jarValidation = await _validateJarRequirement(
            transaction.subcategoryId, transaction.jarId);
        if (jarValidation.isLeft()) {
          return jarValidation;
        }

        // Balance validation for expenses
        final balanceValidation = await _validateBalance(transaction);
        if (balanceValidation.isLeft()) {
          return balanceValidation;
        }
      }

      // Currency validation
      if (transaction.currencyId.isNotEmpty) {
        final currencyExists = await _validateCurrency(transaction.currencyId);
        if (!currencyExists) {
          return Left(ValidationFailure(message: 'Invalid currency'));
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<bool> _validateAccount(String accountId) async {
    try {
      final response = await supabase
          .from('account')
          .select('id')
          .eq('id', accountId)
          .single();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _validateCategory(
      String categoryId, String subcategoryId) async {
    try {
      final response = await supabase
          .from('subcategory')
          .select('id, category_id')
          .eq('id', subcategoryId)
          .eq('category_id', categoryId)
          .single();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _validateCurrency(String currencyId) async {
    try {
      final response = await supabase
          .from('currency')
          .select('id')
          .eq('id', currencyId)
          .single();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<Either<Failure, Unit>> _validateJarRequirement(
      String subcategoryId, String? jarId) async {
    try {
      final subcategory = await supabase
          .from('subcategory')
          .select('jar_id, name')
          .eq('id', subcategoryId)
          .single();

      if (subcategory['jar_id'] != null && jarId == null) {
        return Left(ValidationFailure(
            message:
                'Category "${subcategory['name']}" requires a jar to be specified'));
      }

      if (jarId != null) {
        final jarExists =
            await supabase.from('jar').select('id').eq('id', jarId).single();
        if (jarExists == null) {
          return Left(ValidationFailure(message: 'Invalid jar'));
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Unit>> _validateBalance(
      Transaction transaction) async {
    try {
      final balance = await supabase.rpc(
        'check_available_balance_for_transfer',
        params: {
          'p_user_id': transaction.userId,
          'p_account_id': transaction.accountId,
          'p_jar_id': transaction.jarId,
        },
      );

      if (balance < transaction.amount) {
        return Left(ValidationFailure(
            message:
                'Insufficient balance. Available: ${balance.toStringAsFixed(2)}'));
      }

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<bool> _isCreditCardAccount(String accountId) async {
    try {
      final response = await supabase
          .from('account')
          .select('account_type_id')
          .eq('id', accountId)
          .single();

      final accountTypeId = response['account_type_id'] as String;
      final accountType = await supabase
          .from('account_type')
          .select('code')
          .eq('id', accountTypeId)
          .single();

      return accountType['code'] == 'CREDIT_CARD';
    } catch (e) {
      return false;
    }
  }
}
