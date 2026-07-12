import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class AnimalsRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  AnimalsRepository(this.apiClient, this.db);

  Future<List<LocalAnimal>> getAnimals() async {
    try {
      final response = await apiClient.dio.get('/animals');
      final list = response.data as List;
      await _updateLocalCache(list);
    } catch (_) {}
    return await db.select(db.localAnimals).get();
  }

  Future<void> addAnimal(Map<String, dynamic> animalData) async {
    final imagePath = animalData['image_path'] as String?;
    animalData.remove('image_path');

    final uuid = animalData['id'] ?? const Uuid().v4();
    animalData['id'] = uuid;
    
    // Always insert/update locally first
    await db.into(db.localAnimals).insertOnConflictUpdate(LocalAnimalsCompanion.insert(
      id: uuid,
      tagId: animalData['tag_id'],
      species: animalData['species'],
      sex: animalData['sex'],
      dateOfBirth: Value(animalData['date_of_birth'] != null ? DateTime.parse(animalData['date_of_birth']) : null),
      currentReproductiveStatus: animalData['current_reproductive_status'] ?? 'open',
      imagePath: Value(imagePath),
      breed: Value(animalData['breed']),
      weight: Value(animalData['weight'] != null ? double.tryParse(animalData['weight'].toString()) : null),
      color: Value(animalData['color']),
      uniqueMarks: Value(animalData['unique_marks']),
      pedigreeType: Value(animalData['pedigree_type']),
      purpose: Value(animalData['purpose']),
      vaccinationStatus: Value(animalData['vaccination_status']),
      dewormingStatus: Value(animalData['deworming_status']),
      status: Value(animalData['status'] ?? 'active'),
      sireId: Value(animalData['sire_id']),
      damId: Value(animalData['dam_id']),
    ));

    try {
      final response = await apiClient.dio.post('/animals', data: animalData);
      final animalId = response.data['id'];

      // If image exists, upload it
      if (imagePath != null && animalId != null) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(imagePath, filename: 'animal_photo.jpg'),
        });
        await apiClient.dio.post('/animals/$animalId/image', data: formData);
      }
    } catch (e) {
      // Add to SyncQueue if API call failed
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/animals',
        method: 'POST',
        body: jsonEncode(animalData),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _updateLocalCache(List<dynamic> animals) async {
    await db.transaction(() async {
      final syncItems = await (db.select(db.syncQueue)
            ..where((t) => t.endpoint.equals('/animals') & t.method.equals('POST')))
          .get();
      final pendingIds = syncItems.map((item) {
        try {
          final data = jsonDecode(item.body);
          return data['id'] as String?;
        } catch (_) {
          return null;
        }
      }).whereType<String>().toList();

      final serverIds = animals.map((a) => a['id'] as String).toList();
      final excludeIds = [...serverIds, ...pendingIds];

      if (excludeIds.isNotEmpty) {
        await (db.delete(db.localAnimals)..where((t) => t.id.isNotIn(excludeIds))).go();
      } else {
        await db.delete(db.localAnimals).go();
      }

      await db.batch((batch) {
        batch.insertAll(
          db.localAnimals,
          animals.map((animal) => LocalAnimalsCompanion.insert(
            id: animal['id'],
            tagId: animal['tag_id'],
            species: animal['species'],
            sex: animal['sex'],
            dateOfBirth: Value(animal['date_of_birth'] != null ? DateTime.parse(animal['date_of_birth']) : null),
            currentReproductiveStatus: animal['current_reproductive_status'] ?? 'open',
            breed: Value(animal['breed']),
            weight: Value(animal['weight'] != null ? double.tryParse(animal['weight'].toString()) : null),
            color: Value(animal['color']),
            uniqueMarks: Value(animal['unique_marks']),
            pedigreeType: Value(animal['pedigree_type']),
            purpose: Value(animal['purpose']),
            vaccinationStatus: Value(animal['vaccination_status']),
            dewormingStatus: Value(animal['deworming_status']),
            imagePath: Value(animal['image_path']),
            status: Value(animal['status'] ?? 'active'),
            sireId: Value(animal['sire_id']),
            damId: Value(animal['dam_id']),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> updateAnimal(String id, Map<String, dynamic> updateData) async {
    final imagePath = updateData['image_path'] as String?;
    updateData.remove('image_path');

    // Always update locally first
    final companion = LocalAnimalsCompanion(
      tagId: updateData['tag_id'] != null ? Value(updateData['tag_id']) : const Value.absent(),
      species: updateData['species'] != null ? Value(updateData['species']) : const Value.absent(),
      sex: updateData['sex'] != null ? Value(updateData['sex']) : const Value.absent(),
      breed: updateData.containsKey('breed') ? Value(updateData['breed']) : const Value.absent(),
      dateOfBirth: updateData['date_of_birth'] != null ? Value(DateTime.parse(updateData['date_of_birth'])) : const Value.absent(),
      currentReproductiveStatus: updateData['current_reproductive_status'] != null ? Value(updateData['current_reproductive_status']) : const Value.absent(),
      weight: updateData.containsKey('weight') ? Value(updateData['weight'] != null ? double.tryParse(updateData['weight'].toString()) : null) : const Value.absent(),
      color: updateData.containsKey('color') ? Value(updateData['color']) : const Value.absent(),
      uniqueMarks: updateData.containsKey('unique_marks') ? Value(updateData['unique_marks']) : const Value.absent(),
      pedigreeType: updateData['pedigree_type'] != null ? Value(updateData['pedigree_type']) : const Value.absent(),
      purpose: updateData['purpose'] != null ? Value(updateData['purpose']) : const Value.absent(),
      vaccinationStatus: updateData.containsKey('vaccination_status') ? Value(updateData['vaccination_status']) : const Value.absent(),
      dewormingStatus: updateData.containsKey('deworming_status') ? Value(updateData['deworming_status']) : const Value.absent(),
      imagePath: imagePath != null ? Value(imagePath) : const Value.absent(),
      status: updateData.containsKey('status') ? Value(updateData['status']) : const Value.absent(),
    );
    await (db.update(db.localAnimals)..where((t) => t.id.equals(id))).write(companion);

    try {
      await apiClient.dio.patch('/animals/$id', data: updateData);
      
      // If image exists, upload it
      if (imagePath != null) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(imagePath, filename: 'animal_photo.jpg'),
        });
        await apiClient.dio.post('/animals/$id/image', data: formData);
      }
    } catch (e) {
      // Add to SyncQueue if API call failed
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/animals/$id',
        method: 'PATCH',
        body: jsonEncode(updateData),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> deleteAnimal(String id) async {
    // Always delete locally first
    await (db.delete(db.localAnimals)..where((t) => t.id.equals(id))).go();

    try {
      await apiClient.dio.delete('/animals/$id');
    } catch (e) {
      // Add to SyncQueue if API call failed
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/animals/$id',
        method: 'DELETE',
        body: '',
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> logAnimalEvent(String animalId, String eventType, Map<String, dynamic> payload) async {
    final eventId = const Uuid().v4();
    final now = DateTime.now();
    
    // Save locally
    await db.into(db.localAnimalMedicalRecords).insert(LocalAnimalMedicalRecordsCompanion.insert(
      id: eventId,
      animalId: animalId,
      medicationId: 'report',
      administeredDose: 0.0,
      cost: 0.0,
      treatmentDate: now,
      diagnosedCondition: ((payload['diagnostics'] as Map?)?['observations'] as String?) ?? 'Medical Report',
      notes: Value(jsonEncode(payload)),
    ));

    // Handle Medical Report Follow-ups and Outcomes
    if (eventType == 'medical_report') {
      // Tasks are now scheduled directly by MedicalReportSheet to respect frequency


      final outcome = payload['outcome'] as Map<String, dynamic>?;
      if (outcome != null && outcome['is_deceased'] == true) {
        await (db.update(db.localAnimals)..where((t) => t.id.equals(animalId))).write(
          const LocalAnimalsCompanion(status: Value('deceased')),
        );
      }
    }

    // Sync to Server
    try {
      final data = {
        'animal_id': animalId,
        'event_type': eventType,
        'event_category': 'health',
        'event_timestamp': now.toIso8601String(),
        'payload': payload,
      };
      await apiClient.dio.post('/animals/$animalId/events', data: data);
      
      if (eventType == 'medical_report') {
        final outcome = payload['outcome'] as Map<String, dynamic>?;
        if (outcome != null && outcome['is_deceased'] == true) {
          await apiClient.dio.patch('/animals/$animalId', data: {'status': 'deceased'});
        }
      }
    } catch (e) {
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/animals/$animalId/events',
        method: 'POST',
        body: jsonEncode({
          'animal_id': animalId,
          'event_type': eventType,
          'event_category': 'health',
          'event_timestamp': now.toIso8601String(),
          'payload': payload,
        }),
        queuedAt: DateTime.now(),
      ));
      
      if (eventType == 'medical_report') {
        final outcome = payload['outcome'] as Map<String, dynamic>?;
        if (outcome != null && outcome['is_deceased'] == true) {
          await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
            endpoint: '/animals/$animalId',
            method: 'PATCH',
            body: jsonEncode({'status': 'deceased'}),
            queuedAt: DateTime.now(),
          ));
        }
      }
    }
  }
}
