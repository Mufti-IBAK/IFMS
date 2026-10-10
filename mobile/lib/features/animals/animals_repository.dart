import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../core/database/local_db.dart';
import '../../core/network/api_client.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/animal_tag_formatter.dart';

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
    await migrateAnimalTagsAndGenerations(db);
    return await db.select(db.localAnimals).get();
  }

  Future<void> addAnimal(Map<String, dynamic> animalData) async {
    final imagePath = animalData['image_path'] as String?;
    animalData.remove('image_path');

    final uuid = animalData['id'] ?? const Uuid().v4();
    animalData['id'] = uuid;
    animalData['status'] = animalData['status'] ?? 'active';
    animalData['current_reproductive_status'] = animalData['current_reproductive_status'] ?? 'open';
    
    // 1. ALWAYS save to local database FIRST (Local-First Reliability)
    final localData = Map<String, dynamic>.from(animalData);
    if (imagePath != null) {
      localData['image_path'] = imagePath;
    }
    await _updateLocalCache([localData]);

    final acqCost = double.tryParse((animalData['acquisition_cost'] ?? 0).toString()) ?? 0.0;
    if (acqCost > 0) {
      final txUuid = const Uuid().v4();
      await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
        id: txUuid,
        transactionType: 'expense',
        category: 'animal_purchase',
        amount: acqCost,
        currency: const Value('NGN'),
        relatedEntityType: const Value('animal'),
        relatedEntityId: Value(uuid),
        description: Value('Acquisition cost for ${animalData['tag_id']} (${animalData['species']})'),
        transactionDate: DateTime.now(),
        isReconciled: const Value(false),
      ));
    }

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'CREATE',
      moduleName: 'animals',
      entityId: uuid,
      entityName: '${animalData['species']} (${animalData['tag_id']})',
      description: 'Registered animal tag #${animalData['tag_id']}',
      details: animalData,
    );

    // 2. Safely attempt remote API sync
    try {
      final apiData = Map<String, dynamic>.from(animalData);
      final response = await apiClient.dio.post('/animals', data: apiData);
      final animalId = response.data?['id'] ?? uuid;

      if (imagePath != null && animalId != null) {
        try {
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(imagePath, filename: 'animal_photo.jpg'),
          });
          await apiClient.dio.post('/animals/$animalId/image', data: formData);
        } catch (_) {}
      }
    } catch (e) {
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/animals',
        method: 'POST',
        body: jsonEncode(animalData),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> _updateLocalCache(List<dynamic> animals) async {
    // Check pending sync items for animals so we do not overwrite un-synced local edits
    final pendingSync = await db.select(db.syncQueue).get();
    final pendingAnimalIds = <String>{};
    for (final s in pendingSync) {
      if (s.endpoint.contains('/animals')) {
        try {
          final body = jsonDecode(s.body);
          if (body is Map && body['id'] != null) {
            pendingAnimalIds.add(body['id'].toString());
          }
        } catch (_) {}
      }
    }

    await db.transaction(() async {
      await db.batch((batch) {
        batch.insertAll(
          db.localAnimals,
          animals
              .where((animal) => !pendingAnimalIds.contains(animal['id']?.toString()))
              .map((animal) {
            final dob = animal['date_of_birth'] != null ? DateTime.tryParse(animal['date_of_birth'].toString()) : null;
            String gen = (animal['generation'] ?? '').toString().trim();
            if (gen.isEmpty) {
              if (dob != null && DateTime.now().difference(dob).inDays < 183) {
                gen = 'F2';
              } else {
                gen = 'F1';
              }
            }
            final rawTag = (animal['tag_id'] ?? '').toString();
            final breedCode = AnimalTagFormatter.getBreedCode(
              breed: (animal['breed'] ?? '').toString(),
              pedigreeType: animal['pedigree_type']?.toString(),
              species: animal['species']?.toString(),
            );
            final formattedTag = AnimalTagFormatter.formatTagId(
              rawTag: rawTag,
              breedCode: breedCode,
              generation: gen,
            );

            return LocalAnimalsCompanion.insert(
              id: animal['id'],
              tagId: formattedTag,
              species: animal['species'] ?? 'Livestock',
              sex: animal['sex'] ?? 'unknown',
              dateOfBirth: Value(dob),
              generation: Value(gen),
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
            );
          }).toList(),
          mode: InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<void> updateAnimal(String id, Map<String, dynamic> updateData) async {
    final imagePath = updateData['image_path'] as String?;
    updateData.remove('image_path');

    // 1. ALWAYS update local database FIRST
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
        pedigreeType: updateData.containsKey('pedigree_type') ? Value(updateData['pedigree_type']) : const Value.absent(),
        generation: updateData.containsKey('generation') ? Value(updateData['generation']) : const Value.absent(),
        currentReproductiveStatus: updateData.containsKey('current_reproductive_status') ? Value(updateData['current_reproductive_status']) : const Value.absent(),
        dateOfBirth: updateData.containsKey('date_of_birth') ? Value(updateData['date_of_birth'] != null ? DateTime.tryParse(updateData['date_of_birth']) : null) : const Value.absent(),
        imagePath: imagePath != null ? Value(imagePath) : const Value.absent(),
      ),
    );

    final existingAnimal = await (db.select(db.localAnimals)..where((t) => t.id.equals(id))).getSingleOrNull();
    final tagLabel = updateData['tag_id'] ?? existingAnimal?.tagId ?? id;
    final speciesLabel = updateData['species'] ?? existingAnimal?.species ?? 'Animal';

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'UPDATE',
      moduleName: 'animals',
      entityId: id,
      entityName: '$speciesLabel (#$tagLabel)',
      description: 'Updated details for $speciesLabel (#$tagLabel)',
      details: updateData,
    );

    // 2. Safely attempt remote API sync
    try {
      await apiClient.dio.patch('/animals?id=eq.$id', data: updateData);
      if (imagePath != null) {
        try {
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(imagePath, filename: 'animal_photo.jpg'),
          });
          await apiClient.dio.post('/animals/$id/image', data: formData);
        } catch (_) {}
      }
    } catch (e) {
      await db.into(db.syncQueue).insert(SyncQueueCompanion.insert(
        endpoint: '/animals/$id',
        method: 'PATCH',
        body: jsonEncode(updateData),
        queuedAt: DateTime.now(),
      ));
    }
  }

  Future<void> deleteAnimal(String id) async {
    final existingAnimal = await (db.select(db.localAnimals)..where((t) => t.id.equals(id))).getSingleOrNull();
    final tagLabel = existingAnimal?.tagId ?? id;
    final speciesLabel = existingAnimal?.species ?? 'Animal';

    try {
      await apiClient.dio.delete('/animals/$id');
      await (db.delete(db.localAnimals)..where((t) => t.id.equals(id))).go();

      sl<AuditRepository>().logAction(
        userName: 'Farm Manager',
        actionType: 'DELETE',
        moduleName: 'animals',
        entityId: id,
        entityName: '$speciesLabel (#$tagLabel)',
        description: 'Deleted record for $speciesLabel (#$tagLabel)',
      );
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
      await apiClient.dio.post('/animal_events', data: data);
      
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

  Future<void> recordAnimalSale({
    required String animalId,
    required double salePrice,
    String? buyer,
    DateTime? saleDate,
  }) async {
    final animal = await (db.select(db.localAnimals)..where((t) => t.id.equals(animalId))).getSingleOrNull();
    final tagId = animal?.tagId ?? animalId;
    final species = animal?.species ?? 'Livestock';
    final date = saleDate ?? DateTime.now();

    // 1. Update animal status to sold
    await (db.update(db.localAnimals)..where((t) => t.id.equals(animalId))).write(
      const LocalAnimalsCompanion(
        status: Value('sold'),
      ),
    );

    // 2. Insert income transaction into localTransactions
    final txUuid = const Uuid().v4();
    await db.into(db.localTransactions).insertOnConflictUpdate(LocalTransactionsCompanion.insert(
      id: txUuid,
      transactionType: 'income',
      category: 'animal_sales',
      amount: salePrice,
      currency: const Value('NGN'),
      relatedEntityType: const Value('animal'),
      relatedEntityId: Value(animalId),
      description: Value('Animal Sale: $species (#$tagId)${buyer != null && buyer.isNotEmpty ? ' to $buyer' : ''}'),
      transactionDate: date,
      isReconciled: const Value(false),
    ));

    // 3. Online sync to backend
    try {
      await apiClient.dio.patch('/animals?id=eq.$animalId', data: {'status': 'sold'});
      await apiClient.dio.post('/finance/transaction', data: {
        'id': txUuid,
        'transaction_type': 'income',
        'category': 'animal_sales',
        'amount': salePrice,
        'currency': 'NGN',
        'related_entity_type': 'animal',
        'related_entity_id': animalId,
        'description': 'Animal Sale: $species (#$tagId)${buyer != null && buyer.isNotEmpty ? ' to $buyer' : ''}',
        'transaction_date': date.toIso8601String().split('T')[0],
      });
    } catch (_) {}

    sl<AuditRepository>().logAction(
      userName: 'Farm Manager',
      actionType: 'UPDATE',
      moduleName: 'animals',
      entityId: animalId,
      entityName: '$species (#$tagId)',
      description: 'Recorded animal sale of ₦$salePrice for tag #$tagId',
    );
  }
}
