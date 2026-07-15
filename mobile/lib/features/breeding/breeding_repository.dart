import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import 'package:uuid/uuid.dart';

class BreedingRepository {
  final ApiClient apiClient;
  final LocalDatabase db;
  final Uuid uuid = const Uuid();

  BreedingRepository(this.apiClient, this.db);

  Future<List<LocalBreedingEvent>> getBreedingEventsForAnimal(String animalId) async {
    return (db.select(db.localBreedingEvents)
          ..where((t) => t.animalId.equals(animalId))
          ..orderBy([(t) => OrderingTerm(expression: t.eventDate, mode: OrderingMode.desc)]))
        .get();
  }

  Future<void> logBreedingEvent(String animalId, String eventType, DateTime eventDate, {String? sireId, String? semenBatchId, String? technician, String? result, String? notes, String? payload}) async {
    final eventId = uuid.v4();

    // Try API Sync First
    final apiPayload = {
      'id': eventId,
      'animal_id': animalId,
      'event_type': eventType,
      'event_date': eventDate.toIso8601String(),
      'sire_id': sireId,
      'semen_batch_id': semenBatchId,
      'technician': technician,
      'result': result,
      'notes': notes,
      'payload': payload,
    };

    try {
      await apiClient.dio.post('/breeding', data: apiPayload);

      // On success, save locally
      await db.into(db.localBreedingEvents).insert(LocalBreedingEventsCompanion.insert(
        id: eventId,
        animalId: animalId,
        eventType: eventType,
        eventDate: eventDate,
        sireId: Value(sireId),
        semenBatchId: Value(semenBatchId),
        technician: Value(technician),
        result: Value(result),
        notes: Value(notes),
        payload: Value(payload),
      ));

      // Automated Workflow Logic
      if (eventType == 'ai' || eventType == 'natural_mating') {
        // Schedule pregnancy check 28 days later
        await _schedulePregnancyCheckTask(animalId, eventDate.add(const Duration(days: 28)));
      } else if (eventType == 'pregnancy_check' && result == 'pregnant') {
        // Calculate due date and prepare alerts
        await _handleConfirmedPregnancy(animalId, eventDate);
      } else if (eventType == 'calving' || eventType == 'abortion') {
        // Reset status to open/active
        await (db.update(db.localAnimals)..where((t) => t.id.equals(animalId))).write(
          const LocalAnimalsCompanion(currentReproductiveStatus: Value('active')),
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to log breeding event: ${e.message}');
      }
      throw Exception('Failed to log breeding event: $e');
    }
  }

  Future<void> _schedulePregnancyCheckTask(String animalId, DateTime dueDate) async {
    // Fetch animal tag
    final animal = await (db.select(db.localAnimals)..where((t) => t.id.equals(animalId))).getSingleOrNull();
    final tag = animal?.tagId ?? 'Unknown';

    await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
      id: uuid.v4(),
      title: 'Pregnancy Check: $tag',
      description: Value('Perform ultrasound or palpation for $tag 28 days post-mating.'),
      priority: 'high',
      status: 'pending',
      category: Value('medical_record'),
      dueDate: Value(dueDate),
      isActionable: const Value(true),
    ));
  }

  Future<void> _handleConfirmedPregnancy(String animalId, DateTime checkDate) async {
    final animal = await (db.select(db.localAnimals)..where((t) => t.id.equals(animalId))).getSingleOrNull();
    if (animal == null) return;

    // Update status
    await (db.update(db.localAnimals)..where((t) => t.id.equals(animalId))).write(
      const LocalAnimalsCompanion(currentReproductiveStatus: Value('pregnant')),
    );

    // Calculate due date based on species.
    // Approximate: Bovine = 283 days, Caprine/Ovine = 150 days.
    // We assume checkDate was 28 days post-mating. True mating date ~ checkDate - 28 days.
    // So Delivery is roughly mating date + gestation.
    final matingDate = checkDate.subtract(const Duration(days: 28));
    int gestationDays = animal.species.toLowerCase() == 'bovine' ? 283 : 150;
    final expectedDelivery = matingDate.add(Duration(days: gestationDays));

    // Schedule Dry Off task (for dairy cows) 60 days before calving
    if (animal.species.toLowerCase() == 'bovine') {
      final dryOffDate = expectedDelivery.subtract(const Duration(days: 60));
      if (dryOffDate.isAfter(DateTime.now())) {
        await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
          id: uuid.v4(),
          title: 'Dry Off Cow: ${animal.tagId}',
          description: Value('Stop milking to prepare for calving.'),
          priority: 'high',
          status: 'pending',
          category: Value('dairy'),
          dueDate: Value(dryOffDate),
          isActionable: const Value(true),
        ));
      }
    }

    // Schedule Maternity Prep 14 days before
    final prepDate = expectedDelivery.subtract(const Duration(days: 14));
    await db.into(db.localTasks).insert(LocalTasksCompanion.insert(
      id: uuid.v4(),
      title: 'Prepare Maternity for ${animal.tagId}',
      description: Value('Expected delivery on ${expectedDelivery.toLocal().toString().split(' ')[0]}.'),
      priority: 'high',
      status: 'pending',
      category: Value('medical_record'),
      dueDate: Value(prepDate),
      isActionable: const Value(true),
    ));
  }
}
