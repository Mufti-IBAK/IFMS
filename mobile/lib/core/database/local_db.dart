import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sq;


part 'local_db.g.dart';

class LocalAnimals extends Table {
  TextColumn get id => text()();
  TextColumn get tagId => text().withLength(min: 1, max: 50)();
  TextColumn get species => text()();
  TextColumn get breed => text().nullable()();
  TextColumn get sex => text()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get locationId => text().nullable()();
  TextColumn get currentReproductiveStatus => text()();
  RealColumn get acquisitionCost => real().withDefault(const Constant(0.0))();
  RealColumn get salvageValue => real().withDefault(const Constant(0.0))();
  TextColumn get imagePath => text().nullable()();
  
  // New comprehensive fields
  RealColumn get weight => real().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get uniqueMarks => text().nullable()();
  TextColumn get pedigreeType => text().nullable()();
  TextColumn get purpose => text().nullable()();
  TextColumn get vaccinationStatus => text().nullable()();
  TextColumn get dewormingStatus => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  
  // Pedigree
  TextColumn get sireId => text().nullable()(); // Father
  TextColumn get damId => text().nullable()();  // Mother
  
  @override
  Set<Column> get primaryKey => {id};
}

class LocalMilkRecords extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  DateTimeColumn get recordDate => dateTime()();
  TextColumn get milkingSession => text()();
  RealColumn get quantityLiters => real()();
  RealColumn get fatPercentage => real().nullable()();
  RealColumn get proteinPercentage => real().nullable()();
  BoolColumn get isWithdrawn => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class LocalTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get transactionType => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  TextColumn get currency => text().withDefault(const Constant('NGN'))();
  TextColumn get relatedEntityType => text().nullable()();
  TextColumn get relatedEntityId => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  BoolColumn get isReconciled => boolean().withDefault(const Constant(false))();
  TextColumn get reversalOf => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalTasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get priority => text()();
  TextColumn get status => text()();
  TextColumn get assignedTo => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get category => text().nullable()(); // 'pharmacy', 'medical', 'feed', 'other'
  BoolColumn get isActionable => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalPoultryBatches extends Table {
  TextColumn get id => text()();
  TextColumn get batchNumber => text()();
  TextColumn get houseName => text()();
  IntColumn get initialCount => integer()();
  IntColumn get currentCount => integer()();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get status => text()(); // "active", "closed"
  
  @override
  Set<Column> get primaryKey => {id};
}

class LocalPoultryLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get batchId => text()();
  DateTimeColumn get logDate => dateTime()();
  IntColumn get feedBags => integer().withDefault(const Constant(0))();
  IntColumn get mortality => integer().withDefault(const Constant(0))();
  RealColumn get averageWeight => real().nullable()();
}

class LocalAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get severity => text()(); // critical, warning, insight
  TextColumn get message => text()();
  TextColumn get location => text().nullable()();
  TextColumn get impact => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isResolved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get endpoint => text()();
  TextColumn get method => text()(); // "POST", "PATCH", "DELETE"
  TextColumn get body => text()(); // JSON string
  DateTimeColumn get queuedAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

class LocalFeedItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // "feed", "drug", "vaccine", "supplement", "supply"
  TextColumn get unit => text()();
  RealColumn get currentStock => real()();
  RealColumn get reorderThreshold => real()();
  RealColumn get costPerUnit => real()();
  RealColumn get weightPerUnit => real().withDefault(const Constant(1.0))();
  RealColumn get costPerKg => real().withDefault(const Constant(0.0))();
  TextColumn get supplier => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalInventoryLogs extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get changeType => text()(); // "purchase", "consumption", "adjustment", "waste", "return"
  RealColumn get quantityChange => real()();
  RealColumn get balanceAfter => real()();
  TextColumn get relatedEntityType => text().nullable()();
  TextColumn get relatedEntityId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get logDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalHatcheryBatches extends Table {
  TextColumn get id => text()();
  TextColumn get eggSource => text()();
  IntColumn get eggCount => integer()();
  TextColumn get breed => text().nullable()();
  DateTimeColumn get setDate => dateTime()();
  DateTimeColumn get expectedHatchDate => dateTime()();
  IntColumn get fertileEggs => integer().nullable()();
  IntColumn get hatchedChicks => integer().nullable()();
  IntColumn get failedEggs => integer().nullable()();
  RealColumn get initialEggCost => real().withDefault(const Constant(0.0))();
  TextColumn get status => text().withDefault(const Constant('incubating'))(); // "incubating", "completed"

  @override
  Set<Column> get primaryKey => {id};
}

