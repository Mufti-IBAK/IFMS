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
    animalData['status'] = animalData['status'] ?? 'active';
    animalData['current_reproductive_status'] = animalData['current_reproductive_status'] ?? 'open';
    
    // Online-First: Make API call first
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

      await _updateLocalCache([response.data]);
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        final localData = Map<String, dynamic>.from(animalData);
        if (imagePath != null) {
          localData['image_path'] = imagePath;
        }
        await _updateLocalCache([localData]);
        
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/animals',
          method: 'POST',
          body: jsonEncode(animalData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to add animal: ${e.message}');
      }
      throw Exception('Failed to add animal: $e');
    }
  }

  Future<void> _updateLocalCache(List<dynamic> animals) async {
    await db.transaction(() async {
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
            acquisitionCost: Value(animal['acquisition_cost'] != null ? double.tryParse(animal['acquisition_cost'].toString()) ?? 0.0 : 0.0),
            salvageValue: Value(animal['salvage_value'] != null ? double.tryParse(animal['salvage_value'].toString()) ?? 0.0 : 0.0),
          )).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> updateAnimal(String id, Map<String, dynamic> updateData) async {
    final imagePath = updateData['image_path'] as String?;
    updateData.remove('image_path');

    try {
      await apiClient.dio.patch('/animals?id=eq.$id', data: updateData);
      
      // If image exists, upload it
      if (imagePath != null) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(imagePath, filename: 'animal_photo.jpg'),
        });
        await apiClient.dio.post('/animals/$id/image', data: formData);
      }
      
      final freshResponse = await apiClient.dio.get('/animals?id=eq.$id');
      if (freshResponse.data is List && freshResponse.data.isNotEmpty) {
        await _updateLocalCache([freshResponse.data[0]]);
      }
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.update(db.localAnimals)..where((t) => t.id.equals(id))).write(
          LocalAnimalsCompanion(
            tagId: updateData.containsKey('tag_id') ? Value(updateData['tag_id']) : const Value.absent(),
            species: updateData.containsKey('species') ? Value(updateData['species']) : const Value.absent(),
            breed: updateData.containsKey('breed') ? Value(updateData['breed']) : const Value.absent(),
            sex: updateData.containsKey('sex') ? Value(updateData['sex']) : const Value.absent(),
            status: updateData.containsKey('status') ? Value(updateData['status']) : const Value.absent(),
            weight: updateData.containsKey('weight') ? Value(double.tryParse(updateData['weight'].toString())) : const Value.absent(),
            color: updateData.containsKey('color') ? Value(updateData['color']) : const Value.absent(),
            uniqueMarks: updateData.containsKey('unique_marks') ? Value(updateData['unique_marks']) : const Value.absent(),
            purpose: updateData.containsKey('purpose') ? Value(updateData['purpose']) : const Value.absent(),
            imagePath: imagePath != null ? Value(imagePath) : const Value.absent(),
          )
        );

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/animals/$id',
          method: 'PATCH',
          body: jsonEncode(updateData),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to update animal: ${e.message}');
      }
      throw Exception('Failed to update animal: $e');
    }
  }

  Future<void> deleteAnimal(String id) async {
    try {
      await apiClient.dio.delete('/animals/$id');
      await (db.delete(db.localAnimals)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
        await (db.delete(db.localAnimals)..where((t) => t.id.equals(id))).go();
        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/animals/$id',
          method: 'DELETE',
          body: jsonEncode({}),
          queuedAt: DateTime.now(),
        ));
        throw Exception('Deleted locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to delete animal: ${e.message}');
      }
      throw Exception('Failed to delete animal: $e');
    }
  }

  Future<void> logAnimalEvent(String animalId, String eventType, Map<String, dynamic> payload) async {
    final eventId = const Uuid().v4();
    final now = DateTime.now();

    final data = {
      'animal_id': animalId,
      'event_type': eventType,
      'event_category': 'health',
      'event_timestamp': now.toIso8601String(),
      'payload': payload,
    };

    try {
      // Sync to Server first
      await apiClient.dio.post('/animal_events', data: data); // Path rewritten by ApiClient interceptor for this anyway, but keeping standard
      
      if (eventType == 'medical_report') {
        final outcome = payload['outcome'] as Map<String, dynamic>?;
        if (outcome != null && outcome['is_deceased'] == true) {
          await apiClient.dio.patch('/animals?id=eq.$animalId', data: {'status': 'deceased'});
        }
      }

      // Save locally after success
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

      if (eventType == 'medical_report') {
        final outcome = payload['outcome'] as Map<String, dynamic>?;
        if (outcome != null && outcome['is_deceased'] == true) {
          await (db.update(db.localAnimals)..where((t) => t.id.equals(animalId))).write(
            const LocalAnimalsCompanion(status: Value('deceased')),
          );
        }
      }
    } catch (e) {
      if (e is DioException && ApiClient.isNetworkError(e)) {
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

        if (eventType == 'medical_report') {
          final outcome = payload['outcome'] as Map<String, dynamic>?;
          if (outcome != null && outcome['is_deceased'] == true) {
            await (db.update(db.localAnimals)..where((t) => t.id.equals(animalId))).write(
              const LocalAnimalsCompanion(status: Value('deceased')),
            );
          }
        }

        await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
          endpoint: '/animal_events',
          method: 'POST',
          body: jsonEncode(data),
          queuedAt: DateTime.now(),
        ));

        throw Exception('Saved locally. Will sync when connection is restored.');
      }
      if (e is DioException) {
        throw Exception(e.response?.data?['message'] ?? e.response?.data?['details'] ?? 'Failed to log event: ${e.message}');
      }
      throw Exception('Failed to log event: $e');
    }
  }
}
