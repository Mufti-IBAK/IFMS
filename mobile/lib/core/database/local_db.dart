import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_db.g.dart';

class LocalAnimals extends Table {
  TextColumn get id => text()();
  TextColumn get tagId => text().withLength(min: 1, max: 50)();
  TextColumn get species => text()();
  TextColumn get breed => text().nullable()();
  TextColumn get sex => text()();
  DateTimeColumn get dateOfBirth => dateTime()();
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
  
  @override
  Set<Column> get primaryKey => {id};
}

class LocalMilkRecords extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  DateTimeColumn get recordDate => dateTime()();
  TextColumn get milkingSession => text()();
  RealColumn get quantityLiters => real()();
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

@DriftDatabase(tables: [LocalAnimals, LocalMilkRecords, LocalTransactions, LocalTasks, LocalPoultryBatches, LocalPoultryLogs, LocalAlerts, SyncQueue])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

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
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ifms_local.db'));
    return NativeDatabase(file);
  });
}
