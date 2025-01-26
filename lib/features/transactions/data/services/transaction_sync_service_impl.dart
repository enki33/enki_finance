import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/services/transaction_sync_service.dart';
import '../../../../core/error/failures.dart';

class TransactionSyncServiceImpl implements TransactionSyncService {
  final SupabaseClient supabase;
  final SharedPreferences prefs;
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _pendingChangesKey = 'pending_transaction_changes';

  TransactionSyncServiceImpl(this.supabase, this.prefs);

  @override
  Future<Either<Failure, List<Transaction>>> syncTransactions({
    required String userId,
    DateTime? lastSyncTimestamp,
  }) async {
    try {
      // Get local transactions that need to be synced
      final localChanges = await _getLocalChanges(lastSyncTimestamp);

      // Get remote changes
      final remoteChanges = await _getRemoteChanges(userId, lastSyncTimestamp);

      // Merge changes, with remote taking precedence
      final mergedTransactions =
          await _mergeChanges(localChanges, remoteChanges);

      // Update local database
      await _updateLocalDatabase(mergedTransactions);

      // Update sync timestamp
      await _updateSyncTimestamp(DateTime.now());

      return Right(mergedTransactions);
    } catch (e) {
      debugPrint('Error syncing transactions: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<List<Transaction>> _getLocalChanges(
      DateTime? lastSyncTimestamp) async {
    try {
      final pendingChangesJson = prefs.getString(_pendingChangesKey);
      if (pendingChangesJson == null) return [];

      final List<dynamic> pendingChanges = jsonDecode(pendingChangesJson);
      final transactions = pendingChanges
          .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
          .toList();

      if (lastSyncTimestamp != null) {
        return transactions
            .where((t) => t.updatedAt.isAfter(lastSyncTimestamp))
            .toList();
      }

      return transactions;
    } catch (e) {
      debugPrint('Error getting local changes: $e');
      return [];
    }
  }

  Future<List<Transaction>> _getRemoteChanges(
    String userId,
    DateTime? lastSyncTimestamp,
  ) async {
    try {
      var query = supabase.from('transaction').select().eq('user_id', userId);

      if (lastSyncTimestamp != null) {
        query = query.gt('updated_at', lastSyncTimestamp.toIso8601String());
      }

      final response = await query.order('transaction_date', ascending: false);
      return response
          .map<Transaction>((json) => Transaction.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting remote changes: $e');
      rethrow;
    }
  }

  Future<List<Transaction>> _mergeChanges(
    List<Transaction> localChanges,
    List<Transaction> remoteChanges,
  ) async {
    // Create a map of transactions by ID for easier lookup
    final mergedMap = <String, Transaction>{};

    // Add remote changes first (they take precedence)
    for (final transaction in remoteChanges) {
      mergedMap[transaction.id] = transaction;
    }

    // Add local changes only if they don't exist in remote
    for (final transaction in localChanges) {
      if (!mergedMap.containsKey(transaction.id)) {
        mergedMap[transaction.id] = transaction;
      }
    }

    return mergedMap.values.toList();
  }

  Future<void> _updateLocalDatabase(List<Transaction> transactions) async {
    try {
      final jsonList = transactions.map((t) => t.toJson()).toList();
      await prefs.setString(_pendingChangesKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error updating local database: $e');
    }
  }

  Future<void> _updateSyncTimestamp(DateTime timestamp) async {
    await prefs.setString(_lastSyncKey, timestamp.toIso8601String());
  }

  @override
  Future<DateTime?> getLastSyncTimestamp() async {
    final timestampStr = prefs.getString(_lastSyncKey);
    if (timestampStr == null) return null;
    return DateTime.parse(timestampStr);
  }

  @override
  Future<void> addPendingChange(Transaction transaction) async {
    try {
      final pendingChangesJson = prefs.getString(_pendingChangesKey);
      final List<dynamic> pendingChanges =
          pendingChangesJson != null ? jsonDecode(pendingChangesJson) : [];

      // Update existing transaction or add new one
      final index = pendingChanges.indexWhere((t) => t['id'] == transaction.id);
      if (index >= 0) {
        pendingChanges[index] = transaction.toJson();
      } else {
        pendingChanges.add(transaction.toJson());
      }

      await prefs.setString(_pendingChangesKey, jsonEncode(pendingChanges));
    } catch (e) {
      debugPrint('Error adding pending change: $e');
    }
  }

  @override
  Future<void> removePendingChange(String transactionId) async {
    try {
      final pendingChangesJson = prefs.getString(_pendingChangesKey);
      if (pendingChangesJson == null) return;

      final List<dynamic> pendingChanges = jsonDecode(pendingChangesJson);
      pendingChanges.removeWhere((t) => t['id'] == transactionId);

      await prefs.setString(_pendingChangesKey, jsonEncode(pendingChanges));
    } catch (e) {
      debugPrint('Error removing pending change: $e');
    }
  }

  @override
  Stream<Transaction> watchTransactions(String userId) {
    return supabase
        .from('transaction')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((event) {
          try {
            final record = event.first;
            return Transaction.fromJson(record as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error processing transaction stream event: $e');
            rethrow;
          }
        });
  }
}
