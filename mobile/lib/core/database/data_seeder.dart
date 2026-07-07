import 'package:drift/drift.dart';
import 'local_db.dart';
import '../di/service_locator.dart';

class DataSeeder {
  static Future<void> seedData() async {
    final db = sl<LocalDatabase>();
    
    // Check if we already have animals to prevent double seeding
    final existingAnimals = await db.select(db.localAnimals).get();
    if (existingAnimals.isNotEmpty) return;

    // 1. Animals
    final animalIds = ['COW-001', 'COW-002', 'GOAT-001', 'GOAT-002'];
    for (var i = 0; i < animalIds.length; i++) {
      await db.into(db.localAnimals).insert(LocalAnimalsCompanion.insert(
        id: 'uuid-animal-$i',
        tagId: animalIds[i],
        species: animalIds[i].startsWith('COW') ? 'bovine' : 'caprine',
        sex: i % 2 == 0 ? 'female' : 'male',
        dateOfBirth: Value(DateTime.now().subtract(Duration(days: 365 * (i + 1)))),
        currentReproductiveStatus: 'active',
        acquisitionCost: const Value(50000.0),
        status: const Value('active'),
      ));
    }

    // 2. Medications
    await db.into(db.localMedications).insert(LocalMedicationsCompanion.insert(
      id: 'med-001',
      name: 'Penicillin G',
      category: 'Antibiotic',
      unit: 'ml',
      currentStock: const Value(100.0),
      reorderThreshold: const Value(20.0),
      costPerUnit: const Value(500.0),
      isActive: const Value(true),
    ));

    await db.into(db.localMedications).insert(LocalMedicationsCompanion.insert(
      id: 'med-002',
      name: 'Ivermectin',
      category: 'Dewormer',
      unit: 'ml',
      currentStock: const Value(50.0),
      reorderThreshold: const Value(10.0),
      costPerUnit: const Value(800.0),
      isActive: const Value(true),
    ));

    // 3. Feed Items
    await db.into(db.localFeedItems).insert(LocalFeedItemsCompanion.insert(
      id: 'feed-001',
      name: 'Dairy Mash',
      category: 'feed',
      unit: 'kg',
      currentStock: 500.0,
      reorderThreshold: 100.0,
      costPerUnit: 250.0,
      isActive: const Value(true),
    ));

    // 4. Tasks (Notification Center)
    await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
      id: 'task-001',
      title: 'Vaccinate Goats',
      description: const Value('Administer PPR vaccine to GOAT-001 and GOAT-002'),
      priority: 'high',
      status: 'pending',
      dueDate: Value(DateTime.now().add(const Duration(days: 1))),
      category: const Value('medical_record'),
      isActionable: const Value(true),
    ));

    // 5. Alerts
    await db.into(db.localAlerts).insert(LocalAlertsCompanion.insert(
      id: 'alert-001',
      title: 'Low Feed Stock',
      severity: 'warning',
      message: 'Dairy Mash is running low.',
      createdAt: DateTime.now(),
    ));

    // 6. Medical Records
    await db.into(db.localAnimalMedicalRecords).insert(LocalAnimalMedicalRecordsCompanion.insert(
      id: 'med-rec-001',
      animalId: 'uuid-animal-0',
      medicationId: 'med-001',
      administeredDose: 10.0,
      cost: 5000.0,
      treatmentDate: DateTime.now().subtract(const Duration(days: 2)),
      diagnosedCondition: 'Mastitis',
    ));
    
    // 7. Transactions
    await db.into(db.localTransactions).insert(LocalTransactionsCompanion.insert(
      id: 'tx-001',
      transactionType: 'income',
      category: 'milk_sales',
      amount: 15000.0,
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      description: const Value('Morning milk sale'),
    ));
  }
}
