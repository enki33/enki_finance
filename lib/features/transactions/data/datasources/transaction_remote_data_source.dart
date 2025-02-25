import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_analysis.dart';
import '../../domain/entities/transaction_filter.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/daily_total.dart';
import '../../domain/entities/transaction_summary.dart' as summary;
import '../../domain/entities/balance_history.dart';
import '../../domain/entities/category_analysis.dart';
import '../../domain/entities/installment_purchase.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/exceptions/transaction_exception.dart';

abstract class TransactionRemoteDataSource {
  Future<Transaction> createTransaction(Transaction transaction);

  Future<List<Transaction>> getTransactions({
    required String userId,
    TransactionFilter? filter,
  });

  Future<Transaction> updateTransaction(Transaction transaction);

  Future<void> deleteTransaction(String transactionId);

  Future<Map<String, double>> getTransactionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<CategoryAnalysis>> analyzeByCategory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
  });

  Future<List<DailyTotal>> getDailyTotals({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
  });

  Future<List<summary.TransactionSummary>> getSummaryByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<Transaction>> searchByTags({
    required String userId,
    required List<String> tags,
  });

  Future<List<Transaction>> searchByNotes({
    required String userId,
    required String searchText,
  });

  Future<List<Transaction>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
    String? categoryId,
    String? subcategoryId,
    String? accountId,
    String? jarId,
  });

  Future<bool> validateTransaction({
    required Transaction transaction,
    required bool isUpdate,
  });

  Future<List<BalanceHistory>> getAccountBalanceHistory({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<BalanceHistory>> getJarBalanceHistory({
    required String jarId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<double> calculateAccountBalance({
    required String accountId,
    DateTime? asOf,
  });

  Future<double> calculateJarBalance({
    required String jarId,
    DateTime? asOf,
  });

  Future<void> recordBalanceHistory(BalanceHistory history);

  Future<InstallmentPurchase> createInstallmentPurchase(
      InstallmentPurchase purchase);
  Future<List<InstallmentPurchase>> getInstallmentPurchases(String userId);
  Future<void> updateInstallmentPurchase(InstallmentPurchase purchase);

  Future<RecurringTransaction> createRecurringTransaction(
      RecurringTransaction transaction);
  Future<List<RecurringTransaction>> getRecurringTransactions(String userId);
  Future<void> updateRecurringTransaction(RecurringTransaction transaction);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  const TransactionRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    final response = await _supabase
        .from('transaction')
        .insert(model.toJson())
        .select()
        .single();
    return TransactionModel.fromJson(response).toEntity();
  }

  @override
  Future<List<Transaction>> getTransactions({
    required String userId,
    TransactionFilter? filter,
  }) async {
    try {
      var query = _supabase.from('transaction').select().eq('user_id', userId);

      if (filter != null) {
        if (filter.startDate != null) {
          query = query.gte(
              'transaction_date', filter.startDate!.toIso8601String());
        }
        if (filter.endDate != null) {
          query =
              query.lte('transaction_date', filter.endDate!.toIso8601String());
        }
        if (filter.categoryId != null) {
          query = query.eq('category_id', filter.categoryId!);
        }
        if (filter.subcategoryId != null) {
          query = query.eq('subcategory_id', filter.subcategoryId!);
        }
        if (filter.accountId != null) {
          query = query.eq('account_id', filter.accountId!);
        }
        if (filter.jarId != null) {
          query = query.eq('jar_id', filter.jarId!);
        }
        if (filter.orderBy != null) {
          query.order(filter.orderBy!,
              ascending: filter.orderDirection == 'asc');
        }
        if (filter.limit != null) {
          query.limit(filter.limit!);
        }
        if (filter.offset != null) {
          query.range(
              filter.offset!, filter.offset! + (filter.limit ?? 10) - 1);
        }
      }

      final response = await query;
      return response
          .map((json) => TransactionModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw TransactionException('Failed to fetch transactions: $e');
    }
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final response = await _supabase.rpc(
      'update_transaction',
      params: TransactionModel.fromEntity(transaction).toJson(),
    );

    return TransactionModel.fromJson(response as Map<String, dynamic>)
        .toEntity();
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await _supabase.rpc(
      'delete_transaction',
      params: {'p_transaction_id': transactionId},
    );
  }

  @override
  Future<Map<String, double>> getTransactionSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _supabase.rpc(
      'get_transaction_summary',
      params: {
        'p_user_id': userId,
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': endDate.toIso8601String(),
      },
    );

    return Map<String, double>.from(response as Map);
  }

  @override
  Future<List<CategoryAnalysis>> analyzeByCategory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? transactionType,
  }) async {
    final response = await _supabase.rpc(
      'analyze_transactions_by_category',
      params: {
        'p_user_id': userId,
        if (startDate != null) 'p_start_date': startDate.toIso8601String(),
        if (endDate != null) 'p_end_date': endDate.toIso8601String(),
        if (transactionType != null) 'p_transaction_type': transactionType,
      },
    );

    return (response as List<dynamic>).map((json) {
      return CategoryAnalysis(
        categoryName: json['category_name'] as String,
        subcategoryName: json['subcategory_name'] as String?,
        transactionCount: json['transaction_count'] as int,
        totalAmount: (json['total_amount'] as num).toDouble(),
        percentageOfTotal: (json['percentage_of_total'] as num).toDouble(),
        averageAmount: (json['average_amount'] as num).toDouble(),
        minAmount: (json['min_amount'] as num).toDouble(),
        maxAmount: (json['max_amount'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<List<DailyTotal>> getDailyTotals({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
  }) async {
    final response = await _supabase.rpc(
      'get_daily_transaction_totals',
      params: {
        'p_user_id': userId,
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': endDate.toIso8601String(),
        'p_transaction_type_id': transactionTypeId,
      },
    );

    return (response as List<dynamic>).map((json) {
      return DailyTotal(
        date: DateTime.parse(json['transaction_date'] as String),
        amount: (json['total_amount'] as num).toDouble(),
        count: json['transaction_count'] as int,
      );
    }).toList();
  }

  @override
  Future<List<summary.TransactionSummary>> getSummaryByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _supabase.rpc(
      'get_transaction_summary_by_date_range',
      params: {
        'p_user_id': userId,
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': endDate.toIso8601String(),
      },
    );

    return (response as List<dynamic>).map((json) {
      return summary.TransactionSummary(
        transactionType: json['transaction_type'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        currencyId: json['currency_id'] as String,
        transactionCount: json['transaction_count'] as int,
        periodStart: DateTime.parse(json['period_start'] as String),
        periodEnd: DateTime.parse(json['period_end'] as String),
      );
    }).toList();
  }

  @override
  Future<List<Transaction>> searchByTags({
    required String userId,
    required List<String> tags,
  }) async {
    final response = await _supabase.rpc(
      'search_transactions_by_tags',
      params: {
        'p_user_id': userId,
        'p_tags': tags,
      },
    );

    return (response as List<dynamic>)
        .map((json) => TransactionModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<Transaction>> searchByNotes({
    required String userId,
    required String searchText,
  }) async {
    final response = await _supabase.rpc(
      'search_transactions_by_notes',
      params: {
        'p_user_id': userId,
        'p_search_text': searchText,
      },
    );

    return (response as List<dynamic>)
        .map((json) => TransactionModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? transactionTypeId,
    String? categoryId,
    String? subcategoryId,
    String? accountId,
    String? jarId,
  }) async {
    final response = await _supabase.rpc(
      'get_transactions_by_date_range',
      params: {
        'p_user_id': userId,
        'p_start_date': startDate.toIso8601String(),
        'p_end_date': endDate.toIso8601String(),
        'p_transaction_type_id': transactionTypeId,
        'p_category_id': categoryId,
        'p_subcategory_id': subcategoryId,
        'p_account_id': accountId,
        'p_jar_id': jarId,
      },
    );

    return (response as List<dynamic>)
        .map((json) => TransactionModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<bool> validateTransaction({
    required Transaction transaction,
    required bool isUpdate,
  }) async {
    try {
      await _supabase.rpc(
        'validate_transaction',
        params: {
          'p_transaction': TransactionModel.fromEntity(transaction).toJson(),
          'p_is_update': isUpdate,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<BalanceHistory>> getAccountBalanceHistory({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query =
        _supabase.from('balance_history').select().eq('account_id', accountId);

    if (startDate != null) {
      query = query.gte('created_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('created_at', endDate.toIso8601String());
    }

    final response = await query;
    return (response as List<dynamic>)
        .map((json) => BalanceHistory.fromJson(json))
        .toList();
  }

  @override
  Future<List<BalanceHistory>> getJarBalanceHistory({
    required String jarId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query =
        _supabase.from('balance_history').select().eq('jar_id', jarId);

    if (startDate != null) {
      query.gte('created_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query.lte('created_at', endDate.toIso8601String());
    }

    final response = await query;
    return response.map((json) => BalanceHistory.fromJson(json)).toList();
  }

  @override
  Future<double> calculateAccountBalance({
    required String accountId,
    DateTime? asOf,
  }) async {
    final query = _supabase.rpc('calculate_account_balance', params: {
      'p_account_id': accountId,
      if (asOf != null) 'p_as_of': asOf.toIso8601String(),
    });

    final response = await query;
    return response as double;
  }

  @override
  Future<double> calculateJarBalance({
    required String jarId,
    DateTime? asOf,
  }) async {
    final query = _supabase.rpc('calculate_jar_balance', params: {
      'p_jar_id': jarId,
      if (asOf != null) 'p_as_of': asOf.toIso8601String(),
    });

    final response = await query;
    return response as double;
  }

  @override
  Future<void> recordBalanceHistory(BalanceHistory history) async {
    await _supabase.from('balance_history').insert(history.toJson());
  }

  @override
  Future<InstallmentPurchase> createInstallmentPurchase(
      InstallmentPurchase purchase) async {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<List<InstallmentPurchase>> getInstallmentPurchases(
      String userId) async {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<void> updateInstallmentPurchase(InstallmentPurchase purchase) async {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<RecurringTransaction> createRecurringTransaction(
      RecurringTransaction transaction) async {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<List<RecurringTransaction>> getRecurringTransactions(
      String userId) async {
    // Implementation needed
    throw UnimplementedError();
  }

  @override
  Future<void> updateRecurringTransaction(
      RecurringTransaction transaction) async {
    // Implementation needed
    throw UnimplementedError();
  }
}
