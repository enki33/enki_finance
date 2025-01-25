import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/daily_total.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../presentation/providers/transaction_filter_provider.dart';

class SupabaseTransactionRepository implements TransactionRepository {
  final SupabaseClient supabase;

  SupabaseTransactionRepository(this.supabase);

  @override
  Future<Either<Failure, Transaction>> createTransaction(
      Transaction transaction) async {
    try {
      debugPrint('Creating transaction...');
      debugPrint(
          'Transaction date: ${transaction.transactionDate.toUtc().toIso8601String()}');

      final response = await supabase
          .from('transaction')
          .insert({
            'user_id': transaction.userId,
            'transaction_date':
                transaction.transactionDate.toUtc().toIso8601String(),
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

      debugPrint('Transaction created successfully');
      return Right(Transaction.fromJson(response));
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      if (e.toString().contains('foreign key constraint')) {
        return Left(ValidationFailure(
            message: 'Invalid reference: One or more IDs do not exist'));
      }
      if (e.toString().contains('duplicate key')) {
        return Left(ValidationFailure(message: 'Transaction already exists'));
      }
      if (e.toString().contains('permission denied')) {
        return Left(UnauthorizedFailure(message: 'Permission denied'));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required String userId,
    TransactionFilter? filter,
  }) async {
    try {
      final startDate = (filter?.startDate ?? DateTime(2000)).toUtc();
      final endDate = (filter?.endDate ?? DateTime.now()).toUtc();

      debugPrint('\nDate Parameters (UTC):');
      debugPrint('Start Date: ${startDate.toIso8601String()}');
      debugPrint('End Date: ${endDate.toIso8601String()}');

      final params = {
        'p_user_id': userId,
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': endDate.toIso8601String(),
        'p_account_id': filter?.accountId,
        'p_category_id': filter?.categoryId,
        'p_subcategory_id': filter?.subcategoryId,
        'p_transaction_type_id': filter?.transactionTypeId,
        'p_jar_id': filter?.jarId,
      };

      debugPrint('\nRPC Parameters:');
      debugPrint('Calling get_transactions_by_date_range with params:');
      params.forEach((key, value) => debugPrint('  $key: $value'));

      final response = await supabase.rpc(
        'get_transactions_by_date_range',
        params: params,
      );

      return Right((response as List)
          .map<Transaction>((json) => Transaction.fromJson(json))
          .toList());
    } catch (e, stackTrace) {
      debugPrint('\n=== Error in getTransactions ===');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      debugPrint('Stack Trace:\n$stackTrace');
      debugPrint('=== End Error Info ===\n');

      if (e.toString().contains('permission denied')) {
        return Left(UnauthorizedFailure(message: 'Permission denied'));
      }
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(
      Transaction transaction) async {
    try {
      final response = await supabase
          .from('transaction')
          .update({
            'transaction_date':
                transaction.transactionDate.toUtc().toIso8601String(),
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
            'modified_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', transaction.id)
          .select()
          .single();

      return Right(Transaction.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTransaction(String transactionId) async {
    try {
      await supabase.from('transaction').delete().eq('id', transactionId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getTransactionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final utcStartDate = startDate.toUtc();
      final utcEndDate = endDate.toUtc();

      debugPrint('\nTransaction Summary Date Parameters (UTC):');
      debugPrint('Start Date: ${utcStartDate.toIso8601String()}');
      debugPrint('End Date: ${utcEndDate.toIso8601String()}');

      final response = await supabase.rpc(
        'get_transaction_summary_by_date_range',
        params: {
          'p_user_id': userId,
          'p_start_date': utcStartDate.toIso8601String(),
          'p_end_date': utcEndDate.toIso8601String(),
        },
      );

      final summary = <String, double>{};
      for (final row in response as List) {
        summary[row['transaction_type'] as String] =
            (row['total_amount'] as num).toDouble();
      }

      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<DailyTotal>>> getDailyTotals({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
  }) async {
    try {
      final utcStartDate = startDate.toUtc();
      final utcEndDate = endDate.toUtc();

      debugPrint('\nDaily Totals Date Parameters (UTC):');
      debugPrint('Start Date: ${utcStartDate.toIso8601String()}');
      debugPrint('End Date: ${utcEndDate.toIso8601String()}');

      final response = await supabase.rpc(
        'get_daily_transaction_totals',
        params: {
          'p_user_id': userId,
          'p_start_date': utcStartDate.toIso8601String(),
          'p_end_date': utcEndDate.toIso8601String(),
          'p_transaction_type_id': transactionTypeId,
        },
      );

      if (response is List && response.isNotEmpty) {
        debugPrint('\nFirst Row Date Analysis:');
        debugPrint('Raw date: ${response[0]['transaction_date']}');
        debugPrint('Type: ${response[0]['transaction_date'].runtimeType}');
      }

      final totals = (response as List).map<DailyTotal>((json) {
        final rawDate = json['transaction_date'] as String;
        final date = DateTime.parse(rawDate).toUtc();
        return DailyTotal(
          date: date,
          amount: (json['total_amount'] as num).toDouble(),
          count: json['transaction_count'] as int,
        );
      }).toList();

      return Right(totals);
    } catch (e, stackTrace) {
      debugPrint('\n=== Error in getDailyTotals ===');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      debugPrint('Stack Trace:\n$stackTrace');
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
