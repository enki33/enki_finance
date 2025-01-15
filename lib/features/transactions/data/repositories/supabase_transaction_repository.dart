import 'package:dartz/dartz.dart';
import 'package:enki_finance/core/errors/failures.dart';
import 'package:enki_finance/core/providers/supabase_provider.dart';
import 'package:enki_finance/features/transactions/domain/entities/transaction.dart';
import 'package:enki_finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTransactionRepository implements TransactionRepository {
  final SupabaseClient supabase;

  SupabaseTransactionRepository(this.supabase);

  @override
  Future<Either<Failure, Transaction>> createTransaction(
      Transaction transaction) async {
    try {
      final response = await supabase
          .from('transaction')
          .insert({
            'user_id': transaction.userId,
            'transaction_date': transaction.transactionDate.toIso8601String(),
            'description': transaction.description,
            'amount': transaction.amount,
            'transaction_type_id': transaction.transactionTypeId,
            'category_id': transaction.categoryId,
            'subcategory_id': transaction.subcategoryId,
            'account_id': transaction.accountId,
            'jar_id': transaction.jarId,
            'transaction_medium_id': transaction.transactionMediumId,
            'currency_id': transaction.currencyId,
            'exchange_rate': transaction.exchangeRate,
            'notes': transaction.notes,
            'tags': transaction.tags,
            'is_recurring': transaction.isRecurring,
            'parent_recurring_id': transaction.parentRecurringId,
          })
          .select()
          .single();

      return Right(Transaction.fromJson(response));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
    String? categoryId,
    String? accountId,
    String? jarId,
  }) async {
    try {
      var query = supabase.from('transaction').select().eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('transaction_date', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('transaction_date', endDate.toIso8601String());
      }
      if (transactionType != null) {
        query = query.eq('transaction_type_id', transactionType);
      }
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (accountId != null) {
        query = query.eq('account_id', accountId);
      }
      if (jarId != null) {
        query = query.eq('jar_id', jarId);
      }

      final response = await query.order('transaction_date', ascending: false);

      return Right(
        response.map((json) => Transaction.fromJson(json)).toList(),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction) async {
    try {
      final response = await supabase
          .from('transaction')
          .update({
            'transaction_date': transaction.transactionDate.toIso8601String(),
            'description': transaction.description,
            'amount': transaction.amount,
            'transaction_type_id': transaction.transactionTypeId,
            'category_id': transaction.categoryId,
            'subcategory_id': transaction.subcategoryId,
            'account_id': transaction.accountId,
            'jar_id': transaction.jarId,
            'transaction_medium_id': transaction.transactionMediumId,
            'currency_id': transaction.currencyId,
            'exchange_rate': transaction.exchangeRate,
            'notes': transaction.notes,
            'tags': transaction.tags,
            'modified_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transaction.id)
          .select()
          .single();

      return Right(Transaction.fromJson(response));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String transactionId) async {
    try {
      await supabase.from('transaction').delete().eq('id', transactionId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getTransactionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_transaction_summary',
        params: {
          'p_user_id': userId,
          'p_start_date': startDate.toIso8601String(),
          'p_end_date': endDate.toIso8601String(),
        },
      );

      return Right(Map<String, double>.from(response));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
