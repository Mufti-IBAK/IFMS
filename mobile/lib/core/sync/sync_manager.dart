import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../database/local_db.dart';
import '../network/api_client.dart';

class SyncManager {
  final LocalDatabase db;
  final ApiClient apiClient;
  bool _isSyncing = false;

  SyncManager(this.db, this.apiClient) {
    Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        triggerSync();
      }
    });
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queueItems = await (db.select(db.syncQueue)
            ..where((t) => t.attempts.isSmallerThanValue(5))
            ..orderBy([(t) => OrderingTerm(expression: t.queuedAt)]))
          .get();

      for (var item in queueItems) {
        try {
          final success = await _processQueueItem(item);
          if (success) {
            await (db.delete(db.syncQueue)..where((t) => t.id.equals(item.id))).go();
          } else {
            await _incrementAttempts(item, 'Network or Server Error');
            break; 
          }
        } catch (e) {
          await _incrementAttempts(item, e.toString());
        }
      }
    } catch (_) {
      // Handle logging
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _incrementAttempts(SyncQueueData item, String error) async {
    await (db.update(db.syncQueue)..where((t) => t.id.equals(item.id))).write(
      SyncQueueCompanion(
        attempts: Value(item.attempts + 1),
        lastError: Value(error),
      ),
    );
  }

  Future<bool> _processQueueItem(SyncQueueData item) async {
    final data = jsonDecode(item.body);
    Response response;
    try {
      if (item.method == 'POST') {
        response = await apiClient.dio.post(item.endpoint, data: data);
      } else if (item.method == 'PATCH') {
        response = await apiClient.dio.patch(item.endpoint, data: data);
      } else if (item.method == 'DELETE') {
        response = await apiClient.dio.delete(item.endpoint, data: data);
      } else {
        return false;
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response?.statusCode != null && e.response!.statusCode! >= 400 && e.response!.statusCode! < 500) {
        // Discard if it's a client error (validation, etc.) to prevent queue block
        return true; 
      }
      return false;
    }
  }
}
