import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:dio/dio.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';

class AnimalsRepository {
  final ApiClient apiClient;
  final LocalDatabase db;

  AnimalsRepository(this.apiClient, this.db);

  Future<List<dynamic>> getAnimals() async {
    try {
      final response = await apiClient.dio.get('/animals');
      final list = response.data as List;
      
      // Update local cache in background
      _updateLocalCache(list);
      
      return list;
    } catch (e) {
      return await db.select(db.localAnimals).get();
    }
  }

  Future<void> addAnimal(Map<String, dynamic> animalData) async {
    final imagePath = animalData['image_path'] as String?;
    animalData.remove('image_path');

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
      // Offline fallback
      final uuid = animalData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      
      await db.into(db.localAnimals).insert(LocalAnimalsCompanion.insert(
        id: uuid,
        tagId: animalData['tag_id'],
        species: animalData['species'],
        sex: animalData['sex'],
        dateOfBirth: DateTime.parse(animalData['date_of_birth']),
        currentReproductiveStatus: animalData['current_reproductive_status'] ?? 'open',
        imagePath: Value(imagePath),
        weight: Value(animalData['weight'] != null ? double.tryParse(animalData['weight'].toString()) : null),
        color: Value(animalData['color']),
        uniqueMarks: Value(animalData['unique_marks']),
        pedigreeType: Value(animalData['pedigree_type']),
        purpose: Value(animalData['purpose']),
        vaccinationStatus: Value(animalData['vaccination_status']),
      ));

      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/animals',
        method: 'POST',
        body: jsonEncode(animalData),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _updateLocalCache(List<dynamic> animals) async {
    await db.delete(db.localAnimals).go();
    for (var animal in animals) {
      await db.into(db.localAnimals).insertOnConflictUpdate(LocalAnimalsCompanion.insert(
        id: animal['id'],
        tagId: animal['tag_id'],
        species: animal['species'],
        sex: animal['sex'],
        dateOfBirth: DateTime.parse(animal['date_of_birth']),
        currentReproductiveStatus: animal['current_reproductive_status'] ?? 'open',
        breed: Value(animal['breed']),
        weight: Value(animal['weight'] != null ? double.tryParse(animal['weight'].toString()) : null),
        color: Value(animal['color']),
        uniqueMarks: Value(animal['unique_marks']),
        pedigreeType: Value(animal['pedigree_type']),
        purpose: Value(animal['purpose']),
        vaccinationStatus: Value(animal['vaccination_status']),
      ));
    }
  }

  Future<void> updateAnimal(String id, Map<String, dynamic> updateData) async {
    try {
      await apiClient.dio.patch('/animals/$id', data: updateData);
    } catch (e) {
      // Local Drift DB Update
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
      );
      await (db.update(db.localAnimals)..where((t) => t.id.equals(id))).write(companion);

      // Add to SyncQueue
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/animals/$id',
        method: 'PATCH',
        body: jsonEncode(updateData),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> deleteAnimal(String id) async {
    try {
      await apiClient.dio.delete('/animals/$id');
    } catch (e) {
      // Local Drift DB Delete
      await (db.delete(db.localAnimals)..where((t) => t.id.equals(id))).go();

      // Add to SyncQueue
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/animals/$id',
        method: 'DELETE',
        body: '',
        queuedAt: DateTime.now(),
      ));
    }
  }
}
