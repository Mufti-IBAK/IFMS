import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class PoultryRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  PoultryRepository(this.apiClient, this.db);

  Future<List<LocalPoultryBatche>> getBatches() async {
    try {
      final response = await apiClient.dio.get('/poultry/batches');
      final list = response.data as List;
      await _syncBatches(list);
    } catch (_) {}
    return await db.select(db.localPoultryBatches).get();
  }

  Future<void> createBatch(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final batchNumber = data['batch_number'].toString();
    final houseName = data['house_name'].toString();
    final initialCount = int.parse(data['initial_count'].toString());
    final initialChickCost = double.parse(data['initial_chick_cost'].toString());
    final breed = data['breed'] ?? 'Broiler';
    final startDate = DateTime.parse(data['start_date'].toString());

    // Remote Sync
    final remoteData = {
      'id': uuid,
      'batch_type': data['batch_type'] ?? 'broiler',
      'breed': breed,
      'start_date': data['start_date'],
      'initial_count': initialCount,
      'initial_chick_cost': initialChickCost,
      'location_id': houseName,
    };

    try {
      await apiClient.dio.post('/poultry/batch', data: remoteData);

      // Local Insert
      await db.into(db.localPoultryBatches).insert(LocalPoultryBatchesCompanion.insert(
        id: uuid,
        batchNumber: batchNumber,
        houseName: houseName,
        initialCount: initialCount,
        currentCount: initialCount,
        startDate: startDate,
        status: 'active',
      ));
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to create batch: ${e.message}');
      }
      throw Exception('Failed to create batch: $e');
    }
  }

  Future<Map<String, dynamic>> getBatchKpi(String batchId) async {
    try {
      final response = await apiClient.dio.get('/poultry/batch/$batchId/kpi');
      return Map<String, dynamic>.from(response.data);
    } catch (_) {
      // Local fallback calculation if offline
      final logs = await (db.select(db.localPoultryLogs)..where((t) => t.batchId.equals(batchId))).get();
      final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
      
      int totalDead = 0;
      int totalBags = 0;
      double latestWeight = 0.04;
      for (var l in logs) {
        totalDead += l.mortality;
        totalBags += l.feedBags;
        if (l.averageWeight != null) {
          latestWeight = l.averageWeight!;
        }
      }
      
      final mortalityRate = batch.initialCount > 0 ? (totalDead / batch.initialCount * 100) : 0.0;
      final feedKg = totalBags * 25.0; // 25kg per bag
      final liveWeight = latestWeight * batch.currentCount;
      final initialWeight = batch.initialCount * 0.04;
      final weightGain = (liveWeight - initialWeight).clamp(0.0, double.infinity);
      final fcr = weightGain > 0 ? (feedKg / weightGain) : 0.0;

      return {
        'mortality_rate_percent': mortalityRate,
        'total_feed_consumed_kg': feedKg,
        'feed_conversion_ratio': fcr,
        'average_weight_kg': latestWeight,
        'live_weight_kg': liveWeight,
        'total_sold_count': 0,
        'revenue': 0.0,
        'total_costs': feedKg * 200.0, // estimated
        'cost_per_kg_sold': 0.0,
        'net_profit': 0.0,
        'alerts': {
          'high_mortality_alert': mortalityRate > 5.0,
          'poor_fcr_alert': fcr > 2.2,
          'disease_outbreak_risk': false,
        }
      };
    }
  }

  Future<void> logBatchEvent(String batchId, Map<String, dynamic> eventData) async {
    // Under local db, we log to localPoultryLogs:
    final changeType = eventData['event_type'].toString(); // feed, mortality, weight_sample
    final double qty = double.parse(eventData['quantity'].toString());
    
    // Remote sync
    final remoteData = {
      'id': const Uuid().v4(),
      'event_type': changeType,
      'event_date': DateTime.now().toIso8601String().substring(0, 10),
      'quantity': qty,
      'value_json': eventData['value_json'],
    };

    try {
      await apiClient.dio.post('/poultry/batch/$batchId/event', data: remoteData);

      if (changeType == 'mortality') {
        final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
        final newCount = (batch.currentCount - qty.toInt()).clamp(0, batch.initialCount);
        await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).write(
          LocalPoultryBatchesCompanion(currentCount: Value(newCount))
        );
        await db.into(db.localPoultryLogs).insert(LocalPoultryLogsCompanion.insert(
          batchId: batchId,
          logDate: DateTime.now(),
          mortality: Value(qty.toInt()),
        ));
      } else if (changeType == 'feed') {
        await db.into(db.localPoultryLogs).insert(LocalPoultryLogsCompanion.insert(
          batchId: batchId,
          logDate: DateTime.now(),
          feedBags: Value(qty.toInt()),
        ));
      } else if (changeType == 'weight_sample') {
        await db.into(db.localPoultryLogs).insert(LocalPoultryLogsCompanion.insert(
          batchId: batchId,
          logDate: DateTime.now(),
          averageWeight: Value(qty),
        ));
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to log event: ${e.message}');
      }
      throw Exception('Failed to log event: $e');
    }
  }

  Future<void> addDailyLog(String batchId, Map<String, dynamic> logData) async {
    final int feedBags = int.parse((logData['feed_bags'] ?? 0).toString());
    final int mortality = int.parse((logData['mortality'] ?? 0).toString());
    final double? avgWeight = logData['average_weight'] != null ? double.parse(logData['average_weight'].toString()) : null;

    // Local insert
    await db.into(db.localPoultryLogs).insert(LocalPoultryLogsCompanion.insert(
      batchId: batchId,
      logDate: DateTime.now(),
      feedBags: Value(feedBags),
      mortality: Value(mortality),
      averageWeight: Value(avgWeight),
    ));

    // Update current count locally
    if (mortality > 0) {
      final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
      final newCount = (batch.currentCount - mortality).clamp(0, batch.initialCount);
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).write(
        LocalPoultryBatchesCompanion(currentCount: Value(newCount))
      );
    }

    // Remote Sync - decompose into individual events
    if (mortality > 0) {
      await logBatchEvent(batchId, {
        'event_type': 'mortality',
        'quantity': mortality.toDouble(),
      });
    }
    if (feedBags > 0) {
      await logBatchEvent(batchId, {
        'event_type': 'feed',
        'quantity': feedBags * 25.0, // Standard 25kg bag
        'value_json': {'price_per_kg': 200.0},
      });
    }
    if (avgWeight != null && avgWeight > 0.0) {
      await logBatchEvent(batchId, {
        'event_type': 'weight_sample',
        'quantity': 1.0,
        'value_json': {'avg_weight_kg': avgWeight},
      });
    }
  }

  Future<void> logBatchSale(String batchId, Map<String, dynamic> saleData) async {
    final int soldCount = int.parse(saleData['quantity'].toString());
    final double avgWeight = double.parse(saleData['avg_weight_kg'].toString());
    final double revenue = double.parse(saleData['revenue'].toString());
    final bool isClosing = saleData['is_closing'] == true;

    // Sync sale event to backend
    final remoteData = {
      'event_type': 'sale',
      'event_date': DateTime.now().toIso8601String().substring(0, 10),
      'quantity': soldCount.toDouble(),
      'value_json': {
        'avg_weight_kg': avgWeight,
        'revenue': revenue,
      }
    };

    final batch = await (db.select(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).getSingle();
    final newCount = (batch.currentCount - soldCount).clamp(0, batch.initialCount);

    try {
      await apiClient.dio.post('/poultry/batch/$batchId/event', data: remoteData);
      if (isClosing && newCount > 0) {
         await apiClient.dio.post('/poultry/batch/$batchId/event', data: {
            'event_type': 'close',
            'event_date': DateTime.now().toIso8601String().substring(0, 10),
            'quantity': 0,
            'value_json': null
         });
      }

      // Update local count and conditionally update status
      var companion = LocalPoultryBatchesCompanion(currentCount: Value(newCount));
      if (isClosing || newCount == 0) {
        companion = companion.copyWith(status: const Value('closed'));
      }
      await (db.update(db.localPoultryBatches)..where((t) => t.id.equals(batchId))).write(companion);

    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to log sale: ${e.message}');
      }
      throw Exception('Failed to log sale: $e');
    }
  }

  Future<void> _syncBatches(List<dynamic> remoteData) async {
    await db.transaction(() async {
      await db.batch((batch) {
        batch.insertAll(
          db.localPoultryBatches,
          remoteData.map((item) => LocalPoultryBatchesCompanion.insert(
            id: item['id'].toString(),
            batchNumber: item['batch_number'].toString(),
            houseName: (item['location_id'] ?? item['house_name'] ?? '').toString(),
            initialCount: int.parse(item['initial_count'].toString()),
            currentCount: int.parse(item['current_count'].toString()),
            startDate: DateTime.parse(item['start_date'].toString()),
            status: item['status'].toString(),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }
}
