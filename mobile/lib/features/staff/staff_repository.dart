import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class StaffRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  StaffRepository(this.apiClient, this.db);

  Future<List<LocalStaffData>> getStaff() async {
    try {
      final response = await apiClient.dio.get('/staff');
      final list = response.data as List;
      await _syncStaffToLocal(list);
    } catch (_) {}
    return await db.select(db.localStaff).get();
  }

  Future<void> _syncStaffToLocal(List<dynamic> remoteList) async {
    await db.transaction(() async {
      await db.batch((batch) {
        batch.insertAll(
          db.localStaff,
          remoteList.map((s) => LocalStaffCompanion.insert(
            id: s['id'],
            name: s['name'],
            role: s['role'],
            phone: Value(s['phone']),
            baseSalary: Value(double.tryParse(s['base_salary'].toString()) ?? 0.0),
            performanceRating: Value(double.tryParse(s['performance_rating'].toString()) ?? 5.0),
            isActive: Value(s['is_active'] ?? true),
            profilePic: Value(s['profile_pic']),
            gender: Value(s['gender']),
            dateOfBirth: Value(s['date_of_birth'] != null ? DateTime.tryParse(s['date_of_birth']) : null),
            address: Value(s['address']),
            emergencyContact: Value(s['emergency_contact']),
            employmentType: Value(s['employment_type']),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }


  Future<void> addStaff(Map<String, dynamic> data) async {
    final newId = data['id'] ?? const Uuid().v4();
    data['id'] = newId;
    
    // Save locally first for offline support and immediate UI feedback
    await db.into(db.localStaff).insertOnConflictUpdate(LocalStaffCompanion.insert(
      id: newId,
      name: data['name'],
      role: data['role'],
      phone: Value(data['phone']),
      baseSalary: Value(data['base_salary']),
      isActive: const Value(true),
      profilePic: Value(data['profile_pic']),
      gender: Value(data['gender']),
      dateOfBirth: Value(data['date_of_birth'] != null ? DateTime.tryParse(data['date_of_birth']) : null),
      address: Value(data['address']),
      emergencyContact: Value(data['emergency_contact']),
      employmentType: Value(data['employment_type']),
    ));

    try {
      if (data['profile_pic'] != null) {
        final Map<String, dynamic> formDataMap = Map.from(data);
        formDataMap.remove('profile_pic');
        
        final formData = FormData.fromMap(formDataMap);
        formData.files.add(MapEntry(
          'profile_pic',
          await MultipartFile.fromFile(data['profile_pic']),
        ));
        await apiClient.dio.post('/staff', data: formData);
      } else {
        await apiClient.dio.post('/staff', data: data);
      }
    } catch (e) {
      log('Offline: Staff saved locally.');
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/staff',
        method: 'POST',
        body: jsonEncode(data),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> updateStaff(String id, Map<String, dynamic> data) async {
    try {
      await apiClient.dio.patch('/staff/$id', data: data);
    } catch (e) {
      // Local update
      await (db.update(db.localStaff)..where((t) => t.id.equals(id))).write(
        LocalStaffCompanion(
          baseSalary: data.containsKey('base_salary') ? Value(double.parse(data['base_salary'].toString())) : const Value.absent(),
          performanceRating: data.containsKey('performance_rating') ? Value(double.parse(data['performance_rating'].toString())) : const Value.absent(),
          isActive: data.containsKey('is_active') ? Value(data['is_active']) : const Value.absent(),
          role: data.containsKey('role') ? Value(data['role'].toString()) : const Value.absent(),
          employmentType: data.containsKey('employment_type') ? Value(data['employment_type'].toString()) : const Value.absent(),
        )
      );
    }
  }

  Future<void> deleteStaff(String id) async {
    try {
      await apiClient.dio.delete('/staff/$id');
    } catch (e) {
      log('Offline: Delete deferred for staff $id');
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/staff/$id',
        method: 'DELETE',
        body: '{}',
        queuedAt: DateTime.now(),
      ));
    }
    await (db.delete(db.localStaff)..where((t) => t.id.equals(id))).go();
  }

  Future<List<LocalStaffQuery>> getQueries({String? staffId}) async {
    try {
      final response = await apiClient.dio.get('/staff/queries', queryParameters: staffId != null ? {'staff_id': staffId} : null);
      final list = response.data as List;
      await _syncQueriesToLocal(list);
    } catch (_) {}
    
    if (staffId != null) {
      return (db.select(db.localStaffQueries)..where((t) => t.staffId.equals(staffId))).get();
    }
    return db.select(db.localStaffQueries).get();
  }

  Future<void> _syncQueriesToLocal(List<dynamic> remoteList) async {
    await db.transaction(() async {
      await db.delete(db.localStaffQueries).go();
      await db.batch((batch) {
        batch.insertAll(
          db.localStaffQueries,
          remoteList.map((q) => LocalStaffQueriesCompanion.insert(
            id: q['id'],
            staffId: q['staff_id'],
            title: q['title'],
            description: q['description'],
            deductionAmount: Value(double.tryParse(q['deduction_amount'].toString()) ?? 0.0),
            isResolved: Value(q['is_resolved'] ?? false),
            resolutionNotes: Value(q['resolution_notes']),
            resolvedAt: Value(q['resolved_at'] != null ? DateTime.parse(q['resolved_at']) : null),
            issueDate: DateTime.parse(q['issue_date']),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> issueQuery(String staffId, Map<String, dynamic> data) async {
    try {
      await apiClient.dio.post('/staff/$staffId/queries', data: data);
    } catch (e) {
       // Minimal offline support
    }
  }

  Future<void> resolveQuery(String queryId, String notes) async {
    try {
      await apiClient.dio.patch('/staff/queries/$queryId/resolve', data: {'resolution_notes': notes});
    } catch (e) {
      // Local update
      await (db.update(db.localStaffQueries)..where((t) => t.id.equals(queryId))).write(
        LocalStaffQueriesCompanion(
          isResolved: const Value(true),
          resolutionNotes: Value(notes),
          resolvedAt: Value(DateTime.now()),
        )
      );
    }
  }

  Future<Map<String, dynamic>> getBudgetSummary() async {
    try {
      final response = await apiClient.dio.get('/staff/salary-budget');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Local fallback computation
      final staffList = await db.select(db.localStaff).get();
      final unresolvedQueries = await (db.select(db.localStaffQueries)..where((t) => t.isResolved.equals(false))).get();
      
      double totalBase = 0;
      int activeCount = 0;
      for (final s in staffList) {
        if (s.isActive) {
          totalBase += s.baseSalary;
          activeCount++;
        }
      }
      
      double totalDeductions = 0;
      for (final q in unresolvedQueries) {
        totalDeductions += q.deductionAmount;
      }
      
      return {
        'total_base_salary': totalBase,
        'total_active_deductions': totalDeductions,
        'net_salary_budget': totalBase - totalDeductions,
        'staff_count': activeCount,
        'active_queries_count': unresolvedQueries.length,
      };
    }
  }

  Future<void> processPayroll(DateTime month) async {
    // 1. Fetch active staff
    final staffList = await (db.select(db.localStaff)..where((t) => t.isActive.equals(true))).get();
    
    // 2. Fetch all unresolved queries
    final unresolvedQueries = await (db.select(db.localStaffQueries)..where((t) => t.isResolved.equals(false))).get();
    
    // Group queries by staff ID
    final Map<String, List<LocalStaffQuery>> queriesByStaff = {};
    for (final q in unresolvedQueries) {
      queriesByStaff.putIfAbsent(q.staffId, () => []).add(q);
    }
    
    // 3. Process in a batch transaction
    await db.transaction(() async {
      for (final staff in staffList) {
        final staffQueries = queriesByStaff[staff.id] ?? [];
        double deductions = 0.0;
        for (final q in staffQueries) {
          deductions += q.deductionAmount;
        }
        
        final netSalary = staff.baseSalary - deductions;
        
        if (netSalary >= 0) {
          // Create transaction record
          final txId = const Uuid().v4();
          await db.into(db.localTransactions).insert(
            LocalTransactionsCompanion.insert(
              id: txId,
              transactionType: 'expense',
              category: 'labor',
              amount: netSalary,
              currency: const Value('NGN'),
              description: Value('Payroll for ${month.month}/${month.year}'),
              transactionDate: DateTime.now(),
              relatedEntityType: const Value('staff'),
              relatedEntityId: Value(staff.id),
              isReconciled: const Value(false),
            )
          );
          
          // Mark queries as resolved
          for (final q in staffQueries) {
            await (db.update(db.localStaffQueries)..where((t) => t.id.equals(q.id))).write(
              LocalStaffQueriesCompanion(
                isResolved: const Value(true),
                resolutionNotes: const Value('Deducted during payroll'),
                resolvedAt: Value(DateTime.now()),
              )
            );
          }
        }
      }
    });
  }
}
