import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/di/service_locator.dart';
import '../../core/network/notification_service.dart';

class PharmacyRepository {
  final LocalDatabase db;

  PharmacyRepository(this.db);

  // ──────────────────────────────────────────────
  // MEDICATIONS (Pharmacy Catalog)
  // ──────────────────────────────────────────────

  Future<List<LocalMedication>> getMedications() async {
    return await (db.select(db.localMedications)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Future<void> addMedication(Map<String, dynamic> data) async {
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();
    await db.into(db.localMedications).insertOnConflictUpdate(LocalMedicationsCompanion.insert(
      id: uuid,
      name: data['name'],
      category: data['category'],
      unit: data['unit'],
      currentStock: Value(double.parse(data['current_stock'].toString())),
      reorderThreshold: Value(double.parse((data['reorder_threshold'] ?? 5.0).toString())),
      costPerUnit: Value(double.parse(data['cost_per_unit'].toString())),
      supplier: Value(data['supplier']),
      expiryDate: Value(data['expiry_date'] != null ? DateTime.parse(data['expiry_date']) : null),
      batchNumber: Value(data['batch_number']),
      milkWithdrawalDays: Value(int.parse((data['milk_withdrawal_days'] ?? 0).toString())),
      meatWithdrawalDays: Value(int.parse((data['meat_withdrawal_days'] ?? 0).toString())),
      isActive: const Value(true),
    ));

    // Log the initial stock if greater than zero
    final initialStock = double.parse(data['current_stock'].toString());
    if (initialStock > 0) {
      await db.into(db.localMedicationLogs).insertOnConflictUpdate(LocalMedicationLogsCompanion.insert(
        id: '${uuid}_init',
        medicationId: uuid,
        changeType: 'purchase',
        quantityChange: initialStock,
        balanceAfter: initialStock,
        logDate: DateTime.now(),
        notes: const Value('Initial stock entry upon creation'),
      ));
    }

    sl<NotificationService>().showLocalNotification(
      'Action Successful',
      'Successfully added medication: ${data['name']}',
      payload: '/pharmacy',
    );
  }

  Future<void> updateMedication(String id, Map<String, dynamic> data) async {
    await (db.update(db.localMedications)..where((t) => t.id.equals(id)))
        .write(LocalMedicationsCompanion(
      name: data.containsKey('name') ? Value(data['name']) : const Value.absent(),
      category: data.containsKey('category') ? Value(data['category']) : const Value.absent(),
      unit: data.containsKey('unit') ? Value(data['unit']) : const Value.absent(),
      reorderThreshold: data.containsKey('reorder_threshold') ? Value(double.parse(data['reorder_threshold'].toString())) : const Value.absent(),
      costPerUnit: data.containsKey('cost_per_unit') ? Value(double.parse(data['cost_per_unit'].toString())) : const Value.absent(),
      supplier: data.containsKey('supplier') ? Value(data['supplier']) : const Value.absent(),
      expiryDate: data.containsKey('expiry_date') ? Value(data['expiry_date'] != null ? DateTime.parse(data['expiry_date']) : null) : const Value.absent(),
      batchNumber: data.containsKey('batch_number') ? Value(data['batch_number']) : const Value.absent(),
      milkWithdrawalDays: data.containsKey('milk_withdrawal_days') ? Value(int.parse(data['milk_withdrawal_days'].toString())) : const Value.absent(),
      meatWithdrawalDays: data.containsKey('meat_withdrawal_days') ? Value(int.parse(data['meat_withdrawal_days'].toString())) : const Value.absent(),
      isActive: data.containsKey('is_active') ? Value(data['is_active']) : const Value.absent(),
    ));
  }

  // ──────────────────────────────────────────────
  // MEDICATION LOGS (Stock Movement Logs)
  // ──────────────────────────────────────────────

  Future<List<LocalMedicationLog>> getMedicationLogs() async {
    return await (db.select(db.localMedicationLogs)
          ..orderBy([(t) => OrderingTerm(expression: t.logDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<void> logMedicationChange(Map<String, dynamic> data) async {
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();
    final medicationId = data['medication_id'];
    final changeType = data['change_type']; // "purchase", "discard", "adjustment"
    final quantityChange = double.parse(data['quantity_change'].toString());

    final medication = await (db.select(db.localMedications)..where((t) => t.id.equals(medicationId))).getSingle();
    final double newStock = (medication.currentStock + quantityChange).clamp(0.0, double.infinity);

    // Update medication stock level and unit cost if provided
    await (db.update(db.localMedications)..where((t) => t.id.equals(medicationId)))
        .write(LocalMedicationsCompanion(
      currentStock: Value(newStock),
      costPerUnit: data.containsKey('cost_per_unit')
          ? Value(double.parse(data['cost_per_unit'].toString()))
          : const Value.absent(),
    ));

    // Record stock log entry
    await db.into(db.localMedicationLogs).insertOnConflictUpdate(LocalMedicationLogsCompanion.insert(
      id: uuid,
      medicationId: medicationId,
      changeType: changeType,
      quantityChange: quantityChange,
      balanceAfter: newStock,
      logDate: DateTime.now(),
      notes: Value(data['notes']),
    ));

    // Add informational notification
    final String actionText = changeType == 'purchase' ? 'Restocked' 
        : changeType == 'discard' ? 'Discarded' 
        : 'Adjusted';
        
    await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
      id: 'task_pharm_$uuid',
      title: 'Pharmacy Inventory $actionText',
      description: Value('$actionText $quantityChange units of ${medication.name}. New balance: $newStock.'),
      priority: 'medium',
      status: 'completed',
      dueDate: Value(DateTime.now()),
      category: const Value('pharmacy'),
      isActionable: const Value(false),
    ));
  }

  // ──────────────────────────────────────────────
  // ANIMAL MEDICAL RECORDS (Treatments & Costs)
  // ──────────────────────────────────────────────

  Future<List<LocalAnimalMedicalRecord>> getMedicalRecords({String? animalId}) async {
    var query = db.select(db.localAnimalMedicalRecords)
      ..orderBy([(t) => OrderingTerm(expression: t.treatmentDate, mode: OrderingMode.desc)]);

    if (animalId != null) {
      query = query..where((t) => t.animalId.equals(animalId));
    }
    return await query.get();
  }

  Future<void> logAnimalTreatment(Map<String, dynamic> data) async {
    final uuid = DateTime.now().millisecondsSinceEpoch.toString();
    final animalId = data['animal_id'];
    final medicationId = data['medication_id'];
    final dose = double.parse(data['administered_dose'].toString());
    final treatmentDate = DateTime.parse(data['treatment_date']);

    // 1. Fetch medication details to get unit cost and withdrawal details
    final med = await (db.select(db.localMedications)..where((t) => t.id.equals(medicationId))).getSingle();

    if (med.currentStock < dose) {
      throw Exception('Insufficient pharmacy stock of "${med.name}". Current: ${med.currentStock.toStringAsFixed(1)} ${med.unit}, Required: ${dose.toStringAsFixed(1)} ${med.unit}');
    }

    // 2. Auto-calculate treatment cost
    final cost = dose * med.costPerUnit;

    // 3. Calculate withdrawal end date
    final maxWithdrawalDays = med.milkWithdrawalDays > med.meatWithdrawalDays ? med.milkWithdrawalDays : med.meatWithdrawalDays;
    final withdrawalEndDate = maxWithdrawalDays > 0 ? treatmentDate.add(Duration(days: maxWithdrawalDays)) : null;

    // 4. Record the treatment
    await db.into(db.localAnimalMedicalRecords).insertOnConflictUpdate(LocalAnimalMedicalRecordsCompanion.insert(
      id: uuid,
      animalId: animalId,
      medicationId: medicationId,
      administeredDose: dose,
      cost: cost,
      treatmentDate: treatmentDate,
      diagnosedCondition: data['diagnosed_condition'],
      administeredBy: Value(data['administered_by']),
      withdrawalEndDate: Value(withdrawalEndDate),
      notes: Value(data['notes']),
    ));

    // 5. Deduct stock from medications catalog
    final double newStock = (med.currentStock - dose).clamp(0.0, double.infinity);
    await (db.update(db.localMedications)..where((t) => t.id.equals(medicationId)))
        .write(LocalMedicationsCompanion(
      currentStock: Value(newStock),
    ));

    // 6. Log the movement in medication logs
    await db.into(db.localMedicationLogs).insertOnConflictUpdate(LocalMedicationLogsCompanion.insert(
      id: '${uuid}_treat',
      medicationId: medicationId,
      changeType: 'treatment',
      quantityChange: -dose,
      balanceAfter: newStock,
      logDate: treatmentDate,
      notes: Value('Administered to animal ID: $animalId for ${data['diagnosed_condition']}'),
    ));

    // 7. Add informational notification for the medical record
    await db.into(db.localTasks).insertOnConflictUpdate(LocalTasksCompanion.insert(
      id: 'task_med_$uuid',
      title: 'Medical Treatment Logged',
      description: Value('Administered $dose units of ${med.name} to animal ID: $animalId for ${data['diagnosed_condition']}'),
      priority: 'high',
      status: 'completed',
      dueDate: Value(treatmentDate),
      category: const Value('medical_record'),
      isActionable: const Value(false),
    ));
  }
}
