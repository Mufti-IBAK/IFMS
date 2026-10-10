import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../database/local_db.dart';

class AnimalTagFormatter {
  /// Extract 2-letter uppercase breed code.
  /// If pure breed: 1st two letters of breed name (or 1st letter of word 1 + 1st letter of word 2).
  /// If cross / mixed breed (e.g. Kalahari x Sahel): 1st letter of parent 1 + 1st letter of parent 2.
  static String getBreedCode({
    required String breed,
    String? pedigreeType,
    String? species,
  }) {
    final cleanBreed = breed.trim();
    final ped = (pedigreeType ?? '').toLowerCase();

    final isCrossOrMixed = ped.contains('cross') || 
        ped.contains('mixed') || 
        cleanBreed.contains(' x ') || 
        cleanBreed.contains(' X ') || 
        cleanBreed.contains('/') || 
        cleanBreed.toLowerCase().contains('cross');

    if (isCrossOrMixed) {
      // Split by ' x ', ' X ', '/', or ','
      final parts = cleanBreed.split(RegExp(r'\s+[xX/]\s+|\s*[/,]\s*'));
      if (parts.length >= 2) {
        final p1 = parts[0].trim().replaceAll(RegExp(r'[^a-zA-Z]'), '');
        final p2 = parts[1].trim().replaceAll(RegExp(r'[^a-zA-Z]'), '');
        if (p1.isNotEmpty && p2.isNotEmpty) {
          return '${p1[0]}${p2[0]}'.toUpperCase();
        }
      }
    }

    if (cleanBreed.toLowerCase() == 'purebreed' || cleanBreed.toLowerCase() == 'pure breed') {
      final spec = (species ?? '').trim().replaceAll(RegExp(r'[^a-zA-Z]'), '');
      if (spec.length >= 2) {
        return spec.substring(0, 2).toUpperCase();
      }
    }

    // Pure breed or single breed name
    final lettersOnly = cleanBreed.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
    final words = lettersOnly
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && w.toLowerCase() != 'and' && w.toLowerCase() != 'or' && w.toLowerCase() != 'the')
        .toList();

    if (words.length >= 2) {
      // Multi-word pure breed e.g. "Red Fulani" -> RF, "Black and white" -> BW
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].length >= 2) {
      // Single word e.g. "Kalahari" -> KA, "Sahel" -> SA
      return words[0].substring(0, 2).toUpperCase();
    } else if (words.isNotEmpty && words[0].length == 1) {
      return '${words[0][0]}X'.toUpperCase();
    }

    // Fallback to species
    final spec = (species ?? '').trim().replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (spec.length >= 2) {
      return spec.substring(0, 2).toUpperCase();
    }

    return 'XX';
  }

  /// Extracts the core tail portion of tagId.
  /// E.g. "KS-F2-045" -> "045", "COW-045" -> "045", "#012" -> "012", "045" -> "045".
  static String extractCoreTagId(String rawTag) {
    String cleaned = rawTag.trim();
    if (cleaned.startsWith('#')) {
      cleaned = cleaned.substring(1).trim();
    }
    if (cleaned.isEmpty) return '001';
    
    // If format is like BREED-GEN-NUMBER (e.g. KS-F2-045 or KA-F1-001)
    final parts = cleaned.split('-');
    if (parts.length >= 3) {
      return parts.sublist(2).join('-');
    } else if (parts.length == 2) {
      return parts[1];
    }
    return cleaned;
  }

  /// Formats tagId to format: BREED_CODE-GENERATION-NUMBER (e.g. KS-F2-045)
  static String formatTagId({
    required String rawTag,
    required String breedCode,
    required String generation,
  }) {
    final core = extractCoreTagId(rawTag);
    final genStr = generation.trim().toUpperCase();
    final breedStr = breedCode.trim().toUpperCase();
    return '$breedStr-$genStr-$core';
  }

  /// Calculates dynamic age string from date of birth relative to DateTime.now()
  static String calculateDynamicAge(DateTime? dob) {
    if (dob == null) return 'Unknown';
    final now = DateTime.now();
    final days = now.difference(dob).inDays;
    if (days < 0) return '0 Days';
    if (days < 30) return '$days Days';
    if (days < 365) {
      final months = (days / 30.4375).toStringAsFixed(1);
      return '$months Mos';
    }
    final years = (days / 365.25).toStringAsFixed(1);
    return '$years Yrs';
  }
}

/// Runs database migration for existing animal records to format tag_id and set generation.
Future<void> migrateAnimalTagsAndGenerations(LocalDatabase db) async {
  try {
    final animals = await db.select(db.localAnimals).get();
    for (final a in animals) {
      final dob = a.dateOfBirth;
      final int ageInDays = dob != null ? DateTime.now().difference(dob).inDays : 9999;
      
      // Determine generation if empty or null
      String gen = a.generation.trim();
      if (gen.isEmpty || gen == 'F1') {
        if (ageInDays < 183) { // Less than 6 months
          gen = 'F2';
        } else {
          gen = 'F1';
        }
      }

      // Determine breed code
      final breedCode = AnimalTagFormatter.getBreedCode(
        breed: a.breed ?? '',
        pedigreeType: a.pedigreeType,
        species: a.species,
      );

      // Format new tag ID
      final newTagId = AnimalTagFormatter.formatTagId(
        rawTag: a.tagId,
        breedCode: breedCode,
        generation: gen,
      );

      if (newTagId != a.tagId || gen != a.generation) {
        await (db.update(db.localAnimals)..where((t) => t.id.equals(a.id))).write(
          LocalAnimalsCompanion(
            tagId: Value(newTagId),
            generation: Value(gen),
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('[DB Migration] Error migrating animal tags and generations: $e');
  }
}
