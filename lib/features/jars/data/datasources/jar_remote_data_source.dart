import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enki_finance/features/jars/domain/entities/jar_distribution.dart';

/// Interface for jar remote data operations
abstract class JarRemoteDataSource {
  /// Analyzes the distribution of funds across jars
  Future<List<JarDistribution>> analyzeDistribution({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Executes a transfer between jars
  Future<void> executeTransfer({
    required String userId,
    required String fromJarId,
    required String toJarId,
    required double amount,
    String? description,
    bool isRollover = false,
  });

  /// Checks if a jar is required for a category
  Future<bool> isJarRequired(String categoryId);

  /// Gets the current balance of a jar
  Future<double> getJarBalance(String jarId);

  /// Gets the target percentage for a jar
  Future<double> getJarTargetPercentage(String jarId);
}

/// Implementation of [JarRemoteDataSource] using Supabase
class JarRemoteDataSourceImpl implements JarRemoteDataSource {
  const JarRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<JarDistribution>> analyzeDistribution({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _supabase
        .from('jar')
        .select('''
          name,
          target_percentage,
          transaction!inner (
            amount,
            transaction_date
          )
        ''')
        .eq('user_id', userId)
        .gte('transaction.transaction_date', startDate?.toIso8601String() ?? '')
        .lte('transaction.transaction_date', endDate?.toIso8601String() ?? '');

    final data = response as List<dynamic>;
    return data.map((row) {
      final transactions =
          (row['transaction'] as List<dynamic>).cast<Map<String, dynamic>>();
      final totalAmount = transactions.fold<double>(
        0,
        (sum, t) => sum + (t['amount'] as num).toDouble(),
      );
      final targetPercentage = (row['target_percentage'] as num).toDouble();
      final currentPercentage =
          totalAmount > 0 ? (totalAmount / totalAmount) * 100 : 0.0;

      return JarDistribution(
        jarName: row['name'] as String,
        currentPercentage: currentPercentage,
        targetPercentage: targetPercentage,
        difference: currentPercentage - targetPercentage,
        isCompliant: (currentPercentage - targetPercentage).abs() <= 2,
      );
    }).toList();
  }

  @override
  Future<void> executeTransfer({
    required String userId,
    required String fromJarId,
    required String toJarId,
    required double amount,
    String? description,
    bool isRollover = false,
  }) async {
    await _supabase.rpc(
      'execute_jar_transfer',
      params: {
        'p_user_id': userId,
        'p_from_jar_id': fromJarId,
        'p_to_jar_id': toJarId,
        'p_amount': amount,
        'p_description': description,
        'p_is_rollover': isRollover,
      },
    );
  }

  @override
  Future<bool> isJarRequired(String categoryId) async {
    final response = await _supabase
        .from('category')
        .select('requires_jar')
        .eq('id', categoryId)
        .single();
    return response['requires_jar'] as bool;
  }

  @override
  Future<double> getJarBalance(String jarId) async {
    final response = await _supabase
        .from('jar_balance')
        .select('current_balance')
        .eq('jar_id', jarId)
        .single();
    return (response['current_balance'] as num).toDouble();
  }

  @override
  Future<double> getJarTargetPercentage(String jarId) async {
    final response = await _supabase
        .from('jar')
        .select('target_percentage')
        .eq('id', jarId)
        .single();
    return (response['target_percentage'] as num).toDouble();
  }
}
