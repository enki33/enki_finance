import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enki_finance/features/jars/domain/entities/jar_distribution.dart';
import 'package:enki_finance/features/jars/domain/entities/jar.dart';
import 'package:enki_finance/features/jars/data/models/jar_model.dart';

/// Interface for jar remote data operations
abstract class JarRemoteDataSource {
  /// Creates a new jar
  Future<Jar> createJar(Jar jar);

  /// Updates an existing jar
  Future<Jar> updateJar(Jar jar);

  /// Deletes a jar
  Future<void> deleteJar(String jarId);

  /// Gets a jar by ID
  Future<Jar> getJar(String jarId);

  /// Gets all jars for a user
  Future<List<Jar>> getJars(String userId);

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
  Future<Jar> createJar(Jar jar) async {
    final model = JarModel.fromEntity(jar);
    final response =
        await _supabase.from('jar').insert(model.toJson()).select().single();
    return JarModel.fromJson(response).toEntity();
  }

  @override
  Future<void> deleteJar(String jarId) async {
    await _supabase.from('jar').delete().eq('id', jarId);
  }

  @override
  Future<Jar> getJar(String jarId) async {
    final response =
        await _supabase.from('jar').select().eq('id', jarId).single();
    return JarModel.fromJson(response).toEntity();
  }

  @override
  Future<List<Jar>> getJars(String userId) async {
    final response = await _supabase.from('jar').select().eq('user_id', userId);
    return (response as List<dynamic>)
        .map((json) => JarModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<Jar> updateJar(Jar jar) async {
    final model = JarModel.fromEntity(jar);
    final response = await _supabase
        .from('jar')
        .update(model.toJson())
        .eq('id', jar.id)
        .select()
        .single();
    return JarModel.fromJson(response).toEntity();
  }

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
