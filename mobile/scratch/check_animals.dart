import 'package:flutter/material.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'dart:io';

import 'package:mobile/core/database/local_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = LocalDatabase(NativeDatabase(File('farm_db.sqlite')));
  final animals = await db.select(db.localAnimals).get();
  for (var a in animals) {
    print("Tag: ${a.tagId}, Sex: ${a.sex}, Species: ${a.species}, Status: ${a.status}, Repro: ${a.currentReproductiveStatus}");
  }
}