class LocalHatcheryEvents extends Table {
  TextColumn get id => text()();
  TextColumn get batchId => text()();
  TextColumn get eventType => text()(); // "candling", "temperature_check", "humidity_check", "turning", "hatch_start", "hatch_complete"
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get valueJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalFeedFormulas extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get batchSize => real()(); // e.g. 1000 for per tonne, 100 for per 100kg
  TextColumn get batchUnit => text().withDefault(const Constant('per_tonne'))(); // "per_tonne", "per_100kg", "custom"
  TextColumn get notes => text().nullable()();
  RealColumn get currentStock => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalFormulaIngredients extends Table {
  TextColumn get id => text()();
  TextColumn get formulaId => text()();
  TextColumn get feedItemId => text()();
  RealColumn get percentage => real()(); // e.g. 55.0 means 55%
  RealColumn get quantityKg => real()(); // auto-calculated: batchSize * percentage / 100

  @override
  Set<Column> get primaryKey => {id};
}

class LocalFeedConsumptionLogs extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get feedItemId => text()();
  RealColumn get quantityKg => real()();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalFeedingPlans extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get formulaId => text()();
  RealColumn get quantityKg => real()();
  BoolColumn get isAutoFeed => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMedications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // "antibiotic", "vaccine", "dewormer", "supplement", "other"
  TextColumn get unit => text()(); // "ml", "vials", "doses", "packs"
  RealColumn get currentStock => real().withDefault(const Constant(0.0))();
  RealColumn get reorderThreshold => real().withDefault(const Constant(5.0))();
  RealColumn get costPerUnit => real().withDefault(const Constant(0.0))();
  TextColumn get supplier => text().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get batchNumber => text().nullable()();
  IntColumn get milkWithdrawalDays => integer().withDefault(const Constant(0))();
  IntColumn get meatWithdrawalDays => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMedicationLogs extends Table {
  TextColumn get id => text()();
  TextColumn get medicationId => text()();
  TextColumn get changeType => text()(); // "purchase", "discard", "treatment", "adjustment"
  RealColumn get quantityChange => real()();
  RealColumn get balanceAfter => real()();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalAnimalMedicalRecords extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get medicationId => text()();
  RealColumn get administeredDose => real()();
  RealColumn get cost => real()();
  DateTimeColumn get treatmentDate => dateTime()();
  TextColumn get diagnosedCondition => text()();
  TextColumn get administeredBy => text().nullable()();
  DateTimeColumn get withdrawalEndDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalStaff extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get phone => text().nullable()();
  RealColumn get baseSalary => real().withDefault(const Constant(0.0))();
  RealColumn get performanceRating => real().withDefault(const Constant(5.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get profilePic => text().nullable()();
  TextColumn get gender => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get emergencyContact => text().nullable()();
  TextColumn get employmentType => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalStaffQueries extends Table {
  TextColumn get id => text()();
  TextColumn get staffId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  RealColumn get deductionAmount => real().withDefault(const Constant(0.0))();
  BoolColumn get isResolved => boolean().withDefault(const Constant(false))();
  TextColumn get resolutionNotes => text().nullable()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get issueDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalFarmEvents extends Table {
  TextColumn get id => text()();
  TextColumn get eventType => text()(); // "mortality", "birth", "disease_outbreak", "general"
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get involvedAnimals => text().nullable()(); // Comma-separated or JSON
  TextColumn get description => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalBreedingEvents extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get eventType => text()(); // "heat", "natural_mating", "ai", "pregnancy_check", "abortion", "calving"
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get sireId => text().nullable()();
  TextColumn get semenBatchId => text().nullable()();
  TextColumn get technician => text().nullable()();
  TextColumn get result => text().nullable()(); // "pregnant", "open", "suspicious"
  TextColumn get notes => text().nullable()();
  TextColumn get payload => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  LocalAnimals,
  LocalMilkRecords,
  LocalTransactions,
  LocalTasks,
  LocalPoultryBatches,
  LocalPoultryLogs,
  LocalAlerts,
  SyncQueue,
  LocalFeedItems,
  LocalInventoryLogs,
  LocalHatcheryBatches,
  LocalHatcheryEvents,
  LocalFeedFormulas,
  LocalFormulaIngredients,
  LocalFeedConsumptionLogs,
  LocalFeedingPlans,
  LocalMedications,
  LocalMedicationLogs,
  LocalAnimalMedicalRecords,
  LocalStaff,
  LocalStaffQueries,
  LocalFarmEvents,
  LocalBreedingEvents
])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 18;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(syncQueue, syncQueue.attempts);
        await m.addColumn(syncQueue, syncQueue.lastError);
      }
      if (from < 3) {
        await m.createTable(localPoultryBatches);
        await m.createTable(localPoultryLogs);
      }
      if (from < 4) {
        await m.createTable(localAlerts);
      }
      if (from < 5) {
        await m.addColumn(localAnimals, localAnimals.imagePath);
      }
      if (from < 6) {
        await m.addColumn(localAnimals, localAnimals.weight);
        await m.addColumn(localAnimals, localAnimals.color);
        await m.addColumn(localAnimals, localAnimals.uniqueMarks);
        await m.addColumn(localAnimals, localAnimals.pedigreeType);
        await m.addColumn(localAnimals, localAnimals.purpose);
        await m.addColumn(localAnimals, localAnimals.vaccinationStatus);
      }
      if (from < 7) {
        await m.addColumn(localAnimals, localAnimals.status);
      }
      if (from < 8) {
        await m.addColumn(localAnimals, localAnimals.dewormingStatus);
      }
      if (from < 9) {
        await m.createTable(localFeedItems);
        await m.createTable(localInventoryLogs);
        await m.createTable(localHatcheryBatches);
        await m.createTable(localHatcheryEvents);
      }
      if (from < 10) {
        await m.createTable(localFeedFormulas);
        await m.createTable(localFormulaIngredients);
        await m.createTable(localFeedConsumptionLogs);
      }
      if (from < 11) {
        await m.addColumn(localFeedItems, localFeedItems.weightPerUnit);
        await m.addColumn(localFeedItems, localFeedItems.costPerKg);
      }
      if (from < 12) {
        await m.addColumn(localFeedFormulas, localFeedFormulas.currentStock);
        await m.createTable(localFeedingPlans);
      }
      if (from < 13) {
        await m.createTable(localMedications);
        await m.createTable(localMedicationLogs);
        await m.createTable(localAnimalMedicalRecords);
      }
      if (from < 14) {
        await m.createTable(localStaff);
        await m.createTable(localStaffQueries);
      }
      if (from < 15) {
        await m.addColumn(localStaff, localStaff.profilePic);
        await m.addColumn(localStaff, localStaff.gender);
        await m.addColumn(localStaff, localStaff.dateOfBirth);
        await m.addColumn(localStaff, localStaff.address);
        await m.addColumn(localStaff, localStaff.emergencyContact);
        await m.addColumn(localStaff, localStaff.employmentType);
      }
      if (from < 16) {
        await m.addColumn(localTasks, localTasks.category);
        await m.addColumn(localTasks, localTasks.isActionable);
      }
      if (from < 17) {
        await m.createTable(localFarmEvents);
      }
      if (from < 18) {
        await m.createTable(localBreedingEvents);
        await m.addColumn(localAnimals, localAnimals.sireId);
        await m.addColumn(localAnimals, localAnimals.damId);
      }
    },
    beforeOpen: (details) async {
      // Create high-performance indexing for SQLite queries
      await customStatement('CREATE INDEX IF NOT EXISTS idx_animals_tag_id ON local_animals (tag_id);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_milk_records_animal_id ON local_milk_records (animal_id, record_date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_date ON local_transactions (transaction_date);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_tasks_status ON local_tasks (status);');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_alerts_resolved ON local_alerts (is_resolved);');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    const dbName = 'ifms_local.db';
    const folderName = 'NamanzoIFMS';

    // ── 1. Try public Documents folder (/sdcard/Documents/NamanzoIFMS/)
    //    This folder is NEVER wiped by Android on uninstall.
    try {
      // Check if we actually have external storage management permission
      final hasPermission = await _hasExternalStoragePermission();
      if (!hasPermission) {
        throw Exception('MANAGE_EXTERNAL_STORAGE permission not granted');
      }

      // getExternalStorageDirectory returns the app-specific external path
      // but we walk up to the root of shared storage and go into Documents.
      final externalRoot = await getExternalStorageDirectory();
      if (externalRoot != null) {
        // Walk up from: /storage/emulated/0/Android/data/<pkg>/files
        // to reach:     /storage/emulated/0/
        final parts = externalRoot.path.split('/');
        final androidIndex = parts.indexOf('Android');
        if (androidIndex > 0) {
          final publicRoot = parts.sublist(0, androidIndex).join('/');
          final publicDir = Directory('$publicRoot/Documents/$folderName');
          if (!await publicDir.exists()) await publicDir.create(recursive: true);

          final publicFile = File(p.join(publicDir.path, dbName));

          // ── Migrate: if old internal DB exists and new one doesn't, copy it over
          final internalDir = await getApplicationDocumentsDirectory();
          final internalFile = File(p.join(internalDir.path, dbName));
          if (!await publicFile.exists() && await internalFile.exists()) {
            await internalFile.copy(publicFile.path);
          }

          // Test write access using native sqlite3 to ensure we don't throw unable to open database file (code 14)
          final testDbPath = p.join(publicDir.path, '.test_db');
          final testDb = sq.sqlite3.open(testDbPath);
          testDb.dispose();
          final testFile = File(testDbPath);
          if (await testFile.exists()) await testFile.delete();

          debugPrint('[DB] Using public storage: ${publicFile.path}');
          return NativeDatabase(publicFile);
        }
      }
    } catch (e) {
      debugPrint('[DB] Public storage unavailable, falling back to internal: $e');
    }

    // ── 2. Fallback: internal app storage (wiped on uninstall but always available)
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, dbName));
    debugPrint('[DB] Using internal storage: ${file.path}');
    return NativeDatabase(file);
  });
}

/// Checks whether the app has permission to write to public external storage.
/// Uses a platform channel to query the native Android side.
Future<bool> _hasExternalStoragePermission() async {
  if (!Platform.isAndroid) return false;
  try {
    const platform = MethodChannel('com.namanzo.ifms/permissions');
    final result = await platform.invokeMethod<bool>('isExternalStorageManager');
    return result ?? false;
  } catch (e) {
    debugPrint('[DB] Could not check storage permission: $e');
    return false;
  }
}

