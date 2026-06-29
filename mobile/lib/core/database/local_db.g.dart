// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $LocalAnimalsTable extends LocalAnimals
    with TableInfo<$LocalAnimalsTable, LocalAnimal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
      'breed', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currentReproductiveStatusMeta =
      const VerificationMeta('currentReproductiveStatus');
  @override
  late final GeneratedColumn<String> currentReproductiveStatus =
      GeneratedColumn<String>('current_reproductive_status', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _acquisitionCostMeta =
      const VerificationMeta('acquisitionCost');
  @override
  late final GeneratedColumn<double> acquisitionCost = GeneratedColumn<double>(
      'acquisition_cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _salvageValueMeta =
      const VerificationMeta('salvageValue');
  @override
  late final GeneratedColumn<double> salvageValue = GeneratedColumn<double>(
      'salvage_value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _uniqueMarksMeta =
      const VerificationMeta('uniqueMarks');
  @override
  late final GeneratedColumn<String> uniqueMarks = GeneratedColumn<String>(
      'unique_marks', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pedigreeTypeMeta =
      const VerificationMeta('pedigreeType');
  @override
  late final GeneratedColumn<String> pedigreeType = GeneratedColumn<String>(
      'pedigree_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vaccinationStatusMeta =
      const VerificationMeta('vaccinationStatus');
  @override
  late final GeneratedColumn<String> vaccinationStatus =
      GeneratedColumn<String>('vaccination_status', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tagId,
        species,
        breed,
        sex,
        dateOfBirth,
        locationId,
        currentReproductiveStatus,
        acquisitionCost,
        salvageValue,
        imagePath,
        weight,
        color,
        uniqueMarks,
        pedigreeType,
        purpose,
        vaccinationStatus,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_animals';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAnimal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
          _breedMeta, breed.isAcceptableOrUnknown(data['breed']!, _breedMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    } else if (isInserting) {
      context.missing(_sexMeta);
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    } else if (isInserting) {
      context.missing(_dateOfBirthMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    }
    if (data.containsKey('current_reproductive_status')) {
      context.handle(
          _currentReproductiveStatusMeta,
          currentReproductiveStatus.isAcceptableOrUnknown(
              data['current_reproductive_status']!,
              _currentReproductiveStatusMeta));
    } else if (isInserting) {
      context.missing(_currentReproductiveStatusMeta);
    }
    if (data.containsKey('acquisition_cost')) {
      context.handle(
          _acquisitionCostMeta,
          acquisitionCost.isAcceptableOrUnknown(
              data['acquisition_cost']!, _acquisitionCostMeta));
    }
    if (data.containsKey('salvage_value')) {
      context.handle(
          _salvageValueMeta,
          salvageValue.isAcceptableOrUnknown(
              data['salvage_value']!, _salvageValueMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('unique_marks')) {
      context.handle(
          _uniqueMarksMeta,
          uniqueMarks.isAcceptableOrUnknown(
              data['unique_marks']!, _uniqueMarksMeta));
    }
    if (data.containsKey('pedigree_type')) {
      context.handle(
          _pedigreeTypeMeta,
          pedigreeType.isAcceptableOrUnknown(
              data['pedigree_type']!, _pedigreeTypeMeta));
    }
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    }
    if (data.containsKey('vaccination_status')) {
      context.handle(
          _vaccinationStatusMeta,
          vaccinationStatus.isAcceptableOrUnknown(
              data['vaccination_status']!, _vaccinationStatusMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnimal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnimal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species'])!,
      breed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breed']),
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex'])!,
      dateOfBirth: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth'])!,
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id']),
      currentReproductiveStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}current_reproductive_status'])!,
      acquisitionCost: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}acquisition_cost'])!,
      salvageValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}salvage_value'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      uniqueMarks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unique_marks']),
      pedigreeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pedigree_type']),
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose']),
      vaccinationStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}vaccination_status']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $LocalAnimalsTable createAlias(String alias) {
    return $LocalAnimalsTable(attachedDatabase, alias);
  }
}

class LocalAnimal extends DataClass implements Insertable<LocalAnimal> {
  final String id;
  final String tagId;
  final String species;
  final String? breed;
  final String sex;
  final DateTime dateOfBirth;
  final String? locationId;
  final String currentReproductiveStatus;
  final double acquisitionCost;
  final double salvageValue;
  final String? imagePath;
  final double? weight;
  final String? color;
  final String? uniqueMarks;
  final String? pedigreeType;
  final String? purpose;
  final String? vaccinationStatus;
  final String status;
  const LocalAnimal(
      {required this.id,
      required this.tagId,
      required this.species,
      this.breed,
      required this.sex,
      required this.dateOfBirth,
      this.locationId,
      required this.currentReproductiveStatus,
      required this.acquisitionCost,
      required this.salvageValue,
      this.imagePath,
      this.weight,
      this.color,
      this.uniqueMarks,
      this.pedigreeType,
      this.purpose,
      this.vaccinationStatus,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tag_id'] = Variable<String>(tagId);
    map['species'] = Variable<String>(species);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    map['sex'] = Variable<String>(sex);
    map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    map['current_reproductive_status'] =
        Variable<String>(currentReproductiveStatus);
    map['acquisition_cost'] = Variable<double>(acquisitionCost);
    map['salvage_value'] = Variable<double>(salvageValue);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || uniqueMarks != null) {
      map['unique_marks'] = Variable<String>(uniqueMarks);
    }
    if (!nullToAbsent || pedigreeType != null) {
      map['pedigree_type'] = Variable<String>(pedigreeType);
    }
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    if (!nullToAbsent || vaccinationStatus != null) {
      map['vaccination_status'] = Variable<String>(vaccinationStatus);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  LocalAnimalsCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimalsCompanion(
      id: Value(id),
      tagId: Value(tagId),
      species: Value(species),
      breed:
          breed == null && nullToAbsent ? const Value.absent() : Value(breed),
      sex: Value(sex),
      dateOfBirth: Value(dateOfBirth),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      currentReproductiveStatus: Value(currentReproductiveStatus),
      acquisitionCost: Value(acquisitionCost),
      salvageValue: Value(salvageValue),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      weight:
          weight == null && nullToAbsent ? const Value.absent() : Value(weight),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      uniqueMarks: uniqueMarks == null && nullToAbsent
          ? const Value.absent()
          : Value(uniqueMarks),
      pedigreeType: pedigreeType == null && nullToAbsent
          ? const Value.absent()
          : Value(pedigreeType),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      vaccinationStatus: vaccinationStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(vaccinationStatus),
      status: Value(status),
    );
  }

  factory LocalAnimal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnimal(
      id: serializer.fromJson<String>(json['id']),
      tagId: serializer.fromJson<String>(json['tagId']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String?>(json['breed']),
      sex: serializer.fromJson<String>(json['sex']),
      dateOfBirth: serializer.fromJson<DateTime>(json['dateOfBirth']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      currentReproductiveStatus:
          serializer.fromJson<String>(json['currentReproductiveStatus']),
      acquisitionCost: serializer.fromJson<double>(json['acquisitionCost']),
      salvageValue: serializer.fromJson<double>(json['salvageValue']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      weight: serializer.fromJson<double?>(json['weight']),
      color: serializer.fromJson<String?>(json['color']),
      uniqueMarks: serializer.fromJson<String?>(json['uniqueMarks']),
      pedigreeType: serializer.fromJson<String?>(json['pedigreeType']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      vaccinationStatus:
          serializer.fromJson<String?>(json['vaccinationStatus']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tagId': serializer.toJson<String>(tagId),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String?>(breed),
      'sex': serializer.toJson<String>(sex),
      'dateOfBirth': serializer.toJson<DateTime>(dateOfBirth),
      'locationId': serializer.toJson<String?>(locationId),
      'currentReproductiveStatus':
          serializer.toJson<String>(currentReproductiveStatus),
      'acquisitionCost': serializer.toJson<double>(acquisitionCost),
      'salvageValue': serializer.toJson<double>(salvageValue),
      'imagePath': serializer.toJson<String?>(imagePath),
      'weight': serializer.toJson<double?>(weight),
      'color': serializer.toJson<String?>(color),
      'uniqueMarks': serializer.toJson<String?>(uniqueMarks),
      'pedigreeType': serializer.toJson<String?>(pedigreeType),
      'purpose': serializer.toJson<String?>(purpose),
      'vaccinationStatus': serializer.toJson<String?>(vaccinationStatus),
      'status': serializer.toJson<String>(status),
    };
  }

  LocalAnimal copyWith(
          {String? id,
          String? tagId,
          String? species,
          Value<String?> breed = const Value.absent(),
          String? sex,
          DateTime? dateOfBirth,
          Value<String?> locationId = const Value.absent(),
          String? currentReproductiveStatus,
          double? acquisitionCost,
          double? salvageValue,
          Value<String?> imagePath = const Value.absent(),
          Value<double?> weight = const Value.absent(),
          Value<String?> color = const Value.absent(),
          Value<String?> uniqueMarks = const Value.absent(),
          Value<String?> pedigreeType = const Value.absent(),
          Value<String?> purpose = const Value.absent(),
          Value<String?> vaccinationStatus = const Value.absent(),
          String? status}) =>
      LocalAnimal(
        id: id ?? this.id,
        tagId: tagId ?? this.tagId,
        species: species ?? this.species,
        breed: breed.present ? breed.value : this.breed,
        sex: sex ?? this.sex,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        locationId: locationId.present ? locationId.value : this.locationId,
        currentReproductiveStatus:
            currentReproductiveStatus ?? this.currentReproductiveStatus,
        acquisitionCost: acquisitionCost ?? this.acquisitionCost,
        salvageValue: salvageValue ?? this.salvageValue,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        weight: weight.present ? weight.value : this.weight,
        color: color.present ? color.value : this.color,
        uniqueMarks: uniqueMarks.present ? uniqueMarks.value : this.uniqueMarks,
        pedigreeType:
            pedigreeType.present ? pedigreeType.value : this.pedigreeType,
        purpose: purpose.present ? purpose.value : this.purpose,
        vaccinationStatus: vaccinationStatus.present
            ? vaccinationStatus.value
            : this.vaccinationStatus,
        status: status ?? this.status,
      );
  LocalAnimal copyWithCompanion(LocalAnimalsCompanion data) {
    return LocalAnimal(
      id: data.id.present ? data.id.value : this.id,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      sex: data.sex.present ? data.sex.value : this.sex,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      currentReproductiveStatus: data.currentReproductiveStatus.present
          ? data.currentReproductiveStatus.value
          : this.currentReproductiveStatus,
      acquisitionCost: data.acquisitionCost.present
          ? data.acquisitionCost.value
          : this.acquisitionCost,
      salvageValue: data.salvageValue.present
          ? data.salvageValue.value
          : this.salvageValue,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      weight: data.weight.present ? data.weight.value : this.weight,
      color: data.color.present ? data.color.value : this.color,
      uniqueMarks:
          data.uniqueMarks.present ? data.uniqueMarks.value : this.uniqueMarks,
      pedigreeType: data.pedigreeType.present
          ? data.pedigreeType.value
          : this.pedigreeType,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      vaccinationStatus: data.vaccinationStatus.present
          ? data.vaccinationStatus.value
          : this.vaccinationStatus,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimal(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('sex: $sex, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('locationId: $locationId, ')
          ..write('currentReproductiveStatus: $currentReproductiveStatus, ')
          ..write('acquisitionCost: $acquisitionCost, ')
          ..write('salvageValue: $salvageValue, ')
          ..write('imagePath: $imagePath, ')
          ..write('weight: $weight, ')
          ..write('color: $color, ')
          ..write('uniqueMarks: $uniqueMarks, ')
          ..write('pedigreeType: $pedigreeType, ')
          ..write('purpose: $purpose, ')
          ..write('vaccinationStatus: $vaccinationStatus, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tagId,
      species,
      breed,
      sex,
      dateOfBirth,
      locationId,
      currentReproductiveStatus,
      acquisitionCost,
      salvageValue,
      imagePath,
      weight,
      color,
      uniqueMarks,
      pedigreeType,
      purpose,
      vaccinationStatus,
      status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnimal &&
          other.id == this.id &&
          other.tagId == this.tagId &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.sex == this.sex &&
          other.dateOfBirth == this.dateOfBirth &&
          other.locationId == this.locationId &&
          other.currentReproductiveStatus == this.currentReproductiveStatus &&
          other.acquisitionCost == this.acquisitionCost &&
          other.salvageValue == this.salvageValue &&
          other.imagePath == this.imagePath &&
          other.weight == this.weight &&
          other.color == this.color &&
          other.uniqueMarks == this.uniqueMarks &&
          other.pedigreeType == this.pedigreeType &&
          other.purpose == this.purpose &&
          other.vaccinationStatus == this.vaccinationStatus &&
          other.status == this.status);
}

class LocalAnimalsCompanion extends UpdateCompanion<LocalAnimal> {
  final Value<String> id;
  final Value<String> tagId;
  final Value<String> species;
  final Value<String?> breed;
  final Value<String> sex;
  final Value<DateTime> dateOfBirth;
  final Value<String?> locationId;
  final Value<String> currentReproductiveStatus;
  final Value<double> acquisitionCost;
  final Value<double> salvageValue;
  final Value<String?> imagePath;
  final Value<double?> weight;
  final Value<String?> color;
  final Value<String?> uniqueMarks;
  final Value<String?> pedigreeType;
  final Value<String?> purpose;
  final Value<String?> vaccinationStatus;
  final Value<String> status;
  final Value<int> rowid;
  const LocalAnimalsCompanion({
    this.id = const Value.absent(),
    this.tagId = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.sex = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.locationId = const Value.absent(),
    this.currentReproductiveStatus = const Value.absent(),
    this.acquisitionCost = const Value.absent(),
    this.salvageValue = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.weight = const Value.absent(),
    this.color = const Value.absent(),
    this.uniqueMarks = const Value.absent(),
    this.pedigreeType = const Value.absent(),
    this.purpose = const Value.absent(),
    this.vaccinationStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnimalsCompanion.insert({
    required String id,
    required String tagId,
    required String species,
    this.breed = const Value.absent(),
    required String sex,
    required DateTime dateOfBirth,
    this.locationId = const Value.absent(),
    required String currentReproductiveStatus,
    this.acquisitionCost = const Value.absent(),
    this.salvageValue = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.weight = const Value.absent(),
    this.color = const Value.absent(),
    this.uniqueMarks = const Value.absent(),
    this.pedigreeType = const Value.absent(),
    this.purpose = const Value.absent(),
    this.vaccinationStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tagId = Value(tagId),
        species = Value(species),
        sex = Value(sex),
        dateOfBirth = Value(dateOfBirth),
        currentReproductiveStatus = Value(currentReproductiveStatus);
  static Insertable<LocalAnimal> custom({
    Expression<String>? id,
    Expression<String>? tagId,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<String>? sex,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? locationId,
    Expression<String>? currentReproductiveStatus,
    Expression<double>? acquisitionCost,
    Expression<double>? salvageValue,
    Expression<String>? imagePath,
    Expression<double>? weight,
    Expression<String>? color,
    Expression<String>? uniqueMarks,
    Expression<String>? pedigreeType,
    Expression<String>? purpose,
    Expression<String>? vaccinationStatus,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tagId != null) 'tag_id': tagId,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (sex != null) 'sex': sex,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (locationId != null) 'location_id': locationId,
      if (currentReproductiveStatus != null)
        'current_reproductive_status': currentReproductiveStatus,
      if (acquisitionCost != null) 'acquisition_cost': acquisitionCost,
      if (salvageValue != null) 'salvage_value': salvageValue,
      if (imagePath != null) 'image_path': imagePath,
      if (weight != null) 'weight': weight,
      if (color != null) 'color': color,
      if (uniqueMarks != null) 'unique_marks': uniqueMarks,
      if (pedigreeType != null) 'pedigree_type': pedigreeType,
      if (purpose != null) 'purpose': purpose,
      if (vaccinationStatus != null) 'vaccination_status': vaccinationStatus,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnimalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tagId,
      Value<String>? species,
      Value<String?>? breed,
      Value<String>? sex,
      Value<DateTime>? dateOfBirth,
      Value<String?>? locationId,
      Value<String>? currentReproductiveStatus,
      Value<double>? acquisitionCost,
      Value<double>? salvageValue,
      Value<String?>? imagePath,
      Value<double?>? weight,
      Value<String?>? color,
      Value<String?>? uniqueMarks,
      Value<String?>? pedigreeType,
      Value<String?>? purpose,
      Value<String?>? vaccinationStatus,
      Value<String>? status,
      Value<int>? rowid}) {
    return LocalAnimalsCompanion(
      id: id ?? this.id,
      tagId: tagId ?? this.tagId,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      sex: sex ?? this.sex,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      locationId: locationId ?? this.locationId,
      currentReproductiveStatus:
          currentReproductiveStatus ?? this.currentReproductiveStatus,
      acquisitionCost: acquisitionCost ?? this.acquisitionCost,
      salvageValue: salvageValue ?? this.salvageValue,
      imagePath: imagePath ?? this.imagePath,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      uniqueMarks: uniqueMarks ?? this.uniqueMarks,
      pedigreeType: pedigreeType ?? this.pedigreeType,
      purpose: purpose ?? this.purpose,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (currentReproductiveStatus.present) {
      map['current_reproductive_status'] =
          Variable<String>(currentReproductiveStatus.value);
    }
    if (acquisitionCost.present) {
      map['acquisition_cost'] = Variable<double>(acquisitionCost.value);
    }
    if (salvageValue.present) {
      map['salvage_value'] = Variable<double>(salvageValue.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (uniqueMarks.present) {
      map['unique_marks'] = Variable<String>(uniqueMarks.value);
    }
    if (pedigreeType.present) {
      map['pedigree_type'] = Variable<String>(pedigreeType.value);
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (vaccinationStatus.present) {
      map['vaccination_status'] = Variable<String>(vaccinationStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalsCompanion(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('sex: $sex, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('locationId: $locationId, ')
          ..write('currentReproductiveStatus: $currentReproductiveStatus, ')
          ..write('acquisitionCost: $acquisitionCost, ')
          ..write('salvageValue: $salvageValue, ')
          ..write('imagePath: $imagePath, ')
          ..write('weight: $weight, ')
          ..write('color: $color, ')
          ..write('uniqueMarks: $uniqueMarks, ')
          ..write('pedigreeType: $pedigreeType, ')
          ..write('purpose: $purpose, ')
          ..write('vaccinationStatus: $vaccinationStatus, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMilkRecordsTable extends LocalMilkRecords
    with TableInfo<$LocalMilkRecordsTable, LocalMilkRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMilkRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _animalIdMeta =
      const VerificationMeta('animalId');
  @override
  late final GeneratedColumn<String> animalId = GeneratedColumn<String>(
      'animal_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordDateMeta =
      const VerificationMeta('recordDate');
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
      'record_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _milkingSessionMeta =
      const VerificationMeta('milkingSession');
  @override
  late final GeneratedColumn<String> milkingSession = GeneratedColumn<String>(
      'milking_session', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityLitersMeta =
      const VerificationMeta('quantityLiters');
  @override
  late final GeneratedColumn<double> quantityLiters = GeneratedColumn<double>(
      'quantity_liters', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isWithdrawnMeta =
      const VerificationMeta('isWithdrawn');
  @override
  late final GeneratedColumn<bool> isWithdrawn = GeneratedColumn<bool>(
      'is_withdrawn', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_withdrawn" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, animalId, recordDate, milkingSession, quantityLiters, isWithdrawn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_milk_records';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMilkRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('animal_id')) {
      context.handle(_animalIdMeta,
          animalId.isAcceptableOrUnknown(data['animal_id']!, _animalIdMeta));
    } else if (isInserting) {
      context.missing(_animalIdMeta);
    }
    if (data.containsKey('record_date')) {
      context.handle(
          _recordDateMeta,
          recordDate.isAcceptableOrUnknown(
              data['record_date']!, _recordDateMeta));
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('milking_session')) {
      context.handle(
          _milkingSessionMeta,
          milkingSession.isAcceptableOrUnknown(
              data['milking_session']!, _milkingSessionMeta));
    } else if (isInserting) {
      context.missing(_milkingSessionMeta);
    }
    if (data.containsKey('quantity_liters')) {
      context.handle(
          _quantityLitersMeta,
          quantityLiters.isAcceptableOrUnknown(
              data['quantity_liters']!, _quantityLitersMeta));
    } else if (isInserting) {
      context.missing(_quantityLitersMeta);
    }
    if (data.containsKey('is_withdrawn')) {
      context.handle(
          _isWithdrawnMeta,
          isWithdrawn.isAcceptableOrUnknown(
              data['is_withdrawn']!, _isWithdrawnMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMilkRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMilkRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      recordDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}record_date'])!,
      milkingSession: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}milking_session'])!,
      quantityLiters: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}quantity_liters'])!,
      isWithdrawn: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_withdrawn'])!,
    );
  }

  @override
  $LocalMilkRecordsTable createAlias(String alias) {
    return $LocalMilkRecordsTable(attachedDatabase, alias);
  }
}

class LocalMilkRecord extends DataClass implements Insertable<LocalMilkRecord> {
  final String id;
  final String animalId;
  final DateTime recordDate;
  final String milkingSession;
  final double quantityLiters;
  final bool isWithdrawn;
  const LocalMilkRecord(
      {required this.id,
      required this.animalId,
      required this.recordDate,
      required this.milkingSession,
      required this.quantityLiters,
      required this.isWithdrawn});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['record_date'] = Variable<DateTime>(recordDate);
    map['milking_session'] = Variable<String>(milkingSession);
    map['quantity_liters'] = Variable<double>(quantityLiters);
    map['is_withdrawn'] = Variable<bool>(isWithdrawn);
    return map;
  }

  LocalMilkRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalMilkRecordsCompanion(
      id: Value(id),
      animalId: Value(animalId),
      recordDate: Value(recordDate),
      milkingSession: Value(milkingSession),
      quantityLiters: Value(quantityLiters),
      isWithdrawn: Value(isWithdrawn),
    );
  }

  factory LocalMilkRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMilkRecord(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      milkingSession: serializer.fromJson<String>(json['milkingSession']),
      quantityLiters: serializer.fromJson<double>(json['quantityLiters']),
      isWithdrawn: serializer.fromJson<bool>(json['isWithdrawn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'milkingSession': serializer.toJson<String>(milkingSession),
      'quantityLiters': serializer.toJson<double>(quantityLiters),
      'isWithdrawn': serializer.toJson<bool>(isWithdrawn),
    };
  }

  LocalMilkRecord copyWith(
          {String? id,
          String? animalId,
          DateTime? recordDate,
          String? milkingSession,
          double? quantityLiters,
          bool? isWithdrawn}) =>
      LocalMilkRecord(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        recordDate: recordDate ?? this.recordDate,
        milkingSession: milkingSession ?? this.milkingSession,
        quantityLiters: quantityLiters ?? this.quantityLiters,
        isWithdrawn: isWithdrawn ?? this.isWithdrawn,
      );
  LocalMilkRecord copyWithCompanion(LocalMilkRecordsCompanion data) {
    return LocalMilkRecord(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      recordDate:
          data.recordDate.present ? data.recordDate.value : this.recordDate,
      milkingSession: data.milkingSession.present
          ? data.milkingSession.value
          : this.milkingSession,
      quantityLiters: data.quantityLiters.present
          ? data.quantityLiters.value
          : this.quantityLiters,
      isWithdrawn:
          data.isWithdrawn.present ? data.isWithdrawn.value : this.isWithdrawn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMilkRecord(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('recordDate: $recordDate, ')
          ..write('milkingSession: $milkingSession, ')
          ..write('quantityLiters: $quantityLiters, ')
          ..write('isWithdrawn: $isWithdrawn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, animalId, recordDate, milkingSession, quantityLiters, isWithdrawn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMilkRecord &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.recordDate == this.recordDate &&
          other.milkingSession == this.milkingSession &&
          other.quantityLiters == this.quantityLiters &&
          other.isWithdrawn == this.isWithdrawn);
}

class LocalMilkRecordsCompanion extends UpdateCompanion<LocalMilkRecord> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<DateTime> recordDate;
  final Value<String> milkingSession;
  final Value<double> quantityLiters;
  final Value<bool> isWithdrawn;
  final Value<int> rowid;
  const LocalMilkRecordsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.milkingSession = const Value.absent(),
    this.quantityLiters = const Value.absent(),
    this.isWithdrawn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMilkRecordsCompanion.insert({
    required String id,
    required String animalId,
    required DateTime recordDate,
    required String milkingSession,
    required double quantityLiters,
    this.isWithdrawn = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        recordDate = Value(recordDate),
        milkingSession = Value(milkingSession),
        quantityLiters = Value(quantityLiters);
  static Insertable<LocalMilkRecord> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<DateTime>? recordDate,
    Expression<String>? milkingSession,
    Expression<double>? quantityLiters,
    Expression<bool>? isWithdrawn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (recordDate != null) 'record_date': recordDate,
      if (milkingSession != null) 'milking_session': milkingSession,
      if (quantityLiters != null) 'quantity_liters': quantityLiters,
      if (isWithdrawn != null) 'is_withdrawn': isWithdrawn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMilkRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? animalId,
      Value<DateTime>? recordDate,
      Value<String>? milkingSession,
      Value<double>? quantityLiters,
      Value<bool>? isWithdrawn,
      Value<int>? rowid}) {
    return LocalMilkRecordsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      recordDate: recordDate ?? this.recordDate,
      milkingSession: milkingSession ?? this.milkingSession,
      quantityLiters: quantityLiters ?? this.quantityLiters,
      isWithdrawn: isWithdrawn ?? this.isWithdrawn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (animalId.present) {
      map['animal_id'] = Variable<String>(animalId.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (milkingSession.present) {
      map['milking_session'] = Variable<String>(milkingSession.value);
    }
    if (quantityLiters.present) {
      map['quantity_liters'] = Variable<double>(quantityLiters.value);
    }
    if (isWithdrawn.present) {
      map['is_withdrawn'] = Variable<bool>(isWithdrawn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMilkRecordsCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('recordDate: $recordDate, ')
          ..write('milkingSession: $milkingSession, ')
          ..write('quantityLiters: $quantityLiters, ')
          ..write('isWithdrawn: $isWithdrawn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransactionsTable extends LocalTransactions
    with TableInfo<$LocalTransactionsTable, LocalTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transactionTypeMeta =
      const VerificationMeta('transactionType');
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
      'transaction_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('NGN'));
  static const VerificationMeta _relatedEntityTypeMeta =
      const VerificationMeta('relatedEntityType');
  @override
  late final GeneratedColumn<String> relatedEntityType =
      GeneratedColumn<String>('related_entity_type', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relatedEntityIdMeta =
      const VerificationMeta('relatedEntityId');
  @override
  late final GeneratedColumn<String> relatedEntityId = GeneratedColumn<String>(
      'related_entity_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transactionDateMeta =
      const VerificationMeta('transactionDate');
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>('transaction_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isReconciledMeta =
      const VerificationMeta('isReconciled');
  @override
  late final GeneratedColumn<bool> isReconciled = GeneratedColumn<bool>(
      'is_reconciled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_reconciled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _reversalOfMeta =
      const VerificationMeta('reversalOf');
  @override
  late final GeneratedColumn<String> reversalOf = GeneratedColumn<String>(
      'reversal_of', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        transactionType,
        category,
        amount,
        currency,
        relatedEntityType,
        relatedEntityId,
        description,
        transactionDate,
        isReconciled,
        reversalOf
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
          _transactionTypeMeta,
          transactionType.isAcceptableOrUnknown(
              data['transaction_type']!, _transactionTypeMeta));
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('related_entity_type')) {
      context.handle(
          _relatedEntityTypeMeta,
          relatedEntityType.isAcceptableOrUnknown(
              data['related_entity_type']!, _relatedEntityTypeMeta));
    }
    if (data.containsKey('related_entity_id')) {
      context.handle(
          _relatedEntityIdMeta,
          relatedEntityId.isAcceptableOrUnknown(
              data['related_entity_id']!, _relatedEntityIdMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
          _transactionDateMeta,
          transactionDate.isAcceptableOrUnknown(
              data['transaction_date']!, _transactionDateMeta));
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('is_reconciled')) {
      context.handle(
          _isReconciledMeta,
          isReconciled.isAcceptableOrUnknown(
              data['is_reconciled']!, _isReconciledMeta));
    }
    if (data.containsKey('reversal_of')) {
      context.handle(
          _reversalOfMeta,
          reversalOf.isAcceptableOrUnknown(
              data['reversal_of']!, _reversalOfMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      transactionType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transaction_type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      relatedEntityType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_entity_type']),
      relatedEntityId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_entity_id']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      transactionDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}transaction_date'])!,
      isReconciled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_reconciled'])!,
      reversalOf: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reversal_of']),
    );
  }

  @override
  $LocalTransactionsTable createAlias(String alias) {
    return $LocalTransactionsTable(attachedDatabase, alias);
  }
}

class LocalTransaction extends DataClass
    implements Insertable<LocalTransaction> {
  final String id;
  final String transactionType;
  final String category;
  final double amount;
  final String currency;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? description;
  final DateTime transactionDate;
  final bool isReconciled;
  final String? reversalOf;
  const LocalTransaction(
      {required this.id,
      required this.transactionType,
      required this.category,
      required this.amount,
      required this.currency,
      this.relatedEntityType,
      this.relatedEntityId,
      this.description,
      required this.transactionDate,
      required this.isReconciled,
      this.reversalOf});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_type'] = Variable<String>(transactionType);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || relatedEntityType != null) {
      map['related_entity_type'] = Variable<String>(relatedEntityType);
    }
    if (!nullToAbsent || relatedEntityId != null) {
      map['related_entity_id'] = Variable<String>(relatedEntityId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    map['is_reconciled'] = Variable<bool>(isReconciled);
    if (!nullToAbsent || reversalOf != null) {
      map['reversal_of'] = Variable<String>(reversalOf);
    }
    return map;
  }

  LocalTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTransactionsCompanion(
      id: Value(id),
      transactionType: Value(transactionType),
      category: Value(category),
      amount: Value(amount),
      currency: Value(currency),
      relatedEntityType: relatedEntityType == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEntityType),
      relatedEntityId: relatedEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEntityId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      transactionDate: Value(transactionDate),
      isReconciled: Value(isReconciled),
      reversalOf: reversalOf == null && nullToAbsent
          ? const Value.absent()
          : Value(reversalOf),
    );
  }

  factory LocalTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaction(
      id: serializer.fromJson<String>(json['id']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      currency: serializer.fromJson<String>(json['currency']),
      relatedEntityType:
          serializer.fromJson<String?>(json['relatedEntityType']),
      relatedEntityId: serializer.fromJson<String?>(json['relatedEntityId']),
      description: serializer.fromJson<String?>(json['description']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      isReconciled: serializer.fromJson<bool>(json['isReconciled']),
      reversalOf: serializer.fromJson<String?>(json['reversalOf']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionType': serializer.toJson<String>(transactionType),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'currency': serializer.toJson<String>(currency),
      'relatedEntityType': serializer.toJson<String?>(relatedEntityType),
      'relatedEntityId': serializer.toJson<String?>(relatedEntityId),
      'description': serializer.toJson<String?>(description),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'isReconciled': serializer.toJson<bool>(isReconciled),
      'reversalOf': serializer.toJson<String?>(reversalOf),
    };
  }

  LocalTransaction copyWith(
          {String? id,
          String? transactionType,
          String? category,
          double? amount,
          String? currency,
          Value<String?> relatedEntityType = const Value.absent(),
          Value<String?> relatedEntityId = const Value.absent(),
          Value<String?> description = const Value.absent(),
          DateTime? transactionDate,
          bool? isReconciled,
          Value<String?> reversalOf = const Value.absent()}) =>
      LocalTransaction(
        id: id ?? this.id,
        transactionType: transactionType ?? this.transactionType,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        relatedEntityType: relatedEntityType.present
            ? relatedEntityType.value
            : this.relatedEntityType,
        relatedEntityId: relatedEntityId.present
            ? relatedEntityId.value
            : this.relatedEntityId,
        description: description.present ? description.value : this.description,
        transactionDate: transactionDate ?? this.transactionDate,
        isReconciled: isReconciled ?? this.isReconciled,
        reversalOf: reversalOf.present ? reversalOf.value : this.reversalOf,
      );
  LocalTransaction copyWithCompanion(LocalTransactionsCompanion data) {
    return LocalTransaction(
      id: data.id.present ? data.id.value : this.id,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      currency: data.currency.present ? data.currency.value : this.currency,
      relatedEntityType: data.relatedEntityType.present
          ? data.relatedEntityType.value
          : this.relatedEntityType,
      relatedEntityId: data.relatedEntityId.present
          ? data.relatedEntityId.value
          : this.relatedEntityId,
      description:
          data.description.present ? data.description.value : this.description,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      isReconciled: data.isReconciled.present
          ? data.isReconciled.value
          : this.isReconciled,
      reversalOf:
          data.reversalOf.present ? data.reversalOf.value : this.reversalOf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaction(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('relatedEntityType: $relatedEntityType, ')
          ..write('relatedEntityId: $relatedEntityId, ')
          ..write('description: $description, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('isReconciled: $isReconciled, ')
          ..write('reversalOf: $reversalOf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      transactionType,
      category,
      amount,
      currency,
      relatedEntityType,
      relatedEntityId,
      description,
      transactionDate,
      isReconciled,
      reversalOf);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaction &&
          other.id == this.id &&
          other.transactionType == this.transactionType &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.currency == this.currency &&
          other.relatedEntityType == this.relatedEntityType &&
          other.relatedEntityId == this.relatedEntityId &&
          other.description == this.description &&
          other.transactionDate == this.transactionDate &&
          other.isReconciled == this.isReconciled &&
          other.reversalOf == this.reversalOf);
}

class LocalTransactionsCompanion extends UpdateCompanion<LocalTransaction> {
  final Value<String> id;
  final Value<String> transactionType;
  final Value<String> category;
  final Value<double> amount;
  final Value<String> currency;
  final Value<String?> relatedEntityType;
  final Value<String?> relatedEntityId;
  final Value<String?> description;
  final Value<DateTime> transactionDate;
  final Value<bool> isReconciled;
  final Value<String?> reversalOf;
  final Value<int> rowid;
  const LocalTransactionsCompanion({
    this.id = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.currency = const Value.absent(),
    this.relatedEntityType = const Value.absent(),
    this.relatedEntityId = const Value.absent(),
    this.description = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.isReconciled = const Value.absent(),
    this.reversalOf = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransactionsCompanion.insert({
    required String id,
    required String transactionType,
    required String category,
    required double amount,
    this.currency = const Value.absent(),
    this.relatedEntityType = const Value.absent(),
    this.relatedEntityId = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime transactionDate,
    this.isReconciled = const Value.absent(),
    this.reversalOf = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        transactionType = Value(transactionType),
        category = Value(category),
        amount = Value(amount),
        transactionDate = Value(transactionDate);
  static Insertable<LocalTransaction> custom({
    Expression<String>? id,
    Expression<String>? transactionType,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<String>? currency,
    Expression<String>? relatedEntityType,
    Expression<String>? relatedEntityId,
    Expression<String>? description,
    Expression<DateTime>? transactionDate,
    Expression<bool>? isReconciled,
    Expression<String>? reversalOf,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionType != null) 'transaction_type': transactionType,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (relatedEntityType != null) 'related_entity_type': relatedEntityType,
      if (relatedEntityId != null) 'related_entity_id': relatedEntityId,
      if (description != null) 'description': description,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (isReconciled != null) 'is_reconciled': isReconciled,
      if (reversalOf != null) 'reversal_of': reversalOf,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? transactionType,
      Value<String>? category,
      Value<double>? amount,
      Value<String>? currency,
      Value<String?>? relatedEntityType,
      Value<String?>? relatedEntityId,
      Value<String?>? description,
      Value<DateTime>? transactionDate,
      Value<bool>? isReconciled,
      Value<String?>? reversalOf,
      Value<int>? rowid}) {
    return LocalTransactionsCompanion(
      id: id ?? this.id,
      transactionType: transactionType ?? this.transactionType,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      isReconciled: isReconciled ?? this.isReconciled,
      reversalOf: reversalOf ?? this.reversalOf,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (relatedEntityType.present) {
      map['related_entity_type'] = Variable<String>(relatedEntityType.value);
    }
    if (relatedEntityId.present) {
      map['related_entity_id'] = Variable<String>(relatedEntityId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (isReconciled.present) {
      map['is_reconciled'] = Variable<bool>(isReconciled.value);
    }
    if (reversalOf.present) {
      map['reversal_of'] = Variable<String>(reversalOf.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('transactionType: $transactionType, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('currency: $currency, ')
          ..write('relatedEntityType: $relatedEntityType, ')
          ..write('relatedEntityId: $relatedEntityId, ')
          ..write('description: $description, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('isReconciled: $isReconciled, ')
          ..write('reversalOf: $reversalOf, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTasksTable extends LocalTasks
    with TableInfo<$LocalTasksTable, LocalTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assignedToMeta =
      const VerificationMeta('assignedTo');
  @override
  late final GeneratedColumn<String> assignedTo = GeneratedColumn<String>(
      'assigned_to', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        priority,
        status,
        assignedTo,
        dueDate,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<LocalTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('assigned_to')) {
      context.handle(
          _assignedToMeta,
          assignedTo.isAcceptableOrUnknown(
              data['assigned_to']!, _assignedToMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTask(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      assignedTo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assigned_to']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $LocalTasksTable createAlias(String alias) {
    return $LocalTasksTable(attachedDatabase, alias);
  }
}

class LocalTask extends DataClass implements Insertable<LocalTask> {
  final String id;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final String? assignedTo;
  final DateTime? dueDate;
  final DateTime? completedAt;
  const LocalTask(
      {required this.id,
      required this.title,
      this.description,
      required this.priority,
      required this.status,
      this.assignedTo,
      this.dueDate,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['priority'] = Variable<String>(priority);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || assignedTo != null) {
      map['assigned_to'] = Variable<String>(assignedTo);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  LocalTasksCompanion toCompanion(bool nullToAbsent) {
    return LocalTasksCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      priority: Value(priority),
      status: Value(status),
      assignedTo: assignedTo == null && nullToAbsent
          ? const Value.absent()
          : Value(assignedTo),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory LocalTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTask(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      priority: serializer.fromJson<String>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      assignedTo: serializer.fromJson<String?>(json['assignedTo']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'priority': serializer.toJson<String>(priority),
      'status': serializer.toJson<String>(status),
      'assignedTo': serializer.toJson<String?>(assignedTo),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  LocalTask copyWith(
          {String? id,
          String? title,
          Value<String?> description = const Value.absent(),
          String? priority,
          String? status,
          Value<String?> assignedTo = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent()}) =>
      LocalTask(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  LocalTask copyWithCompanion(LocalTasksCompanion data) {
    return LocalTask(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      assignedTo:
          data.assignedTo.present ? data.assignedTo.value : this.assignedTo,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTask(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, priority, status,
      assignedTo, dueDate, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTask &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.assignedTo == this.assignedTo &&
          other.dueDate == this.dueDate &&
          other.completedAt == this.completedAt);
}

class LocalTasksCompanion extends UpdateCompanion<LocalTask> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> priority;
  final Value<String> status;
  final Value<String?> assignedTo;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const LocalTasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.assignedTo = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTasksCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String priority,
    required String status,
    this.assignedTo = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        priority = Value(priority),
        status = Value(status);
  static Insertable<LocalTask> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? priority,
    Expression<String>? status,
    Expression<String>? assignedTo,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (dueDate != null) 'due_date': dueDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<String>? priority,
      Value<String>? status,
      Value<String?>? assignedTo,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return LocalTasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (assignedTo.present) {
      map['assigned_to'] = Variable<String>(assignedTo.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('assignedTo: $assignedTo, ')
          ..write('dueDate: $dueDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPoultryBatchesTable extends LocalPoultryBatches
    with TableInfo<$LocalPoultryBatchesTable, LocalPoultryBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPoultryBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _batchNumberMeta =
      const VerificationMeta('batchNumber');
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
      'batch_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _houseNameMeta =
      const VerificationMeta('houseName');
  @override
  late final GeneratedColumn<String> houseName = GeneratedColumn<String>(
      'house_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _initialCountMeta =
      const VerificationMeta('initialCount');
  @override
  late final GeneratedColumn<int> initialCount = GeneratedColumn<int>(
      'initial_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentCountMeta =
      const VerificationMeta('currentCount');
  @override
  late final GeneratedColumn<int> currentCount = GeneratedColumn<int>(
      'current_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        batchNumber,
        houseName,
        initialCount,
        currentCount,
        startDate,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_poultry_batches';
  @override
  VerificationContext validateIntegrity(Insertable<LocalPoultryBatche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_number')) {
      context.handle(
          _batchNumberMeta,
          batchNumber.isAcceptableOrUnknown(
              data['batch_number']!, _batchNumberMeta));
    } else if (isInserting) {
      context.missing(_batchNumberMeta);
    }
    if (data.containsKey('house_name')) {
      context.handle(_houseNameMeta,
          houseName.isAcceptableOrUnknown(data['house_name']!, _houseNameMeta));
    } else if (isInserting) {
      context.missing(_houseNameMeta);
    }
    if (data.containsKey('initial_count')) {
      context.handle(
          _initialCountMeta,
          initialCount.isAcceptableOrUnknown(
              data['initial_count']!, _initialCountMeta));
    } else if (isInserting) {
      context.missing(_initialCountMeta);
    }
    if (data.containsKey('current_count')) {
      context.handle(
          _currentCountMeta,
          currentCount.isAcceptableOrUnknown(
              data['current_count']!, _currentCountMeta));
    } else if (isInserting) {
      context.missing(_currentCountMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPoultryBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPoultryBatche(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      batchNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_number'])!,
      houseName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_name'])!,
      initialCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}initial_count'])!,
      currentCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_count'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $LocalPoultryBatchesTable createAlias(String alias) {
    return $LocalPoultryBatchesTable(attachedDatabase, alias);
  }
}

class LocalPoultryBatche extends DataClass
    implements Insertable<LocalPoultryBatche> {
  final String id;
  final String batchNumber;
  final String houseName;
  final int initialCount;
  final int currentCount;
  final DateTime startDate;
  final String status;
  const LocalPoultryBatche(
      {required this.id,
      required this.batchNumber,
      required this.houseName,
      required this.initialCount,
      required this.currentCount,
      required this.startDate,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['batch_number'] = Variable<String>(batchNumber);
    map['house_name'] = Variable<String>(houseName);
    map['initial_count'] = Variable<int>(initialCount);
    map['current_count'] = Variable<int>(currentCount);
    map['start_date'] = Variable<DateTime>(startDate);
    map['status'] = Variable<String>(status);
    return map;
  }

  LocalPoultryBatchesCompanion toCompanion(bool nullToAbsent) {
    return LocalPoultryBatchesCompanion(
      id: Value(id),
      batchNumber: Value(batchNumber),
      houseName: Value(houseName),
      initialCount: Value(initialCount),
      currentCount: Value(currentCount),
      startDate: Value(startDate),
      status: Value(status),
    );
  }

  factory LocalPoultryBatche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPoultryBatche(
      id: serializer.fromJson<String>(json['id']),
      batchNumber: serializer.fromJson<String>(json['batchNumber']),
      houseName: serializer.fromJson<String>(json['houseName']),
      initialCount: serializer.fromJson<int>(json['initialCount']),
      currentCount: serializer.fromJson<int>(json['currentCount']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchNumber': serializer.toJson<String>(batchNumber),
      'houseName': serializer.toJson<String>(houseName),
      'initialCount': serializer.toJson<int>(initialCount),
      'currentCount': serializer.toJson<int>(currentCount),
      'startDate': serializer.toJson<DateTime>(startDate),
      'status': serializer.toJson<String>(status),
    };
  }

  LocalPoultryBatche copyWith(
          {String? id,
          String? batchNumber,
          String? houseName,
          int? initialCount,
          int? currentCount,
          DateTime? startDate,
          String? status}) =>
      LocalPoultryBatche(
        id: id ?? this.id,
        batchNumber: batchNumber ?? this.batchNumber,
        houseName: houseName ?? this.houseName,
        initialCount: initialCount ?? this.initialCount,
        currentCount: currentCount ?? this.currentCount,
        startDate: startDate ?? this.startDate,
        status: status ?? this.status,
      );
  LocalPoultryBatche copyWithCompanion(LocalPoultryBatchesCompanion data) {
    return LocalPoultryBatche(
      id: data.id.present ? data.id.value : this.id,
      batchNumber:
          data.batchNumber.present ? data.batchNumber.value : this.batchNumber,
      houseName: data.houseName.present ? data.houseName.value : this.houseName,
      initialCount: data.initialCount.present
          ? data.initialCount.value
          : this.initialCount,
      currentCount: data.currentCount.present
          ? data.currentCount.value
          : this.currentCount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPoultryBatche(')
          ..write('id: $id, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('houseName: $houseName, ')
          ..write('initialCount: $initialCount, ')
          ..write('currentCount: $currentCount, ')
          ..write('startDate: $startDate, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, batchNumber, houseName, initialCount,
      currentCount, startDate, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPoultryBatche &&
          other.id == this.id &&
          other.batchNumber == this.batchNumber &&
          other.houseName == this.houseName &&
          other.initialCount == this.initialCount &&
          other.currentCount == this.currentCount &&
          other.startDate == this.startDate &&
          other.status == this.status);
}

class LocalPoultryBatchesCompanion extends UpdateCompanion<LocalPoultryBatche> {
  final Value<String> id;
  final Value<String> batchNumber;
  final Value<String> houseName;
  final Value<int> initialCount;
  final Value<int> currentCount;
  final Value<DateTime> startDate;
  final Value<String> status;
  final Value<int> rowid;
  const LocalPoultryBatchesCompanion({
    this.id = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.houseName = const Value.absent(),
    this.initialCount = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPoultryBatchesCompanion.insert({
    required String id,
    required String batchNumber,
    required String houseName,
    required int initialCount,
    required int currentCount,
    required DateTime startDate,
    required String status,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        batchNumber = Value(batchNumber),
        houseName = Value(houseName),
        initialCount = Value(initialCount),
        currentCount = Value(currentCount),
        startDate = Value(startDate),
        status = Value(status);
  static Insertable<LocalPoultryBatche> custom({
    Expression<String>? id,
    Expression<String>? batchNumber,
    Expression<String>? houseName,
    Expression<int>? initialCount,
    Expression<int>? currentCount,
    Expression<DateTime>? startDate,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (houseName != null) 'house_name': houseName,
      if (initialCount != null) 'initial_count': initialCount,
      if (currentCount != null) 'current_count': currentCount,
      if (startDate != null) 'start_date': startDate,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPoultryBatchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? batchNumber,
      Value<String>? houseName,
      Value<int>? initialCount,
      Value<int>? currentCount,
      Value<DateTime>? startDate,
      Value<String>? status,
      Value<int>? rowid}) {
    return LocalPoultryBatchesCompanion(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      houseName: houseName ?? this.houseName,
      initialCount: initialCount ?? this.initialCount,
      currentCount: currentCount ?? this.currentCount,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (houseName.present) {
      map['house_name'] = Variable<String>(houseName.value);
    }
    if (initialCount.present) {
      map['initial_count'] = Variable<int>(initialCount.value);
    }
    if (currentCount.present) {
      map['current_count'] = Variable<int>(currentCount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPoultryBatchesCompanion(')
          ..write('id: $id, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('houseName: $houseName, ')
          ..write('initialCount: $initialCount, ')
          ..write('currentCount: $currentCount, ')
          ..write('startDate: $startDate, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPoultryLogsTable extends LocalPoultryLogs
    with TableInfo<$LocalPoultryLogsTable, LocalPoultryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPoultryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _batchIdMeta =
      const VerificationMeta('batchId');
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
      'batch_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _logDateMeta =
      const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
      'log_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _feedBagsMeta =
      const VerificationMeta('feedBags');
  @override
  late final GeneratedColumn<int> feedBags = GeneratedColumn<int>(
      'feed_bags', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _mortalityMeta =
      const VerificationMeta('mortality');
  @override
  late final GeneratedColumn<int> mortality = GeneratedColumn<int>(
      'mortality', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _averageWeightMeta =
      const VerificationMeta('averageWeight');
  @override
  late final GeneratedColumn<double> averageWeight = GeneratedColumn<double>(
      'average_weight', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, batchId, logDate, feedBags, mortality, averageWeight];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_poultry_logs';
  @override
  VerificationContext validateIntegrity(Insertable<LocalPoultryLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(_batchIdMeta,
          batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta));
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta,
          logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('feed_bags')) {
      context.handle(_feedBagsMeta,
          feedBags.isAcceptableOrUnknown(data['feed_bags']!, _feedBagsMeta));
    }
    if (data.containsKey('mortality')) {
      context.handle(_mortalityMeta,
          mortality.isAcceptableOrUnknown(data['mortality']!, _mortalityMeta));
    }
    if (data.containsKey('average_weight')) {
      context.handle(
          _averageWeightMeta,
          averageWeight.isAcceptableOrUnknown(
              data['average_weight']!, _averageWeightMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPoultryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPoultryLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      batchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_id'])!,
      logDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}log_date'])!,
      feedBags: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}feed_bags'])!,
      mortality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mortality'])!,
      averageWeight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}average_weight']),
    );
  }

  @override
  $LocalPoultryLogsTable createAlias(String alias) {
    return $LocalPoultryLogsTable(attachedDatabase, alias);
  }
}

class LocalPoultryLog extends DataClass implements Insertable<LocalPoultryLog> {
  final int id;
  final String batchId;
  final DateTime logDate;
  final int feedBags;
  final int mortality;
  final double? averageWeight;
  const LocalPoultryLog(
      {required this.id,
      required this.batchId,
      required this.logDate,
      required this.feedBags,
      required this.mortality,
      this.averageWeight});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['batch_id'] = Variable<String>(batchId);
    map['log_date'] = Variable<DateTime>(logDate);
    map['feed_bags'] = Variable<int>(feedBags);
    map['mortality'] = Variable<int>(mortality);
    if (!nullToAbsent || averageWeight != null) {
      map['average_weight'] = Variable<double>(averageWeight);
    }
    return map;
  }

  LocalPoultryLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalPoultryLogsCompanion(
      id: Value(id),
      batchId: Value(batchId),
      logDate: Value(logDate),
      feedBags: Value(feedBags),
      mortality: Value(mortality),
      averageWeight: averageWeight == null && nullToAbsent
          ? const Value.absent()
          : Value(averageWeight),
    );
  }

  factory LocalPoultryLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPoultryLog(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<String>(json['batchId']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      feedBags: serializer.fromJson<int>(json['feedBags']),
      mortality: serializer.fromJson<int>(json['mortality']),
      averageWeight: serializer.fromJson<double?>(json['averageWeight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<String>(batchId),
      'logDate': serializer.toJson<DateTime>(logDate),
      'feedBags': serializer.toJson<int>(feedBags),
      'mortality': serializer.toJson<int>(mortality),
      'averageWeight': serializer.toJson<double?>(averageWeight),
    };
  }

  LocalPoultryLog copyWith(
          {int? id,
          String? batchId,
          DateTime? logDate,
          int? feedBags,
          int? mortality,
          Value<double?> averageWeight = const Value.absent()}) =>
      LocalPoultryLog(
        id: id ?? this.id,
        batchId: batchId ?? this.batchId,
        logDate: logDate ?? this.logDate,
        feedBags: feedBags ?? this.feedBags,
        mortality: mortality ?? this.mortality,
        averageWeight:
            averageWeight.present ? averageWeight.value : this.averageWeight,
      );
  LocalPoultryLog copyWithCompanion(LocalPoultryLogsCompanion data) {
    return LocalPoultryLog(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      feedBags: data.feedBags.present ? data.feedBags.value : this.feedBags,
      mortality: data.mortality.present ? data.mortality.value : this.mortality,
      averageWeight: data.averageWeight.present
          ? data.averageWeight.value
          : this.averageWeight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPoultryLog(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('logDate: $logDate, ')
          ..write('feedBags: $feedBags, ')
          ..write('mortality: $mortality, ')
          ..write('averageWeight: $averageWeight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, batchId, logDate, feedBags, mortality, averageWeight);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPoultryLog &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.logDate == this.logDate &&
          other.feedBags == this.feedBags &&
          other.mortality == this.mortality &&
          other.averageWeight == this.averageWeight);
}

class LocalPoultryLogsCompanion extends UpdateCompanion<LocalPoultryLog> {
  final Value<int> id;
  final Value<String> batchId;
  final Value<DateTime> logDate;
  final Value<int> feedBags;
  final Value<int> mortality;
  final Value<double?> averageWeight;
  const LocalPoultryLogsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.logDate = const Value.absent(),
    this.feedBags = const Value.absent(),
    this.mortality = const Value.absent(),
    this.averageWeight = const Value.absent(),
  });
  LocalPoultryLogsCompanion.insert({
    this.id = const Value.absent(),
    required String batchId,
    required DateTime logDate,
    this.feedBags = const Value.absent(),
    this.mortality = const Value.absent(),
    this.averageWeight = const Value.absent(),
  })  : batchId = Value(batchId),
        logDate = Value(logDate);
  static Insertable<LocalPoultryLog> custom({
    Expression<int>? id,
    Expression<String>? batchId,
    Expression<DateTime>? logDate,
    Expression<int>? feedBags,
    Expression<int>? mortality,
    Expression<double>? averageWeight,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (logDate != null) 'log_date': logDate,
      if (feedBags != null) 'feed_bags': feedBags,
      if (mortality != null) 'mortality': mortality,
      if (averageWeight != null) 'average_weight': averageWeight,
    });
  }

  LocalPoultryLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? batchId,
      Value<DateTime>? logDate,
      Value<int>? feedBags,
      Value<int>? mortality,
      Value<double?>? averageWeight}) {
    return LocalPoultryLogsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      logDate: logDate ?? this.logDate,
      feedBags: feedBags ?? this.feedBags,
      mortality: mortality ?? this.mortality,
      averageWeight: averageWeight ?? this.averageWeight,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (feedBags.present) {
      map['feed_bags'] = Variable<int>(feedBags.value);
    }
    if (mortality.present) {
      map['mortality'] = Variable<int>(mortality.value);
    }
    if (averageWeight.present) {
      map['average_weight'] = Variable<double>(averageWeight.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPoultryLogsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('logDate: $logDate, ')
          ..write('feedBags: $feedBags, ')
          ..write('mortality: $mortality, ')
          ..write('averageWeight: $averageWeight')
          ..write(')'))
        .toString();
  }
}

class $LocalAlertsTable extends LocalAlerts
    with TableInfo<$LocalAlertsTable, LocalAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  @override
  late final GeneratedColumn<String> impact = GeneratedColumn<String>(
      'impact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isResolvedMeta =
      const VerificationMeta('isResolved');
  @override
  late final GeneratedColumn<bool> isResolved = GeneratedColumn<bool>(
      'is_resolved', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_resolved" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, severity, message, location, impact, createdAt, isResolved];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_alerts';
  @override
  VerificationContext validateIntegrity(Insertable<LocalAlert> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('impact')) {
      context.handle(_impactMeta,
          impact.isAcceptableOrUnknown(data['impact']!, _impactMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_resolved')) {
      context.handle(
          _isResolvedMeta,
          isResolved.isAcceptableOrUnknown(
              data['is_resolved']!, _isResolvedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAlert(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      impact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}impact']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isResolved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_resolved'])!,
    );
  }

  @override
  $LocalAlertsTable createAlias(String alias) {
    return $LocalAlertsTable(attachedDatabase, alias);
  }
}

class LocalAlert extends DataClass implements Insertable<LocalAlert> {
  final String id;
  final String title;
  final String severity;
  final String message;
  final String? location;
  final String? impact;
  final DateTime createdAt;
  final bool isResolved;
  const LocalAlert(
      {required this.id,
      required this.title,
      required this.severity,
      required this.message,
      this.location,
      this.impact,
      required this.createdAt,
      required this.isResolved});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['severity'] = Variable<String>(severity);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || impact != null) {
      map['impact'] = Variable<String>(impact);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_resolved'] = Variable<bool>(isResolved);
    return map;
  }

  LocalAlertsCompanion toCompanion(bool nullToAbsent) {
    return LocalAlertsCompanion(
      id: Value(id),
      title: Value(title),
      severity: Value(severity),
      message: Value(message),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      impact:
          impact == null && nullToAbsent ? const Value.absent() : Value(impact),
      createdAt: Value(createdAt),
      isResolved: Value(isResolved),
    );
  }

  factory LocalAlert.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAlert(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      severity: serializer.fromJson<String>(json['severity']),
      message: serializer.fromJson<String>(json['message']),
      location: serializer.fromJson<String?>(json['location']),
      impact: serializer.fromJson<String?>(json['impact']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isResolved: serializer.fromJson<bool>(json['isResolved']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'severity': serializer.toJson<String>(severity),
      'message': serializer.toJson<String>(message),
      'location': serializer.toJson<String?>(location),
      'impact': serializer.toJson<String?>(impact),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isResolved': serializer.toJson<bool>(isResolved),
    };
  }

  LocalAlert copyWith(
          {String? id,
          String? title,
          String? severity,
          String? message,
          Value<String?> location = const Value.absent(),
          Value<String?> impact = const Value.absent(),
          DateTime? createdAt,
          bool? isResolved}) =>
      LocalAlert(
        id: id ?? this.id,
        title: title ?? this.title,
        severity: severity ?? this.severity,
        message: message ?? this.message,
        location: location.present ? location.value : this.location,
        impact: impact.present ? impact.value : this.impact,
        createdAt: createdAt ?? this.createdAt,
        isResolved: isResolved ?? this.isResolved,
      );
  LocalAlert copyWithCompanion(LocalAlertsCompanion data) {
    return LocalAlert(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      severity: data.severity.present ? data.severity.value : this.severity,
      message: data.message.present ? data.message.value : this.message,
      location: data.location.present ? data.location.value : this.location,
      impact: data.impact.present ? data.impact.value : this.impact,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isResolved:
          data.isResolved.present ? data.isResolved.value : this.isResolved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlert(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('severity: $severity, ')
          ..write('message: $message, ')
          ..write('location: $location, ')
          ..write('impact: $impact, ')
          ..write('createdAt: $createdAt, ')
          ..write('isResolved: $isResolved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, severity, message, location, impact, createdAt, isResolved);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAlert &&
          other.id == this.id &&
          other.title == this.title &&
          other.severity == this.severity &&
          other.message == this.message &&
          other.location == this.location &&
          other.impact == this.impact &&
          other.createdAt == this.createdAt &&
          other.isResolved == this.isResolved);
}

class LocalAlertsCompanion extends UpdateCompanion<LocalAlert> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> severity;
  final Value<String> message;
  final Value<String?> location;
  final Value<String?> impact;
  final Value<DateTime> createdAt;
  final Value<bool> isResolved;
  final Value<int> rowid;
  const LocalAlertsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.severity = const Value.absent(),
    this.message = const Value.absent(),
    this.location = const Value.absent(),
    this.impact = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAlertsCompanion.insert({
    required String id,
    required String title,
    required String severity,
    required String message,
    this.location = const Value.absent(),
    this.impact = const Value.absent(),
    required DateTime createdAt,
    this.isResolved = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        severity = Value(severity),
        message = Value(message),
        createdAt = Value(createdAt);
  static Insertable<LocalAlert> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? severity,
    Expression<String>? message,
    Expression<String>? location,
    Expression<String>? impact,
    Expression<DateTime>? createdAt,
    Expression<bool>? isResolved,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (severity != null) 'severity': severity,
      if (message != null) 'message': message,
      if (location != null) 'location': location,
      if (impact != null) 'impact': impact,
      if (createdAt != null) 'created_at': createdAt,
      if (isResolved != null) 'is_resolved': isResolved,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAlertsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? severity,
      Value<String>? message,
      Value<String?>? location,
      Value<String?>? impact,
      Value<DateTime>? createdAt,
      Value<bool>? isResolved,
      Value<int>? rowid}) {
    return LocalAlertsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      location: location ?? this.location,
      impact: impact ?? this.impact,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (impact.present) {
      map['impact'] = Variable<String>(impact.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isResolved.present) {
      map['is_resolved'] = Variable<bool>(isResolved.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAlertsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('severity: $severity, ')
          ..write('message: $message, ')
          ..write('location: $location, ')
          ..write('impact: $impact, ')
          ..write('createdAt: $createdAt, ')
          ..write('isResolved: $isResolved, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _endpointMeta =
      const VerificationMeta('endpoint');
  @override
  late final GeneratedColumn<String> endpoint = GeneratedColumn<String>(
      'endpoint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _queuedAtMeta =
      const VerificationMeta('queuedAt');
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
      'queued_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, endpoint, method, body, queuedAt, attempts, lastError];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('endpoint')) {
      context.handle(_endpointMeta,
          endpoint.isAcceptableOrUnknown(data['endpoint']!, _endpointMeta));
    } else if (isInserting) {
      context.missing(_endpointMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('queued_at')) {
      context.handle(_queuedAtMeta,
          queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta));
    } else if (isInserting) {
      context.missing(_queuedAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      endpoint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}endpoint'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      queuedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}queued_at'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String endpoint;
  final String method;
  final String body;
  final DateTime queuedAt;
  final int attempts;
  final String? lastError;
  const SyncQueueData(
      {required this.id,
      required this.endpoint,
      required this.method,
      required this.body,
      required this.queuedAt,
      required this.attempts,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['endpoint'] = Variable<String>(endpoint);
    map['method'] = Variable<String>(method);
    map['body'] = Variable<String>(body);
    map['queued_at'] = Variable<DateTime>(queuedAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      endpoint: Value(endpoint),
      method: Value(method),
      body: Value(body),
      queuedAt: Value(queuedAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      endpoint: serializer.fromJson<String>(json['endpoint']),
      method: serializer.fromJson<String>(json['method']),
      body: serializer.fromJson<String>(json['body']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'endpoint': serializer.toJson<String>(endpoint),
      'method': serializer.toJson<String>(method),
      'body': serializer.toJson<String>(body),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? endpoint,
          String? method,
          String? body,
          DateTime? queuedAt,
          int? attempts,
          Value<String?> lastError = const Value.absent()}) =>
      SyncQueueData(
        id: id ?? this.id,
        endpoint: endpoint ?? this.endpoint,
        method: method ?? this.method,
        body: body ?? this.body,
        queuedAt: queuedAt ?? this.queuedAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      endpoint: data.endpoint.present ? data.endpoint.value : this.endpoint,
      method: data.method.present ? data.method.value : this.method,
      body: data.body.present ? data.body.value : this.body,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('endpoint: $endpoint, ')
          ..write('method: $method, ')
          ..write('body: $body, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, endpoint, method, body, queuedAt, attempts, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.endpoint == this.endpoint &&
          other.method == this.method &&
          other.body == this.body &&
          other.queuedAt == this.queuedAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> endpoint;
  final Value<String> method;
  final Value<String> body;
  final Value<DateTime> queuedAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.endpoint = const Value.absent(),
    this.method = const Value.absent(),
    this.body = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String endpoint,
    required String method,
    required String body,
    required DateTime queuedAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : endpoint = Value(endpoint),
        method = Value(method),
        body = Value(body),
        queuedAt = Value(queuedAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? endpoint,
    Expression<String>? method,
    Expression<String>? body,
    Expression<DateTime>? queuedAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (endpoint != null) 'endpoint': endpoint,
      if (method != null) 'method': method,
      if (body != null) 'body': body,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? endpoint,
      Value<String>? method,
      Value<String>? body,
      Value<DateTime>? queuedAt,
      Value<int>? attempts,
      Value<String?>? lastError}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      endpoint: endpoint ?? this.endpoint,
      method: method ?? this.method,
      body: body ?? this.body,
      queuedAt: queuedAt ?? this.queuedAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (endpoint.present) {
      map['endpoint'] = Variable<String>(endpoint.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('endpoint: $endpoint, ')
          ..write('method: $method, ')
          ..write('body: $body, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $LocalAnimalsTable localAnimals = $LocalAnimalsTable(this);
  late final $LocalMilkRecordsTable localMilkRecords =
      $LocalMilkRecordsTable(this);
  late final $LocalTransactionsTable localTransactions =
      $LocalTransactionsTable(this);
  late final $LocalTasksTable localTasks = $LocalTasksTable(this);
  late final $LocalPoultryBatchesTable localPoultryBatches =
      $LocalPoultryBatchesTable(this);
  late final $LocalPoultryLogsTable localPoultryLogs =
      $LocalPoultryLogsTable(this);
  late final $LocalAlertsTable localAlerts = $LocalAlertsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        localAnimals,
        localMilkRecords,
        localTransactions,
        localTasks,
        localPoultryBatches,
        localPoultryLogs,
        localAlerts,
        syncQueue
      ];
}

typedef $$LocalAnimalsTableCreateCompanionBuilder = LocalAnimalsCompanion
    Function({
  required String id,
  required String tagId,
  required String species,
  Value<String?> breed,
  required String sex,
  required DateTime dateOfBirth,
  Value<String?> locationId,
  required String currentReproductiveStatus,
  Value<double> acquisitionCost,
  Value<double> salvageValue,
  Value<String?> imagePath,
  Value<double?> weight,
  Value<String?> color,
  Value<String?> uniqueMarks,
  Value<String?> pedigreeType,
  Value<String?> purpose,
  Value<String?> vaccinationStatus,
  Value<String> status,
  Value<int> rowid,
});
typedef $$LocalAnimalsTableUpdateCompanionBuilder = LocalAnimalsCompanion
    Function({
  Value<String> id,
  Value<String> tagId,
  Value<String> species,
  Value<String?> breed,
  Value<String> sex,
  Value<DateTime> dateOfBirth,
  Value<String?> locationId,
  Value<String> currentReproductiveStatus,
  Value<double> acquisitionCost,
  Value<double> salvageValue,
  Value<String?> imagePath,
  Value<double?> weight,
  Value<String?> color,
  Value<String?> uniqueMarks,
  Value<String?> pedigreeType,
  Value<String?> purpose,
  Value<String?> vaccinationStatus,
  Value<String> status,
  Value<int> rowid,
});

class $$LocalAnimalsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalAnimalsTable> {
  $$LocalAnimalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currentReproductiveStatus => $composableBuilder(
      column: $table.currentReproductiveStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get acquisitionCost => $composableBuilder(
      column: $table.acquisitionCost,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salvageValue => $composableBuilder(
      column: $table.salvageValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uniqueMarks => $composableBuilder(
      column: $table.uniqueMarks, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pedigreeType => $composableBuilder(
      column: $table.pedigreeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vaccinationStatus => $composableBuilder(
      column: $table.vaccinationStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$LocalAnimalsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalAnimalsTable> {
  $$LocalAnimalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currentReproductiveStatus => $composableBuilder(
      column: $table.currentReproductiveStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get acquisitionCost => $composableBuilder(
      column: $table.acquisitionCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salvageValue => $composableBuilder(
      column: $table.salvageValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uniqueMarks => $composableBuilder(
      column: $table.uniqueMarks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pedigreeType => $composableBuilder(
      column: $table.pedigreeType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vaccinationStatus => $composableBuilder(
      column: $table.vaccinationStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$LocalAnimalsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalAnimalsTable> {
  $$LocalAnimalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);

  GeneratedColumn<String> get currentReproductiveStatus => $composableBuilder(
      column: $table.currentReproductiveStatus, builder: (column) => column);

  GeneratedColumn<double> get acquisitionCost => $composableBuilder(
      column: $table.acquisitionCost, builder: (column) => column);

  GeneratedColumn<double> get salvageValue => $composableBuilder(
      column: $table.salvageValue, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get uniqueMarks => $composableBuilder(
      column: $table.uniqueMarks, builder: (column) => column);

  GeneratedColumn<String> get pedigreeType => $composableBuilder(
      column: $table.pedigreeType, builder: (column) => column);

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get vaccinationStatus => $composableBuilder(
      column: $table.vaccinationStatus, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$LocalAnimalsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalAnimalsTable,
    LocalAnimal,
    $$LocalAnimalsTableFilterComposer,
    $$LocalAnimalsTableOrderingComposer,
    $$LocalAnimalsTableAnnotationComposer,
    $$LocalAnimalsTableCreateCompanionBuilder,
    $$LocalAnimalsTableUpdateCompanionBuilder,
    (
      LocalAnimal,
      BaseReferences<_$LocalDatabase, $LocalAnimalsTable, LocalAnimal>
    ),
    LocalAnimal,
    PrefetchHooks Function()> {
  $$LocalAnimalsTableTableManager(_$LocalDatabase db, $LocalAnimalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnimalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnimalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAnimalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<String> species = const Value.absent(),
            Value<String?> breed = const Value.absent(),
            Value<String> sex = const Value.absent(),
            Value<DateTime> dateOfBirth = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<String> currentReproductiveStatus = const Value.absent(),
            Value<double> acquisitionCost = const Value.absent(),
            Value<double> salvageValue = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> uniqueMarks = const Value.absent(),
            Value<String?> pedigreeType = const Value.absent(),
            Value<String?> purpose = const Value.absent(),
            Value<String?> vaccinationStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAnimalsCompanion(
            id: id,
            tagId: tagId,
            species: species,
            breed: breed,
            sex: sex,
            dateOfBirth: dateOfBirth,
            locationId: locationId,
            currentReproductiveStatus: currentReproductiveStatus,
            acquisitionCost: acquisitionCost,
            salvageValue: salvageValue,
            imagePath: imagePath,
            weight: weight,
            color: color,
            uniqueMarks: uniqueMarks,
            pedigreeType: pedigreeType,
            purpose: purpose,
            vaccinationStatus: vaccinationStatus,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tagId,
            required String species,
            Value<String?> breed = const Value.absent(),
            required String sex,
            required DateTime dateOfBirth,
            Value<String?> locationId = const Value.absent(),
            required String currentReproductiveStatus,
            Value<double> acquisitionCost = const Value.absent(),
            Value<double> salvageValue = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<double?> weight = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<String?> uniqueMarks = const Value.absent(),
            Value<String?> pedigreeType = const Value.absent(),
            Value<String?> purpose = const Value.absent(),
            Value<String?> vaccinationStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAnimalsCompanion.insert(
            id: id,
            tagId: tagId,
            species: species,
            breed: breed,
            sex: sex,
            dateOfBirth: dateOfBirth,
            locationId: locationId,
            currentReproductiveStatus: currentReproductiveStatus,
            acquisitionCost: acquisitionCost,
            salvageValue: salvageValue,
            imagePath: imagePath,
            weight: weight,
            color: color,
            uniqueMarks: uniqueMarks,
            pedigreeType: pedigreeType,
            purpose: purpose,
            vaccinationStatus: vaccinationStatus,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalAnimalsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalAnimalsTable,
    LocalAnimal,
    $$LocalAnimalsTableFilterComposer,
    $$LocalAnimalsTableOrderingComposer,
    $$LocalAnimalsTableAnnotationComposer,
    $$LocalAnimalsTableCreateCompanionBuilder,
    $$LocalAnimalsTableUpdateCompanionBuilder,
    (
      LocalAnimal,
      BaseReferences<_$LocalDatabase, $LocalAnimalsTable, LocalAnimal>
    ),
    LocalAnimal,
    PrefetchHooks Function()>;
typedef $$LocalMilkRecordsTableCreateCompanionBuilder
    = LocalMilkRecordsCompanion Function({
  required String id,
  required String animalId,
  required DateTime recordDate,
  required String milkingSession,
  required double quantityLiters,
  Value<bool> isWithdrawn,
  Value<int> rowid,
});
typedef $$LocalMilkRecordsTableUpdateCompanionBuilder
    = LocalMilkRecordsCompanion Function({
  Value<String> id,
  Value<String> animalId,
  Value<DateTime> recordDate,
  Value<String> milkingSession,
  Value<double> quantityLiters,
  Value<bool> isWithdrawn,
  Value<int> rowid,
});

class $$LocalMilkRecordsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalMilkRecordsTable> {
  $$LocalMilkRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get milkingSession => $composableBuilder(
      column: $table.milkingSession,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityLiters => $composableBuilder(
      column: $table.quantityLiters,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isWithdrawn => $composableBuilder(
      column: $table.isWithdrawn, builder: (column) => ColumnFilters(column));
}

class $$LocalMilkRecordsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalMilkRecordsTable> {
  $$LocalMilkRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get animalId => $composableBuilder(
      column: $table.animalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get milkingSession => $composableBuilder(
      column: $table.milkingSession,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityLiters => $composableBuilder(
      column: $table.quantityLiters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isWithdrawn => $composableBuilder(
      column: $table.isWithdrawn, builder: (column) => ColumnOrderings(column));
}

class $$LocalMilkRecordsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalMilkRecordsTable> {
  $$LocalMilkRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get animalId =>
      $composableBuilder(column: $table.animalId, builder: (column) => column);

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => column);

  GeneratedColumn<String> get milkingSession => $composableBuilder(
      column: $table.milkingSession, builder: (column) => column);

  GeneratedColumn<double> get quantityLiters => $composableBuilder(
      column: $table.quantityLiters, builder: (column) => column);

  GeneratedColumn<bool> get isWithdrawn => $composableBuilder(
      column: $table.isWithdrawn, builder: (column) => column);
}

class $$LocalMilkRecordsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalMilkRecordsTable,
    LocalMilkRecord,
    $$LocalMilkRecordsTableFilterComposer,
    $$LocalMilkRecordsTableOrderingComposer,
    $$LocalMilkRecordsTableAnnotationComposer,
    $$LocalMilkRecordsTableCreateCompanionBuilder,
    $$LocalMilkRecordsTableUpdateCompanionBuilder,
    (
      LocalMilkRecord,
      BaseReferences<_$LocalDatabase, $LocalMilkRecordsTable, LocalMilkRecord>
    ),
    LocalMilkRecord,
    PrefetchHooks Function()> {
  $$LocalMilkRecordsTableTableManager(
      _$LocalDatabase db, $LocalMilkRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMilkRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMilkRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMilkRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<DateTime> recordDate = const Value.absent(),
            Value<String> milkingSession = const Value.absent(),
            Value<double> quantityLiters = const Value.absent(),
            Value<bool> isWithdrawn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMilkRecordsCompanion(
            id: id,
            animalId: animalId,
            recordDate: recordDate,
            milkingSession: milkingSession,
            quantityLiters: quantityLiters,
            isWithdrawn: isWithdrawn,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required DateTime recordDate,
            required String milkingSession,
            required double quantityLiters,
            Value<bool> isWithdrawn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMilkRecordsCompanion.insert(
            id: id,
            animalId: animalId,
            recordDate: recordDate,
            milkingSession: milkingSession,
            quantityLiters: quantityLiters,
            isWithdrawn: isWithdrawn,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMilkRecordsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalMilkRecordsTable,
    LocalMilkRecord,
    $$LocalMilkRecordsTableFilterComposer,
    $$LocalMilkRecordsTableOrderingComposer,
    $$LocalMilkRecordsTableAnnotationComposer,
    $$LocalMilkRecordsTableCreateCompanionBuilder,
    $$LocalMilkRecordsTableUpdateCompanionBuilder,
    (
      LocalMilkRecord,
      BaseReferences<_$LocalDatabase, $LocalMilkRecordsTable, LocalMilkRecord>
    ),
    LocalMilkRecord,
    PrefetchHooks Function()>;
typedef $$LocalTransactionsTableCreateCompanionBuilder
    = LocalTransactionsCompanion Function({
  required String id,
  required String transactionType,
  required String category,
  required double amount,
  Value<String> currency,
  Value<String?> relatedEntityType,
  Value<String?> relatedEntityId,
  Value<String?> description,
  required DateTime transactionDate,
  Value<bool> isReconciled,
  Value<String?> reversalOf,
  Value<int> rowid,
});
typedef $$LocalTransactionsTableUpdateCompanionBuilder
    = LocalTransactionsCompanion Function({
  Value<String> id,
  Value<String> transactionType,
  Value<String> category,
  Value<double> amount,
  Value<String> currency,
  Value<String?> relatedEntityType,
  Value<String?> relatedEntityId,
  Value<String?> description,
  Value<DateTime> transactionDate,
  Value<bool> isReconciled,
  Value<String?> reversalOf,
  Value<int> rowid,
});

class $$LocalTransactionsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedEntityType => $composableBuilder(
      column: $table.relatedEntityType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedEntityId => $composableBuilder(
      column: $table.relatedEntityId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isReconciled => $composableBuilder(
      column: $table.isReconciled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reversalOf => $composableBuilder(
      column: $table.reversalOf, builder: (column) => ColumnFilters(column));
}

class $$LocalTransactionsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transactionType => $composableBuilder(
      column: $table.transactionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedEntityType => $composableBuilder(
      column: $table.relatedEntityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedEntityId => $composableBuilder(
      column: $table.relatedEntityId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isReconciled => $composableBuilder(
      column: $table.isReconciled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reversalOf => $composableBuilder(
      column: $table.reversalOf, builder: (column) => ColumnOrderings(column));
}

class $$LocalTransactionsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
      column: $table.transactionType, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get relatedEntityType => $composableBuilder(
      column: $table.relatedEntityType, builder: (column) => column);

  GeneratedColumn<String> get relatedEntityId => $composableBuilder(
      column: $table.relatedEntityId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
      column: $table.transactionDate, builder: (column) => column);

  GeneratedColumn<bool> get isReconciled => $composableBuilder(
      column: $table.isReconciled, builder: (column) => column);

  GeneratedColumn<String> get reversalOf => $composableBuilder(
      column: $table.reversalOf, builder: (column) => column);
}

class $$LocalTransactionsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalTransactionsTable,
    LocalTransaction,
    $$LocalTransactionsTableFilterComposer,
    $$LocalTransactionsTableOrderingComposer,
    $$LocalTransactionsTableAnnotationComposer,
    $$LocalTransactionsTableCreateCompanionBuilder,
    $$LocalTransactionsTableUpdateCompanionBuilder,
    (
      LocalTransaction,
      BaseReferences<_$LocalDatabase, $LocalTransactionsTable, LocalTransaction>
    ),
    LocalTransaction,
    PrefetchHooks Function()> {
  $$LocalTransactionsTableTableManager(
      _$LocalDatabase db, $LocalTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> transactionType = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> relatedEntityType = const Value.absent(),
            Value<String?> relatedEntityId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> transactionDate = const Value.absent(),
            Value<bool> isReconciled = const Value.absent(),
            Value<String?> reversalOf = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTransactionsCompanion(
            id: id,
            transactionType: transactionType,
            category: category,
            amount: amount,
            currency: currency,
            relatedEntityType: relatedEntityType,
            relatedEntityId: relatedEntityId,
            description: description,
            transactionDate: transactionDate,
            isReconciled: isReconciled,
            reversalOf: reversalOf,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String transactionType,
            required String category,
            required double amount,
            Value<String> currency = const Value.absent(),
            Value<String?> relatedEntityType = const Value.absent(),
            Value<String?> relatedEntityId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            required DateTime transactionDate,
            Value<bool> isReconciled = const Value.absent(),
            Value<String?> reversalOf = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTransactionsCompanion.insert(
            id: id,
            transactionType: transactionType,
            category: category,
            amount: amount,
            currency: currency,
            relatedEntityType: relatedEntityType,
            relatedEntityId: relatedEntityId,
            description: description,
            transactionDate: transactionDate,
            isReconciled: isReconciled,
            reversalOf: reversalOf,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalTransactionsTable,
    LocalTransaction,
    $$LocalTransactionsTableFilterComposer,
    $$LocalTransactionsTableOrderingComposer,
    $$LocalTransactionsTableAnnotationComposer,
    $$LocalTransactionsTableCreateCompanionBuilder,
    $$LocalTransactionsTableUpdateCompanionBuilder,
    (
      LocalTransaction,
      BaseReferences<_$LocalDatabase, $LocalTransactionsTable, LocalTransaction>
    ),
    LocalTransaction,
    PrefetchHooks Function()>;
typedef $$LocalTasksTableCreateCompanionBuilder = LocalTasksCompanion Function({
  required String id,
  required String title,
  Value<String?> description,
  required String priority,
  required String status,
  Value<String?> assignedTo,
  Value<DateTime?> dueDate,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$LocalTasksTableUpdateCompanionBuilder = LocalTasksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<String> priority,
  Value<String> status,
  Value<String?> assignedTo,
  Value<DateTime?> dueDate,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$LocalTasksTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalTasksTable> {
  $$LocalTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assignedTo => $composableBuilder(
      column: $table.assignedTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalTasksTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalTasksTable> {
  $$LocalTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assignedTo => $composableBuilder(
      column: $table.assignedTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalTasksTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalTasksTable> {
  $$LocalTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get assignedTo => $composableBuilder(
      column: $table.assignedTo, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$LocalTasksTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalTasksTable,
    LocalTask,
    $$LocalTasksTableFilterComposer,
    $$LocalTasksTableOrderingComposer,
    $$LocalTasksTableAnnotationComposer,
    $$LocalTasksTableCreateCompanionBuilder,
    $$LocalTasksTableUpdateCompanionBuilder,
    (LocalTask, BaseReferences<_$LocalDatabase, $LocalTasksTable, LocalTask>),
    LocalTask,
    PrefetchHooks Function()> {
  $$LocalTasksTableTableManager(_$LocalDatabase db, $LocalTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> assignedTo = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTasksCompanion(
            id: id,
            title: title,
            description: description,
            priority: priority,
            status: status,
            assignedTo: assignedTo,
            dueDate: dueDate,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> description = const Value.absent(),
            required String priority,
            required String status,
            Value<String?> assignedTo = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalTasksCompanion.insert(
            id: id,
            title: title,
            description: description,
            priority: priority,
            status: status,
            assignedTo: assignedTo,
            dueDate: dueDate,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalTasksTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalTasksTable,
    LocalTask,
    $$LocalTasksTableFilterComposer,
    $$LocalTasksTableOrderingComposer,
    $$LocalTasksTableAnnotationComposer,
    $$LocalTasksTableCreateCompanionBuilder,
    $$LocalTasksTableUpdateCompanionBuilder,
    (LocalTask, BaseReferences<_$LocalDatabase, $LocalTasksTable, LocalTask>),
    LocalTask,
    PrefetchHooks Function()>;
typedef $$LocalPoultryBatchesTableCreateCompanionBuilder
    = LocalPoultryBatchesCompanion Function({
  required String id,
  required String batchNumber,
  required String houseName,
  required int initialCount,
  required int currentCount,
  required DateTime startDate,
  required String status,
  Value<int> rowid,
});
typedef $$LocalPoultryBatchesTableUpdateCompanionBuilder
    = LocalPoultryBatchesCompanion Function({
  Value<String> id,
  Value<String> batchNumber,
  Value<String> houseName,
  Value<int> initialCount,
  Value<int> currentCount,
  Value<DateTime> startDate,
  Value<String> status,
  Value<int> rowid,
});

class $$LocalPoultryBatchesTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalPoultryBatchesTable> {
  $$LocalPoultryBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get houseName => $composableBuilder(
      column: $table.houseName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get initialCount => $composableBuilder(
      column: $table.initialCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentCount => $composableBuilder(
      column: $table.currentCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$LocalPoultryBatchesTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalPoultryBatchesTable> {
  $$LocalPoultryBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get houseName => $composableBuilder(
      column: $table.houseName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get initialCount => $composableBuilder(
      column: $table.initialCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentCount => $composableBuilder(
      column: $table.currentCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$LocalPoultryBatchesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalPoultryBatchesTable> {
  $$LocalPoultryBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => column);

  GeneratedColumn<String> get houseName =>
      $composableBuilder(column: $table.houseName, builder: (column) => column);

  GeneratedColumn<int> get initialCount => $composableBuilder(
      column: $table.initialCount, builder: (column) => column);

  GeneratedColumn<int> get currentCount => $composableBuilder(
      column: $table.currentCount, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$LocalPoultryBatchesTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalPoultryBatchesTable,
    LocalPoultryBatche,
    $$LocalPoultryBatchesTableFilterComposer,
    $$LocalPoultryBatchesTableOrderingComposer,
    $$LocalPoultryBatchesTableAnnotationComposer,
    $$LocalPoultryBatchesTableCreateCompanionBuilder,
    $$LocalPoultryBatchesTableUpdateCompanionBuilder,
    (
      LocalPoultryBatche,
      BaseReferences<_$LocalDatabase, $LocalPoultryBatchesTable,
          LocalPoultryBatche>
    ),
    LocalPoultryBatche,
    PrefetchHooks Function()> {
  $$LocalPoultryBatchesTableTableManager(
      _$LocalDatabase db, $LocalPoultryBatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPoultryBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPoultryBatchesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPoultryBatchesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> batchNumber = const Value.absent(),
            Value<String> houseName = const Value.absent(),
            Value<int> initialCount = const Value.absent(),
            Value<int> currentCount = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPoultryBatchesCompanion(
            id: id,
            batchNumber: batchNumber,
            houseName: houseName,
            initialCount: initialCount,
            currentCount: currentCount,
            startDate: startDate,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String batchNumber,
            required String houseName,
            required int initialCount,
            required int currentCount,
            required DateTime startDate,
            required String status,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalPoultryBatchesCompanion.insert(
            id: id,
            batchNumber: batchNumber,
            houseName: houseName,
            initialCount: initialCount,
            currentCount: currentCount,
            startDate: startDate,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalPoultryBatchesTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalPoultryBatchesTable,
    LocalPoultryBatche,
    $$LocalPoultryBatchesTableFilterComposer,
    $$LocalPoultryBatchesTableOrderingComposer,
    $$LocalPoultryBatchesTableAnnotationComposer,
    $$LocalPoultryBatchesTableCreateCompanionBuilder,
    $$LocalPoultryBatchesTableUpdateCompanionBuilder,
    (
      LocalPoultryBatche,
      BaseReferences<_$LocalDatabase, $LocalPoultryBatchesTable,
          LocalPoultryBatche>
    ),
    LocalPoultryBatche,
    PrefetchHooks Function()>;
typedef $$LocalPoultryLogsTableCreateCompanionBuilder
    = LocalPoultryLogsCompanion Function({
  Value<int> id,
  required String batchId,
  required DateTime logDate,
  Value<int> feedBags,
  Value<int> mortality,
  Value<double?> averageWeight,
});
typedef $$LocalPoultryLogsTableUpdateCompanionBuilder
    = LocalPoultryLogsCompanion Function({
  Value<int> id,
  Value<String> batchId,
  Value<DateTime> logDate,
  Value<int> feedBags,
  Value<int> mortality,
  Value<double?> averageWeight,
});

class $$LocalPoultryLogsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalPoultryLogsTable> {
  $$LocalPoultryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get feedBags => $composableBuilder(
      column: $table.feedBags, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mortality => $composableBuilder(
      column: $table.mortality, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageWeight => $composableBuilder(
      column: $table.averageWeight, builder: (column) => ColumnFilters(column));
}

class $$LocalPoultryLogsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalPoultryLogsTable> {
  $$LocalPoultryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get feedBags => $composableBuilder(
      column: $table.feedBags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mortality => $composableBuilder(
      column: $table.mortality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageWeight => $composableBuilder(
      column: $table.averageWeight,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalPoultryLogsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalPoultryLogsTable> {
  $$LocalPoultryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<int> get feedBags =>
      $composableBuilder(column: $table.feedBags, builder: (column) => column);

  GeneratedColumn<int> get mortality =>
      $composableBuilder(column: $table.mortality, builder: (column) => column);

  GeneratedColumn<double> get averageWeight => $composableBuilder(
      column: $table.averageWeight, builder: (column) => column);
}

class $$LocalPoultryLogsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalPoultryLogsTable,
    LocalPoultryLog,
    $$LocalPoultryLogsTableFilterComposer,
    $$LocalPoultryLogsTableOrderingComposer,
    $$LocalPoultryLogsTableAnnotationComposer,
    $$LocalPoultryLogsTableCreateCompanionBuilder,
    $$LocalPoultryLogsTableUpdateCompanionBuilder,
    (
      LocalPoultryLog,
      BaseReferences<_$LocalDatabase, $LocalPoultryLogsTable, LocalPoultryLog>
    ),
    LocalPoultryLog,
    PrefetchHooks Function()> {
  $$LocalPoultryLogsTableTableManager(
      _$LocalDatabase db, $LocalPoultryLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPoultryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPoultryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPoultryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> batchId = const Value.absent(),
            Value<DateTime> logDate = const Value.absent(),
            Value<int> feedBags = const Value.absent(),
            Value<int> mortality = const Value.absent(),
            Value<double?> averageWeight = const Value.absent(),
          }) =>
              LocalPoultryLogsCompanion(
            id: id,
            batchId: batchId,
            logDate: logDate,
            feedBags: feedBags,
            mortality: mortality,
            averageWeight: averageWeight,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String batchId,
            required DateTime logDate,
            Value<int> feedBags = const Value.absent(),
            Value<int> mortality = const Value.absent(),
            Value<double?> averageWeight = const Value.absent(),
          }) =>
              LocalPoultryLogsCompanion.insert(
            id: id,
            batchId: batchId,
            logDate: logDate,
            feedBags: feedBags,
            mortality: mortality,
            averageWeight: averageWeight,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalPoultryLogsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalPoultryLogsTable,
    LocalPoultryLog,
    $$LocalPoultryLogsTableFilterComposer,
    $$LocalPoultryLogsTableOrderingComposer,
    $$LocalPoultryLogsTableAnnotationComposer,
    $$LocalPoultryLogsTableCreateCompanionBuilder,
    $$LocalPoultryLogsTableUpdateCompanionBuilder,
    (
      LocalPoultryLog,
      BaseReferences<_$LocalDatabase, $LocalPoultryLogsTable, LocalPoultryLog>
    ),
    LocalPoultryLog,
    PrefetchHooks Function()>;
typedef $$LocalAlertsTableCreateCompanionBuilder = LocalAlertsCompanion
    Function({
  required String id,
  required String title,
  required String severity,
  required String message,
  Value<String?> location,
  Value<String?> impact,
  required DateTime createdAt,
  Value<bool> isResolved,
  Value<int> rowid,
});
typedef $$LocalAlertsTableUpdateCompanionBuilder = LocalAlertsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> severity,
  Value<String> message,
  Value<String?> location,
  Value<String?> impact,
  Value<DateTime> createdAt,
  Value<bool> isResolved,
  Value<int> rowid,
});

class $$LocalAlertsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalAlertsTable> {
  $$LocalAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get impact => $composableBuilder(
      column: $table.impact, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnFilters(column));
}

class $$LocalAlertsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalAlertsTable> {
  $$LocalAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get impact => $composableBuilder(
      column: $table.impact, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnOrderings(column));
}

class $$LocalAlertsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalAlertsTable> {
  $$LocalAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get impact =>
      $composableBuilder(column: $table.impact, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => column);
}

class $$LocalAlertsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalAlertsTable,
    LocalAlert,
    $$LocalAlertsTableFilterComposer,
    $$LocalAlertsTableOrderingComposer,
    $$LocalAlertsTableAnnotationComposer,
    $$LocalAlertsTableCreateCompanionBuilder,
    $$LocalAlertsTableUpdateCompanionBuilder,
    (
      LocalAlert,
      BaseReferences<_$LocalDatabase, $LocalAlertsTable, LocalAlert>
    ),
    LocalAlert,
    PrefetchHooks Function()> {
  $$LocalAlertsTableTableManager(_$LocalDatabase db, $LocalAlertsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> impact = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isResolved = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAlertsCompanion(
            id: id,
            title: title,
            severity: severity,
            message: message,
            location: location,
            impact: impact,
            createdAt: createdAt,
            isResolved: isResolved,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String severity,
            required String message,
            Value<String?> location = const Value.absent(),
            Value<String?> impact = const Value.absent(),
            required DateTime createdAt,
            Value<bool> isResolved = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAlertsCompanion.insert(
            id: id,
            title: title,
            severity: severity,
            message: message,
            location: location,
            impact: impact,
            createdAt: createdAt,
            isResolved: isResolved,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalAlertsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalAlertsTable,
    LocalAlert,
    $$LocalAlertsTableFilterComposer,
    $$LocalAlertsTableOrderingComposer,
    $$LocalAlertsTableAnnotationComposer,
    $$LocalAlertsTableCreateCompanionBuilder,
    $$LocalAlertsTableUpdateCompanionBuilder,
    (
      LocalAlert,
      BaseReferences<_$LocalDatabase, $LocalAlertsTable, LocalAlert>
    ),
    LocalAlert,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String endpoint,
  required String method,
  required String body,
  required DateTime queuedAt,
  Value<int> attempts,
  Value<String?> lastError,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> endpoint,
  Value<String> method,
  Value<String> body,
  Value<DateTime> queuedAt,
  Value<int> attempts,
  Value<String?> lastError,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
      column: $table.queuedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endpoint => $composableBuilder(
      column: $table.endpoint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
      column: $table.queuedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get endpoint =>
      $composableBuilder(column: $table.endpoint, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$LocalDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$LocalDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> endpoint = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<DateTime> queuedAt = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            endpoint: endpoint,
            method: method,
            body: body,
            queuedAt: queuedAt,
            attempts: attempts,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String endpoint,
            required String method,
            required String body,
            required DateTime queuedAt,
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            endpoint: endpoint,
            method: method,
            body: body,
            queuedAt: queuedAt,
            attempts: attempts,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$LocalDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$LocalAnimalsTableTableManager get localAnimals =>
      $$LocalAnimalsTableTableManager(_db, _db.localAnimals);
  $$LocalMilkRecordsTableTableManager get localMilkRecords =>
      $$LocalMilkRecordsTableTableManager(_db, _db.localMilkRecords);
  $$LocalTransactionsTableTableManager get localTransactions =>
      $$LocalTransactionsTableTableManager(_db, _db.localTransactions);
  $$LocalTasksTableTableManager get localTasks =>
      $$LocalTasksTableTableManager(_db, _db.localTasks);
  $$LocalPoultryBatchesTableTableManager get localPoultryBatches =>
      $$LocalPoultryBatchesTableTableManager(_db, _db.localPoultryBatches);
  $$LocalPoultryLogsTableTableManager get localPoultryLogs =>
      $$LocalPoultryLogsTableTableManager(_db, _db.localPoultryLogs);
  $$LocalAlertsTableTableManager get localAlerts =>
      $$LocalAlertsTableTableManager(_db, _db.localAlerts);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
