import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/goal.dart';

abstract class GoalRemoteDataSource {
  Future<List<Goal>> getActiveGoals(String userId);
  Future<Goal> getGoal(String goalId);
  Future<Goal> createGoal(Goal goal);
  Future<Goal> updateGoal(Goal goal);
  Future<void> deleteGoal(String goalId);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final SupabaseClient _supabase;

  const GoalRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<Goal>> getActiveGoals(String userId) async {
    final response = await _supabase
        .from('financial_goal')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true);

    return (response as List<dynamic>)
        .map((json) => Goal.fromJson(json))
        .toList();
  }

  @override
  Future<Goal> getGoal(String goalId) async {
    final response = await _supabase
        .from('financial_goal')
        .select()
        .eq('id', goalId)
        .single();

    return Goal.fromJson(response);
  }

  @override
  Future<Goal> createGoal(Goal goal) async {
    final response = await _supabase
        .from('financial_goal')
        .insert(goal.toJson())
        .select()
        .single();

    return Goal.fromJson(response);
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    final response = await _supabase
        .from('financial_goal')
        .update(goal.toJson())
        .eq('id', goal.id)
        .select()
        .single();

    return Goal.fromJson(response);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await _supabase.from('financial_goal').delete().eq('id', goalId);
  }
}
