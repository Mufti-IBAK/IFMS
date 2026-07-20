import 'dart:convert';
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
            startDate: Value(s['start_date'] != null ? DateTime.tryParse(s['start_date']) : null),
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

    final apiData = {
      'id': newId,
      'name': data['name'],
      'role': data['role'],
      'phone': data['phone'],
      'base_salary': data['base_salary'] != null ? double.parse(data['base_salary'].toString()) : 0.0,
      'performance_rating': 5.0,
      'is_active': true,
      'profile_pic': null, // PostgREST has no multipart support
      'gender': data['gender'],
      'date_of_birth': data['date_of_birth'],
      'start_date': data['start_date'],
      'address': data['address'],
      'emergency_contact': data['emergency_contact'],
      'employment_type': data['employment_type'],
    };
    
    try {
      await apiClient.dio.post('/staff', data: apiData);

      // Save locally on success
      await db.into(db.localStaff).insertOnConflictUpdate(LocalStaffCompanion.insert(
        id: newId,
        name: data['name'],
        role: data['role'],
        phone: Value(data['phone']),
        baseSalary: Value(data['base_salary'] != null ? double.parse(data['base_salary'].toString()) : 0.0),
        isActive: const Value(true),
        profilePic: Value(data['profile_pic']),
        gender: Value(data['gender']),
        dateOfBirth: Value(data['date_of_birth'] != null ? DateTime.tryParse(data['date_of_birth']) : null),
        startDate: Value(data['start_date'] != null ? DateTime.tryParse(data['start_date']) : null),
        address: Value(data['address']),
        emergencyContact: Value(data['emergency_contact']),
        employmentType: Value(data['employment_type']),
      ));
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.localStaff).insertOnConflictUpdate(LocalStaffCompanion.insert(
          id: newId,
          name: data['name'],
          role: data['role'],
          phone: Value(data['phone']),
          baseSalary: Value(data['base_salary'] != null ? double.parse(data['base_salary'].toString()) : 0.0),
          isActive: const Value(true),
          profilePic: Value(data['profile_pic']),
          gender: Value(data['gender']),
          dateOfBirth: Value(data['date_of_birth'] != null ? DateTime.tryParse(data['date_of_birth']) : null),
          startDate: Value(data['start_date'] != null ? DateTime.tryParse(data['start_date']) : null),
          address: Value(data['address']),
          emergencyContact: Value(data['emergency_contact']),
          employmentType: Value(data['employment_type']),
        ));

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/staff',
          method: 'POST',
          body: jsonEncode(apiData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to add staff: ${e.message}');
      }
      throw Exception('Failed to add staff: $e');
    }
  }

  Future<void> updateStaff(String id, Map<String, dynamic> data) async {
    try {
      await apiClient.dio.patch('/staff/$id', data: data);

      // Local update on success
      await (db.update(db.localStaff)..where((t) => t.id.equals(id))).write(
        LocalStaffCompanion(
          name: data.containsKey('name') ? Value(data['name'].toString()) : const Value.absent(),
          role: data.containsKey('role') ? Value(data['role'].toString()) : const Value.absent(),
          phone: data.containsKey('phone') ? Value(data['phone']?.toString()) : const Value.absent(),
          baseSalary: data.containsKey('base_salary') ? Value(double.parse(data['base_salary'].toString())) : const Value.absent(),
          performanceRating: data.containsKey('performance_rating') ? Value(double.parse(data['performance_rating'].toString())) : const Value.absent(),
          isActive: data.containsKey('is_active') ? Value(data['is_active']) : const Value.absent(),
          profilePic: data.containsKey('profile_pic') ? Value(data['profile_pic']?.toString()) : const Value.absent(),
          gender: data.containsKey('gender') ? Value(data['gender']?.toString()) : const Value.absent(),
          dateOfBirth: data.containsKey('date_of_birth') ? Value(data['date_of_birth'] != null ? DateTime.tryParse(data['date_of_birth'].toString()) : null) : const Value.absent(),
          startDate: data.containsKey('start_date') ? Value(data['start_date'] != null ? DateTime.tryParse(data['start_date'].toString()) : null) : const Value.absent(),
          address: data.containsKey('address') ? Value(data['address']?.toString()) : const Value.absent(),
          emergencyContact: data.containsKey('emergency_contact') ? Value(data['emergency_contact']?.toString()) : const Value.absent(),
          employmentType: data.containsKey('employment_type') ? Value(data['employment_type'].toString()) : const Value.absent(),
        )
      );
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.update(db.localStaff)..where((t) => t.id.equals(id))).write(
          LocalStaffCompanion(
            name: data.containsKey('name') ? Value(data['name'].toString()) : const Value.absent(),
            role: data.containsKey('role') ? Value(data['role'].toString()) : const Value.absent(),
            phone: data.containsKey('phone') ? Value(data['phone']?.toString()) : const Value.absent(),
            baseSalary: data.containsKey('base_salary') ? Value(double.parse(data['base_salary'].toString())) : const Value.absent(),
            performanceRating: data.containsKey('performance_rating') ? Value(double.parse(data['performance_rating'].toString())) : const Value.absent(),
            isActive: data.containsKey('is_active') ? Value(data['is_active']) : const Value.absent(),
            profilePic: data.containsKey('profile_pic') ? Value(data['profile_pic']?.toString()) : const Value.absent(),
            gender: data.containsKey('gender') ? Value(data['gender']?.toString()) : const Value.absent(),
            dateOfBirth: data.containsKey('date_of_birth') ? Value(data['date_of_birth'] != null ? DateTime.tryParse(data['date_of_birth'].toString()) : null) : const Value.absent(),
            startDate: data.containsKey('start_date') ? Value(data['start_date'] != null ? DateTime.tryParse(data['start_date'].toString()) : null) : const Value.absent(),
            address: data.containsKey('address') ? Value(data['address']?.toString()) : const Value.absent(),
            emergencyContact: data.containsKey('emergency_contact') ? Value(data['emergency_contact']?.toString()) : const Value.absent(),
            employmentType: data.containsKey('employment_type') ? Value(data['employment_type'].toString()) : const Value.absent(),
          )
        );

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/staff/$id',
          method: 'PATCH',
          body: jsonEncode(data),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to update staff: ${e.message}');
      }
      throw Exception('Failed to update staff: $e');
    }
  }

  Future<void> deleteStaff(String id) async {
    try {
      await apiClient.dio.delete('/staff/$id');
      await (db.delete(db.localStaff)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.delete(db.localStaff)..where((t) => t.id.equals(id))).go();
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/staff/$id',
          method: 'DELETE',
          body: jsonEncode({}),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Deleted locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to delete staff: ${e.message}');
      }
      throw Exception('Failed to delete staff: $e');
    }
  }

  Future<List<LocalStaffQuery>> getQueries({String? staffId}) async {
    try {
      final response = await apiClient.dio.get('/staff/queries', queryParameters: staffId != null ? {'staff_id': 'eq.$staffId'} : null);
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
            description: Value(q['description'] as String?),
            deductionAmount: Value(double.tryParse((q['deduction_amount'] ?? 0.0).toString()) ?? 0.0),
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
    final uuid = const Uuid().v4();
    final apiData = {
      'id': uuid,
      'staff_id': staffId,
      'title': data['title'],
      'description': data['description'],
      'deduction_amount': double.parse((data['deduction_amount'] ?? 0.0).toString()),
      'is_resolved': false,
      'issue_date': data['issue_date'] ?? DateTime.now().toIso8601String(),
    };

    try {
      await apiClient.dio.post('/staff/queries', data: apiData);
      
      await db.into(db.localStaffQueries).insert(LocalStaffQueriesCompanion.insert(
        id: uuid,
        staffId: staffId,
        title: data['title'] ?? 'Infraction',
        description: Value(data['description'] as String?),
        deductionAmount: Value(double.parse((data['deduction_amount'] ?? 0.0).toString())),
        isResolved: const Value(false),
        issueDate: DateTime.parse(apiData['issue_date']!),
      ));
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.localStaffQueries).insert(LocalStaffQueriesCompanion.insert(
          id: uuid,
          staffId: staffId,
          title: data['title'] ?? 'Infraction',
          description: Value(data['description'] as String?),
          deductionAmount: Value(double.parse((data['deduction_amount'] ?? 0.0).toString())),
          isResolved: const Value(false),
          issueDate: DateTime.parse(apiData['issue_date']!),
        ));

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/staff/queries',
          method: 'POST',
          body: jsonEncode(apiData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to issue query: ${e.message}');
      }
      throw Exception('Failed to issue query: $e');
    }
  }

  Future<void> resolveQuery(String queryId, String notes) async {
    final patchData = {
      'is_resolved': true,
      'deduction_amount': 0.0,
      'resolution_notes': notes,
      'resolved_at': DateTime.now().toIso8601String(),
    };

    try {
      await apiClient.dio.patch('/staff/queries/$queryId', data: patchData);

      // Local update on success
      await (db.update(db.localStaffQueries)..where((t) => t.id.equals(queryId))).write(
        LocalStaffQueriesCompanion(
          isResolved: const Value(true),
          deductionAmount: const Value(0.0),
          resolutionNotes: Value(notes),
          resolvedAt: Value(DateTime.now()),
        )
      );
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        // Local update on network failure (offline)
        await (db.update(db.localStaffQueries)..where((t) => t.id.equals(queryId))).write(
          LocalStaffQueriesCompanion(
            isResolved: const Value(true),
            deductionAmount: const Value(0.0),
            resolutionNotes: Value(notes),
            resolvedAt: Value(DateTime.now()),
          )
        );

        // Queue for synchronization
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/staff/queries/$queryId',
          method: 'PATCH',
          body: jsonEncode(patchData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      rethrow;
    }
  }

  Future<void> createAdvance(Map<String, dynamic> data) async {
    final uuid = const Uuid().v4();
    final apiData = {
      'id': uuid,
      'staff_id': data['staff_id'],
      'advance_amount': double.parse((data['advance_amount'] ?? 0.0).toString()),
      'monthly_deduction': double.parse((data['monthly_deduction'] ?? 0.0).toString()),
      'total_repaid': 0.0,
      'collection_date': data['collection_date'] ?? DateTime.now().toIso8601String(),
      'is_fully_repaid': false,
      'notes': data['notes'],
    };

    try {
      await apiClient.dio.post('/salary_advances', data: apiData);
      
      await db.into(db.localSalaryAdvances).insert(LocalSalaryAdvancesCompanion.insert(
        id: uuid,
        staffId: data['staff_id'],
        advanceAmount: double.parse((data['advance_amount'] ?? 0.0).toString()),
        monthlyDeduction: double.parse((data['monthly_deduction'] ?? 0.0).toString()),
        totalRepaid: const Value(0.0),
        collectionDate: DateTime.parse(apiData['collection_date']!),
        isFullyRepaid: const Value(false),
        notes: Value(data['notes']),
      ));
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await db.into(db.localSalaryAdvances).insert(LocalSalaryAdvancesCompanion.insert(
          id: uuid,
          staffId: data['staff_id'],
          advanceAmount: double.parse((data['advance_amount'] ?? 0.0).toString()),
          monthlyDeduction: double.parse((data['monthly_deduction'] ?? 0.0).toString()),
          totalRepaid: const Value(0.0),
          collectionDate: DateTime.parse(apiData['collection_date']!),
          isFullyRepaid: const Value(false),
          notes: Value(data['notes']),
        ));

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/salary_advances',
          method: 'POST',
          body: jsonEncode(apiData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to create advance: ${e.message}');
      }
      throw Exception('Failed to create advance: $e');
    }
  }

  Future<List<LocalSalaryAdvance>> getActiveAdvances(String staffId) async {
    return (db.select(db.localSalaryAdvances)..where((t) => t.staffId.equals(staffId) & t.isFullyRepaid.equals(false))).get();
  }

  Future<double> getTotalActiveMonthlyDeductions(String staffId) async {
    final advances = await getActiveAdvances(staffId);
    double total = 0.0;
    for (final adv in advances) {
      total += adv.monthlyDeduction;
    }
    return total;
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
      
      final activeAdvances = await (db.select(db.localSalaryAdvances)..where((t) => t.isFullyRepaid.equals(false))).get();
      for (final adv in activeAdvances) {
        totalDeductions += adv.monthlyDeduction;
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
    
    // Fetch active salary advances
    final activeAdvances = await (db.select(db.localSalaryAdvances)..where((t) => t.isFullyRepaid.equals(false))).get();
    final Map<String, List<LocalSalaryAdvance>> advancesByStaff = {};
    for (final a in activeAdvances) {
      advancesByStaff.putIfAbsent(a.staffId, () => []).add(a);
    }

    // 3. Process in a batch transaction
    await db.transaction(() async {
      for (final staff in staffList) {
        final staffQueries = queriesByStaff[staff.id] ?? [];
        final staffAdvances = advancesByStaff[staff.id] ?? [];
        
        double deductions = 0.0;
        for (final q in staffQueries) {
          deductions += q.deductionAmount;
        }
        for (final a in staffAdvances) {
          deductions += a.monthlyDeduction;
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

          // Process salary advances
          for (final a in staffAdvances) {
            double newRepaid = a.totalRepaid + a.monthlyDeduction;
            bool isFullyRepaid = newRepaid >= a.advanceAmount;
            if (newRepaid > a.advanceAmount) {
              newRepaid = a.advanceAmount;
            }
            
            await (db.update(db.localSalaryAdvances)..where((t) => t.id.equals(a.id))).write(
              LocalSalaryAdvancesCompanion(
                totalRepaid: Value(newRepaid),
                isFullyRepaid: Value(isFullyRepaid),
              )
            );
          }
        }
      }
    });
  }
}
