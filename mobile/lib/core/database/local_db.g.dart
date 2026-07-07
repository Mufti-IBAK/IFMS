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
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
  static const VerificationMeta _dewormingStatusMeta =
      const VerificationMeta('dewormingStatus');
  @override
  late final GeneratedColumn<String> dewormingStatus = GeneratedColumn<String>(
      'deworming_status', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _sireIdMeta = const VerificationMeta('sireId');
  @override
  late final GeneratedColumn<String> sireId = GeneratedColumn<String>(
      'sire_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _damIdMeta = const VerificationMeta('damId');
  @override
  late final GeneratedColumn<String> damId = GeneratedColumn<String>(
      'dam_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        dewormingStatus,
        status,
        sireId,
        damId
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
    if (data.containsKey('deworming_status')) {
      context.handle(
          _dewormingStatusMeta,
          dewormingStatus.isAcceptableOrUnknown(
              data['deworming_status']!, _dewormingStatusMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('sire_id')) {
      context.handle(_sireIdMeta,
          sireId.isAcceptableOrUnknown(data['sire_id']!, _sireIdMeta));
    }
    if (data.containsKey('dam_id')) {
      context.handle(
          _damIdMeta, damId.isAcceptableOrUnknown(data['dam_id']!, _damIdMeta));
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
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
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
      dewormingStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}deworming_status']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      sireId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sire_id']),
      damId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dam_id']),
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
  final DateTime? dateOfBirth;
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
  final String? dewormingStatus;
  final String status;
  final String? sireId;
  final String? damId;
  const LocalAnimal(
      {required this.id,
      required this.tagId,
      required this.species,
      this.breed,
      required this.sex,
      this.dateOfBirth,
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
      this.dewormingStatus,
      required this.status,
      this.sireId,
      this.damId});
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
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
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
    if (!nullToAbsent || dewormingStatus != null) {
      map['deworming_status'] = Variable<String>(dewormingStatus);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || sireId != null) {
      map['sire_id'] = Variable<String>(sireId);
    }
    if (!nullToAbsent || damId != null) {
      map['dam_id'] = Variable<String>(damId);
    }
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
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
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
      dewormingStatus: dewormingStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(dewormingStatus),
      status: Value(status),
      sireId:
          sireId == null && nullToAbsent ? const Value.absent() : Value(sireId),
      damId:
          damId == null && nullToAbsent ? const Value.absent() : Value(damId),
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
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
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
      dewormingStatus: serializer.fromJson<String?>(json['dewormingStatus']),
      status: serializer.fromJson<String>(json['status']),
      sireId: serializer.fromJson<String?>(json['sireId']),
      damId: serializer.fromJson<String?>(json['damId']),
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
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
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
      'dewormingStatus': serializer.toJson<String?>(dewormingStatus),
      'status': serializer.toJson<String>(status),
      'sireId': serializer.toJson<String?>(sireId),
      'damId': serializer.toJson<String?>(damId),
    };
  }

  LocalAnimal copyWith(
          {String? id,
          String? tagId,
          String? species,
          Value<String?> breed = const Value.absent(),
          String? sex,
          Value<DateTime?> dateOfBirth = const Value.absent(),
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
          Value<String?> dewormingStatus = const Value.absent(),
          String? status,
          Value<String?> sireId = const Value.absent(),
          Value<String?> damId = const Value.absent()}) =>
      LocalAnimal(
        id: id ?? this.id,
        tagId: tagId ?? this.tagId,
        species: species ?? this.species,
        breed: breed.present ? breed.value : this.breed,
        sex: sex ?? this.sex,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
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
        dewormingStatus: dewormingStatus.present
            ? dewormingStatus.value
            : this.dewormingStatus,
        status: status ?? this.status,
        sireId: sireId.present ? sireId.value : this.sireId,
        damId: damId.present ? damId.value : this.damId,
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
      dewormingStatus: data.dewormingStatus.present
          ? data.dewormingStatus.value
          : this.dewormingStatus,
      status: data.status.present ? data.status.value : this.status,
      sireId: data.sireId.present ? data.sireId.value : this.sireId,
      damId: data.damId.present ? data.damId.value : this.damId,
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
          ..write('dewormingStatus: $dewormingStatus, ')
          ..write('status: $status, ')
          ..write('sireId: $sireId, ')
          ..write('damId: $damId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
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
        dewormingStatus,
        status,
        sireId,
        damId
      ]);
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
          other.dewormingStatus == this.dewormingStatus &&
          other.status == this.status &&
          other.sireId == this.sireId &&
          other.damId == this.damId);
}

class LocalAnimalsCompanion extends UpdateCompanion<LocalAnimal> {
  final Value<String> id;
  final Value<String> tagId;
  final Value<String> species;
  final Value<String?> breed;
  final Value<String> sex;
  final Value<DateTime?> dateOfBirth;
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
  final Value<String?> dewormingStatus;
  final Value<String> status;
  final Value<String?> sireId;
  final Value<String?> damId;
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
    this.dewormingStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.sireId = const Value.absent(),
    this.damId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnimalsCompanion.insert({
    required String id,
    required String tagId,
    required String species,
    this.breed = const Value.absent(),
    required String sex,
    this.dateOfBirth = const Value.absent(),
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
    this.dewormingStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.sireId = const Value.absent(),
    this.damId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tagId = Value(tagId),
        species = Value(species),
        sex = Value(sex),
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
    Expression<String>? dewormingStatus,
    Expression<String>? status,
    Expression<String>? sireId,
    Expression<String>? damId,
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
      if (dewormingStatus != null) 'deworming_status': dewormingStatus,
      if (status != null) 'status': status,
      if (sireId != null) 'sire_id': sireId,
      if (damId != null) 'dam_id': damId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnimalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tagId,
      Value<String>? species,
      Value<String?>? breed,
      Value<String>? sex,
      Value<DateTime?>? dateOfBirth,
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
      Value<String?>? dewormingStatus,
      Value<String>? status,
      Value<String?>? sireId,
      Value<String?>? damId,
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
      dewormingStatus: dewormingStatus ?? this.dewormingStatus,
      status: status ?? this.status,
      sireId: sireId ?? this.sireId,
      damId: damId ?? this.damId,
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
    if (dewormingStatus.present) {
      map['deworming_status'] = Variable<String>(dewormingStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (sireId.present) {
      map['sire_id'] = Variable<String>(sireId.value);
    }
    if (damId.present) {
      map['dam_id'] = Variable<String>(damId.value);
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
          ..write('dewormingStatus: $dewormingStatus, ')
          ..write('status: $status, ')
          ..write('sireId: $sireId, ')
          ..write('damId: $damId, ')
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
  static const VerificationMeta _fatPercentageMeta =
      const VerificationMeta('fatPercentage');
  @override
  late final GeneratedColumn<double> fatPercentage = GeneratedColumn<double>(
      'fat_percentage', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _proteinPercentageMeta =
      const VerificationMeta('proteinPercentage');
  @override
  late final GeneratedColumn<double> proteinPercentage =
      GeneratedColumn<double>('protein_percentage', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
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
  List<GeneratedColumn> get $columns => [
        id,
        animalId,
        recordDate,
        milkingSession,
        quantityLiters,
        fatPercentage,
        proteinPercentage,
        isWithdrawn
      ];
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
    if (data.containsKey('fat_percentage')) {
      context.handle(
          _fatPercentageMeta,
          fatPercentage.isAcceptableOrUnknown(
              data['fat_percentage']!, _fatPercentageMeta));
    }
    if (data.containsKey('protein_percentage')) {
      context.handle(
          _proteinPercentageMeta,
          proteinPercentage.isAcceptableOrUnknown(
              data['protein_percentage']!, _proteinPercentageMeta));
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
      fatPercentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fat_percentage']),
      proteinPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}protein_percentage']),
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
  final double? fatPercentage;
  final double? proteinPercentage;
  final bool isWithdrawn;
  const LocalMilkRecord(
      {required this.id,
      required this.animalId,
      required this.recordDate,
      required this.milkingSession,
      required this.quantityLiters,
      this.fatPercentage,
      this.proteinPercentage,
      required this.isWithdrawn});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['record_date'] = Variable<DateTime>(recordDate);
    map['milking_session'] = Variable<String>(milkingSession);
    map['quantity_liters'] = Variable<double>(quantityLiters);
    if (!nullToAbsent || fatPercentage != null) {
      map['fat_percentage'] = Variable<double>(fatPercentage);
    }
    if (!nullToAbsent || proteinPercentage != null) {
      map['protein_percentage'] = Variable<double>(proteinPercentage);
    }
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
      fatPercentage: fatPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(fatPercentage),
      proteinPercentage: proteinPercentage == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinPercentage),
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
      fatPercentage: serializer.fromJson<double?>(json['fatPercentage']),
      proteinPercentage:
          serializer.fromJson<double?>(json['proteinPercentage']),
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
      'fatPercentage': serializer.toJson<double?>(fatPercentage),
      'proteinPercentage': serializer.toJson<double?>(proteinPercentage),
      'isWithdrawn': serializer.toJson<bool>(isWithdrawn),
    };
  }

  LocalMilkRecord copyWith(
          {String? id,
          String? animalId,
          DateTime? recordDate,
          String? milkingSession,
          double? quantityLiters,
          Value<double?> fatPercentage = const Value.absent(),
          Value<double?> proteinPercentage = const Value.absent(),
          bool? isWithdrawn}) =>
      LocalMilkRecord(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        recordDate: recordDate ?? this.recordDate,
        milkingSession: milkingSession ?? this.milkingSession,
        quantityLiters: quantityLiters ?? this.quantityLiters,
        fatPercentage:
            fatPercentage.present ? fatPercentage.value : this.fatPercentage,
        proteinPercentage: proteinPercentage.present
            ? proteinPercentage.value
            : this.proteinPercentage,
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
      fatPercentage: data.fatPercentage.present
          ? data.fatPercentage.value
          : this.fatPercentage,
      proteinPercentage: data.proteinPercentage.present
          ? data.proteinPercentage.value
          : this.proteinPercentage,
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
          ..write('fatPercentage: $fatPercentage, ')
          ..write('proteinPercentage: $proteinPercentage, ')
          ..write('isWithdrawn: $isWithdrawn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, animalId, recordDate, milkingSession,
      quantityLiters, fatPercentage, proteinPercentage, isWithdrawn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMilkRecord &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.recordDate == this.recordDate &&
          other.milkingSession == this.milkingSession &&
          other.quantityLiters == this.quantityLiters &&
          other.fatPercentage == this.fatPercentage &&
          other.proteinPercentage == this.proteinPercentage &&
          other.isWithdrawn == this.isWithdrawn);
}

class LocalMilkRecordsCompanion extends UpdateCompanion<LocalMilkRecord> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<DateTime> recordDate;
  final Value<String> milkingSession;
  final Value<double> quantityLiters;
  final Value<double?> fatPercentage;
  final Value<double?> proteinPercentage;
  final Value<bool> isWithdrawn;
  final Value<int> rowid;
  const LocalMilkRecordsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.milkingSession = const Value.absent(),
    this.quantityLiters = const Value.absent(),
    this.fatPercentage = const Value.absent(),
    this.proteinPercentage = const Value.absent(),
    this.isWithdrawn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMilkRecordsCompanion.insert({
    required String id,
    required String animalId,
    required DateTime recordDate,
    required String milkingSession,
    required double quantityLiters,
    this.fatPercentage = const Value.absent(),
    this.proteinPercentage = const Value.absent(),
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
    Expression<double>? fatPercentage,
    Expression<double>? proteinPercentage,
    Expression<bool>? isWithdrawn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (recordDate != null) 'record_date': recordDate,
      if (milkingSession != null) 'milking_session': milkingSession,
      if (quantityLiters != null) 'quantity_liters': quantityLiters,
      if (fatPercentage != null) 'fat_percentage': fatPercentage,
      if (proteinPercentage != null) 'protein_percentage': proteinPercentage,
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
      Value<double?>? fatPercentage,
      Value<double?>? proteinPercentage,
      Value<bool>? isWithdrawn,
      Value<int>? rowid}) {
    return LocalMilkRecordsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      recordDate: recordDate ?? this.recordDate,
      milkingSession: milkingSession ?? this.milkingSession,
      quantityLiters: quantityLiters ?? this.quantityLiters,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      proteinPercentage: proteinPercentage ?? this.proteinPercentage,
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
    if (fatPercentage.present) {
      map['fat_percentage'] = Variable<double>(fatPercentage.value);
    }
    if (proteinPercentage.present) {
      map['protein_percentage'] = Variable<double>(proteinPercentage.value);
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
          ..write('fatPercentage: $fatPercentage, ')
          ..write('proteinPercentage: $proteinPercentage, ')
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
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActionableMeta =
      const VerificationMeta('isActionable');
  @override
  late final GeneratedColumn<bool> isActionable = GeneratedColumn<bool>(
      'is_actionable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_actionable" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        priority,
        status,
        assignedTo,
        dueDate,
        completedAt,
        category,
        isActionable
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
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('is_actionable')) {
      context.handle(
          _isActionableMeta,
          isActionable.isAcceptableOrUnknown(
              data['is_actionable']!, _isActionableMeta));
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
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      isActionable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_actionable'])!,
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
  final String? category;
  final bool isActionable;
  const LocalTask(
      {required this.id,
      required this.title,
      this.description,
      required this.priority,
      required this.status,
      this.assignedTo,
      this.dueDate,
      this.completedAt,
      this.category,
      required this.isActionable});
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
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['is_actionable'] = Variable<bool>(isActionable);
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
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      isActionable: Value(isActionable),
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
      category: serializer.fromJson<String?>(json['category']),
      isActionable: serializer.fromJson<bool>(json['isActionable']),
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
      'category': serializer.toJson<String?>(category),
      'isActionable': serializer.toJson<bool>(isActionable),
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
          Value<DateTime?> completedAt = const Value.absent(),
          Value<String?> category = const Value.absent(),
          bool? isActionable}) =>
      LocalTask(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        assignedTo: assignedTo.present ? assignedTo.value : this.assignedTo,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        category: category.present ? category.value : this.category,
        isActionable: isActionable ?? this.isActionable,
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
      category: data.category.present ? data.category.value : this.category,
      isActionable: data.isActionable.present
          ? data.isActionable.value
          : this.isActionable,
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
          ..write('completedAt: $completedAt, ')
          ..write('category: $category, ')
          ..write('isActionable: $isActionable')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, priority, status,
      assignedTo, dueDate, completedAt, category, isActionable);
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
          other.completedAt == this.completedAt &&
          other.category == this.category &&
          other.isActionable == this.isActionable);
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
  final Value<String?> category;
  final Value<bool> isActionable;
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
    this.category = const Value.absent(),
    this.isActionable = const Value.absent(),
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
    this.category = const Value.absent(),
    this.isActionable = const Value.absent(),
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
    Expression<String>? category,
    Expression<bool>? isActionable,
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
      if (category != null) 'category': category,
      if (isActionable != null) 'is_actionable': isActionable,
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
      Value<String?>? category,
      Value<bool>? isActionable,
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
      category: category ?? this.category,
      isActionable: isActionable ?? this.isActionable,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isActionable.present) {
      map['is_actionable'] = Variable<bool>(isActionable.value);
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
          ..write('category: $category, ')
          ..write('isActionable: $isActionable, ')
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

class $LocalFeedItemsTable extends LocalFeedItems
    with TableInfo<$LocalFeedItemsTable, LocalFeedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFeedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentStockMeta =
      const VerificationMeta('currentStock');
  @override
  late final GeneratedColumn<double> currentStock = GeneratedColumn<double>(
      'current_stock', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _reorderThresholdMeta =
      const VerificationMeta('reorderThreshold');
  @override
  late final GeneratedColumn<double> reorderThreshold = GeneratedColumn<double>(
      'reorder_threshold', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _costPerUnitMeta =
      const VerificationMeta('costPerUnit');
  @override
  late final GeneratedColumn<double> costPerUnit = GeneratedColumn<double>(
      'cost_per_unit', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _weightPerUnitMeta =
      const VerificationMeta('weightPerUnit');
  @override
  late final GeneratedColumn<double> weightPerUnit = GeneratedColumn<double>(
      'weight_per_unit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _costPerKgMeta =
      const VerificationMeta('costPerKg');
  @override
  late final GeneratedColumn<double> costPerKg = GeneratedColumn<double>(
      'cost_per_kg', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _supplierMeta =
      const VerificationMeta('supplier');
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
      'supplier', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        unit,
        currentStock,
        reorderThreshold,
        costPerUnit,
        weightPerUnit,
        costPerKg,
        supplier,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_feed_items';
  @override
  VerificationContext validateIntegrity(Insertable<LocalFeedItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('current_stock')) {
      context.handle(
          _currentStockMeta,
          currentStock.isAcceptableOrUnknown(
              data['current_stock']!, _currentStockMeta));
    } else if (isInserting) {
      context.missing(_currentStockMeta);
    }
    if (data.containsKey('reorder_threshold')) {
      context.handle(
          _reorderThresholdMeta,
          reorderThreshold.isAcceptableOrUnknown(
              data['reorder_threshold']!, _reorderThresholdMeta));
    } else if (isInserting) {
      context.missing(_reorderThresholdMeta);
    }
    if (data.containsKey('cost_per_unit')) {
      context.handle(
          _costPerUnitMeta,
          costPerUnit.isAcceptableOrUnknown(
              data['cost_per_unit']!, _costPerUnitMeta));
    } else if (isInserting) {
      context.missing(_costPerUnitMeta);
    }
    if (data.containsKey('weight_per_unit')) {
      context.handle(
          _weightPerUnitMeta,
          weightPerUnit.isAcceptableOrUnknown(
              data['weight_per_unit']!, _weightPerUnitMeta));
    }
    if (data.containsKey('cost_per_kg')) {
      context.handle(
          _costPerKgMeta,
          costPerKg.isAcceptableOrUnknown(
              data['cost_per_kg']!, _costPerKgMeta));
    }
    if (data.containsKey('supplier')) {
      context.handle(_supplierMeta,
          supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFeedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFeedItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      currentStock: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_stock'])!,
      reorderThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}reorder_threshold'])!,
      costPerUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_per_unit'])!,
      weightPerUnit: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}weight_per_unit'])!,
      costPerKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_per_kg'])!,
      supplier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $LocalFeedItemsTable createAlias(String alias) {
    return $LocalFeedItemsTable(attachedDatabase, alias);
  }
}

class LocalFeedItem extends DataClass implements Insertable<LocalFeedItem> {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double currentStock;
  final double reorderThreshold;
  final double costPerUnit;
  final double weightPerUnit;
  final double costPerKg;
  final String? supplier;
  final bool isActive;
  const LocalFeedItem(
      {required this.id,
      required this.name,
      required this.category,
      required this.unit,
      required this.currentStock,
      required this.reorderThreshold,
      required this.costPerUnit,
      required this.weightPerUnit,
      required this.costPerKg,
      this.supplier,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['unit'] = Variable<String>(unit);
    map['current_stock'] = Variable<double>(currentStock);
    map['reorder_threshold'] = Variable<double>(reorderThreshold);
    map['cost_per_unit'] = Variable<double>(costPerUnit);
    map['weight_per_unit'] = Variable<double>(weightPerUnit);
    map['cost_per_kg'] = Variable<double>(costPerKg);
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LocalFeedItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalFeedItemsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      unit: Value(unit),
      currentStock: Value(currentStock),
      reorderThreshold: Value(reorderThreshold),
      costPerUnit: Value(costPerUnit),
      weightPerUnit: Value(weightPerUnit),
      costPerKg: Value(costPerKg),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      isActive: Value(isActive),
    );
  }

  factory LocalFeedItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFeedItem(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      unit: serializer.fromJson<String>(json['unit']),
      currentStock: serializer.fromJson<double>(json['currentStock']),
      reorderThreshold: serializer.fromJson<double>(json['reorderThreshold']),
      costPerUnit: serializer.fromJson<double>(json['costPerUnit']),
      weightPerUnit: serializer.fromJson<double>(json['weightPerUnit']),
      costPerKg: serializer.fromJson<double>(json['costPerKg']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'unit': serializer.toJson<String>(unit),
      'currentStock': serializer.toJson<double>(currentStock),
      'reorderThreshold': serializer.toJson<double>(reorderThreshold),
      'costPerUnit': serializer.toJson<double>(costPerUnit),
      'weightPerUnit': serializer.toJson<double>(weightPerUnit),
      'costPerKg': serializer.toJson<double>(costPerKg),
      'supplier': serializer.toJson<String?>(supplier),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  LocalFeedItem copyWith(
          {String? id,
          String? name,
          String? category,
          String? unit,
          double? currentStock,
          double? reorderThreshold,
          double? costPerUnit,
          double? weightPerUnit,
          double? costPerKg,
          Value<String?> supplier = const Value.absent(),
          bool? isActive}) =>
      LocalFeedItem(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        unit: unit ?? this.unit,
        currentStock: currentStock ?? this.currentStock,
        reorderThreshold: reorderThreshold ?? this.reorderThreshold,
        costPerUnit: costPerUnit ?? this.costPerUnit,
        weightPerUnit: weightPerUnit ?? this.weightPerUnit,
        costPerKg: costPerKg ?? this.costPerKg,
        supplier: supplier.present ? supplier.value : this.supplier,
        isActive: isActive ?? this.isActive,
      );
  LocalFeedItem copyWithCompanion(LocalFeedItemsCompanion data) {
    return LocalFeedItem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      unit: data.unit.present ? data.unit.value : this.unit,
      currentStock: data.currentStock.present
          ? data.currentStock.value
          : this.currentStock,
      reorderThreshold: data.reorderThreshold.present
          ? data.reorderThreshold.value
          : this.reorderThreshold,
      costPerUnit:
          data.costPerUnit.present ? data.costPerUnit.value : this.costPerUnit,
      weightPerUnit: data.weightPerUnit.present
          ? data.weightPerUnit.value
          : this.weightPerUnit,
      costPerKg: data.costPerKg.present ? data.costPerKg.value : this.costPerKg,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedItem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('currentStock: $currentStock, ')
          ..write('reorderThreshold: $reorderThreshold, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('weightPerUnit: $weightPerUnit, ')
          ..write('costPerKg: $costPerKg, ')
          ..write('supplier: $supplier, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      unit,
      currentStock,
      reorderThreshold,
      costPerUnit,
      weightPerUnit,
      costPerKg,
      supplier,
      isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFeedItem &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.unit == this.unit &&
          other.currentStock == this.currentStock &&
          other.reorderThreshold == this.reorderThreshold &&
          other.costPerUnit == this.costPerUnit &&
          other.weightPerUnit == this.weightPerUnit &&
          other.costPerKg == this.costPerKg &&
          other.supplier == this.supplier &&
          other.isActive == this.isActive);
}

class LocalFeedItemsCompanion extends UpdateCompanion<LocalFeedItem> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> unit;
  final Value<double> currentStock;
  final Value<double> reorderThreshold;
  final Value<double> costPerUnit;
  final Value<double> weightPerUnit;
  final Value<double> costPerKg;
  final Value<String?> supplier;
  final Value<bool> isActive;
  final Value<int> rowid;
  const LocalFeedItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.currentStock = const Value.absent(),
    this.reorderThreshold = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.weightPerUnit = const Value.absent(),
    this.costPerKg = const Value.absent(),
    this.supplier = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFeedItemsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required String unit,
    required double currentStock,
    required double reorderThreshold,
    required double costPerUnit,
    this.weightPerUnit = const Value.absent(),
    this.costPerKg = const Value.absent(),
    this.supplier = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        unit = Value(unit),
        currentStock = Value(currentStock),
        reorderThreshold = Value(reorderThreshold),
        costPerUnit = Value(costPerUnit);
  static Insertable<LocalFeedItem> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? unit,
    Expression<double>? currentStock,
    Expression<double>? reorderThreshold,
    Expression<double>? costPerUnit,
    Expression<double>? weightPerUnit,
    Expression<double>? costPerKg,
    Expression<String>? supplier,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (currentStock != null) 'current_stock': currentStock,
      if (reorderThreshold != null) 'reorder_threshold': reorderThreshold,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (weightPerUnit != null) 'weight_per_unit': weightPerUnit,
      if (costPerKg != null) 'cost_per_kg': costPerKg,
      if (supplier != null) 'supplier': supplier,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFeedItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String>? unit,
      Value<double>? currentStock,
      Value<double>? reorderThreshold,
      Value<double>? costPerUnit,
      Value<double>? weightPerUnit,
      Value<double>? costPerKg,
      Value<String?>? supplier,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return LocalFeedItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      reorderThreshold: reorderThreshold ?? this.reorderThreshold,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      weightPerUnit: weightPerUnit ?? this.weightPerUnit,
      costPerKg: costPerKg ?? this.costPerKg,
      supplier: supplier ?? this.supplier,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (currentStock.present) {
      map['current_stock'] = Variable<double>(currentStock.value);
    }
    if (reorderThreshold.present) {
      map['reorder_threshold'] = Variable<double>(reorderThreshold.value);
    }
    if (costPerUnit.present) {
      map['cost_per_unit'] = Variable<double>(costPerUnit.value);
    }
    if (weightPerUnit.present) {
      map['weight_per_unit'] = Variable<double>(weightPerUnit.value);
    }
    if (costPerKg.present) {
      map['cost_per_kg'] = Variable<double>(costPerKg.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('currentStock: $currentStock, ')
          ..write('reorderThreshold: $reorderThreshold, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('weightPerUnit: $weightPerUnit, ')
          ..write('costPerKg: $costPerKg, ')
          ..write('supplier: $supplier, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInventoryLogsTable extends LocalInventoryLogs
    with TableInfo<$LocalInventoryLogsTable, LocalInventoryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInventoryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changeTypeMeta =
      const VerificationMeta('changeType');
  @override
  late final GeneratedColumn<String> changeType = GeneratedColumn<String>(
      'change_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityChangeMeta =
      const VerificationMeta('quantityChange');
  @override
  late final GeneratedColumn<double> quantityChange = GeneratedColumn<double>(
      'quantity_change', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _balanceAfterMeta =
      const VerificationMeta('balanceAfter');
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
      'balance_after', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _logDateMeta =
      const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
      'log_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        itemId,
        changeType,
        quantityChange,
        balanceAfter,
        relatedEntityType,
        relatedEntityId,
        notes,
        logDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_inventory_logs';
  @override
  VerificationContext validateIntegrity(Insertable<LocalInventoryLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('change_type')) {
      context.handle(
          _changeTypeMeta,
          changeType.isAcceptableOrUnknown(
              data['change_type']!, _changeTypeMeta));
    } else if (isInserting) {
      context.missing(_changeTypeMeta);
    }
    if (data.containsKey('quantity_change')) {
      context.handle(
          _quantityChangeMeta,
          quantityChange.isAcceptableOrUnknown(
              data['quantity_change']!, _quantityChangeMeta));
    } else if (isInserting) {
      context.missing(_quantityChangeMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
          _balanceAfterMeta,
          balanceAfter.isAcceptableOrUnknown(
              data['balance_after']!, _balanceAfterMeta));
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
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
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta,
          logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInventoryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInventoryLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      changeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}change_type'])!,
      quantityChange: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}quantity_change'])!,
      balanceAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance_after'])!,
      relatedEntityType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_entity_type']),
      relatedEntityId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_entity_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      logDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}log_date'])!,
    );
  }

  @override
  $LocalInventoryLogsTable createAlias(String alias) {
    return $LocalInventoryLogsTable(attachedDatabase, alias);
  }
}

class LocalInventoryLog extends DataClass
    implements Insertable<LocalInventoryLog> {
  final String id;
  final String itemId;
  final String changeType;
  final double quantityChange;
  final double balanceAfter;
  final String? relatedEntityType;
  final String? relatedEntityId;
  final String? notes;
  final DateTime logDate;
  const LocalInventoryLog(
      {required this.id,
      required this.itemId,
      required this.changeType,
      required this.quantityChange,
      required this.balanceAfter,
      this.relatedEntityType,
      this.relatedEntityId,
      this.notes,
      required this.logDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['change_type'] = Variable<String>(changeType);
    map['quantity_change'] = Variable<double>(quantityChange);
    map['balance_after'] = Variable<double>(balanceAfter);
    if (!nullToAbsent || relatedEntityType != null) {
      map['related_entity_type'] = Variable<String>(relatedEntityType);
    }
    if (!nullToAbsent || relatedEntityId != null) {
      map['related_entity_id'] = Variable<String>(relatedEntityId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['log_date'] = Variable<DateTime>(logDate);
    return map;
  }

  LocalInventoryLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalInventoryLogsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      changeType: Value(changeType),
      quantityChange: Value(quantityChange),
      balanceAfter: Value(balanceAfter),
      relatedEntityType: relatedEntityType == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEntityType),
      relatedEntityId: relatedEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEntityId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      logDate: Value(logDate),
    );
  }

  factory LocalInventoryLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInventoryLog(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      changeType: serializer.fromJson<String>(json['changeType']),
      quantityChange: serializer.fromJson<double>(json['quantityChange']),
      balanceAfter: serializer.fromJson<double>(json['balanceAfter']),
      relatedEntityType:
          serializer.fromJson<String?>(json['relatedEntityType']),
      relatedEntityId: serializer.fromJson<String?>(json['relatedEntityId']),
      notes: serializer.fromJson<String?>(json['notes']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'changeType': serializer.toJson<String>(changeType),
      'quantityChange': serializer.toJson<double>(quantityChange),
      'balanceAfter': serializer.toJson<double>(balanceAfter),
      'relatedEntityType': serializer.toJson<String?>(relatedEntityType),
      'relatedEntityId': serializer.toJson<String?>(relatedEntityId),
      'notes': serializer.toJson<String?>(notes),
      'logDate': serializer.toJson<DateTime>(logDate),
    };
  }

  LocalInventoryLog copyWith(
          {String? id,
          String? itemId,
          String? changeType,
          double? quantityChange,
          double? balanceAfter,
          Value<String?> relatedEntityType = const Value.absent(),
          Value<String?> relatedEntityId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? logDate}) =>
      LocalInventoryLog(
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        changeType: changeType ?? this.changeType,
        quantityChange: quantityChange ?? this.quantityChange,
        balanceAfter: balanceAfter ?? this.balanceAfter,
        relatedEntityType: relatedEntityType.present
            ? relatedEntityType.value
            : this.relatedEntityType,
        relatedEntityId: relatedEntityId.present
            ? relatedEntityId.value
            : this.relatedEntityId,
        notes: notes.present ? notes.value : this.notes,
        logDate: logDate ?? this.logDate,
      );
  LocalInventoryLog copyWithCompanion(LocalInventoryLogsCompanion data) {
    return LocalInventoryLog(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      changeType:
          data.changeType.present ? data.changeType.value : this.changeType,
      quantityChange: data.quantityChange.present
          ? data.quantityChange.value
          : this.quantityChange,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      relatedEntityType: data.relatedEntityType.present
          ? data.relatedEntityType.value
          : this.relatedEntityType,
      relatedEntityId: data.relatedEntityId.present
          ? data.relatedEntityId.value
          : this.relatedEntityId,
      notes: data.notes.present ? data.notes.value : this.notes,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryLog(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('changeType: $changeType, ')
          ..write('quantityChange: $quantityChange, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('relatedEntityType: $relatedEntityType, ')
          ..write('relatedEntityId: $relatedEntityId, ')
          ..write('notes: $notes, ')
          ..write('logDate: $logDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, changeType, quantityChange,
      balanceAfter, relatedEntityType, relatedEntityId, notes, logDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInventoryLog &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.changeType == this.changeType &&
          other.quantityChange == this.quantityChange &&
          other.balanceAfter == this.balanceAfter &&
          other.relatedEntityType == this.relatedEntityType &&
          other.relatedEntityId == this.relatedEntityId &&
          other.notes == this.notes &&
          other.logDate == this.logDate);
}

class LocalInventoryLogsCompanion extends UpdateCompanion<LocalInventoryLog> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> changeType;
  final Value<double> quantityChange;
  final Value<double> balanceAfter;
  final Value<String?> relatedEntityType;
  final Value<String?> relatedEntityId;
  final Value<String?> notes;
  final Value<DateTime> logDate;
  final Value<int> rowid;
  const LocalInventoryLogsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.changeType = const Value.absent(),
    this.quantityChange = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.relatedEntityType = const Value.absent(),
    this.relatedEntityId = const Value.absent(),
    this.notes = const Value.absent(),
    this.logDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInventoryLogsCompanion.insert({
    required String id,
    required String itemId,
    required String changeType,
    required double quantityChange,
    required double balanceAfter,
    this.relatedEntityType = const Value.absent(),
    this.relatedEntityId = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime logDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        itemId = Value(itemId),
        changeType = Value(changeType),
        quantityChange = Value(quantityChange),
        balanceAfter = Value(balanceAfter),
        logDate = Value(logDate);
  static Insertable<LocalInventoryLog> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? changeType,
    Expression<double>? quantityChange,
    Expression<double>? balanceAfter,
    Expression<String>? relatedEntityType,
    Expression<String>? relatedEntityId,
    Expression<String>? notes,
    Expression<DateTime>? logDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (changeType != null) 'change_type': changeType,
      if (quantityChange != null) 'quantity_change': quantityChange,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (relatedEntityType != null) 'related_entity_type': relatedEntityType,
      if (relatedEntityId != null) 'related_entity_id': relatedEntityId,
      if (notes != null) 'notes': notes,
      if (logDate != null) 'log_date': logDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInventoryLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? itemId,
      Value<String>? changeType,
      Value<double>? quantityChange,
      Value<double>? balanceAfter,
      Value<String?>? relatedEntityType,
      Value<String?>? relatedEntityId,
      Value<String?>? notes,
      Value<DateTime>? logDate,
      Value<int>? rowid}) {
    return LocalInventoryLogsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      changeType: changeType ?? this.changeType,
      quantityChange: quantityChange ?? this.quantityChange,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      notes: notes ?? this.notes,
      logDate: logDate ?? this.logDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(changeType.value);
    }
    if (quantityChange.present) {
      map['quantity_change'] = Variable<double>(quantityChange.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (relatedEntityType.present) {
      map['related_entity_type'] = Variable<String>(relatedEntityType.value);
    }
    if (relatedEntityId.present) {
      map['related_entity_id'] = Variable<String>(relatedEntityId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryLogsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('changeType: $changeType, ')
          ..write('quantityChange: $quantityChange, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('relatedEntityType: $relatedEntityType, ')
          ..write('relatedEntityId: $relatedEntityId, ')
          ..write('notes: $notes, ')
          ..write('logDate: $logDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalHatcheryBatchesTable extends LocalHatcheryBatches
    with TableInfo<$LocalHatcheryBatchesTable, LocalHatcheryBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHatcheryBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eggSourceMeta =
      const VerificationMeta('eggSource');
  @override
  late final GeneratedColumn<String> eggSource = GeneratedColumn<String>(
      'egg_source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eggCountMeta =
      const VerificationMeta('eggCount');
  @override
  late final GeneratedColumn<int> eggCount = GeneratedColumn<int>(
      'egg_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
      'breed', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _setDateMeta =
      const VerificationMeta('setDate');
  @override
  late final GeneratedColumn<DateTime> setDate = GeneratedColumn<DateTime>(
      'set_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expectedHatchDateMeta =
      const VerificationMeta('expectedHatchDate');
  @override
  late final GeneratedColumn<DateTime> expectedHatchDate =
      GeneratedColumn<DateTime>('expected_hatch_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fertileEggsMeta =
      const VerificationMeta('fertileEggs');
  @override
  late final GeneratedColumn<int> fertileEggs = GeneratedColumn<int>(
      'fertile_eggs', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hatchedChicksMeta =
      const VerificationMeta('hatchedChicks');
  @override
  late final GeneratedColumn<int> hatchedChicks = GeneratedColumn<int>(
      'hatched_chicks', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _failedEggsMeta =
      const VerificationMeta('failedEggs');
  @override
  late final GeneratedColumn<int> failedEggs = GeneratedColumn<int>(
      'failed_eggs', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _initialEggCostMeta =
      const VerificationMeta('initialEggCost');
  @override
  late final GeneratedColumn<double> initialEggCost = GeneratedColumn<double>(
      'initial_egg_cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('incubating'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        eggSource,
        eggCount,
        breed,
        setDate,
        expectedHatchDate,
        fertileEggs,
        hatchedChicks,
        failedEggs,
        initialEggCost,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_hatchery_batches';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalHatcheryBatche> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('egg_source')) {
      context.handle(_eggSourceMeta,
          eggSource.isAcceptableOrUnknown(data['egg_source']!, _eggSourceMeta));
    } else if (isInserting) {
      context.missing(_eggSourceMeta);
    }
    if (data.containsKey('egg_count')) {
      context.handle(_eggCountMeta,
          eggCount.isAcceptableOrUnknown(data['egg_count']!, _eggCountMeta));
    } else if (isInserting) {
      context.missing(_eggCountMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
          _breedMeta, breed.isAcceptableOrUnknown(data['breed']!, _breedMeta));
    }
    if (data.containsKey('set_date')) {
      context.handle(_setDateMeta,
          setDate.isAcceptableOrUnknown(data['set_date']!, _setDateMeta));
    } else if (isInserting) {
      context.missing(_setDateMeta);
    }
    if (data.containsKey('expected_hatch_date')) {
      context.handle(
          _expectedHatchDateMeta,
          expectedHatchDate.isAcceptableOrUnknown(
              data['expected_hatch_date']!, _expectedHatchDateMeta));
    } else if (isInserting) {
      context.missing(_expectedHatchDateMeta);
    }
    if (data.containsKey('fertile_eggs')) {
      context.handle(
          _fertileEggsMeta,
          fertileEggs.isAcceptableOrUnknown(
              data['fertile_eggs']!, _fertileEggsMeta));
    }
    if (data.containsKey('hatched_chicks')) {
      context.handle(
          _hatchedChicksMeta,
          hatchedChicks.isAcceptableOrUnknown(
              data['hatched_chicks']!, _hatchedChicksMeta));
    }
    if (data.containsKey('failed_eggs')) {
      context.handle(
          _failedEggsMeta,
          failedEggs.isAcceptableOrUnknown(
              data['failed_eggs']!, _failedEggsMeta));
    }
    if (data.containsKey('initial_egg_cost')) {
      context.handle(
          _initialEggCostMeta,
          initialEggCost.isAcceptableOrUnknown(
              data['initial_egg_cost']!, _initialEggCostMeta));
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
  LocalHatcheryBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHatcheryBatche(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      eggSource: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}egg_source'])!,
      eggCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}egg_count'])!,
      breed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breed']),
      setDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}set_date'])!,
      expectedHatchDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}expected_hatch_date'])!,
      fertileEggs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fertile_eggs']),
      hatchedChicks: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hatched_chicks']),
      failedEggs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}failed_eggs']),
      initialEggCost: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}initial_egg_cost'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $LocalHatcheryBatchesTable createAlias(String alias) {
    return $LocalHatcheryBatchesTable(attachedDatabase, alias);
  }
}

class LocalHatcheryBatche extends DataClass
    implements Insertable<LocalHatcheryBatche> {
  final String id;
  final String eggSource;
  final int eggCount;
  final String? breed;
  final DateTime setDate;
  final DateTime expectedHatchDate;
  final int? fertileEggs;
  final int? hatchedChicks;
  final int? failedEggs;
  final double initialEggCost;
  final String status;
  const LocalHatcheryBatche(
      {required this.id,
      required this.eggSource,
      required this.eggCount,
      this.breed,
      required this.setDate,
      required this.expectedHatchDate,
      this.fertileEggs,
      this.hatchedChicks,
      this.failedEggs,
      required this.initialEggCost,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['egg_source'] = Variable<String>(eggSource);
    map['egg_count'] = Variable<int>(eggCount);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    map['set_date'] = Variable<DateTime>(setDate);
    map['expected_hatch_date'] = Variable<DateTime>(expectedHatchDate);
    if (!nullToAbsent || fertileEggs != null) {
      map['fertile_eggs'] = Variable<int>(fertileEggs);
    }
    if (!nullToAbsent || hatchedChicks != null) {
      map['hatched_chicks'] = Variable<int>(hatchedChicks);
    }
    if (!nullToAbsent || failedEggs != null) {
      map['failed_eggs'] = Variable<int>(failedEggs);
    }
    map['initial_egg_cost'] = Variable<double>(initialEggCost);
    map['status'] = Variable<String>(status);
    return map;
  }

  LocalHatcheryBatchesCompanion toCompanion(bool nullToAbsent) {
    return LocalHatcheryBatchesCompanion(
      id: Value(id),
      eggSource: Value(eggSource),
      eggCount: Value(eggCount),
      breed:
          breed == null && nullToAbsent ? const Value.absent() : Value(breed),
      setDate: Value(setDate),
      expectedHatchDate: Value(expectedHatchDate),
      fertileEggs: fertileEggs == null && nullToAbsent
          ? const Value.absent()
          : Value(fertileEggs),
      hatchedChicks: hatchedChicks == null && nullToAbsent
          ? const Value.absent()
          : Value(hatchedChicks),
      failedEggs: failedEggs == null && nullToAbsent
          ? const Value.absent()
          : Value(failedEggs),
      initialEggCost: Value(initialEggCost),
      status: Value(status),
    );
  }

  factory LocalHatcheryBatche.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHatcheryBatche(
      id: serializer.fromJson<String>(json['id']),
      eggSource: serializer.fromJson<String>(json['eggSource']),
      eggCount: serializer.fromJson<int>(json['eggCount']),
      breed: serializer.fromJson<String?>(json['breed']),
      setDate: serializer.fromJson<DateTime>(json['setDate']),
      expectedHatchDate:
          serializer.fromJson<DateTime>(json['expectedHatchDate']),
      fertileEggs: serializer.fromJson<int?>(json['fertileEggs']),
      hatchedChicks: serializer.fromJson<int?>(json['hatchedChicks']),
      failedEggs: serializer.fromJson<int?>(json['failedEggs']),
      initialEggCost: serializer.fromJson<double>(json['initialEggCost']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eggSource': serializer.toJson<String>(eggSource),
      'eggCount': serializer.toJson<int>(eggCount),
      'breed': serializer.toJson<String?>(breed),
      'setDate': serializer.toJson<DateTime>(setDate),
      'expectedHatchDate': serializer.toJson<DateTime>(expectedHatchDate),
      'fertileEggs': serializer.toJson<int?>(fertileEggs),
      'hatchedChicks': serializer.toJson<int?>(hatchedChicks),
      'failedEggs': serializer.toJson<int?>(failedEggs),
      'initialEggCost': serializer.toJson<double>(initialEggCost),
      'status': serializer.toJson<String>(status),
    };
  }

  LocalHatcheryBatche copyWith(
          {String? id,
          String? eggSource,
          int? eggCount,
          Value<String?> breed = const Value.absent(),
          DateTime? setDate,
          DateTime? expectedHatchDate,
          Value<int?> fertileEggs = const Value.absent(),
          Value<int?> hatchedChicks = const Value.absent(),
          Value<int?> failedEggs = const Value.absent(),
          double? initialEggCost,
          String? status}) =>
      LocalHatcheryBatche(
        id: id ?? this.id,
        eggSource: eggSource ?? this.eggSource,
        eggCount: eggCount ?? this.eggCount,
        breed: breed.present ? breed.value : this.breed,
        setDate: setDate ?? this.setDate,
        expectedHatchDate: expectedHatchDate ?? this.expectedHatchDate,
        fertileEggs: fertileEggs.present ? fertileEggs.value : this.fertileEggs,
        hatchedChicks:
            hatchedChicks.present ? hatchedChicks.value : this.hatchedChicks,
        failedEggs: failedEggs.present ? failedEggs.value : this.failedEggs,
        initialEggCost: initialEggCost ?? this.initialEggCost,
        status: status ?? this.status,
      );
  LocalHatcheryBatche copyWithCompanion(LocalHatcheryBatchesCompanion data) {
    return LocalHatcheryBatche(
      id: data.id.present ? data.id.value : this.id,
      eggSource: data.eggSource.present ? data.eggSource.value : this.eggSource,
      eggCount: data.eggCount.present ? data.eggCount.value : this.eggCount,
      breed: data.breed.present ? data.breed.value : this.breed,
      setDate: data.setDate.present ? data.setDate.value : this.setDate,
      expectedHatchDate: data.expectedHatchDate.present
          ? data.expectedHatchDate.value
          : this.expectedHatchDate,
      fertileEggs:
          data.fertileEggs.present ? data.fertileEggs.value : this.fertileEggs,
      hatchedChicks: data.hatchedChicks.present
          ? data.hatchedChicks.value
          : this.hatchedChicks,
      failedEggs:
          data.failedEggs.present ? data.failedEggs.value : this.failedEggs,
      initialEggCost: data.initialEggCost.present
          ? data.initialEggCost.value
          : this.initialEggCost,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHatcheryBatche(')
          ..write('id: $id, ')
          ..write('eggSource: $eggSource, ')
          ..write('eggCount: $eggCount, ')
          ..write('breed: $breed, ')
          ..write('setDate: $setDate, ')
          ..write('expectedHatchDate: $expectedHatchDate, ')
          ..write('fertileEggs: $fertileEggs, ')
          ..write('hatchedChicks: $hatchedChicks, ')
          ..write('failedEggs: $failedEggs, ')
          ..write('initialEggCost: $initialEggCost, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      eggSource,
      eggCount,
      breed,
      setDate,
      expectedHatchDate,
      fertileEggs,
      hatchedChicks,
      failedEggs,
      initialEggCost,
      status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHatcheryBatche &&
          other.id == this.id &&
          other.eggSource == this.eggSource &&
          other.eggCount == this.eggCount &&
          other.breed == this.breed &&
          other.setDate == this.setDate &&
          other.expectedHatchDate == this.expectedHatchDate &&
          other.fertileEggs == this.fertileEggs &&
          other.hatchedChicks == this.hatchedChicks &&
          other.failedEggs == this.failedEggs &&
          other.initialEggCost == this.initialEggCost &&
          other.status == this.status);
}

class LocalHatcheryBatchesCompanion
    extends UpdateCompanion<LocalHatcheryBatche> {
  final Value<String> id;
  final Value<String> eggSource;
  final Value<int> eggCount;
  final Value<String?> breed;
  final Value<DateTime> setDate;
  final Value<DateTime> expectedHatchDate;
  final Value<int?> fertileEggs;
  final Value<int?> hatchedChicks;
  final Value<int?> failedEggs;
  final Value<double> initialEggCost;
  final Value<String> status;
  final Value<int> rowid;
  const LocalHatcheryBatchesCompanion({
    this.id = const Value.absent(),
    this.eggSource = const Value.absent(),
    this.eggCount = const Value.absent(),
    this.breed = const Value.absent(),
    this.setDate = const Value.absent(),
    this.expectedHatchDate = const Value.absent(),
    this.fertileEggs = const Value.absent(),
    this.hatchedChicks = const Value.absent(),
    this.failedEggs = const Value.absent(),
    this.initialEggCost = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalHatcheryBatchesCompanion.insert({
    required String id,
    required String eggSource,
    required int eggCount,
    this.breed = const Value.absent(),
    required DateTime setDate,
    required DateTime expectedHatchDate,
    this.fertileEggs = const Value.absent(),
    this.hatchedChicks = const Value.absent(),
    this.failedEggs = const Value.absent(),
    this.initialEggCost = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        eggSource = Value(eggSource),
        eggCount = Value(eggCount),
        setDate = Value(setDate),
        expectedHatchDate = Value(expectedHatchDate);
  static Insertable<LocalHatcheryBatche> custom({
    Expression<String>? id,
    Expression<String>? eggSource,
    Expression<int>? eggCount,
    Expression<String>? breed,
    Expression<DateTime>? setDate,
    Expression<DateTime>? expectedHatchDate,
    Expression<int>? fertileEggs,
    Expression<int>? hatchedChicks,
    Expression<int>? failedEggs,
    Expression<double>? initialEggCost,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eggSource != null) 'egg_source': eggSource,
      if (eggCount != null) 'egg_count': eggCount,
      if (breed != null) 'breed': breed,
      if (setDate != null) 'set_date': setDate,
      if (expectedHatchDate != null) 'expected_hatch_date': expectedHatchDate,
      if (fertileEggs != null) 'fertile_eggs': fertileEggs,
      if (hatchedChicks != null) 'hatched_chicks': hatchedChicks,
      if (failedEggs != null) 'failed_eggs': failedEggs,
      if (initialEggCost != null) 'initial_egg_cost': initialEggCost,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalHatcheryBatchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? eggSource,
      Value<int>? eggCount,
      Value<String?>? breed,
      Value<DateTime>? setDate,
      Value<DateTime>? expectedHatchDate,
      Value<int?>? fertileEggs,
      Value<int?>? hatchedChicks,
      Value<int?>? failedEggs,
      Value<double>? initialEggCost,
      Value<String>? status,
      Value<int>? rowid}) {
    return LocalHatcheryBatchesCompanion(
      id: id ?? this.id,
      eggSource: eggSource ?? this.eggSource,
      eggCount: eggCount ?? this.eggCount,
      breed: breed ?? this.breed,
      setDate: setDate ?? this.setDate,
      expectedHatchDate: expectedHatchDate ?? this.expectedHatchDate,
      fertileEggs: fertileEggs ?? this.fertileEggs,
      hatchedChicks: hatchedChicks ?? this.hatchedChicks,
      failedEggs: failedEggs ?? this.failedEggs,
      initialEggCost: initialEggCost ?? this.initialEggCost,
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
    if (eggSource.present) {
      map['egg_source'] = Variable<String>(eggSource.value);
    }
    if (eggCount.present) {
      map['egg_count'] = Variable<int>(eggCount.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (setDate.present) {
      map['set_date'] = Variable<DateTime>(setDate.value);
    }
    if (expectedHatchDate.present) {
      map['expected_hatch_date'] = Variable<DateTime>(expectedHatchDate.value);
    }
    if (fertileEggs.present) {
      map['fertile_eggs'] = Variable<int>(fertileEggs.value);
    }
    if (hatchedChicks.present) {
      map['hatched_chicks'] = Variable<int>(hatchedChicks.value);
    }
    if (failedEggs.present) {
      map['failed_eggs'] = Variable<int>(failedEggs.value);
    }
    if (initialEggCost.present) {
      map['initial_egg_cost'] = Variable<double>(initialEggCost.value);
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
    return (StringBuffer('LocalHatcheryBatchesCompanion(')
          ..write('id: $id, ')
          ..write('eggSource: $eggSource, ')
          ..write('eggCount: $eggCount, ')
          ..write('breed: $breed, ')
          ..write('setDate: $setDate, ')
          ..write('expectedHatchDate: $expectedHatchDate, ')
          ..write('fertileEggs: $fertileEggs, ')
          ..write('hatchedChicks: $hatchedChicks, ')
          ..write('failedEggs: $failedEggs, ')
          ..write('initialEggCost: $initialEggCost, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalHatcheryEventsTable extends LocalHatcheryEvents
    with TableInfo<$LocalHatcheryEventsTable, LocalHatcheryEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalHatcheryEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _batchIdMeta =
      const VerificationMeta('batchId');
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
      'batch_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
      'event_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _valueJsonMeta =
      const VerificationMeta('valueJson');
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
      'value_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, batchId, eventType, eventDate, valueJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_hatchery_events';
  @override
  VerificationContext validateIntegrity(Insertable<LocalHatcheryEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(_batchIdMeta,
          batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta));
    } else if (isInserting) {
      context.missing(_batchIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(_valueJsonMeta,
          valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalHatcheryEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalHatcheryEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      batchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}event_date'])!,
      valueJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value_json']),
    );
  }

  @override
  $LocalHatcheryEventsTable createAlias(String alias) {
    return $LocalHatcheryEventsTable(attachedDatabase, alias);
  }
}

class LocalHatcheryEvent extends DataClass
    implements Insertable<LocalHatcheryEvent> {
  final String id;
  final String batchId;
  final String eventType;
  final DateTime eventDate;
  final String? valueJson;
  const LocalHatcheryEvent(
      {required this.id,
      required this.batchId,
      required this.eventType,
      required this.eventDate,
      this.valueJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['batch_id'] = Variable<String>(batchId);
    map['event_type'] = Variable<String>(eventType);
    map['event_date'] = Variable<DateTime>(eventDate);
    if (!nullToAbsent || valueJson != null) {
      map['value_json'] = Variable<String>(valueJson);
    }
    return map;
  }

  LocalHatcheryEventsCompanion toCompanion(bool nullToAbsent) {
    return LocalHatcheryEventsCompanion(
      id: Value(id),
      batchId: Value(batchId),
      eventType: Value(eventType),
      eventDate: Value(eventDate),
      valueJson: valueJson == null && nullToAbsent
          ? const Value.absent()
          : Value(valueJson),
    );
  }

  factory LocalHatcheryEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalHatcheryEvent(
      id: serializer.fromJson<String>(json['id']),
      batchId: serializer.fromJson<String>(json['batchId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      valueJson: serializer.fromJson<String?>(json['valueJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'batchId': serializer.toJson<String>(batchId),
      'eventType': serializer.toJson<String>(eventType),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'valueJson': serializer.toJson<String?>(valueJson),
    };
  }

  LocalHatcheryEvent copyWith(
          {String? id,
          String? batchId,
          String? eventType,
          DateTime? eventDate,
          Value<String?> valueJson = const Value.absent()}) =>
      LocalHatcheryEvent(
        id: id ?? this.id,
        batchId: batchId ?? this.batchId,
        eventType: eventType ?? this.eventType,
        eventDate: eventDate ?? this.eventDate,
        valueJson: valueJson.present ? valueJson.value : this.valueJson,
      );
  LocalHatcheryEvent copyWithCompanion(LocalHatcheryEventsCompanion data) {
    return LocalHatcheryEvent(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalHatcheryEvent(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('eventType: $eventType, ')
          ..write('eventDate: $eventDate, ')
          ..write('valueJson: $valueJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, batchId, eventType, eventDate, valueJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalHatcheryEvent &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.eventType == this.eventType &&
          other.eventDate == this.eventDate &&
          other.valueJson == this.valueJson);
}

class LocalHatcheryEventsCompanion extends UpdateCompanion<LocalHatcheryEvent> {
  final Value<String> id;
  final Value<String> batchId;
  final Value<String> eventType;
  final Value<DateTime> eventDate;
  final Value<String?> valueJson;
  final Value<int> rowid;
  const LocalHatcheryEventsCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalHatcheryEventsCompanion.insert({
    required String id,
    required String batchId,
    required String eventType,
    required DateTime eventDate,
    this.valueJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        batchId = Value(batchId),
        eventType = Value(eventType),
        eventDate = Value(eventDate);
  static Insertable<LocalHatcheryEvent> custom({
    Expression<String>? id,
    Expression<String>? batchId,
    Expression<String>? eventType,
    Expression<DateTime>? eventDate,
    Expression<String>? valueJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (eventType != null) 'event_type': eventType,
      if (eventDate != null) 'event_date': eventDate,
      if (valueJson != null) 'value_json': valueJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalHatcheryEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? batchId,
      Value<String>? eventType,
      Value<DateTime>? eventDate,
      Value<String?>? valueJson,
      Value<int>? rowid}) {
    return LocalHatcheryEventsCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      valueJson: valueJson ?? this.valueJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalHatcheryEventsCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('eventType: $eventType, ')
          ..write('eventDate: $eventDate, ')
          ..write('valueJson: $valueJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFeedFormulasTable extends LocalFeedFormulas
    with TableInfo<$LocalFeedFormulasTable, LocalFeedFormula> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFeedFormulasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _batchSizeMeta =
      const VerificationMeta('batchSize');
  @override
  late final GeneratedColumn<double> batchSize = GeneratedColumn<double>(
      'batch_size', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _batchUnitMeta =
      const VerificationMeta('batchUnit');
  @override
  late final GeneratedColumn<String> batchUnit = GeneratedColumn<String>(
      'batch_unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('per_tonne'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currentStockMeta =
      const VerificationMeta('currentStock');
  @override
  late final GeneratedColumn<double> currentStock = GeneratedColumn<double>(
      'current_stock', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, batchSize, batchUnit, notes, currentStock];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_feed_formulas';
  @override
  VerificationContext validateIntegrity(Insertable<LocalFeedFormula> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('batch_size')) {
      context.handle(_batchSizeMeta,
          batchSize.isAcceptableOrUnknown(data['batch_size']!, _batchSizeMeta));
    } else if (isInserting) {
      context.missing(_batchSizeMeta);
    }
    if (data.containsKey('batch_unit')) {
      context.handle(_batchUnitMeta,
          batchUnit.isAcceptableOrUnknown(data['batch_unit']!, _batchUnitMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('current_stock')) {
      context.handle(
          _currentStockMeta,
          currentStock.isAcceptableOrUnknown(
              data['current_stock']!, _currentStockMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFeedFormula map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFeedFormula(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      batchSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}batch_size'])!,
      batchUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_unit'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      currentStock: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_stock'])!,
    );
  }

  @override
  $LocalFeedFormulasTable createAlias(String alias) {
    return $LocalFeedFormulasTable(attachedDatabase, alias);
  }
}

class LocalFeedFormula extends DataClass
    implements Insertable<LocalFeedFormula> {
  final String id;
  final String name;
  final double batchSize;
  final String batchUnit;
  final String? notes;
  final double currentStock;
  const LocalFeedFormula(
      {required this.id,
      required this.name,
      required this.batchSize,
      required this.batchUnit,
      this.notes,
      required this.currentStock});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['batch_size'] = Variable<double>(batchSize);
    map['batch_unit'] = Variable<String>(batchUnit);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['current_stock'] = Variable<double>(currentStock);
    return map;
  }

  LocalFeedFormulasCompanion toCompanion(bool nullToAbsent) {
    return LocalFeedFormulasCompanion(
      id: Value(id),
      name: Value(name),
      batchSize: Value(batchSize),
      batchUnit: Value(batchUnit),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      currentStock: Value(currentStock),
    );
  }

  factory LocalFeedFormula.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFeedFormula(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      batchSize: serializer.fromJson<double>(json['batchSize']),
      batchUnit: serializer.fromJson<String>(json['batchUnit']),
      notes: serializer.fromJson<String?>(json['notes']),
      currentStock: serializer.fromJson<double>(json['currentStock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'batchSize': serializer.toJson<double>(batchSize),
      'batchUnit': serializer.toJson<String>(batchUnit),
      'notes': serializer.toJson<String?>(notes),
      'currentStock': serializer.toJson<double>(currentStock),
    };
  }

  LocalFeedFormula copyWith(
          {String? id,
          String? name,
          double? batchSize,
          String? batchUnit,
          Value<String?> notes = const Value.absent(),
          double? currentStock}) =>
      LocalFeedFormula(
        id: id ?? this.id,
        name: name ?? this.name,
        batchSize: batchSize ?? this.batchSize,
        batchUnit: batchUnit ?? this.batchUnit,
        notes: notes.present ? notes.value : this.notes,
        currentStock: currentStock ?? this.currentStock,
      );
  LocalFeedFormula copyWithCompanion(LocalFeedFormulasCompanion data) {
    return LocalFeedFormula(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      batchSize: data.batchSize.present ? data.batchSize.value : this.batchSize,
      batchUnit: data.batchUnit.present ? data.batchUnit.value : this.batchUnit,
      notes: data.notes.present ? data.notes.value : this.notes,
      currentStock: data.currentStock.present
          ? data.currentStock.value
          : this.currentStock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedFormula(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('batchSize: $batchSize, ')
          ..write('batchUnit: $batchUnit, ')
          ..write('notes: $notes, ')
          ..write('currentStock: $currentStock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, batchSize, batchUnit, notes, currentStock);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFeedFormula &&
          other.id == this.id &&
          other.name == this.name &&
          other.batchSize == this.batchSize &&
          other.batchUnit == this.batchUnit &&
          other.notes == this.notes &&
          other.currentStock == this.currentStock);
}

class LocalFeedFormulasCompanion extends UpdateCompanion<LocalFeedFormula> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> batchSize;
  final Value<String> batchUnit;
  final Value<String?> notes;
  final Value<double> currentStock;
  final Value<int> rowid;
  const LocalFeedFormulasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.batchSize = const Value.absent(),
    this.batchUnit = const Value.absent(),
    this.notes = const Value.absent(),
    this.currentStock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFeedFormulasCompanion.insert({
    required String id,
    required String name,
    required double batchSize,
    this.batchUnit = const Value.absent(),
    this.notes = const Value.absent(),
    this.currentStock = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        batchSize = Value(batchSize);
  static Insertable<LocalFeedFormula> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? batchSize,
    Expression<String>? batchUnit,
    Expression<String>? notes,
    Expression<double>? currentStock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (batchSize != null) 'batch_size': batchSize,
      if (batchUnit != null) 'batch_unit': batchUnit,
      if (notes != null) 'notes': notes,
      if (currentStock != null) 'current_stock': currentStock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFeedFormulasCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? batchSize,
      Value<String>? batchUnit,
      Value<String?>? notes,
      Value<double>? currentStock,
      Value<int>? rowid}) {
    return LocalFeedFormulasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      batchSize: batchSize ?? this.batchSize,
      batchUnit: batchUnit ?? this.batchUnit,
      notes: notes ?? this.notes,
      currentStock: currentStock ?? this.currentStock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (batchSize.present) {
      map['batch_size'] = Variable<double>(batchSize.value);
    }
    if (batchUnit.present) {
      map['batch_unit'] = Variable<String>(batchUnit.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (currentStock.present) {
      map['current_stock'] = Variable<double>(currentStock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedFormulasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('batchSize: $batchSize, ')
          ..write('batchUnit: $batchUnit, ')
          ..write('notes: $notes, ')
          ..write('currentStock: $currentStock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFormulaIngredientsTable extends LocalFormulaIngredients
    with TableInfo<$LocalFormulaIngredientsTable, LocalFormulaIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFormulaIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _formulaIdMeta =
      const VerificationMeta('formulaId');
  @override
  late final GeneratedColumn<String> formulaId = GeneratedColumn<String>(
      'formula_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _feedItemIdMeta =
      const VerificationMeta('feedItemId');
  @override
  late final GeneratedColumn<String> feedItemId = GeneratedColumn<String>(
      'feed_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _percentageMeta =
      const VerificationMeta('percentage');
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
      'percentage', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityKgMeta =
      const VerificationMeta('quantityKg');
  @override
  late final GeneratedColumn<double> quantityKg = GeneratedColumn<double>(
      'quantity_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, formulaId, feedItemId, percentage, quantityKg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_formula_ingredients';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalFormulaIngredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('formula_id')) {
      context.handle(_formulaIdMeta,
          formulaId.isAcceptableOrUnknown(data['formula_id']!, _formulaIdMeta));
    } else if (isInserting) {
      context.missing(_formulaIdMeta);
    }
    if (data.containsKey('feed_item_id')) {
      context.handle(
          _feedItemIdMeta,
          feedItemId.isAcceptableOrUnknown(
              data['feed_item_id']!, _feedItemIdMeta));
    } else if (isInserting) {
      context.missing(_feedItemIdMeta);
    }
    if (data.containsKey('percentage')) {
      context.handle(
          _percentageMeta,
          percentage.isAcceptableOrUnknown(
              data['percentage']!, _percentageMeta));
    } else if (isInserting) {
      context.missing(_percentageMeta);
    }
    if (data.containsKey('quantity_kg')) {
      context.handle(
          _quantityKgMeta,
          quantityKg.isAcceptableOrUnknown(
              data['quantity_kg']!, _quantityKgMeta));
    } else if (isInserting) {
      context.missing(_quantityKgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFormulaIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFormulaIngredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      formulaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}formula_id'])!,
      feedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feed_item_id'])!,
      percentage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}percentage'])!,
      quantityKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity_kg'])!,
    );
  }

  @override
  $LocalFormulaIngredientsTable createAlias(String alias) {
    return $LocalFormulaIngredientsTable(attachedDatabase, alias);
  }
}

class LocalFormulaIngredient extends DataClass
    implements Insertable<LocalFormulaIngredient> {
  final String id;
  final String formulaId;
  final String feedItemId;
  final double percentage;
  final double quantityKg;
  const LocalFormulaIngredient(
      {required this.id,
      required this.formulaId,
      required this.feedItemId,
      required this.percentage,
      required this.quantityKg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['formula_id'] = Variable<String>(formulaId);
    map['feed_item_id'] = Variable<String>(feedItemId);
    map['percentage'] = Variable<double>(percentage);
    map['quantity_kg'] = Variable<double>(quantityKg);
    return map;
  }

  LocalFormulaIngredientsCompanion toCompanion(bool nullToAbsent) {
    return LocalFormulaIngredientsCompanion(
      id: Value(id),
      formulaId: Value(formulaId),
      feedItemId: Value(feedItemId),
      percentage: Value(percentage),
      quantityKg: Value(quantityKg),
    );
  }

  factory LocalFormulaIngredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFormulaIngredient(
      id: serializer.fromJson<String>(json['id']),
      formulaId: serializer.fromJson<String>(json['formulaId']),
      feedItemId: serializer.fromJson<String>(json['feedItemId']),
      percentage: serializer.fromJson<double>(json['percentage']),
      quantityKg: serializer.fromJson<double>(json['quantityKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'formulaId': serializer.toJson<String>(formulaId),
      'feedItemId': serializer.toJson<String>(feedItemId),
      'percentage': serializer.toJson<double>(percentage),
      'quantityKg': serializer.toJson<double>(quantityKg),
    };
  }

  LocalFormulaIngredient copyWith(
          {String? id,
          String? formulaId,
          String? feedItemId,
          double? percentage,
          double? quantityKg}) =>
      LocalFormulaIngredient(
        id: id ?? this.id,
        formulaId: formulaId ?? this.formulaId,
        feedItemId: feedItemId ?? this.feedItemId,
        percentage: percentage ?? this.percentage,
        quantityKg: quantityKg ?? this.quantityKg,
      );
  LocalFormulaIngredient copyWithCompanion(
      LocalFormulaIngredientsCompanion data) {
    return LocalFormulaIngredient(
      id: data.id.present ? data.id.value : this.id,
      formulaId: data.formulaId.present ? data.formulaId.value : this.formulaId,
      feedItemId:
          data.feedItemId.present ? data.feedItemId.value : this.feedItemId,
      percentage:
          data.percentage.present ? data.percentage.value : this.percentage,
      quantityKg:
          data.quantityKg.present ? data.quantityKg.value : this.quantityKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFormulaIngredient(')
          ..write('id: $id, ')
          ..write('formulaId: $formulaId, ')
          ..write('feedItemId: $feedItemId, ')
          ..write('percentage: $percentage, ')
          ..write('quantityKg: $quantityKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, formulaId, feedItemId, percentage, quantityKg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFormulaIngredient &&
          other.id == this.id &&
          other.formulaId == this.formulaId &&
          other.feedItemId == this.feedItemId &&
          other.percentage == this.percentage &&
          other.quantityKg == this.quantityKg);
}

class LocalFormulaIngredientsCompanion
    extends UpdateCompanion<LocalFormulaIngredient> {
  final Value<String> id;
  final Value<String> formulaId;
  final Value<String> feedItemId;
  final Value<double> percentage;
  final Value<double> quantityKg;
  final Value<int> rowid;
  const LocalFormulaIngredientsCompanion({
    this.id = const Value.absent(),
    this.formulaId = const Value.absent(),
    this.feedItemId = const Value.absent(),
    this.percentage = const Value.absent(),
    this.quantityKg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFormulaIngredientsCompanion.insert({
    required String id,
    required String formulaId,
    required String feedItemId,
    required double percentage,
    required double quantityKg,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        formulaId = Value(formulaId),
        feedItemId = Value(feedItemId),
        percentage = Value(percentage),
        quantityKg = Value(quantityKg);
  static Insertable<LocalFormulaIngredient> custom({
    Expression<String>? id,
    Expression<String>? formulaId,
    Expression<String>? feedItemId,
    Expression<double>? percentage,
    Expression<double>? quantityKg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (formulaId != null) 'formula_id': formulaId,
      if (feedItemId != null) 'feed_item_id': feedItemId,
      if (percentage != null) 'percentage': percentage,
      if (quantityKg != null) 'quantity_kg': quantityKg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFormulaIngredientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? formulaId,
      Value<String>? feedItemId,
      Value<double>? percentage,
      Value<double>? quantityKg,
      Value<int>? rowid}) {
    return LocalFormulaIngredientsCompanion(
      id: id ?? this.id,
      formulaId: formulaId ?? this.formulaId,
      feedItemId: feedItemId ?? this.feedItemId,
      percentage: percentage ?? this.percentage,
      quantityKg: quantityKg ?? this.quantityKg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (formulaId.present) {
      map['formula_id'] = Variable<String>(formulaId.value);
    }
    if (feedItemId.present) {
      map['feed_item_id'] = Variable<String>(feedItemId.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    if (quantityKg.present) {
      map['quantity_kg'] = Variable<double>(quantityKg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFormulaIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('formulaId: $formulaId, ')
          ..write('feedItemId: $feedItemId, ')
          ..write('percentage: $percentage, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFeedConsumptionLogsTable extends LocalFeedConsumptionLogs
    with TableInfo<$LocalFeedConsumptionLogsTable, LocalFeedConsumptionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFeedConsumptionLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _feedItemIdMeta =
      const VerificationMeta('feedItemId');
  @override
  late final GeneratedColumn<String> feedItemId = GeneratedColumn<String>(
      'feed_item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityKgMeta =
      const VerificationMeta('quantityKg');
  @override
  late final GeneratedColumn<double> quantityKg = GeneratedColumn<double>(
      'quantity_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _logDateMeta =
      const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
      'log_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, animalId, feedItemId, quantityKg, logDate, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_feed_consumption_logs';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalFeedConsumptionLog> instance,
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
    if (data.containsKey('feed_item_id')) {
      context.handle(
          _feedItemIdMeta,
          feedItemId.isAcceptableOrUnknown(
              data['feed_item_id']!, _feedItemIdMeta));
    } else if (isInserting) {
      context.missing(_feedItemIdMeta);
    }
    if (data.containsKey('quantity_kg')) {
      context.handle(
          _quantityKgMeta,
          quantityKg.isAcceptableOrUnknown(
              data['quantity_kg']!, _quantityKgMeta));
    } else if (isInserting) {
      context.missing(_quantityKgMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta,
          logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFeedConsumptionLog map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFeedConsumptionLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      feedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feed_item_id'])!,
      quantityKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity_kg'])!,
      logDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}log_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $LocalFeedConsumptionLogsTable createAlias(String alias) {
    return $LocalFeedConsumptionLogsTable(attachedDatabase, alias);
  }
}

class LocalFeedConsumptionLog extends DataClass
    implements Insertable<LocalFeedConsumptionLog> {
  final String id;
  final String animalId;
  final String feedItemId;
  final double quantityKg;
  final DateTime logDate;
  final String? notes;
  const LocalFeedConsumptionLog(
      {required this.id,
      required this.animalId,
      required this.feedItemId,
      required this.quantityKg,
      required this.logDate,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['feed_item_id'] = Variable<String>(feedItemId);
    map['quantity_kg'] = Variable<double>(quantityKg);
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalFeedConsumptionLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalFeedConsumptionLogsCompanion(
      id: Value(id),
      animalId: Value(animalId),
      feedItemId: Value(feedItemId),
      quantityKg: Value(quantityKg),
      logDate: Value(logDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory LocalFeedConsumptionLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFeedConsumptionLog(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      feedItemId: serializer.fromJson<String>(json['feedItemId']),
      quantityKg: serializer.fromJson<double>(json['quantityKg']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'feedItemId': serializer.toJson<String>(feedItemId),
      'quantityKg': serializer.toJson<double>(quantityKg),
      'logDate': serializer.toJson<DateTime>(logDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalFeedConsumptionLog copyWith(
          {String? id,
          String? animalId,
          String? feedItemId,
          double? quantityKg,
          DateTime? logDate,
          Value<String?> notes = const Value.absent()}) =>
      LocalFeedConsumptionLog(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        feedItemId: feedItemId ?? this.feedItemId,
        quantityKg: quantityKg ?? this.quantityKg,
        logDate: logDate ?? this.logDate,
        notes: notes.present ? notes.value : this.notes,
      );
  LocalFeedConsumptionLog copyWithCompanion(
      LocalFeedConsumptionLogsCompanion data) {
    return LocalFeedConsumptionLog(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      feedItemId:
          data.feedItemId.present ? data.feedItemId.value : this.feedItemId,
      quantityKg:
          data.quantityKg.present ? data.quantityKg.value : this.quantityKg,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedConsumptionLog(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('feedItemId: $feedItemId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('logDate: $logDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, animalId, feedItemId, quantityKg, logDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFeedConsumptionLog &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.feedItemId == this.feedItemId &&
          other.quantityKg == this.quantityKg &&
          other.logDate == this.logDate &&
          other.notes == this.notes);
}

class LocalFeedConsumptionLogsCompanion
    extends UpdateCompanion<LocalFeedConsumptionLog> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String> feedItemId;
  final Value<double> quantityKg;
  final Value<DateTime> logDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalFeedConsumptionLogsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.feedItemId = const Value.absent(),
    this.quantityKg = const Value.absent(),
    this.logDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFeedConsumptionLogsCompanion.insert({
    required String id,
    required String animalId,
    required String feedItemId,
    required double quantityKg,
    required DateTime logDate,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        feedItemId = Value(feedItemId),
        quantityKg = Value(quantityKg),
        logDate = Value(logDate);
  static Insertable<LocalFeedConsumptionLog> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? feedItemId,
    Expression<double>? quantityKg,
    Expression<DateTime>? logDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (feedItemId != null) 'feed_item_id': feedItemId,
      if (quantityKg != null) 'quantity_kg': quantityKg,
      if (logDate != null) 'log_date': logDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFeedConsumptionLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? animalId,
      Value<String>? feedItemId,
      Value<double>? quantityKg,
      Value<DateTime>? logDate,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return LocalFeedConsumptionLogsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      feedItemId: feedItemId ?? this.feedItemId,
      quantityKg: quantityKg ?? this.quantityKg,
      logDate: logDate ?? this.logDate,
      notes: notes ?? this.notes,
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
    if (feedItemId.present) {
      map['feed_item_id'] = Variable<String>(feedItemId.value);
    }
    if (quantityKg.present) {
      map['quantity_kg'] = Variable<double>(quantityKg.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedConsumptionLogsCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('feedItemId: $feedItemId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('logDate: $logDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFeedingPlansTable extends LocalFeedingPlans
    with TableInfo<$LocalFeedingPlansTable, LocalFeedingPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFeedingPlansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _formulaIdMeta =
      const VerificationMeta('formulaId');
  @override
  late final GeneratedColumn<String> formulaId = GeneratedColumn<String>(
      'formula_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityKgMeta =
      const VerificationMeta('quantityKg');
  @override
  late final GeneratedColumn<double> quantityKg = GeneratedColumn<double>(
      'quantity_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isAutoFeedMeta =
      const VerificationMeta('isAutoFeed');
  @override
  late final GeneratedColumn<bool> isAutoFeed = GeneratedColumn<bool>(
      'is_auto_feed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_auto_feed" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, animalId, formulaId, quantityKg, isAutoFeed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_feeding_plans';
  @override
  VerificationContext validateIntegrity(Insertable<LocalFeedingPlan> instance,
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
    if (data.containsKey('formula_id')) {
      context.handle(_formulaIdMeta,
          formulaId.isAcceptableOrUnknown(data['formula_id']!, _formulaIdMeta));
    } else if (isInserting) {
      context.missing(_formulaIdMeta);
    }
    if (data.containsKey('quantity_kg')) {
      context.handle(
          _quantityKgMeta,
          quantityKg.isAcceptableOrUnknown(
              data['quantity_kg']!, _quantityKgMeta));
    } else if (isInserting) {
      context.missing(_quantityKgMeta);
    }
    if (data.containsKey('is_auto_feed')) {
      context.handle(
          _isAutoFeedMeta,
          isAutoFeed.isAcceptableOrUnknown(
              data['is_auto_feed']!, _isAutoFeedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFeedingPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFeedingPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      formulaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}formula_id'])!,
      quantityKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity_kg'])!,
      isAutoFeed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_auto_feed'])!,
    );
  }

  @override
  $LocalFeedingPlansTable createAlias(String alias) {
    return $LocalFeedingPlansTable(attachedDatabase, alias);
  }
}

class LocalFeedingPlan extends DataClass
    implements Insertable<LocalFeedingPlan> {
  final String id;
  final String animalId;
  final String formulaId;
  final double quantityKg;
  final bool isAutoFeed;
  const LocalFeedingPlan(
      {required this.id,
      required this.animalId,
      required this.formulaId,
      required this.quantityKg,
      required this.isAutoFeed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['formula_id'] = Variable<String>(formulaId);
    map['quantity_kg'] = Variable<double>(quantityKg);
    map['is_auto_feed'] = Variable<bool>(isAutoFeed);
    return map;
  }

  LocalFeedingPlansCompanion toCompanion(bool nullToAbsent) {
    return LocalFeedingPlansCompanion(
      id: Value(id),
      animalId: Value(animalId),
      formulaId: Value(formulaId),
      quantityKg: Value(quantityKg),
      isAutoFeed: Value(isAutoFeed),
    );
  }

  factory LocalFeedingPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFeedingPlan(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      formulaId: serializer.fromJson<String>(json['formulaId']),
      quantityKg: serializer.fromJson<double>(json['quantityKg']),
      isAutoFeed: serializer.fromJson<bool>(json['isAutoFeed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'formulaId': serializer.toJson<String>(formulaId),
      'quantityKg': serializer.toJson<double>(quantityKg),
      'isAutoFeed': serializer.toJson<bool>(isAutoFeed),
    };
  }

  LocalFeedingPlan copyWith(
          {String? id,
          String? animalId,
          String? formulaId,
          double? quantityKg,
          bool? isAutoFeed}) =>
      LocalFeedingPlan(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        formulaId: formulaId ?? this.formulaId,
        quantityKg: quantityKg ?? this.quantityKg,
        isAutoFeed: isAutoFeed ?? this.isAutoFeed,
      );
  LocalFeedingPlan copyWithCompanion(LocalFeedingPlansCompanion data) {
    return LocalFeedingPlan(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      formulaId: data.formulaId.present ? data.formulaId.value : this.formulaId,
      quantityKg:
          data.quantityKg.present ? data.quantityKg.value : this.quantityKg,
      isAutoFeed:
          data.isAutoFeed.present ? data.isAutoFeed.value : this.isAutoFeed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedingPlan(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('formulaId: $formulaId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('isAutoFeed: $isAutoFeed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, animalId, formulaId, quantityKg, isAutoFeed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFeedingPlan &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.formulaId == this.formulaId &&
          other.quantityKg == this.quantityKg &&
          other.isAutoFeed == this.isAutoFeed);
}

class LocalFeedingPlansCompanion extends UpdateCompanion<LocalFeedingPlan> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String> formulaId;
  final Value<double> quantityKg;
  final Value<bool> isAutoFeed;
  final Value<int> rowid;
  const LocalFeedingPlansCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.formulaId = const Value.absent(),
    this.quantityKg = const Value.absent(),
    this.isAutoFeed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFeedingPlansCompanion.insert({
    required String id,
    required String animalId,
    required String formulaId,
    required double quantityKg,
    this.isAutoFeed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        formulaId = Value(formulaId),
        quantityKg = Value(quantityKg);
  static Insertable<LocalFeedingPlan> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? formulaId,
    Expression<double>? quantityKg,
    Expression<bool>? isAutoFeed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (formulaId != null) 'formula_id': formulaId,
      if (quantityKg != null) 'quantity_kg': quantityKg,
      if (isAutoFeed != null) 'is_auto_feed': isAutoFeed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFeedingPlansCompanion copyWith(
      {Value<String>? id,
      Value<String>? animalId,
      Value<String>? formulaId,
      Value<double>? quantityKg,
      Value<bool>? isAutoFeed,
      Value<int>? rowid}) {
    return LocalFeedingPlansCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      formulaId: formulaId ?? this.formulaId,
      quantityKg: quantityKg ?? this.quantityKg,
      isAutoFeed: isAutoFeed ?? this.isAutoFeed,
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
    if (formulaId.present) {
      map['formula_id'] = Variable<String>(formulaId.value);
    }
    if (quantityKg.present) {
      map['quantity_kg'] = Variable<double>(quantityKg.value);
    }
    if (isAutoFeed.present) {
      map['is_auto_feed'] = Variable<bool>(isAutoFeed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFeedingPlansCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('formulaId: $formulaId, ')
          ..write('quantityKg: $quantityKg, ')
          ..write('isAutoFeed: $isAutoFeed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMedicationsTable extends LocalMedications
    with TableInfo<$LocalMedicationsTable, LocalMedication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentStockMeta =
      const VerificationMeta('currentStock');
  @override
  late final GeneratedColumn<double> currentStock = GeneratedColumn<double>(
      'current_stock', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _reorderThresholdMeta =
      const VerificationMeta('reorderThreshold');
  @override
  late final GeneratedColumn<double> reorderThreshold = GeneratedColumn<double>(
      'reorder_threshold', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(5.0));
  static const VerificationMeta _costPerUnitMeta =
      const VerificationMeta('costPerUnit');
  @override
  late final GeneratedColumn<double> costPerUnit = GeneratedColumn<double>(
      'cost_per_unit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _supplierMeta =
      const VerificationMeta('supplier');
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
      'supplier', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiryDateMeta =
      const VerificationMeta('expiryDate');
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
      'expiry_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _batchNumberMeta =
      const VerificationMeta('batchNumber');
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
      'batch_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _milkWithdrawalDaysMeta =
      const VerificationMeta('milkWithdrawalDays');
  @override
  late final GeneratedColumn<int> milkWithdrawalDays = GeneratedColumn<int>(
      'milk_withdrawal_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _meatWithdrawalDaysMeta =
      const VerificationMeta('meatWithdrawalDays');
  @override
  late final GeneratedColumn<int> meatWithdrawalDays = GeneratedColumn<int>(
      'meat_withdrawal_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        unit,
        currentStock,
        reorderThreshold,
        costPerUnit,
        supplier,
        expiryDate,
        batchNumber,
        milkWithdrawalDays,
        meatWithdrawalDays,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_medications';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMedication> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('current_stock')) {
      context.handle(
          _currentStockMeta,
          currentStock.isAcceptableOrUnknown(
              data['current_stock']!, _currentStockMeta));
    }
    if (data.containsKey('reorder_threshold')) {
      context.handle(
          _reorderThresholdMeta,
          reorderThreshold.isAcceptableOrUnknown(
              data['reorder_threshold']!, _reorderThresholdMeta));
    }
    if (data.containsKey('cost_per_unit')) {
      context.handle(
          _costPerUnitMeta,
          costPerUnit.isAcceptableOrUnknown(
              data['cost_per_unit']!, _costPerUnitMeta));
    }
    if (data.containsKey('supplier')) {
      context.handle(_supplierMeta,
          supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta));
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
          _expiryDateMeta,
          expiryDate.isAcceptableOrUnknown(
              data['expiry_date']!, _expiryDateMeta));
    }
    if (data.containsKey('batch_number')) {
      context.handle(
          _batchNumberMeta,
          batchNumber.isAcceptableOrUnknown(
              data['batch_number']!, _batchNumberMeta));
    }
    if (data.containsKey('milk_withdrawal_days')) {
      context.handle(
          _milkWithdrawalDaysMeta,
          milkWithdrawalDays.isAcceptableOrUnknown(
              data['milk_withdrawal_days']!, _milkWithdrawalDaysMeta));
    }
    if (data.containsKey('meat_withdrawal_days')) {
      context.handle(
          _meatWithdrawalDaysMeta,
          meatWithdrawalDays.isAcceptableOrUnknown(
              data['meat_withdrawal_days']!, _meatWithdrawalDaysMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMedication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMedication(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      currentStock: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_stock'])!,
      reorderThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}reorder_threshold'])!,
      costPerUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_per_unit'])!,
      supplier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier']),
      expiryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expiry_date']),
      batchNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batch_number']),
      milkWithdrawalDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}milk_withdrawal_days'])!,
      meatWithdrawalDays: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}meat_withdrawal_days'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $LocalMedicationsTable createAlias(String alias) {
    return $LocalMedicationsTable(attachedDatabase, alias);
  }
}

class LocalMedication extends DataClass implements Insertable<LocalMedication> {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double currentStock;
  final double reorderThreshold;
  final double costPerUnit;
  final String? supplier;
  final DateTime? expiryDate;
  final String? batchNumber;
  final int milkWithdrawalDays;
  final int meatWithdrawalDays;
  final bool isActive;
  const LocalMedication(
      {required this.id,
      required this.name,
      required this.category,
      required this.unit,
      required this.currentStock,
      required this.reorderThreshold,
      required this.costPerUnit,
      this.supplier,
      this.expiryDate,
      this.batchNumber,
      required this.milkWithdrawalDays,
      required this.meatWithdrawalDays,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['unit'] = Variable<String>(unit);
    map['current_stock'] = Variable<double>(currentStock);
    map['reorder_threshold'] = Variable<double>(reorderThreshold);
    map['cost_per_unit'] = Variable<double>(costPerUnit);
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    if (!nullToAbsent || batchNumber != null) {
      map['batch_number'] = Variable<String>(batchNumber);
    }
    map['milk_withdrawal_days'] = Variable<int>(milkWithdrawalDays);
    map['meat_withdrawal_days'] = Variable<int>(meatWithdrawalDays);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LocalMedicationsCompanion toCompanion(bool nullToAbsent) {
    return LocalMedicationsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      unit: Value(unit),
      currentStock: Value(currentStock),
      reorderThreshold: Value(reorderThreshold),
      costPerUnit: Value(costPerUnit),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      batchNumber: batchNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(batchNumber),
      milkWithdrawalDays: Value(milkWithdrawalDays),
      meatWithdrawalDays: Value(meatWithdrawalDays),
      isActive: Value(isActive),
    );
  }

  factory LocalMedication.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMedication(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      unit: serializer.fromJson<String>(json['unit']),
      currentStock: serializer.fromJson<double>(json['currentStock']),
      reorderThreshold: serializer.fromJson<double>(json['reorderThreshold']),
      costPerUnit: serializer.fromJson<double>(json['costPerUnit']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      batchNumber: serializer.fromJson<String?>(json['batchNumber']),
      milkWithdrawalDays: serializer.fromJson<int>(json['milkWithdrawalDays']),
      meatWithdrawalDays: serializer.fromJson<int>(json['meatWithdrawalDays']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'unit': serializer.toJson<String>(unit),
      'currentStock': serializer.toJson<double>(currentStock),
      'reorderThreshold': serializer.toJson<double>(reorderThreshold),
      'costPerUnit': serializer.toJson<double>(costPerUnit),
      'supplier': serializer.toJson<String?>(supplier),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'batchNumber': serializer.toJson<String?>(batchNumber),
      'milkWithdrawalDays': serializer.toJson<int>(milkWithdrawalDays),
      'meatWithdrawalDays': serializer.toJson<int>(meatWithdrawalDays),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  LocalMedication copyWith(
          {String? id,
          String? name,
          String? category,
          String? unit,
          double? currentStock,
          double? reorderThreshold,
          double? costPerUnit,
          Value<String?> supplier = const Value.absent(),
          Value<DateTime?> expiryDate = const Value.absent(),
          Value<String?> batchNumber = const Value.absent(),
          int? milkWithdrawalDays,
          int? meatWithdrawalDays,
          bool? isActive}) =>
      LocalMedication(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        unit: unit ?? this.unit,
        currentStock: currentStock ?? this.currentStock,
        reorderThreshold: reorderThreshold ?? this.reorderThreshold,
        costPerUnit: costPerUnit ?? this.costPerUnit,
        supplier: supplier.present ? supplier.value : this.supplier,
        expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
        batchNumber: batchNumber.present ? batchNumber.value : this.batchNumber,
        milkWithdrawalDays: milkWithdrawalDays ?? this.milkWithdrawalDays,
        meatWithdrawalDays: meatWithdrawalDays ?? this.meatWithdrawalDays,
        isActive: isActive ?? this.isActive,
      );
  LocalMedication copyWithCompanion(LocalMedicationsCompanion data) {
    return LocalMedication(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      unit: data.unit.present ? data.unit.value : this.unit,
      currentStock: data.currentStock.present
          ? data.currentStock.value
          : this.currentStock,
      reorderThreshold: data.reorderThreshold.present
          ? data.reorderThreshold.value
          : this.reorderThreshold,
      costPerUnit:
          data.costPerUnit.present ? data.costPerUnit.value : this.costPerUnit,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      expiryDate:
          data.expiryDate.present ? data.expiryDate.value : this.expiryDate,
      batchNumber:
          data.batchNumber.present ? data.batchNumber.value : this.batchNumber,
      milkWithdrawalDays: data.milkWithdrawalDays.present
          ? data.milkWithdrawalDays.value
          : this.milkWithdrawalDays,
      meatWithdrawalDays: data.meatWithdrawalDays.present
          ? data.meatWithdrawalDays.value
          : this.meatWithdrawalDays,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMedication(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('currentStock: $currentStock, ')
          ..write('reorderThreshold: $reorderThreshold, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('supplier: $supplier, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('milkWithdrawalDays: $milkWithdrawalDays, ')
          ..write('meatWithdrawalDays: $meatWithdrawalDays, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      unit,
      currentStock,
      reorderThreshold,
      costPerUnit,
      supplier,
      expiryDate,
      batchNumber,
      milkWithdrawalDays,
      meatWithdrawalDays,
      isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMedication &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.unit == this.unit &&
          other.currentStock == this.currentStock &&
          other.reorderThreshold == this.reorderThreshold &&
          other.costPerUnit == this.costPerUnit &&
          other.supplier == this.supplier &&
          other.expiryDate == this.expiryDate &&
          other.batchNumber == this.batchNumber &&
          other.milkWithdrawalDays == this.milkWithdrawalDays &&
          other.meatWithdrawalDays == this.meatWithdrawalDays &&
          other.isActive == this.isActive);
}

class LocalMedicationsCompanion extends UpdateCompanion<LocalMedication> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> unit;
  final Value<double> currentStock;
  final Value<double> reorderThreshold;
  final Value<double> costPerUnit;
  final Value<String?> supplier;
  final Value<DateTime?> expiryDate;
  final Value<String?> batchNumber;
  final Value<int> milkWithdrawalDays;
  final Value<int> meatWithdrawalDays;
  final Value<bool> isActive;
  final Value<int> rowid;
  const LocalMedicationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.currentStock = const Value.absent(),
    this.reorderThreshold = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.supplier = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.milkWithdrawalDays = const Value.absent(),
    this.meatWithdrawalDays = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMedicationsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required String unit,
    this.currentStock = const Value.absent(),
    this.reorderThreshold = const Value.absent(),
    this.costPerUnit = const Value.absent(),
    this.supplier = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.milkWithdrawalDays = const Value.absent(),
    this.meatWithdrawalDays = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        category = Value(category),
        unit = Value(unit);
  static Insertable<LocalMedication> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? unit,
    Expression<double>? currentStock,
    Expression<double>? reorderThreshold,
    Expression<double>? costPerUnit,
    Expression<String>? supplier,
    Expression<DateTime>? expiryDate,
    Expression<String>? batchNumber,
    Expression<int>? milkWithdrawalDays,
    Expression<int>? meatWithdrawalDays,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (currentStock != null) 'current_stock': currentStock,
      if (reorderThreshold != null) 'reorder_threshold': reorderThreshold,
      if (costPerUnit != null) 'cost_per_unit': costPerUnit,
      if (supplier != null) 'supplier': supplier,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (milkWithdrawalDays != null)
        'milk_withdrawal_days': milkWithdrawalDays,
      if (meatWithdrawalDays != null)
        'meat_withdrawal_days': meatWithdrawalDays,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMedicationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String>? unit,
      Value<double>? currentStock,
      Value<double>? reorderThreshold,
      Value<double>? costPerUnit,
      Value<String?>? supplier,
      Value<DateTime?>? expiryDate,
      Value<String?>? batchNumber,
      Value<int>? milkWithdrawalDays,
      Value<int>? meatWithdrawalDays,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return LocalMedicationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      reorderThreshold: reorderThreshold ?? this.reorderThreshold,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      supplier: supplier ?? this.supplier,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      milkWithdrawalDays: milkWithdrawalDays ?? this.milkWithdrawalDays,
      meatWithdrawalDays: meatWithdrawalDays ?? this.meatWithdrawalDays,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (currentStock.present) {
      map['current_stock'] = Variable<double>(currentStock.value);
    }
    if (reorderThreshold.present) {
      map['reorder_threshold'] = Variable<double>(reorderThreshold.value);
    }
    if (costPerUnit.present) {
      map['cost_per_unit'] = Variable<double>(costPerUnit.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (milkWithdrawalDays.present) {
      map['milk_withdrawal_days'] = Variable<int>(milkWithdrawalDays.value);
    }
    if (meatWithdrawalDays.present) {
      map['meat_withdrawal_days'] = Variable<int>(meatWithdrawalDays.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMedicationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('currentStock: $currentStock, ')
          ..write('reorderThreshold: $reorderThreshold, ')
          ..write('costPerUnit: $costPerUnit, ')
          ..write('supplier: $supplier, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('milkWithdrawalDays: $milkWithdrawalDays, ')
          ..write('meatWithdrawalDays: $meatWithdrawalDays, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMedicationLogsTable extends LocalMedicationLogs
    with TableInfo<$LocalMedicationLogsTable, LocalMedicationLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMedicationLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _medicationIdMeta =
      const VerificationMeta('medicationId');
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
      'medication_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _changeTypeMeta =
      const VerificationMeta('changeType');
  @override
  late final GeneratedColumn<String> changeType = GeneratedColumn<String>(
      'change_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityChangeMeta =
      const VerificationMeta('quantityChange');
  @override
  late final GeneratedColumn<double> quantityChange = GeneratedColumn<double>(
      'quantity_change', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _balanceAfterMeta =
      const VerificationMeta('balanceAfter');
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
      'balance_after', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _logDateMeta =
      const VerificationMeta('logDate');
  @override
  late final GeneratedColumn<DateTime> logDate = GeneratedColumn<DateTime>(
      'log_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        medicationId,
        changeType,
        quantityChange,
        balanceAfter,
        logDate,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_medication_logs';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMedicationLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
          _medicationIdMeta,
          medicationId.isAcceptableOrUnknown(
              data['medication_id']!, _medicationIdMeta));
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('change_type')) {
      context.handle(
          _changeTypeMeta,
          changeType.isAcceptableOrUnknown(
              data['change_type']!, _changeTypeMeta));
    } else if (isInserting) {
      context.missing(_changeTypeMeta);
    }
    if (data.containsKey('quantity_change')) {
      context.handle(
          _quantityChangeMeta,
          quantityChange.isAcceptableOrUnknown(
              data['quantity_change']!, _quantityChangeMeta));
    } else if (isInserting) {
      context.missing(_quantityChangeMeta);
    }
    if (data.containsKey('balance_after')) {
      context.handle(
          _balanceAfterMeta,
          balanceAfter.isAcceptableOrUnknown(
              data['balance_after']!, _balanceAfterMeta));
    } else if (isInserting) {
      context.missing(_balanceAfterMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(_logDateMeta,
          logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta));
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMedicationLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMedicationLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      medicationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medication_id'])!,
      changeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}change_type'])!,
      quantityChange: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}quantity_change'])!,
      balanceAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance_after'])!,
      logDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}log_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $LocalMedicationLogsTable createAlias(String alias) {
    return $LocalMedicationLogsTable(attachedDatabase, alias);
  }
}

class LocalMedicationLog extends DataClass
    implements Insertable<LocalMedicationLog> {
  final String id;
  final String medicationId;
  final String changeType;
  final double quantityChange;
  final double balanceAfter;
  final DateTime logDate;
  final String? notes;
  const LocalMedicationLog(
      {required this.id,
      required this.medicationId,
      required this.changeType,
      required this.quantityChange,
      required this.balanceAfter,
      required this.logDate,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['medication_id'] = Variable<String>(medicationId);
    map['change_type'] = Variable<String>(changeType);
    map['quantity_change'] = Variable<double>(quantityChange);
    map['balance_after'] = Variable<double>(balanceAfter);
    map['log_date'] = Variable<DateTime>(logDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalMedicationLogsCompanion toCompanion(bool nullToAbsent) {
    return LocalMedicationLogsCompanion(
      id: Value(id),
      medicationId: Value(medicationId),
      changeType: Value(changeType),
      quantityChange: Value(quantityChange),
      balanceAfter: Value(balanceAfter),
      logDate: Value(logDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory LocalMedicationLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMedicationLog(
      id: serializer.fromJson<String>(json['id']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      changeType: serializer.fromJson<String>(json['changeType']),
      quantityChange: serializer.fromJson<double>(json['quantityChange']),
      balanceAfter: serializer.fromJson<double>(json['balanceAfter']),
      logDate: serializer.fromJson<DateTime>(json['logDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicationId': serializer.toJson<String>(medicationId),
      'changeType': serializer.toJson<String>(changeType),
      'quantityChange': serializer.toJson<double>(quantityChange),
      'balanceAfter': serializer.toJson<double>(balanceAfter),
      'logDate': serializer.toJson<DateTime>(logDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalMedicationLog copyWith(
          {String? id,
          String? medicationId,
          String? changeType,
          double? quantityChange,
          double? balanceAfter,
          DateTime? logDate,
          Value<String?> notes = const Value.absent()}) =>
      LocalMedicationLog(
        id: id ?? this.id,
        medicationId: medicationId ?? this.medicationId,
        changeType: changeType ?? this.changeType,
        quantityChange: quantityChange ?? this.quantityChange,
        balanceAfter: balanceAfter ?? this.balanceAfter,
        logDate: logDate ?? this.logDate,
        notes: notes.present ? notes.value : this.notes,
      );
  LocalMedicationLog copyWithCompanion(LocalMedicationLogsCompanion data) {
    return LocalMedicationLog(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      changeType:
          data.changeType.present ? data.changeType.value : this.changeType,
      quantityChange: data.quantityChange.present
          ? data.quantityChange.value
          : this.quantityChange,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMedicationLog(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('changeType: $changeType, ')
          ..write('quantityChange: $quantityChange, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('logDate: $logDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, medicationId, changeType, quantityChange,
      balanceAfter, logDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMedicationLog &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.changeType == this.changeType &&
          other.quantityChange == this.quantityChange &&
          other.balanceAfter == this.balanceAfter &&
          other.logDate == this.logDate &&
          other.notes == this.notes);
}

class LocalMedicationLogsCompanion extends UpdateCompanion<LocalMedicationLog> {
  final Value<String> id;
  final Value<String> medicationId;
  final Value<String> changeType;
  final Value<double> quantityChange;
  final Value<double> balanceAfter;
  final Value<DateTime> logDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalMedicationLogsCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.changeType = const Value.absent(),
    this.quantityChange = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.logDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMedicationLogsCompanion.insert({
    required String id,
    required String medicationId,
    required String changeType,
    required double quantityChange,
    required double balanceAfter,
    required DateTime logDate,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        medicationId = Value(medicationId),
        changeType = Value(changeType),
        quantityChange = Value(quantityChange),
        balanceAfter = Value(balanceAfter),
        logDate = Value(logDate);
  static Insertable<LocalMedicationLog> custom({
    Expression<String>? id,
    Expression<String>? medicationId,
    Expression<String>? changeType,
    Expression<double>? quantityChange,
    Expression<double>? balanceAfter,
    Expression<DateTime>? logDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (changeType != null) 'change_type': changeType,
      if (quantityChange != null) 'quantity_change': quantityChange,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (logDate != null) 'log_date': logDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMedicationLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? medicationId,
      Value<String>? changeType,
      Value<double>? quantityChange,
      Value<double>? balanceAfter,
      Value<DateTime>? logDate,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return LocalMedicationLogsCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      changeType: changeType ?? this.changeType,
      quantityChange: quantityChange ?? this.quantityChange,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      logDate: logDate ?? this.logDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (changeType.present) {
      map['change_type'] = Variable<String>(changeType.value);
    }
    if (quantityChange.present) {
      map['quantity_change'] = Variable<double>(quantityChange.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<DateTime>(logDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMedicationLogsCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('changeType: $changeType, ')
          ..write('quantityChange: $quantityChange, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('logDate: $logDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAnimalMedicalRecordsTable extends LocalAnimalMedicalRecords
    with TableInfo<$LocalAnimalMedicalRecordsTable, LocalAnimalMedicalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAnimalMedicalRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _medicationIdMeta =
      const VerificationMeta('medicationId');
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
      'medication_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _administeredDoseMeta =
      const VerificationMeta('administeredDose');
  @override
  late final GeneratedColumn<double> administeredDose = GeneratedColumn<double>(
      'administered_dose', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
      'cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _treatmentDateMeta =
      const VerificationMeta('treatmentDate');
  @override
  late final GeneratedColumn<DateTime> treatmentDate =
      GeneratedColumn<DateTime>('treatment_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _diagnosedConditionMeta =
      const VerificationMeta('diagnosedCondition');
  @override
  late final GeneratedColumn<String> diagnosedCondition =
      GeneratedColumn<String>('diagnosed_condition', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _administeredByMeta =
      const VerificationMeta('administeredBy');
  @override
  late final GeneratedColumn<String> administeredBy = GeneratedColumn<String>(
      'administered_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _withdrawalEndDateMeta =
      const VerificationMeta('withdrawalEndDate');
  @override
  late final GeneratedColumn<DateTime> withdrawalEndDate =
      GeneratedColumn<DateTime>('withdrawal_end_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        animalId,
        medicationId,
        administeredDose,
        cost,
        treatmentDate,
        diagnosedCondition,
        administeredBy,
        withdrawalEndDate,
        notes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_animal_medical_records';
  @override
  VerificationContext validateIntegrity(
      Insertable<LocalAnimalMedicalRecord> instance,
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
    if (data.containsKey('medication_id')) {
      context.handle(
          _medicationIdMeta,
          medicationId.isAcceptableOrUnknown(
              data['medication_id']!, _medicationIdMeta));
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('administered_dose')) {
      context.handle(
          _administeredDoseMeta,
          administeredDose.isAcceptableOrUnknown(
              data['administered_dose']!, _administeredDoseMeta));
    } else if (isInserting) {
      context.missing(_administeredDoseMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
          _costMeta, cost.isAcceptableOrUnknown(data['cost']!, _costMeta));
    } else if (isInserting) {
      context.missing(_costMeta);
    }
    if (data.containsKey('treatment_date')) {
      context.handle(
          _treatmentDateMeta,
          treatmentDate.isAcceptableOrUnknown(
              data['treatment_date']!, _treatmentDateMeta));
    } else if (isInserting) {
      context.missing(_treatmentDateMeta);
    }
    if (data.containsKey('diagnosed_condition')) {
      context.handle(
          _diagnosedConditionMeta,
          diagnosedCondition.isAcceptableOrUnknown(
              data['diagnosed_condition']!, _diagnosedConditionMeta));
    } else if (isInserting) {
      context.missing(_diagnosedConditionMeta);
    }
    if (data.containsKey('administered_by')) {
      context.handle(
          _administeredByMeta,
          administeredBy.isAcceptableOrUnknown(
              data['administered_by']!, _administeredByMeta));
    }
    if (data.containsKey('withdrawal_end_date')) {
      context.handle(
          _withdrawalEndDateMeta,
          withdrawalEndDate.isAcceptableOrUnknown(
              data['withdrawal_end_date']!, _withdrawalEndDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAnimalMedicalRecord map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAnimalMedicalRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      medicationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}medication_id'])!,
      administeredDose: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}administered_dose'])!,
      cost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost'])!,
      treatmentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}treatment_date'])!,
      diagnosedCondition: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}diagnosed_condition'])!,
      administeredBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}administered_by']),
      withdrawalEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}withdrawal_end_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $LocalAnimalMedicalRecordsTable createAlias(String alias) {
    return $LocalAnimalMedicalRecordsTable(attachedDatabase, alias);
  }
}

class LocalAnimalMedicalRecord extends DataClass
    implements Insertable<LocalAnimalMedicalRecord> {
  final String id;
  final String animalId;
  final String medicationId;
  final double administeredDose;
  final double cost;
  final DateTime treatmentDate;
  final String diagnosedCondition;
  final String? administeredBy;
  final DateTime? withdrawalEndDate;
  final String? notes;
  const LocalAnimalMedicalRecord(
      {required this.id,
      required this.animalId,
      required this.medicationId,
      required this.administeredDose,
      required this.cost,
      required this.treatmentDate,
      required this.diagnosedCondition,
      this.administeredBy,
      this.withdrawalEndDate,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['medication_id'] = Variable<String>(medicationId);
    map['administered_dose'] = Variable<double>(administeredDose);
    map['cost'] = Variable<double>(cost);
    map['treatment_date'] = Variable<DateTime>(treatmentDate);
    map['diagnosed_condition'] = Variable<String>(diagnosedCondition);
    if (!nullToAbsent || administeredBy != null) {
      map['administered_by'] = Variable<String>(administeredBy);
    }
    if (!nullToAbsent || withdrawalEndDate != null) {
      map['withdrawal_end_date'] = Variable<DateTime>(withdrawalEndDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalAnimalMedicalRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalAnimalMedicalRecordsCompanion(
      id: Value(id),
      animalId: Value(animalId),
      medicationId: Value(medicationId),
      administeredDose: Value(administeredDose),
      cost: Value(cost),
      treatmentDate: Value(treatmentDate),
      diagnosedCondition: Value(diagnosedCondition),
      administeredBy: administeredBy == null && nullToAbsent
          ? const Value.absent()
          : Value(administeredBy),
      withdrawalEndDate: withdrawalEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(withdrawalEndDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory LocalAnimalMedicalRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAnimalMedicalRecord(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      administeredDose: serializer.fromJson<double>(json['administeredDose']),
      cost: serializer.fromJson<double>(json['cost']),
      treatmentDate: serializer.fromJson<DateTime>(json['treatmentDate']),
      diagnosedCondition:
          serializer.fromJson<String>(json['diagnosedCondition']),
      administeredBy: serializer.fromJson<String?>(json['administeredBy']),
      withdrawalEndDate:
          serializer.fromJson<DateTime?>(json['withdrawalEndDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'medicationId': serializer.toJson<String>(medicationId),
      'administeredDose': serializer.toJson<double>(administeredDose),
      'cost': serializer.toJson<double>(cost),
      'treatmentDate': serializer.toJson<DateTime>(treatmentDate),
      'diagnosedCondition': serializer.toJson<String>(diagnosedCondition),
      'administeredBy': serializer.toJson<String?>(administeredBy),
      'withdrawalEndDate': serializer.toJson<DateTime?>(withdrawalEndDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalAnimalMedicalRecord copyWith(
          {String? id,
          String? animalId,
          String? medicationId,
          double? administeredDose,
          double? cost,
          DateTime? treatmentDate,
          String? diagnosedCondition,
          Value<String?> administeredBy = const Value.absent(),
          Value<DateTime?> withdrawalEndDate = const Value.absent(),
          Value<String?> notes = const Value.absent()}) =>
      LocalAnimalMedicalRecord(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        medicationId: medicationId ?? this.medicationId,
        administeredDose: administeredDose ?? this.administeredDose,
        cost: cost ?? this.cost,
        treatmentDate: treatmentDate ?? this.treatmentDate,
        diagnosedCondition: diagnosedCondition ?? this.diagnosedCondition,
        administeredBy:
            administeredBy.present ? administeredBy.value : this.administeredBy,
        withdrawalEndDate: withdrawalEndDate.present
            ? withdrawalEndDate.value
            : this.withdrawalEndDate,
        notes: notes.present ? notes.value : this.notes,
      );
  LocalAnimalMedicalRecord copyWithCompanion(
      LocalAnimalMedicalRecordsCompanion data) {
    return LocalAnimalMedicalRecord(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      administeredDose: data.administeredDose.present
          ? data.administeredDose.value
          : this.administeredDose,
      cost: data.cost.present ? data.cost.value : this.cost,
      treatmentDate: data.treatmentDate.present
          ? data.treatmentDate.value
          : this.treatmentDate,
      diagnosedCondition: data.diagnosedCondition.present
          ? data.diagnosedCondition.value
          : this.diagnosedCondition,
      administeredBy: data.administeredBy.present
          ? data.administeredBy.value
          : this.administeredBy,
      withdrawalEndDate: data.withdrawalEndDate.present
          ? data.withdrawalEndDate.value
          : this.withdrawalEndDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalMedicalRecord(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('medicationId: $medicationId, ')
          ..write('administeredDose: $administeredDose, ')
          ..write('cost: $cost, ')
          ..write('treatmentDate: $treatmentDate, ')
          ..write('diagnosedCondition: $diagnosedCondition, ')
          ..write('administeredBy: $administeredBy, ')
          ..write('withdrawalEndDate: $withdrawalEndDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      animalId,
      medicationId,
      administeredDose,
      cost,
      treatmentDate,
      diagnosedCondition,
      administeredBy,
      withdrawalEndDate,
      notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAnimalMedicalRecord &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.medicationId == this.medicationId &&
          other.administeredDose == this.administeredDose &&
          other.cost == this.cost &&
          other.treatmentDate == this.treatmentDate &&
          other.diagnosedCondition == this.diagnosedCondition &&
          other.administeredBy == this.administeredBy &&
          other.withdrawalEndDate == this.withdrawalEndDate &&
          other.notes == this.notes);
}

class LocalAnimalMedicalRecordsCompanion
    extends UpdateCompanion<LocalAnimalMedicalRecord> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String> medicationId;
  final Value<double> administeredDose;
  final Value<double> cost;
  final Value<DateTime> treatmentDate;
  final Value<String> diagnosedCondition;
  final Value<String?> administeredBy;
  final Value<DateTime?> withdrawalEndDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalAnimalMedicalRecordsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.administeredDose = const Value.absent(),
    this.cost = const Value.absent(),
    this.treatmentDate = const Value.absent(),
    this.diagnosedCondition = const Value.absent(),
    this.administeredBy = const Value.absent(),
    this.withdrawalEndDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAnimalMedicalRecordsCompanion.insert({
    required String id,
    required String animalId,
    required String medicationId,
    required double administeredDose,
    required double cost,
    required DateTime treatmentDate,
    required String diagnosedCondition,
    this.administeredBy = const Value.absent(),
    this.withdrawalEndDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        medicationId = Value(medicationId),
        administeredDose = Value(administeredDose),
        cost = Value(cost),
        treatmentDate = Value(treatmentDate),
        diagnosedCondition = Value(diagnosedCondition);
  static Insertable<LocalAnimalMedicalRecord> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? medicationId,
    Expression<double>? administeredDose,
    Expression<double>? cost,
    Expression<DateTime>? treatmentDate,
    Expression<String>? diagnosedCondition,
    Expression<String>? administeredBy,
    Expression<DateTime>? withdrawalEndDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (medicationId != null) 'medication_id': medicationId,
      if (administeredDose != null) 'administered_dose': administeredDose,
      if (cost != null) 'cost': cost,
      if (treatmentDate != null) 'treatment_date': treatmentDate,
      if (diagnosedCondition != null) 'diagnosed_condition': diagnosedCondition,
      if (administeredBy != null) 'administered_by': administeredBy,
      if (withdrawalEndDate != null) 'withdrawal_end_date': withdrawalEndDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAnimalMedicalRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? animalId,
      Value<String>? medicationId,
      Value<double>? administeredDose,
      Value<double>? cost,
      Value<DateTime>? treatmentDate,
      Value<String>? diagnosedCondition,
      Value<String?>? administeredBy,
      Value<DateTime?>? withdrawalEndDate,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return LocalAnimalMedicalRecordsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      medicationId: medicationId ?? this.medicationId,
      administeredDose: administeredDose ?? this.administeredDose,
      cost: cost ?? this.cost,
      treatmentDate: treatmentDate ?? this.treatmentDate,
      diagnosedCondition: diagnosedCondition ?? this.diagnosedCondition,
      administeredBy: administeredBy ?? this.administeredBy,
      withdrawalEndDate: withdrawalEndDate ?? this.withdrawalEndDate,
      notes: notes ?? this.notes,
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
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (administeredDose.present) {
      map['administered_dose'] = Variable<double>(administeredDose.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (treatmentDate.present) {
      map['treatment_date'] = Variable<DateTime>(treatmentDate.value);
    }
    if (diagnosedCondition.present) {
      map['diagnosed_condition'] = Variable<String>(diagnosedCondition.value);
    }
    if (administeredBy.present) {
      map['administered_by'] = Variable<String>(administeredBy.value);
    }
    if (withdrawalEndDate.present) {
      map['withdrawal_end_date'] = Variable<DateTime>(withdrawalEndDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAnimalMedicalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('medicationId: $medicationId, ')
          ..write('administeredDose: $administeredDose, ')
          ..write('cost: $cost, ')
          ..write('treatmentDate: $treatmentDate, ')
          ..write('diagnosedCondition: $diagnosedCondition, ')
          ..write('administeredBy: $administeredBy, ')
          ..write('withdrawalEndDate: $withdrawalEndDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalStaffTable extends LocalStaff
    with TableInfo<$LocalStaffTable, LocalStaffData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStaffTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _baseSalaryMeta =
      const VerificationMeta('baseSalary');
  @override
  late final GeneratedColumn<double> baseSalary = GeneratedColumn<double>(
      'base_salary', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _performanceRatingMeta =
      const VerificationMeta('performanceRating');
  @override
  late final GeneratedColumn<double> performanceRating =
      GeneratedColumn<double>('performance_rating', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(5.0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _profilePicMeta =
      const VerificationMeta('profilePic');
  @override
  late final GeneratedColumn<String> profilePic = GeneratedColumn<String>(
      'profile_pic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emergencyContactMeta =
      const VerificationMeta('emergencyContact');
  @override
  late final GeneratedColumn<String> emergencyContact = GeneratedColumn<String>(
      'emergency_contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _employmentTypeMeta =
      const VerificationMeta('employmentType');
  @override
  late final GeneratedColumn<String> employmentType = GeneratedColumn<String>(
      'employment_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        role,
        phone,
        baseSalary,
        performanceRating,
        isActive,
        profilePic,
        gender,
        dateOfBirth,
        address,
        emergencyContact,
        employmentType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_staff';
  @override
  VerificationContext validateIntegrity(Insertable<LocalStaffData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('base_salary')) {
      context.handle(
          _baseSalaryMeta,
          baseSalary.isAcceptableOrUnknown(
              data['base_salary']!, _baseSalaryMeta));
    }
    if (data.containsKey('performance_rating')) {
      context.handle(
          _performanceRatingMeta,
          performanceRating.isAcceptableOrUnknown(
              data['performance_rating']!, _performanceRatingMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('profile_pic')) {
      context.handle(
          _profilePicMeta,
          profilePic.isAcceptableOrUnknown(
              data['profile_pic']!, _profilePicMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('emergency_contact')) {
      context.handle(
          _emergencyContactMeta,
          emergencyContact.isAcceptableOrUnknown(
              data['emergency_contact']!, _emergencyContactMeta));
    }
    if (data.containsKey('employment_type')) {
      context.handle(
          _employmentTypeMeta,
          employmentType.isAcceptableOrUnknown(
              data['employment_type']!, _employmentTypeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalStaffData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStaffData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      baseSalary: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}base_salary'])!,
      performanceRating: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}performance_rating'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      profilePic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_pic']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      emergencyContact: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}emergency_contact']),
      employmentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}employment_type']),
    );
  }

  @override
  $LocalStaffTable createAlias(String alias) {
    return $LocalStaffTable(attachedDatabase, alias);
  }
}

class LocalStaffData extends DataClass implements Insertable<LocalStaffData> {
  final String id;
  final String name;
  final String role;
  final String? phone;
  final double baseSalary;
  final double performanceRating;
  final bool isActive;
  final String? profilePic;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final String? emergencyContact;
  final String? employmentType;
  const LocalStaffData(
      {required this.id,
      required this.name,
      required this.role,
      this.phone,
      required this.baseSalary,
      required this.performanceRating,
      required this.isActive,
      this.profilePic,
      this.gender,
      this.dateOfBirth,
      this.address,
      this.emergencyContact,
      this.employmentType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['base_salary'] = Variable<double>(baseSalary);
    map['performance_rating'] = Variable<double>(performanceRating);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || profilePic != null) {
      map['profile_pic'] = Variable<String>(profilePic);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || emergencyContact != null) {
      map['emergency_contact'] = Variable<String>(emergencyContact);
    }
    if (!nullToAbsent || employmentType != null) {
      map['employment_type'] = Variable<String>(employmentType);
    }
    return map;
  }

  LocalStaffCompanion toCompanion(bool nullToAbsent) {
    return LocalStaffCompanion(
      id: Value(id),
      name: Value(name),
      role: Value(role),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      baseSalary: Value(baseSalary),
      performanceRating: Value(performanceRating),
      isActive: Value(isActive),
      profilePic: profilePic == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePic),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      emergencyContact: emergencyContact == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContact),
      employmentType: employmentType == null && nullToAbsent
          ? const Value.absent()
          : Value(employmentType),
    );
  }

  factory LocalStaffData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStaffData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      phone: serializer.fromJson<String?>(json['phone']),
      baseSalary: serializer.fromJson<double>(json['baseSalary']),
      performanceRating: serializer.fromJson<double>(json['performanceRating']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      profilePic: serializer.fromJson<String?>(json['profilePic']),
      gender: serializer.fromJson<String?>(json['gender']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      address: serializer.fromJson<String?>(json['address']),
      emergencyContact: serializer.fromJson<String?>(json['emergencyContact']),
      employmentType: serializer.fromJson<String?>(json['employmentType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'phone': serializer.toJson<String?>(phone),
      'baseSalary': serializer.toJson<double>(baseSalary),
      'performanceRating': serializer.toJson<double>(performanceRating),
      'isActive': serializer.toJson<bool>(isActive),
      'profilePic': serializer.toJson<String?>(profilePic),
      'gender': serializer.toJson<String?>(gender),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'address': serializer.toJson<String?>(address),
      'emergencyContact': serializer.toJson<String?>(emergencyContact),
      'employmentType': serializer.toJson<String?>(employmentType),
    };
  }

  LocalStaffData copyWith(
          {String? id,
          String? name,
          String? role,
          Value<String?> phone = const Value.absent(),
          double? baseSalary,
          double? performanceRating,
          bool? isActive,
          Value<String?> profilePic = const Value.absent(),
          Value<String?> gender = const Value.absent(),
          Value<DateTime?> dateOfBirth = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> emergencyContact = const Value.absent(),
          Value<String?> employmentType = const Value.absent()}) =>
      LocalStaffData(
        id: id ?? this.id,
        name: name ?? this.name,
        role: role ?? this.role,
        phone: phone.present ? phone.value : this.phone,
        baseSalary: baseSalary ?? this.baseSalary,
        performanceRating: performanceRating ?? this.performanceRating,
        isActive: isActive ?? this.isActive,
        profilePic: profilePic.present ? profilePic.value : this.profilePic,
        gender: gender.present ? gender.value : this.gender,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        address: address.present ? address.value : this.address,
        emergencyContact: emergencyContact.present
            ? emergencyContact.value
            : this.emergencyContact,
        employmentType:
            employmentType.present ? employmentType.value : this.employmentType,
      );
  LocalStaffData copyWithCompanion(LocalStaffCompanion data) {
    return LocalStaffData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      phone: data.phone.present ? data.phone.value : this.phone,
      baseSalary:
          data.baseSalary.present ? data.baseSalary.value : this.baseSalary,
      performanceRating: data.performanceRating.present
          ? data.performanceRating.value
          : this.performanceRating,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      profilePic:
          data.profilePic.present ? data.profilePic.value : this.profilePic,
      gender: data.gender.present ? data.gender.value : this.gender,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      address: data.address.present ? data.address.value : this.address,
      emergencyContact: data.emergencyContact.present
          ? data.emergencyContact.value
          : this.emergencyContact,
      employmentType: data.employmentType.present
          ? data.employmentType.value
          : this.employmentType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStaffData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('phone: $phone, ')
          ..write('baseSalary: $baseSalary, ')
          ..write('performanceRating: $performanceRating, ')
          ..write('isActive: $isActive, ')
          ..write('profilePic: $profilePic, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('address: $address, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('employmentType: $employmentType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      role,
      phone,
      baseSalary,
      performanceRating,
      isActive,
      profilePic,
      gender,
      dateOfBirth,
      address,
      emergencyContact,
      employmentType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStaffData &&
          other.id == this.id &&
          other.name == this.name &&
          other.role == this.role &&
          other.phone == this.phone &&
          other.baseSalary == this.baseSalary &&
          other.performanceRating == this.performanceRating &&
          other.isActive == this.isActive &&
          other.profilePic == this.profilePic &&
          other.gender == this.gender &&
          other.dateOfBirth == this.dateOfBirth &&
          other.address == this.address &&
          other.emergencyContact == this.emergencyContact &&
          other.employmentType == this.employmentType);
}

class LocalStaffCompanion extends UpdateCompanion<LocalStaffData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> role;
  final Value<String?> phone;
  final Value<double> baseSalary;
  final Value<double> performanceRating;
  final Value<bool> isActive;
  final Value<String?> profilePic;
  final Value<String?> gender;
  final Value<DateTime?> dateOfBirth;
  final Value<String?> address;
  final Value<String?> emergencyContact;
  final Value<String?> employmentType;
  final Value<int> rowid;
  const LocalStaffCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.phone = const Value.absent(),
    this.baseSalary = const Value.absent(),
    this.performanceRating = const Value.absent(),
    this.isActive = const Value.absent(),
    this.profilePic = const Value.absent(),
    this.gender = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.address = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.employmentType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStaffCompanion.insert({
    required String id,
    required String name,
    required String role,
    this.phone = const Value.absent(),
    this.baseSalary = const Value.absent(),
    this.performanceRating = const Value.absent(),
    this.isActive = const Value.absent(),
    this.profilePic = const Value.absent(),
    this.gender = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.address = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.employmentType = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        role = Value(role);
  static Insertable<LocalStaffData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? phone,
    Expression<double>? baseSalary,
    Expression<double>? performanceRating,
    Expression<bool>? isActive,
    Expression<String>? profilePic,
    Expression<String>? gender,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? address,
    Expression<String>? emergencyContact,
    Expression<String>? employmentType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
      if (baseSalary != null) 'base_salary': baseSalary,
      if (performanceRating != null) 'performance_rating': performanceRating,
      if (isActive != null) 'is_active': isActive,
      if (profilePic != null) 'profile_pic': profilePic,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (address != null) 'address': address,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (employmentType != null) 'employment_type': employmentType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStaffCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? role,
      Value<String?>? phone,
      Value<double>? baseSalary,
      Value<double>? performanceRating,
      Value<bool>? isActive,
      Value<String?>? profilePic,
      Value<String?>? gender,
      Value<DateTime?>? dateOfBirth,
      Value<String?>? address,
      Value<String?>? emergencyContact,
      Value<String?>? employmentType,
      Value<int>? rowid}) {
    return LocalStaffCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      baseSalary: baseSalary ?? this.baseSalary,
      performanceRating: performanceRating ?? this.performanceRating,
      isActive: isActive ?? this.isActive,
      profilePic: profilePic ?? this.profilePic,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      employmentType: employmentType ?? this.employmentType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (baseSalary.present) {
      map['base_salary'] = Variable<double>(baseSalary.value);
    }
    if (performanceRating.present) {
      map['performance_rating'] = Variable<double>(performanceRating.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (profilePic.present) {
      map['profile_pic'] = Variable<String>(profilePic.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (emergencyContact.present) {
      map['emergency_contact'] = Variable<String>(emergencyContact.value);
    }
    if (employmentType.present) {
      map['employment_type'] = Variable<String>(employmentType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStaffCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('phone: $phone, ')
          ..write('baseSalary: $baseSalary, ')
          ..write('performanceRating: $performanceRating, ')
          ..write('isActive: $isActive, ')
          ..write('profilePic: $profilePic, ')
          ..write('gender: $gender, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('address: $address, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('employmentType: $employmentType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalStaffQueriesTable extends LocalStaffQueries
    with TableInfo<$LocalStaffQueriesTable, LocalStaffQuery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStaffQueriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _staffIdMeta =
      const VerificationMeta('staffId');
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
      'staff_id', aliasedName, false,
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
  static const VerificationMeta _deductionAmountMeta =
      const VerificationMeta('deductionAmount');
  @override
  late final GeneratedColumn<double> deductionAmount = GeneratedColumn<double>(
      'deduction_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
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
  static const VerificationMeta _resolutionNotesMeta =
      const VerificationMeta('resolutionNotes');
  @override
  late final GeneratedColumn<String> resolutionNotes = GeneratedColumn<String>(
      'resolution_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resolvedAtMeta =
      const VerificationMeta('resolvedAt');
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
      'resolved_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _issueDateMeta =
      const VerificationMeta('issueDate');
  @override
  late final GeneratedColumn<DateTime> issueDate = GeneratedColumn<DateTime>(
      'issue_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        staffId,
        title,
        description,
        deductionAmount,
        isResolved,
        resolutionNotes,
        resolvedAt,
        issueDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_staff_queries';
  @override
  VerificationContext validateIntegrity(Insertable<LocalStaffQuery> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('staff_id')) {
      context.handle(_staffIdMeta,
          staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta));
    } else if (isInserting) {
      context.missing(_staffIdMeta);
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
    if (data.containsKey('deduction_amount')) {
      context.handle(
          _deductionAmountMeta,
          deductionAmount.isAcceptableOrUnknown(
              data['deduction_amount']!, _deductionAmountMeta));
    }
    if (data.containsKey('is_resolved')) {
      context.handle(
          _isResolvedMeta,
          isResolved.isAcceptableOrUnknown(
              data['is_resolved']!, _isResolvedMeta));
    }
    if (data.containsKey('resolution_notes')) {
      context.handle(
          _resolutionNotesMeta,
          resolutionNotes.isAcceptableOrUnknown(
              data['resolution_notes']!, _resolutionNotesMeta));
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
          _resolvedAtMeta,
          resolvedAt.isAcceptableOrUnknown(
              data['resolved_at']!, _resolvedAtMeta));
    }
    if (data.containsKey('issue_date')) {
      context.handle(_issueDateMeta,
          issueDate.isAcceptableOrUnknown(data['issue_date']!, _issueDateMeta));
    } else if (isInserting) {
      context.missing(_issueDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalStaffQuery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStaffQuery(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      staffId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}staff_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      deductionAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}deduction_amount'])!,
      isResolved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_resolved'])!,
      resolutionNotes: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resolution_notes']),
      resolvedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}resolved_at']),
      issueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}issue_date'])!,
    );
  }

  @override
  $LocalStaffQueriesTable createAlias(String alias) {
    return $LocalStaffQueriesTable(attachedDatabase, alias);
  }
}

class LocalStaffQuery extends DataClass implements Insertable<LocalStaffQuery> {
  final String id;
  final String staffId;
  final String title;
  final String? description;
  final double deductionAmount;
  final bool isResolved;
  final String? resolutionNotes;
  final DateTime? resolvedAt;
  final DateTime issueDate;
  const LocalStaffQuery(
      {required this.id,
      required this.staffId,
      required this.title,
      this.description,
      required this.deductionAmount,
      required this.isResolved,
      this.resolutionNotes,
      this.resolvedAt,
      required this.issueDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['staff_id'] = Variable<String>(staffId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['deduction_amount'] = Variable<double>(deductionAmount);
    map['is_resolved'] = Variable<bool>(isResolved);
    if (!nullToAbsent || resolutionNotes != null) {
      map['resolution_notes'] = Variable<String>(resolutionNotes);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    map['issue_date'] = Variable<DateTime>(issueDate);
    return map;
  }

  LocalStaffQueriesCompanion toCompanion(bool nullToAbsent) {
    return LocalStaffQueriesCompanion(
      id: Value(id),
      staffId: Value(staffId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      deductionAmount: Value(deductionAmount),
      isResolved: Value(isResolved),
      resolutionNotes: resolutionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionNotes),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      issueDate: Value(issueDate),
    );
  }

  factory LocalStaffQuery.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStaffQuery(
      id: serializer.fromJson<String>(json['id']),
      staffId: serializer.fromJson<String>(json['staffId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      deductionAmount: serializer.fromJson<double>(json['deductionAmount']),
      isResolved: serializer.fromJson<bool>(json['isResolved']),
      resolutionNotes: serializer.fromJson<String?>(json['resolutionNotes']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      issueDate: serializer.fromJson<DateTime>(json['issueDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'staffId': serializer.toJson<String>(staffId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'deductionAmount': serializer.toJson<double>(deductionAmount),
      'isResolved': serializer.toJson<bool>(isResolved),
      'resolutionNotes': serializer.toJson<String?>(resolutionNotes),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'issueDate': serializer.toJson<DateTime>(issueDate),
    };
  }

  LocalStaffQuery copyWith(
          {String? id,
          String? staffId,
          String? title,
          Value<String?> description = const Value.absent(),
          double? deductionAmount,
          bool? isResolved,
          Value<String?> resolutionNotes = const Value.absent(),
          Value<DateTime?> resolvedAt = const Value.absent(),
          DateTime? issueDate}) =>
      LocalStaffQuery(
        id: id ?? this.id,
        staffId: staffId ?? this.staffId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        deductionAmount: deductionAmount ?? this.deductionAmount,
        isResolved: isResolved ?? this.isResolved,
        resolutionNotes: resolutionNotes.present
            ? resolutionNotes.value
            : this.resolutionNotes,
        resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
        issueDate: issueDate ?? this.issueDate,
      );
  LocalStaffQuery copyWithCompanion(LocalStaffQueriesCompanion data) {
    return LocalStaffQuery(
      id: data.id.present ? data.id.value : this.id,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      deductionAmount: data.deductionAmount.present
          ? data.deductionAmount.value
          : this.deductionAmount,
      isResolved:
          data.isResolved.present ? data.isResolved.value : this.isResolved,
      resolutionNotes: data.resolutionNotes.present
          ? data.resolutionNotes.value
          : this.resolutionNotes,
      resolvedAt:
          data.resolvedAt.present ? data.resolvedAt.value : this.resolvedAt,
      issueDate: data.issueDate.present ? data.issueDate.value : this.issueDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStaffQuery(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('deductionAmount: $deductionAmount, ')
          ..write('isResolved: $isResolved, ')
          ..write('resolutionNotes: $resolutionNotes, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('issueDate: $issueDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, staffId, title, description,
      deductionAmount, isResolved, resolutionNotes, resolvedAt, issueDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStaffQuery &&
          other.id == this.id &&
          other.staffId == this.staffId &&
          other.title == this.title &&
          other.description == this.description &&
          other.deductionAmount == this.deductionAmount &&
          other.isResolved == this.isResolved &&
          other.resolutionNotes == this.resolutionNotes &&
          other.resolvedAt == this.resolvedAt &&
          other.issueDate == this.issueDate);
}

class LocalStaffQueriesCompanion extends UpdateCompanion<LocalStaffQuery> {
  final Value<String> id;
  final Value<String> staffId;
  final Value<String> title;
  final Value<String?> description;
  final Value<double> deductionAmount;
  final Value<bool> isResolved;
  final Value<String?> resolutionNotes;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime> issueDate;
  final Value<int> rowid;
  const LocalStaffQueriesCompanion({
    this.id = const Value.absent(),
    this.staffId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.deductionAmount = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.resolutionNotes = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.issueDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalStaffQueriesCompanion.insert({
    required String id,
    required String staffId,
    required String title,
    this.description = const Value.absent(),
    this.deductionAmount = const Value.absent(),
    this.isResolved = const Value.absent(),
    this.resolutionNotes = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    required DateTime issueDate,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        staffId = Value(staffId),
        title = Value(title),
        issueDate = Value(issueDate);
  static Insertable<LocalStaffQuery> custom({
    Expression<String>? id,
    Expression<String>? staffId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<double>? deductionAmount,
    Expression<bool>? isResolved,
    Expression<String>? resolutionNotes,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? issueDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (staffId != null) 'staff_id': staffId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (deductionAmount != null) 'deduction_amount': deductionAmount,
      if (isResolved != null) 'is_resolved': isResolved,
      if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (issueDate != null) 'issue_date': issueDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalStaffQueriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? staffId,
      Value<String>? title,
      Value<String?>? description,
      Value<double>? deductionAmount,
      Value<bool>? isResolved,
      Value<String?>? resolutionNotes,
      Value<DateTime?>? resolvedAt,
      Value<DateTime>? issueDate,
      Value<int>? rowid}) {
    return LocalStaffQueriesCompanion(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      title: title ?? this.title,
      description: description ?? this.description,
      deductionAmount: deductionAmount ?? this.deductionAmount,
      isResolved: isResolved ?? this.isResolved,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      issueDate: issueDate ?? this.issueDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (deductionAmount.present) {
      map['deduction_amount'] = Variable<double>(deductionAmount.value);
    }
    if (isResolved.present) {
      map['is_resolved'] = Variable<bool>(isResolved.value);
    }
    if (resolutionNotes.present) {
      map['resolution_notes'] = Variable<String>(resolutionNotes.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (issueDate.present) {
      map['issue_date'] = Variable<DateTime>(issueDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStaffQueriesCompanion(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('deductionAmount: $deductionAmount, ')
          ..write('isResolved: $isResolved, ')
          ..write('resolutionNotes: $resolutionNotes, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('issueDate: $issueDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalFarmEventsTable extends LocalFarmEvents
    with TableInfo<$LocalFarmEventsTable, LocalFarmEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFarmEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
      'event_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _involvedAnimalsMeta =
      const VerificationMeta('involvedAnimals');
  @override
  late final GeneratedColumn<String> involvedAnimals = GeneratedColumn<String>(
      'involved_animals', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, eventType, eventDate, involvedAnimals, description, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_farm_events';
  @override
  VerificationContext validateIntegrity(Insertable<LocalFarmEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('involved_animals')) {
      context.handle(
          _involvedAnimalsMeta,
          involvedAnimals.isAcceptableOrUnknown(
              data['involved_animals']!, _involvedAnimalsMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFarmEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFarmEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}event_date'])!,
      involvedAnimals: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}involved_animals']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LocalFarmEventsTable createAlias(String alias) {
    return $LocalFarmEventsTable(attachedDatabase, alias);
  }
}

class LocalFarmEvent extends DataClass implements Insertable<LocalFarmEvent> {
  final String id;
  final String eventType;
  final DateTime eventDate;
  final String? involvedAnimals;
  final String description;
  final DateTime createdAt;
  const LocalFarmEvent(
      {required this.id,
      required this.eventType,
      required this.eventDate,
      this.involvedAnimals,
      required this.description,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_type'] = Variable<String>(eventType);
    map['event_date'] = Variable<DateTime>(eventDate);
    if (!nullToAbsent || involvedAnimals != null) {
      map['involved_animals'] = Variable<String>(involvedAnimals);
    }
    map['description'] = Variable<String>(description);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalFarmEventsCompanion toCompanion(bool nullToAbsent) {
    return LocalFarmEventsCompanion(
      id: Value(id),
      eventType: Value(eventType),
      eventDate: Value(eventDate),
      involvedAnimals: involvedAnimals == null && nullToAbsent
          ? const Value.absent()
          : Value(involvedAnimals),
      description: Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory LocalFarmEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFarmEvent(
      id: serializer.fromJson<String>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      involvedAnimals: serializer.fromJson<String?>(json['involvedAnimals']),
      description: serializer.fromJson<String>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventType': serializer.toJson<String>(eventType),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'involvedAnimals': serializer.toJson<String?>(involvedAnimals),
      'description': serializer.toJson<String>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalFarmEvent copyWith(
          {String? id,
          String? eventType,
          DateTime? eventDate,
          Value<String?> involvedAnimals = const Value.absent(),
          String? description,
          DateTime? createdAt}) =>
      LocalFarmEvent(
        id: id ?? this.id,
        eventType: eventType ?? this.eventType,
        eventDate: eventDate ?? this.eventDate,
        involvedAnimals: involvedAnimals.present
            ? involvedAnimals.value
            : this.involvedAnimals,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
      );
  LocalFarmEvent copyWithCompanion(LocalFarmEventsCompanion data) {
    return LocalFarmEvent(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      involvedAnimals: data.involvedAnimals.present
          ? data.involvedAnimals.value
          : this.involvedAnimals,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFarmEvent(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('eventDate: $eventDate, ')
          ..write('involvedAnimals: $involvedAnimals, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, eventType, eventDate, involvedAnimals, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFarmEvent &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.eventDate == this.eventDate &&
          other.involvedAnimals == this.involvedAnimals &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class LocalFarmEventsCompanion extends UpdateCompanion<LocalFarmEvent> {
  final Value<String> id;
  final Value<String> eventType;
  final Value<DateTime> eventDate;
  final Value<String?> involvedAnimals;
  final Value<String> description;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalFarmEventsCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.involvedAnimals = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalFarmEventsCompanion.insert({
    required String id,
    required String eventType,
    required DateTime eventDate,
    this.involvedAnimals = const Value.absent(),
    required String description,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        eventType = Value(eventType),
        eventDate = Value(eventDate),
        description = Value(description);
  static Insertable<LocalFarmEvent> custom({
    Expression<String>? id,
    Expression<String>? eventType,
    Expression<DateTime>? eventDate,
    Expression<String>? involvedAnimals,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (eventDate != null) 'event_date': eventDate,
      if (involvedAnimals != null) 'involved_animals': involvedAnimals,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalFarmEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? eventType,
      Value<DateTime>? eventDate,
      Value<String?>? involvedAnimals,
      Value<String>? description,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LocalFarmEventsCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      involvedAnimals: involvedAnimals ?? this.involvedAnimals,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (involvedAnimals.present) {
      map['involved_animals'] = Variable<String>(involvedAnimals.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFarmEventsCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('eventDate: $eventDate, ')
          ..write('involvedAnimals: $involvedAnimals, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalBreedingEventsTable extends LocalBreedingEvents
    with TableInfo<$LocalBreedingEventsTable, LocalBreedingEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBreedingEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
      'event_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sireIdMeta = const VerificationMeta('sireId');
  @override
  late final GeneratedColumn<String> sireId = GeneratedColumn<String>(
      'sire_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _semenBatchIdMeta =
      const VerificationMeta('semenBatchId');
  @override
  late final GeneratedColumn<String> semenBatchId = GeneratedColumn<String>(
      'semen_batch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _technicianMeta =
      const VerificationMeta('technician');
  @override
  late final GeneratedColumn<String> technician = GeneratedColumn<String>(
      'technician', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        animalId,
        eventType,
        eventDate,
        sireId,
        semenBatchId,
        technician,
        result,
        notes,
        payload,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_breeding_events';
  @override
  VerificationContext validateIntegrity(Insertable<LocalBreedingEvent> instance,
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
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('sire_id')) {
      context.handle(_sireIdMeta,
          sireId.isAcceptableOrUnknown(data['sire_id']!, _sireIdMeta));
    }
    if (data.containsKey('semen_batch_id')) {
      context.handle(
          _semenBatchIdMeta,
          semenBatchId.isAcceptableOrUnknown(
              data['semen_batch_id']!, _semenBatchIdMeta));
    }
    if (data.containsKey('technician')) {
      context.handle(
          _technicianMeta,
          technician.isAcceptableOrUnknown(
              data['technician']!, _technicianMeta));
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalBreedingEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBreedingEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      animalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}animal_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}event_date'])!,
      sireId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sire_id']),
      semenBatchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}semen_batch_id']),
      technician: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}technician']),
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LocalBreedingEventsTable createAlias(String alias) {
    return $LocalBreedingEventsTable(attachedDatabase, alias);
  }
}

class LocalBreedingEvent extends DataClass
    implements Insertable<LocalBreedingEvent> {
  final String id;
  final String animalId;
  final String eventType;
  final DateTime eventDate;
  final String? sireId;
  final String? semenBatchId;
  final String? technician;
  final String? result;
  final String? notes;
  final String? payload;
  final DateTime createdAt;
  const LocalBreedingEvent(
      {required this.id,
      required this.animalId,
      required this.eventType,
      required this.eventDate,
      this.sireId,
      this.semenBatchId,
      this.technician,
      this.result,
      this.notes,
      this.payload,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['animal_id'] = Variable<String>(animalId);
    map['event_type'] = Variable<String>(eventType);
    map['event_date'] = Variable<DateTime>(eventDate);
    if (!nullToAbsent || sireId != null) {
      map['sire_id'] = Variable<String>(sireId);
    }
    if (!nullToAbsent || semenBatchId != null) {
      map['semen_batch_id'] = Variable<String>(semenBatchId);
    }
    if (!nullToAbsent || technician != null) {
      map['technician'] = Variable<String>(technician);
    }
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalBreedingEventsCompanion toCompanion(bool nullToAbsent) {
    return LocalBreedingEventsCompanion(
      id: Value(id),
      animalId: Value(animalId),
      eventType: Value(eventType),
      eventDate: Value(eventDate),
      sireId:
          sireId == null && nullToAbsent ? const Value.absent() : Value(sireId),
      semenBatchId: semenBatchId == null && nullToAbsent
          ? const Value.absent()
          : Value(semenBatchId),
      technician: technician == null && nullToAbsent
          ? const Value.absent()
          : Value(technician),
      result:
          result == null && nullToAbsent ? const Value.absent() : Value(result),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory LocalBreedingEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBreedingEvent(
      id: serializer.fromJson<String>(json['id']),
      animalId: serializer.fromJson<String>(json['animalId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      sireId: serializer.fromJson<String?>(json['sireId']),
      semenBatchId: serializer.fromJson<String?>(json['semenBatchId']),
      technician: serializer.fromJson<String?>(json['technician']),
      result: serializer.fromJson<String?>(json['result']),
      notes: serializer.fromJson<String?>(json['notes']),
      payload: serializer.fromJson<String?>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'animalId': serializer.toJson<String>(animalId),
      'eventType': serializer.toJson<String>(eventType),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'sireId': serializer.toJson<String?>(sireId),
      'semenBatchId': serializer.toJson<String?>(semenBatchId),
      'technician': serializer.toJson<String?>(technician),
      'result': serializer.toJson<String?>(result),
      'notes': serializer.toJson<String?>(notes),
      'payload': serializer.toJson<String?>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalBreedingEvent copyWith(
          {String? id,
          String? animalId,
          String? eventType,
          DateTime? eventDate,
          Value<String?> sireId = const Value.absent(),
          Value<String?> semenBatchId = const Value.absent(),
          Value<String?> technician = const Value.absent(),
          Value<String?> result = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<String?> payload = const Value.absent(),
          DateTime? createdAt}) =>
      LocalBreedingEvent(
        id: id ?? this.id,
        animalId: animalId ?? this.animalId,
        eventType: eventType ?? this.eventType,
        eventDate: eventDate ?? this.eventDate,
        sireId: sireId.present ? sireId.value : this.sireId,
        semenBatchId:
            semenBatchId.present ? semenBatchId.value : this.semenBatchId,
        technician: technician.present ? technician.value : this.technician,
        result: result.present ? result.value : this.result,
        notes: notes.present ? notes.value : this.notes,
        payload: payload.present ? payload.value : this.payload,
        createdAt: createdAt ?? this.createdAt,
      );
  LocalBreedingEvent copyWithCompanion(LocalBreedingEventsCompanion data) {
    return LocalBreedingEvent(
      id: data.id.present ? data.id.value : this.id,
      animalId: data.animalId.present ? data.animalId.value : this.animalId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      sireId: data.sireId.present ? data.sireId.value : this.sireId,
      semenBatchId: data.semenBatchId.present
          ? data.semenBatchId.value
          : this.semenBatchId,
      technician:
          data.technician.present ? data.technician.value : this.technician,
      result: data.result.present ? data.result.value : this.result,
      notes: data.notes.present ? data.notes.value : this.notes,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBreedingEvent(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('eventType: $eventType, ')
          ..write('eventDate: $eventDate, ')
          ..write('sireId: $sireId, ')
          ..write('semenBatchId: $semenBatchId, ')
          ..write('technician: $technician, ')
          ..write('result: $result, ')
          ..write('notes: $notes, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, animalId, eventType, eventDate, sireId,
      semenBatchId, technician, result, notes, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBreedingEvent &&
          other.id == this.id &&
          other.animalId == this.animalId &&
          other.eventType == this.eventType &&
          other.eventDate == this.eventDate &&
          other.sireId == this.sireId &&
          other.semenBatchId == this.semenBatchId &&
          other.technician == this.technician &&
          other.result == this.result &&
          other.notes == this.notes &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class LocalBreedingEventsCompanion extends UpdateCompanion<LocalBreedingEvent> {
  final Value<String> id;
  final Value<String> animalId;
  final Value<String> eventType;
  final Value<DateTime> eventDate;
  final Value<String?> sireId;
  final Value<String?> semenBatchId;
  final Value<String?> technician;
  final Value<String?> result;
  final Value<String?> notes;
  final Value<String?> payload;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalBreedingEventsCompanion({
    this.id = const Value.absent(),
    this.animalId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.sireId = const Value.absent(),
    this.semenBatchId = const Value.absent(),
    this.technician = const Value.absent(),
    this.result = const Value.absent(),
    this.notes = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalBreedingEventsCompanion.insert({
    required String id,
    required String animalId,
    required String eventType,
    required DateTime eventDate,
    this.sireId = const Value.absent(),
    this.semenBatchId = const Value.absent(),
    this.technician = const Value.absent(),
    this.result = const Value.absent(),
    this.notes = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        animalId = Value(animalId),
        eventType = Value(eventType),
        eventDate = Value(eventDate);
  static Insertable<LocalBreedingEvent> custom({
    Expression<String>? id,
    Expression<String>? animalId,
    Expression<String>? eventType,
    Expression<DateTime>? eventDate,
    Expression<String>? sireId,
    Expression<String>? semenBatchId,
    Expression<String>? technician,
    Expression<String>? result,
    Expression<String>? notes,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (animalId != null) 'animal_id': animalId,
      if (eventType != null) 'event_type': eventType,
      if (eventDate != null) 'event_date': eventDate,
      if (sireId != null) 'sire_id': sireId,
      if (semenBatchId != null) 'semen_batch_id': semenBatchId,
      if (technician != null) 'technician': technician,
      if (result != null) 'result': result,
      if (notes != null) 'notes': notes,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalBreedingEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? animalId,
      Value<String>? eventType,
      Value<DateTime>? eventDate,
      Value<String?>? sireId,
      Value<String?>? semenBatchId,
      Value<String?>? technician,
      Value<String?>? result,
      Value<String?>? notes,
      Value<String?>? payload,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LocalBreedingEventsCompanion(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      sireId: sireId ?? this.sireId,
      semenBatchId: semenBatchId ?? this.semenBatchId,
      technician: technician ?? this.technician,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
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
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (sireId.present) {
      map['sire_id'] = Variable<String>(sireId.value);
    }
    if (semenBatchId.present) {
      map['semen_batch_id'] = Variable<String>(semenBatchId.value);
    }
    if (technician.present) {
      map['technician'] = Variable<String>(technician.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBreedingEventsCompanion(')
          ..write('id: $id, ')
          ..write('animalId: $animalId, ')
          ..write('eventType: $eventType, ')
          ..write('eventDate: $eventDate, ')
          ..write('sireId: $sireId, ')
          ..write('semenBatchId: $semenBatchId, ')
          ..write('technician: $technician, ')
          ..write('result: $result, ')
          ..write('notes: $notes, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
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
  late final $LocalFeedItemsTable localFeedItems = $LocalFeedItemsTable(this);
  late final $LocalInventoryLogsTable localInventoryLogs =
      $LocalInventoryLogsTable(this);
  late final $LocalHatcheryBatchesTable localHatcheryBatches =
      $LocalHatcheryBatchesTable(this);
  late final $LocalHatcheryEventsTable localHatcheryEvents =
      $LocalHatcheryEventsTable(this);
  late final $LocalFeedFormulasTable localFeedFormulas =
      $LocalFeedFormulasTable(this);
  late final $LocalFormulaIngredientsTable localFormulaIngredients =
      $LocalFormulaIngredientsTable(this);
  late final $LocalFeedConsumptionLogsTable localFeedConsumptionLogs =
      $LocalFeedConsumptionLogsTable(this);
  late final $LocalFeedingPlansTable localFeedingPlans =
      $LocalFeedingPlansTable(this);
  late final $LocalMedicationsTable localMedications =
      $LocalMedicationsTable(this);
  late final $LocalMedicationLogsTable localMedicationLogs =
      $LocalMedicationLogsTable(this);
  late final $LocalAnimalMedicalRecordsTable localAnimalMedicalRecords =
      $LocalAnimalMedicalRecordsTable(this);
  late final $LocalStaffTable localStaff = $LocalStaffTable(this);
  late final $LocalStaffQueriesTable localStaffQueries =
      $LocalStaffQueriesTable(this);
  late final $LocalFarmEventsTable localFarmEvents =
      $LocalFarmEventsTable(this);
  late final $LocalBreedingEventsTable localBreedingEvents =
      $LocalBreedingEventsTable(this);
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
        syncQueue,
        localFeedItems,
        localInventoryLogs,
        localHatcheryBatches,
        localHatcheryEvents,
        localFeedFormulas,
        localFormulaIngredients,
        localFeedConsumptionLogs,
        localFeedingPlans,
        localMedications,
        localMedicationLogs,
        localAnimalMedicalRecords,
        localStaff,
        localStaffQueries,
        localFarmEvents,
        localBreedingEvents
      ];
}

typedef $$LocalAnimalsTableCreateCompanionBuilder = LocalAnimalsCompanion
    Function({
  required String id,
  required String tagId,
  required String species,
  Value<String?> breed,
  required String sex,
  Value<DateTime?> dateOfBirth,
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
  Value<String?> dewormingStatus,
  Value<String> status,
  Value<String?> sireId,
  Value<String?> damId,
  Value<int> rowid,
});
typedef $$LocalAnimalsTableUpdateCompanionBuilder = LocalAnimalsCompanion
    Function({
  Value<String> id,
  Value<String> tagId,
  Value<String> species,
  Value<String?> breed,
  Value<String> sex,
  Value<DateTime?> dateOfBirth,
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
  Value<String?> dewormingStatus,
  Value<String> status,
  Value<String?> sireId,
  Value<String?> damId,
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

  ColumnFilters<String> get dewormingStatus => $composableBuilder(
      column: $table.dewormingStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sireId => $composableBuilder(
      column: $table.sireId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get damId => $composableBuilder(
      column: $table.damId, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get dewormingStatus => $composableBuilder(
      column: $table.dewormingStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sireId => $composableBuilder(
      column: $table.sireId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get damId => $composableBuilder(
      column: $table.damId, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get dewormingStatus => $composableBuilder(
      column: $table.dewormingStatus, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get sireId =>
      $composableBuilder(column: $table.sireId, builder: (column) => column);

  GeneratedColumn<String> get damId =>
      $composableBuilder(column: $table.damId, builder: (column) => column);
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
            Value<DateTime?> dateOfBirth = const Value.absent(),
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
            Value<String?> dewormingStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> sireId = const Value.absent(),
            Value<String?> damId = const Value.absent(),
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
            dewormingStatus: dewormingStatus,
            status: status,
            sireId: sireId,
            damId: damId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tagId,
            required String species,
            Value<String?> breed = const Value.absent(),
            required String sex,
            Value<DateTime?> dateOfBirth = const Value.absent(),
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
            Value<String?> dewormingStatus = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> sireId = const Value.absent(),
            Value<String?> damId = const Value.absent(),
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
            dewormingStatus: dewormingStatus,
            status: status,
            sireId: sireId,
            damId: damId,
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
  Value<double?> fatPercentage,
  Value<double?> proteinPercentage,
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
  Value<double?> fatPercentage,
  Value<double?> proteinPercentage,
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

  ColumnFilters<double> get fatPercentage => $composableBuilder(
      column: $table.fatPercentage, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinPercentage => $composableBuilder(
      column: $table.proteinPercentage,
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

  ColumnOrderings<double> get fatPercentage => $composableBuilder(
      column: $table.fatPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinPercentage => $composableBuilder(
      column: $table.proteinPercentage,
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

  GeneratedColumn<double> get fatPercentage => $composableBuilder(
      column: $table.fatPercentage, builder: (column) => column);

  GeneratedColumn<double> get proteinPercentage => $composableBuilder(
      column: $table.proteinPercentage, builder: (column) => column);

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
            Value<double?> fatPercentage = const Value.absent(),
            Value<double?> proteinPercentage = const Value.absent(),
            Value<bool> isWithdrawn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMilkRecordsCompanion(
            id: id,
            animalId: animalId,
            recordDate: recordDate,
            milkingSession: milkingSession,
            quantityLiters: quantityLiters,
            fatPercentage: fatPercentage,
            proteinPercentage: proteinPercentage,
            isWithdrawn: isWithdrawn,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required DateTime recordDate,
            required String milkingSession,
            required double quantityLiters,
            Value<double?> fatPercentage = const Value.absent(),
            Value<double?> proteinPercentage = const Value.absent(),
            Value<bool> isWithdrawn = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMilkRecordsCompanion.insert(
            id: id,
            animalId: animalId,
            recordDate: recordDate,
            milkingSession: milkingSession,
            quantityLiters: quantityLiters,
            fatPercentage: fatPercentage,
            proteinPercentage: proteinPercentage,
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
  Value<String?> category,
  Value<bool> isActionable,
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
  Value<String?> category,
  Value<bool> isActionable,
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

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActionable => $composableBuilder(
      column: $table.isActionable, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActionable => $composableBuilder(
      column: $table.isActionable,
      builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isActionable => $composableBuilder(
      column: $table.isActionable, builder: (column) => column);
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
            Value<String?> category = const Value.absent(),
            Value<bool> isActionable = const Value.absent(),
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
            category: category,
            isActionable: isActionable,
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
            Value<String?> category = const Value.absent(),
            Value<bool> isActionable = const Value.absent(),
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
            category: category,
            isActionable: isActionable,
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
typedef $$LocalFeedItemsTableCreateCompanionBuilder = LocalFeedItemsCompanion
    Function({
  required String id,
  required String name,
  required String category,
  required String unit,
  required double currentStock,
  required double reorderThreshold,
  required double costPerUnit,
  Value<double> weightPerUnit,
  Value<double> costPerKg,
  Value<String?> supplier,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$LocalFeedItemsTableUpdateCompanionBuilder = LocalFeedItemsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String> unit,
  Value<double> currentStock,
  Value<double> reorderThreshold,
  Value<double> costPerUnit,
  Value<double> weightPerUnit,
  Value<double> costPerKg,
  Value<String?> supplier,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$LocalFeedItemsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalFeedItemsTable> {
  $$LocalFeedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get reorderThreshold => $composableBuilder(
      column: $table.reorderThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPerUnit => $composableBuilder(
      column: $table.costPerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightPerUnit => $composableBuilder(
      column: $table.weightPerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPerKg => $composableBuilder(
      column: $table.costPerKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$LocalFeedItemsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalFeedItemsTable> {
  $$LocalFeedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentStock => $composableBuilder(
      column: $table.currentStock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get reorderThreshold => $composableBuilder(
      column: $table.reorderThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPerUnit => $composableBuilder(
      column: $table.costPerUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightPerUnit => $composableBuilder(
      column: $table.weightPerUnit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPerKg => $composableBuilder(
      column: $table.costPerKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$LocalFeedItemsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalFeedItemsTable> {
  $$LocalFeedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => column);

  GeneratedColumn<double> get reorderThreshold => $composableBuilder(
      column: $table.reorderThreshold, builder: (column) => column);

  GeneratedColumn<double> get costPerUnit => $composableBuilder(
      column: $table.costPerUnit, builder: (column) => column);

  GeneratedColumn<double> get weightPerUnit => $composableBuilder(
      column: $table.weightPerUnit, builder: (column) => column);

  GeneratedColumn<double> get costPerKg =>
      $composableBuilder(column: $table.costPerKg, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LocalFeedItemsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalFeedItemsTable,
    LocalFeedItem,
    $$LocalFeedItemsTableFilterComposer,
    $$LocalFeedItemsTableOrderingComposer,
    $$LocalFeedItemsTableAnnotationComposer,
    $$LocalFeedItemsTableCreateCompanionBuilder,
    $$LocalFeedItemsTableUpdateCompanionBuilder,
    (
      LocalFeedItem,
      BaseReferences<_$LocalDatabase, $LocalFeedItemsTable, LocalFeedItem>
    ),
    LocalFeedItem,
    PrefetchHooks Function()> {
  $$LocalFeedItemsTableTableManager(
      _$LocalDatabase db, $LocalFeedItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFeedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFeedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFeedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> currentStock = const Value.absent(),
            Value<double> reorderThreshold = const Value.absent(),
            Value<double> costPerUnit = const Value.absent(),
            Value<double> weightPerUnit = const Value.absent(),
            Value<double> costPerKg = const Value.absent(),
            Value<String?> supplier = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFeedItemsCompanion(
            id: id,
            name: name,
            category: category,
            unit: unit,
            currentStock: currentStock,
            reorderThreshold: reorderThreshold,
            costPerUnit: costPerUnit,
            weightPerUnit: weightPerUnit,
            costPerKg: costPerKg,
            supplier: supplier,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            required String unit,
            required double currentStock,
            required double reorderThreshold,
            required double costPerUnit,
            Value<double> weightPerUnit = const Value.absent(),
            Value<double> costPerKg = const Value.absent(),
            Value<String?> supplier = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFeedItemsCompanion.insert(
            id: id,
            name: name,
            category: category,
            unit: unit,
            currentStock: currentStock,
            reorderThreshold: reorderThreshold,
            costPerUnit: costPerUnit,
            weightPerUnit: weightPerUnit,
            costPerKg: costPerKg,
            supplier: supplier,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFeedItemsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalFeedItemsTable,
    LocalFeedItem,
    $$LocalFeedItemsTableFilterComposer,
    $$LocalFeedItemsTableOrderingComposer,
    $$LocalFeedItemsTableAnnotationComposer,
    $$LocalFeedItemsTableCreateCompanionBuilder,
    $$LocalFeedItemsTableUpdateCompanionBuilder,
    (
      LocalFeedItem,
      BaseReferences<_$LocalDatabase, $LocalFeedItemsTable, LocalFeedItem>
    ),
    LocalFeedItem,
    PrefetchHooks Function()>;
typedef $$LocalInventoryLogsTableCreateCompanionBuilder
    = LocalInventoryLogsCompanion Function({
  required String id,
  required String itemId,
  required String changeType,
  required double quantityChange,
  required double balanceAfter,
  Value<String?> relatedEntityType,
  Value<String?> relatedEntityId,
  Value<String?> notes,
  required DateTime logDate,
  Value<int> rowid,
});
typedef $$LocalInventoryLogsTableUpdateCompanionBuilder
    = LocalInventoryLogsCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String> changeType,
  Value<double> quantityChange,
  Value<double> balanceAfter,
  Value<String?> relatedEntityType,
  Value<String?> relatedEntityId,
  Value<String?> notes,
  Value<DateTime> logDate,
  Value<int> rowid,
});

class $$LocalInventoryLogsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalInventoryLogsTable> {
  $$LocalInventoryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changeType => $composableBuilder(
      column: $table.changeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityChange => $composableBuilder(
      column: $table.quantityChange,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedEntityType => $composableBuilder(
      column: $table.relatedEntityType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedEntityId => $composableBuilder(
      column: $table.relatedEntityId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnFilters(column));
}

class $$LocalInventoryLogsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalInventoryLogsTable> {
  $$LocalInventoryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changeType => $composableBuilder(
      column: $table.changeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityChange => $composableBuilder(
      column: $table.quantityChange,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedEntityType => $composableBuilder(
      column: $table.relatedEntityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedEntityId => $composableBuilder(
      column: $table.relatedEntityId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnOrderings(column));
}

class $$LocalInventoryLogsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalInventoryLogsTable> {
  $$LocalInventoryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get changeType => $composableBuilder(
      column: $table.changeType, builder: (column) => column);

  GeneratedColumn<double> get quantityChange => $composableBuilder(
      column: $table.quantityChange, builder: (column) => column);

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => column);

  GeneratedColumn<String> get relatedEntityType => $composableBuilder(
      column: $table.relatedEntityType, builder: (column) => column);

  GeneratedColumn<String> get relatedEntityId => $composableBuilder(
      column: $table.relatedEntityId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);
}

class $$LocalInventoryLogsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalInventoryLogsTable,
    LocalInventoryLog,
    $$LocalInventoryLogsTableFilterComposer,
    $$LocalInventoryLogsTableOrderingComposer,
    $$LocalInventoryLogsTableAnnotationComposer,
    $$LocalInventoryLogsTableCreateCompanionBuilder,
    $$LocalInventoryLogsTableUpdateCompanionBuilder,
    (
      LocalInventoryLog,
      BaseReferences<_$LocalDatabase, $LocalInventoryLogsTable,
          LocalInventoryLog>
    ),
    LocalInventoryLog,
    PrefetchHooks Function()> {
  $$LocalInventoryLogsTableTableManager(
      _$LocalDatabase db, $LocalInventoryLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInventoryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalInventoryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalInventoryLogsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> changeType = const Value.absent(),
            Value<double> quantityChange = const Value.absent(),
            Value<double> balanceAfter = const Value.absent(),
            Value<String?> relatedEntityType = const Value.absent(),
            Value<String?> relatedEntityId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> logDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalInventoryLogsCompanion(
            id: id,
            itemId: itemId,
            changeType: changeType,
            quantityChange: quantityChange,
            balanceAfter: balanceAfter,
            relatedEntityType: relatedEntityType,
            relatedEntityId: relatedEntityId,
            notes: notes,
            logDate: logDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String itemId,
            required String changeType,
            required double quantityChange,
            required double balanceAfter,
            Value<String?> relatedEntityType = const Value.absent(),
            Value<String?> relatedEntityId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime logDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalInventoryLogsCompanion.insert(
            id: id,
            itemId: itemId,
            changeType: changeType,
            quantityChange: quantityChange,
            balanceAfter: balanceAfter,
            relatedEntityType: relatedEntityType,
            relatedEntityId: relatedEntityId,
            notes: notes,
            logDate: logDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalInventoryLogsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalInventoryLogsTable,
    LocalInventoryLog,
    $$LocalInventoryLogsTableFilterComposer,
    $$LocalInventoryLogsTableOrderingComposer,
    $$LocalInventoryLogsTableAnnotationComposer,
    $$LocalInventoryLogsTableCreateCompanionBuilder,
    $$LocalInventoryLogsTableUpdateCompanionBuilder,
    (
      LocalInventoryLog,
      BaseReferences<_$LocalDatabase, $LocalInventoryLogsTable,
          LocalInventoryLog>
    ),
    LocalInventoryLog,
    PrefetchHooks Function()>;
typedef $$LocalHatcheryBatchesTableCreateCompanionBuilder
    = LocalHatcheryBatchesCompanion Function({
  required String id,
  required String eggSource,
  required int eggCount,
  Value<String?> breed,
  required DateTime setDate,
  required DateTime expectedHatchDate,
  Value<int?> fertileEggs,
  Value<int?> hatchedChicks,
  Value<int?> failedEggs,
  Value<double> initialEggCost,
  Value<String> status,
  Value<int> rowid,
});
typedef $$LocalHatcheryBatchesTableUpdateCompanionBuilder
    = LocalHatcheryBatchesCompanion Function({
  Value<String> id,
  Value<String> eggSource,
  Value<int> eggCount,
  Value<String?> breed,
  Value<DateTime> setDate,
  Value<DateTime> expectedHatchDate,
  Value<int?> fertileEggs,
  Value<int?> hatchedChicks,
  Value<int?> failedEggs,
  Value<double> initialEggCost,
  Value<String> status,
  Value<int> rowid,
});

class $$LocalHatcheryBatchesTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalHatcheryBatchesTable> {
  $$LocalHatcheryBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eggSource => $composableBuilder(
      column: $table.eggSource, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get eggCount => $composableBuilder(
      column: $table.eggCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get setDate => $composableBuilder(
      column: $table.setDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expectedHatchDate => $composableBuilder(
      column: $table.expectedHatchDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fertileEggs => $composableBuilder(
      column: $table.fertileEggs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hatchedChicks => $composableBuilder(
      column: $table.hatchedChicks, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get failedEggs => $composableBuilder(
      column: $table.failedEggs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get initialEggCost => $composableBuilder(
      column: $table.initialEggCost,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$LocalHatcheryBatchesTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalHatcheryBatchesTable> {
  $$LocalHatcheryBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eggSource => $composableBuilder(
      column: $table.eggSource, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get eggCount => $composableBuilder(
      column: $table.eggCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get setDate => $composableBuilder(
      column: $table.setDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expectedHatchDate => $composableBuilder(
      column: $table.expectedHatchDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fertileEggs => $composableBuilder(
      column: $table.fertileEggs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hatchedChicks => $composableBuilder(
      column: $table.hatchedChicks,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get failedEggs => $composableBuilder(
      column: $table.failedEggs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get initialEggCost => $composableBuilder(
      column: $table.initialEggCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$LocalHatcheryBatchesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalHatcheryBatchesTable> {
  $$LocalHatcheryBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eggSource =>
      $composableBuilder(column: $table.eggSource, builder: (column) => column);

  GeneratedColumn<int> get eggCount =>
      $composableBuilder(column: $table.eggCount, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<DateTime> get setDate =>
      $composableBuilder(column: $table.setDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expectedHatchDate => $composableBuilder(
      column: $table.expectedHatchDate, builder: (column) => column);

  GeneratedColumn<int> get fertileEggs => $composableBuilder(
      column: $table.fertileEggs, builder: (column) => column);

  GeneratedColumn<int> get hatchedChicks => $composableBuilder(
      column: $table.hatchedChicks, builder: (column) => column);

  GeneratedColumn<int> get failedEggs => $composableBuilder(
      column: $table.failedEggs, builder: (column) => column);

  GeneratedColumn<double> get initialEggCost => $composableBuilder(
      column: $table.initialEggCost, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$LocalHatcheryBatchesTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalHatcheryBatchesTable,
    LocalHatcheryBatche,
    $$LocalHatcheryBatchesTableFilterComposer,
    $$LocalHatcheryBatchesTableOrderingComposer,
    $$LocalHatcheryBatchesTableAnnotationComposer,
    $$LocalHatcheryBatchesTableCreateCompanionBuilder,
    $$LocalHatcheryBatchesTableUpdateCompanionBuilder,
    (
      LocalHatcheryBatche,
      BaseReferences<_$LocalDatabase, $LocalHatcheryBatchesTable,
          LocalHatcheryBatche>
    ),
    LocalHatcheryBatche,
    PrefetchHooks Function()> {
  $$LocalHatcheryBatchesTableTableManager(
      _$LocalDatabase db, $LocalHatcheryBatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalHatcheryBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalHatcheryBatchesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalHatcheryBatchesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> eggSource = const Value.absent(),
            Value<int> eggCount = const Value.absent(),
            Value<String?> breed = const Value.absent(),
            Value<DateTime> setDate = const Value.absent(),
            Value<DateTime> expectedHatchDate = const Value.absent(),
            Value<int?> fertileEggs = const Value.absent(),
            Value<int?> hatchedChicks = const Value.absent(),
            Value<int?> failedEggs = const Value.absent(),
            Value<double> initialEggCost = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalHatcheryBatchesCompanion(
            id: id,
            eggSource: eggSource,
            eggCount: eggCount,
            breed: breed,
            setDate: setDate,
            expectedHatchDate: expectedHatchDate,
            fertileEggs: fertileEggs,
            hatchedChicks: hatchedChicks,
            failedEggs: failedEggs,
            initialEggCost: initialEggCost,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String eggSource,
            required int eggCount,
            Value<String?> breed = const Value.absent(),
            required DateTime setDate,
            required DateTime expectedHatchDate,
            Value<int?> fertileEggs = const Value.absent(),
            Value<int?> hatchedChicks = const Value.absent(),
            Value<int?> failedEggs = const Value.absent(),
            Value<double> initialEggCost = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalHatcheryBatchesCompanion.insert(
            id: id,
            eggSource: eggSource,
            eggCount: eggCount,
            breed: breed,
            setDate: setDate,
            expectedHatchDate: expectedHatchDate,
            fertileEggs: fertileEggs,
            hatchedChicks: hatchedChicks,
            failedEggs: failedEggs,
            initialEggCost: initialEggCost,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalHatcheryBatchesTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $LocalHatcheryBatchesTable,
        LocalHatcheryBatche,
        $$LocalHatcheryBatchesTableFilterComposer,
        $$LocalHatcheryBatchesTableOrderingComposer,
        $$LocalHatcheryBatchesTableAnnotationComposer,
        $$LocalHatcheryBatchesTableCreateCompanionBuilder,
        $$LocalHatcheryBatchesTableUpdateCompanionBuilder,
        (
          LocalHatcheryBatche,
          BaseReferences<_$LocalDatabase, $LocalHatcheryBatchesTable,
              LocalHatcheryBatche>
        ),
        LocalHatcheryBatche,
        PrefetchHooks Function()>;
typedef $$LocalHatcheryEventsTableCreateCompanionBuilder
    = LocalHatcheryEventsCompanion Function({
  required String id,
  required String batchId,
  required String eventType,
  required DateTime eventDate,
  Value<String?> valueJson,
  Value<int> rowid,
});
typedef $$LocalHatcheryEventsTableUpdateCompanionBuilder
    = LocalHatcheryEventsCompanion Function({
  Value<String> id,
  Value<String> batchId,
  Value<String> eventType,
  Value<DateTime> eventDate,
  Value<String?> valueJson,
  Value<int> rowid,
});

class $$LocalHatcheryEventsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalHatcheryEventsTable> {
  $$LocalHatcheryEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valueJson => $composableBuilder(
      column: $table.valueJson, builder: (column) => ColumnFilters(column));
}

class $$LocalHatcheryEventsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalHatcheryEventsTable> {
  $$LocalHatcheryEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valueJson => $composableBuilder(
      column: $table.valueJson, builder: (column) => ColumnOrderings(column));
}

class $$LocalHatcheryEventsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalHatcheryEventsTable> {
  $$LocalHatcheryEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);
}

class $$LocalHatcheryEventsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalHatcheryEventsTable,
    LocalHatcheryEvent,
    $$LocalHatcheryEventsTableFilterComposer,
    $$LocalHatcheryEventsTableOrderingComposer,
    $$LocalHatcheryEventsTableAnnotationComposer,
    $$LocalHatcheryEventsTableCreateCompanionBuilder,
    $$LocalHatcheryEventsTableUpdateCompanionBuilder,
    (
      LocalHatcheryEvent,
      BaseReferences<_$LocalDatabase, $LocalHatcheryEventsTable,
          LocalHatcheryEvent>
    ),
    LocalHatcheryEvent,
    PrefetchHooks Function()> {
  $$LocalHatcheryEventsTableTableManager(
      _$LocalDatabase db, $LocalHatcheryEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalHatcheryEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalHatcheryEventsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalHatcheryEventsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> batchId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<DateTime> eventDate = const Value.absent(),
            Value<String?> valueJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalHatcheryEventsCompanion(
            id: id,
            batchId: batchId,
            eventType: eventType,
            eventDate: eventDate,
            valueJson: valueJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String batchId,
            required String eventType,
            required DateTime eventDate,
            Value<String?> valueJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalHatcheryEventsCompanion.insert(
            id: id,
            batchId: batchId,
            eventType: eventType,
            eventDate: eventDate,
            valueJson: valueJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalHatcheryEventsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalHatcheryEventsTable,
    LocalHatcheryEvent,
    $$LocalHatcheryEventsTableFilterComposer,
    $$LocalHatcheryEventsTableOrderingComposer,
    $$LocalHatcheryEventsTableAnnotationComposer,
    $$LocalHatcheryEventsTableCreateCompanionBuilder,
    $$LocalHatcheryEventsTableUpdateCompanionBuilder,
    (
      LocalHatcheryEvent,
      BaseReferences<_$LocalDatabase, $LocalHatcheryEventsTable,
          LocalHatcheryEvent>
    ),
    LocalHatcheryEvent,
    PrefetchHooks Function()>;
typedef $$LocalFeedFormulasTableCreateCompanionBuilder
    = LocalFeedFormulasCompanion Function({
  required String id,
  required String name,
  required double batchSize,
  Value<String> batchUnit,
  Value<String?> notes,
  Value<double> currentStock,
  Value<int> rowid,
});
typedef $$LocalFeedFormulasTableUpdateCompanionBuilder
    = LocalFeedFormulasCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> batchSize,
  Value<String> batchUnit,
  Value<String?> notes,
  Value<double> currentStock,
  Value<int> rowid,
});

class $$LocalFeedFormulasTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalFeedFormulasTable> {
  $$LocalFeedFormulasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get batchSize => $composableBuilder(
      column: $table.batchSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchUnit => $composableBuilder(
      column: $table.batchUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => ColumnFilters(column));
}

class $$LocalFeedFormulasTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalFeedFormulasTable> {
  $$LocalFeedFormulasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get batchSize => $composableBuilder(
      column: $table.batchSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchUnit => $composableBuilder(
      column: $table.batchUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentStock => $composableBuilder(
      column: $table.currentStock,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalFeedFormulasTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalFeedFormulasTable> {
  $$LocalFeedFormulasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get batchSize =>
      $composableBuilder(column: $table.batchSize, builder: (column) => column);

  GeneratedColumn<String> get batchUnit =>
      $composableBuilder(column: $table.batchUnit, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => column);
}

class $$LocalFeedFormulasTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalFeedFormulasTable,
    LocalFeedFormula,
    $$LocalFeedFormulasTableFilterComposer,
    $$LocalFeedFormulasTableOrderingComposer,
    $$LocalFeedFormulasTableAnnotationComposer,
    $$LocalFeedFormulasTableCreateCompanionBuilder,
    $$LocalFeedFormulasTableUpdateCompanionBuilder,
    (
      LocalFeedFormula,
      BaseReferences<_$LocalDatabase, $LocalFeedFormulasTable, LocalFeedFormula>
    ),
    LocalFeedFormula,
    PrefetchHooks Function()> {
  $$LocalFeedFormulasTableTableManager(
      _$LocalDatabase db, $LocalFeedFormulasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFeedFormulasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFeedFormulasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFeedFormulasTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> batchSize = const Value.absent(),
            Value<String> batchUnit = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<double> currentStock = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFeedFormulasCompanion(
            id: id,
            name: name,
            batchSize: batchSize,
            batchUnit: batchUnit,
            notes: notes,
            currentStock: currentStock,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double batchSize,
            Value<String> batchUnit = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<double> currentStock = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFeedFormulasCompanion.insert(
            id: id,
            name: name,
            batchSize: batchSize,
            batchUnit: batchUnit,
            notes: notes,
            currentStock: currentStock,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFeedFormulasTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalFeedFormulasTable,
    LocalFeedFormula,
    $$LocalFeedFormulasTableFilterComposer,
    $$LocalFeedFormulasTableOrderingComposer,
    $$LocalFeedFormulasTableAnnotationComposer,
    $$LocalFeedFormulasTableCreateCompanionBuilder,
    $$LocalFeedFormulasTableUpdateCompanionBuilder,
    (
      LocalFeedFormula,
      BaseReferences<_$LocalDatabase, $LocalFeedFormulasTable, LocalFeedFormula>
    ),
    LocalFeedFormula,
    PrefetchHooks Function()>;
typedef $$LocalFormulaIngredientsTableCreateCompanionBuilder
    = LocalFormulaIngredientsCompanion Function({
  required String id,
  required String formulaId,
  required String feedItemId,
  required double percentage,
  required double quantityKg,
  Value<int> rowid,
});
typedef $$LocalFormulaIngredientsTableUpdateCompanionBuilder
    = LocalFormulaIngredientsCompanion Function({
  Value<String> id,
  Value<String> formulaId,
  Value<String> feedItemId,
  Value<double> percentage,
  Value<double> quantityKg,
  Value<int> rowid,
});

class $$LocalFormulaIngredientsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalFormulaIngredientsTable> {
  $$LocalFormulaIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formulaId => $composableBuilder(
      column: $table.formulaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get feedItemId => $composableBuilder(
      column: $table.feedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityKg => $composableBuilder(
      column: $table.quantityKg, builder: (column) => ColumnFilters(column));
}

class $$LocalFormulaIngredientsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalFormulaIngredientsTable> {
  $$LocalFormulaIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formulaId => $composableBuilder(
      column: $table.formulaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get feedItemId => $composableBuilder(
      column: $table.feedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityKg => $composableBuilder(
      column: $table.quantityKg, builder: (column) => ColumnOrderings(column));
}

class $$LocalFormulaIngredientsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalFormulaIngredientsTable> {
  $$LocalFormulaIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get formulaId =>
      $composableBuilder(column: $table.formulaId, builder: (column) => column);

  GeneratedColumn<String> get feedItemId => $composableBuilder(
      column: $table.feedItemId, builder: (column) => column);

  GeneratedColumn<double> get percentage => $composableBuilder(
      column: $table.percentage, builder: (column) => column);

  GeneratedColumn<double> get quantityKg => $composableBuilder(
      column: $table.quantityKg, builder: (column) => column);
}

class $$LocalFormulaIngredientsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalFormulaIngredientsTable,
    LocalFormulaIngredient,
    $$LocalFormulaIngredientsTableFilterComposer,
    $$LocalFormulaIngredientsTableOrderingComposer,
    $$LocalFormulaIngredientsTableAnnotationComposer,
    $$LocalFormulaIngredientsTableCreateCompanionBuilder,
    $$LocalFormulaIngredientsTableUpdateCompanionBuilder,
    (
      LocalFormulaIngredient,
      BaseReferences<_$LocalDatabase, $LocalFormulaIngredientsTable,
          LocalFormulaIngredient>
    ),
    LocalFormulaIngredient,
    PrefetchHooks Function()> {
  $$LocalFormulaIngredientsTableTableManager(
      _$LocalDatabase db, $LocalFormulaIngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFormulaIngredientsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFormulaIngredientsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFormulaIngredientsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> formulaId = const Value.absent(),
            Value<String> feedItemId = const Value.absent(),
            Value<double> percentage = const Value.absent(),
            Value<double> quantityKg = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFormulaIngredientsCompanion(
            id: id,
            formulaId: formulaId,
            feedItemId: feedItemId,
            percentage: percentage,
            quantityKg: quantityKg,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String formulaId,
            required String feedItemId,
            required double percentage,
            required double quantityKg,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFormulaIngredientsCompanion.insert(
            id: id,
            formulaId: formulaId,
            feedItemId: feedItemId,
            percentage: percentage,
            quantityKg: quantityKg,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFormulaIngredientsTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $LocalFormulaIngredientsTable,
        LocalFormulaIngredient,
        $$LocalFormulaIngredientsTableFilterComposer,
        $$LocalFormulaIngredientsTableOrderingComposer,
        $$LocalFormulaIngredientsTableAnnotationComposer,
        $$LocalFormulaIngredientsTableCreateCompanionBuilder,
        $$LocalFormulaIngredientsTableUpdateCompanionBuilder,
        (
          LocalFormulaIngredient,
          BaseReferences<_$LocalDatabase, $LocalFormulaIngredientsTable,
              LocalFormulaIngredient>
        ),
        LocalFormulaIngredient,
        PrefetchHooks Function()>;
typedef $$LocalFeedConsumptionLogsTableCreateCompanionBuilder
    = LocalFeedConsumptionLogsCompanion Function({
  required String id,
  required String animalId,
  required String feedItemId,
  required double quantityKg,
  required DateTime logDate,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$LocalFeedConsumptionLogsTableUpdateCompanionBuilder
    = LocalFeedConsumptionLogsCompanion Function({
  Value<String> id,
  Value<String> animalId,
  Value<String> feedItemId,
  Value<double> quantityKg,
  Value<DateTime> logDate,
  Value<String?> notes,
  Value<int> rowid,
});

class $$LocalFeedConsumptionLogsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalFeedConsumptionLogsTable> {
  $$LocalFeedConsumptionLogsTableFilterComposer({
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

  ColumnFilters<String> get feedItemId => $composableBuilder(
      column: $table.feedItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityKg => $composableBuilder(
      column: $table.quantityKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$LocalFeedConsumptionLogsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalFeedConsumptionLogsTable> {
  $$LocalFeedConsumptionLogsTableOrderingComposer({
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

  ColumnOrderings<String> get feedItemId => $composableBuilder(
      column: $table.feedItemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityKg => $composableBuilder(
      column: $table.quantityKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$LocalFeedConsumptionLogsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalFeedConsumptionLogsTable> {
  $$LocalFeedConsumptionLogsTableAnnotationComposer({
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

  GeneratedColumn<String> get feedItemId => $composableBuilder(
      column: $table.feedItemId, builder: (column) => column);

  GeneratedColumn<double> get quantityKg => $composableBuilder(
      column: $table.quantityKg, builder: (column) => column);

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalFeedConsumptionLogsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalFeedConsumptionLogsTable,
    LocalFeedConsumptionLog,
    $$LocalFeedConsumptionLogsTableFilterComposer,
    $$LocalFeedConsumptionLogsTableOrderingComposer,
    $$LocalFeedConsumptionLogsTableAnnotationComposer,
    $$LocalFeedConsumptionLogsTableCreateCompanionBuilder,
    $$LocalFeedConsumptionLogsTableUpdateCompanionBuilder,
    (
      LocalFeedConsumptionLog,
      BaseReferences<_$LocalDatabase, $LocalFeedConsumptionLogsTable,
          LocalFeedConsumptionLog>
    ),
    LocalFeedConsumptionLog,
    PrefetchHooks Function()> {
  $$LocalFeedConsumptionLogsTableTableManager(
      _$LocalDatabase db, $LocalFeedConsumptionLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFeedConsumptionLogsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFeedConsumptionLogsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFeedConsumptionLogsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> feedItemId = const Value.absent(),
            Value<double> quantityKg = const Value.absent(),
            Value<DateTime> logDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFeedConsumptionLogsCompanion(
            id: id,
            animalId: animalId,
            feedItemId: feedItemId,
            quantityKg: quantityKg,
            logDate: logDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required String feedItemId,
            required double quantityKg,
            required DateTime logDate,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFeedConsumptionLogsCompanion.insert(
            id: id,
            animalId: animalId,
            feedItemId: feedItemId,
            quantityKg: quantityKg,
            logDate: logDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFeedConsumptionLogsTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $LocalFeedConsumptionLogsTable,
        LocalFeedConsumptionLog,
        $$LocalFeedConsumptionLogsTableFilterComposer,
        $$LocalFeedConsumptionLogsTableOrderingComposer,
        $$LocalFeedConsumptionLogsTableAnnotationComposer,
        $$LocalFeedConsumptionLogsTableCreateCompanionBuilder,
        $$LocalFeedConsumptionLogsTableUpdateCompanionBuilder,
        (
          LocalFeedConsumptionLog,
          BaseReferences<_$LocalDatabase, $LocalFeedConsumptionLogsTable,
              LocalFeedConsumptionLog>
        ),
        LocalFeedConsumptionLog,
        PrefetchHooks Function()>;
typedef $$LocalFeedingPlansTableCreateCompanionBuilder
    = LocalFeedingPlansCompanion Function({
  required String id,
  required String animalId,
  required String formulaId,
  required double quantityKg,
  Value<bool> isAutoFeed,
  Value<int> rowid,
});
typedef $$LocalFeedingPlansTableUpdateCompanionBuilder
    = LocalFeedingPlansCompanion Function({
  Value<String> id,
  Value<String> animalId,
  Value<String> formulaId,
  Value<double> quantityKg,
  Value<bool> isAutoFeed,
  Value<int> rowid,
});

class $$LocalFeedingPlansTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalFeedingPlansTable> {
  $$LocalFeedingPlansTableFilterComposer({
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

  ColumnFilters<String> get formulaId => $composableBuilder(
      column: $table.formulaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityKg => $composableBuilder(
      column: $table.quantityKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAutoFeed => $composableBuilder(
      column: $table.isAutoFeed, builder: (column) => ColumnFilters(column));
}

class $$LocalFeedingPlansTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalFeedingPlansTable> {
  $$LocalFeedingPlansTableOrderingComposer({
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

  ColumnOrderings<String> get formulaId => $composableBuilder(
      column: $table.formulaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityKg => $composableBuilder(
      column: $table.quantityKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAutoFeed => $composableBuilder(
      column: $table.isAutoFeed, builder: (column) => ColumnOrderings(column));
}

class $$LocalFeedingPlansTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalFeedingPlansTable> {
  $$LocalFeedingPlansTableAnnotationComposer({
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

  GeneratedColumn<String> get formulaId =>
      $composableBuilder(column: $table.formulaId, builder: (column) => column);

  GeneratedColumn<double> get quantityKg => $composableBuilder(
      column: $table.quantityKg, builder: (column) => column);

  GeneratedColumn<bool> get isAutoFeed => $composableBuilder(
      column: $table.isAutoFeed, builder: (column) => column);
}

class $$LocalFeedingPlansTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalFeedingPlansTable,
    LocalFeedingPlan,
    $$LocalFeedingPlansTableFilterComposer,
    $$LocalFeedingPlansTableOrderingComposer,
    $$LocalFeedingPlansTableAnnotationComposer,
    $$LocalFeedingPlansTableCreateCompanionBuilder,
    $$LocalFeedingPlansTableUpdateCompanionBuilder,
    (
      LocalFeedingPlan,
      BaseReferences<_$LocalDatabase, $LocalFeedingPlansTable, LocalFeedingPlan>
    ),
    LocalFeedingPlan,
    PrefetchHooks Function()> {
  $$LocalFeedingPlansTableTableManager(
      _$LocalDatabase db, $LocalFeedingPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFeedingPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFeedingPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFeedingPlansTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> formulaId = const Value.absent(),
            Value<double> quantityKg = const Value.absent(),
            Value<bool> isAutoFeed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFeedingPlansCompanion(
            id: id,
            animalId: animalId,
            formulaId: formulaId,
            quantityKg: quantityKg,
            isAutoFeed: isAutoFeed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required String formulaId,
            required double quantityKg,
            Value<bool> isAutoFeed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFeedingPlansCompanion.insert(
            id: id,
            animalId: animalId,
            formulaId: formulaId,
            quantityKg: quantityKg,
            isAutoFeed: isAutoFeed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFeedingPlansTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalFeedingPlansTable,
    LocalFeedingPlan,
    $$LocalFeedingPlansTableFilterComposer,
    $$LocalFeedingPlansTableOrderingComposer,
    $$LocalFeedingPlansTableAnnotationComposer,
    $$LocalFeedingPlansTableCreateCompanionBuilder,
    $$LocalFeedingPlansTableUpdateCompanionBuilder,
    (
      LocalFeedingPlan,
      BaseReferences<_$LocalDatabase, $LocalFeedingPlansTable, LocalFeedingPlan>
    ),
    LocalFeedingPlan,
    PrefetchHooks Function()>;
typedef $$LocalMedicationsTableCreateCompanionBuilder
    = LocalMedicationsCompanion Function({
  required String id,
  required String name,
  required String category,
  required String unit,
  Value<double> currentStock,
  Value<double> reorderThreshold,
  Value<double> costPerUnit,
  Value<String?> supplier,
  Value<DateTime?> expiryDate,
  Value<String?> batchNumber,
  Value<int> milkWithdrawalDays,
  Value<int> meatWithdrawalDays,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$LocalMedicationsTableUpdateCompanionBuilder
    = LocalMedicationsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> category,
  Value<String> unit,
  Value<double> currentStock,
  Value<double> reorderThreshold,
  Value<double> costPerUnit,
  Value<String?> supplier,
  Value<DateTime?> expiryDate,
  Value<String?> batchNumber,
  Value<int> milkWithdrawalDays,
  Value<int> meatWithdrawalDays,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$LocalMedicationsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalMedicationsTable> {
  $$LocalMedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get reorderThreshold => $composableBuilder(
      column: $table.reorderThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPerUnit => $composableBuilder(
      column: $table.costPerUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get milkWithdrawalDays => $composableBuilder(
      column: $table.milkWithdrawalDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get meatWithdrawalDays => $composableBuilder(
      column: $table.meatWithdrawalDays,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$LocalMedicationsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalMedicationsTable> {
  $$LocalMedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentStock => $composableBuilder(
      column: $table.currentStock,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get reorderThreshold => $composableBuilder(
      column: $table.reorderThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPerUnit => $composableBuilder(
      column: $table.costPerUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get milkWithdrawalDays => $composableBuilder(
      column: $table.milkWithdrawalDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get meatWithdrawalDays => $composableBuilder(
      column: $table.meatWithdrawalDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$LocalMedicationsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalMedicationsTable> {
  $$LocalMedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get currentStock => $composableBuilder(
      column: $table.currentStock, builder: (column) => column);

  GeneratedColumn<double> get reorderThreshold => $composableBuilder(
      column: $table.reorderThreshold, builder: (column) => column);

  GeneratedColumn<double> get costPerUnit => $composableBuilder(
      column: $table.costPerUnit, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => column);

  GeneratedColumn<String> get batchNumber => $composableBuilder(
      column: $table.batchNumber, builder: (column) => column);

  GeneratedColumn<int> get milkWithdrawalDays => $composableBuilder(
      column: $table.milkWithdrawalDays, builder: (column) => column);

  GeneratedColumn<int> get meatWithdrawalDays => $composableBuilder(
      column: $table.meatWithdrawalDays, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LocalMedicationsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalMedicationsTable,
    LocalMedication,
    $$LocalMedicationsTableFilterComposer,
    $$LocalMedicationsTableOrderingComposer,
    $$LocalMedicationsTableAnnotationComposer,
    $$LocalMedicationsTableCreateCompanionBuilder,
    $$LocalMedicationsTableUpdateCompanionBuilder,
    (
      LocalMedication,
      BaseReferences<_$LocalDatabase, $LocalMedicationsTable, LocalMedication>
    ),
    LocalMedication,
    PrefetchHooks Function()> {
  $$LocalMedicationsTableTableManager(
      _$LocalDatabase db, $LocalMedicationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> currentStock = const Value.absent(),
            Value<double> reorderThreshold = const Value.absent(),
            Value<double> costPerUnit = const Value.absent(),
            Value<String?> supplier = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<String?> batchNumber = const Value.absent(),
            Value<int> milkWithdrawalDays = const Value.absent(),
            Value<int> meatWithdrawalDays = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMedicationsCompanion(
            id: id,
            name: name,
            category: category,
            unit: unit,
            currentStock: currentStock,
            reorderThreshold: reorderThreshold,
            costPerUnit: costPerUnit,
            supplier: supplier,
            expiryDate: expiryDate,
            batchNumber: batchNumber,
            milkWithdrawalDays: milkWithdrawalDays,
            meatWithdrawalDays: meatWithdrawalDays,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String category,
            required String unit,
            Value<double> currentStock = const Value.absent(),
            Value<double> reorderThreshold = const Value.absent(),
            Value<double> costPerUnit = const Value.absent(),
            Value<String?> supplier = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<String?> batchNumber = const Value.absent(),
            Value<int> milkWithdrawalDays = const Value.absent(),
            Value<int> meatWithdrawalDays = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMedicationsCompanion.insert(
            id: id,
            name: name,
            category: category,
            unit: unit,
            currentStock: currentStock,
            reorderThreshold: reorderThreshold,
            costPerUnit: costPerUnit,
            supplier: supplier,
            expiryDate: expiryDate,
            batchNumber: batchNumber,
            milkWithdrawalDays: milkWithdrawalDays,
            meatWithdrawalDays: meatWithdrawalDays,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMedicationsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalMedicationsTable,
    LocalMedication,
    $$LocalMedicationsTableFilterComposer,
    $$LocalMedicationsTableOrderingComposer,
    $$LocalMedicationsTableAnnotationComposer,
    $$LocalMedicationsTableCreateCompanionBuilder,
    $$LocalMedicationsTableUpdateCompanionBuilder,
    (
      LocalMedication,
      BaseReferences<_$LocalDatabase, $LocalMedicationsTable, LocalMedication>
    ),
    LocalMedication,
    PrefetchHooks Function()>;
typedef $$LocalMedicationLogsTableCreateCompanionBuilder
    = LocalMedicationLogsCompanion Function({
  required String id,
  required String medicationId,
  required String changeType,
  required double quantityChange,
  required double balanceAfter,
  required DateTime logDate,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$LocalMedicationLogsTableUpdateCompanionBuilder
    = LocalMedicationLogsCompanion Function({
  Value<String> id,
  Value<String> medicationId,
  Value<String> changeType,
  Value<double> quantityChange,
  Value<double> balanceAfter,
  Value<DateTime> logDate,
  Value<String?> notes,
  Value<int> rowid,
});

class $$LocalMedicationLogsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalMedicationLogsTable> {
  $$LocalMedicationLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicationId => $composableBuilder(
      column: $table.medicationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changeType => $composableBuilder(
      column: $table.changeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantityChange => $composableBuilder(
      column: $table.quantityChange,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$LocalMedicationLogsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalMedicationLogsTable> {
  $$LocalMedicationLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicationId => $composableBuilder(
      column: $table.medicationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changeType => $composableBuilder(
      column: $table.changeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantityChange => $composableBuilder(
      column: $table.quantityChange,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get logDate => $composableBuilder(
      column: $table.logDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$LocalMedicationLogsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalMedicationLogsTable> {
  $$LocalMedicationLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get medicationId => $composableBuilder(
      column: $table.medicationId, builder: (column) => column);

  GeneratedColumn<String> get changeType => $composableBuilder(
      column: $table.changeType, builder: (column) => column);

  GeneratedColumn<double> get quantityChange => $composableBuilder(
      column: $table.quantityChange, builder: (column) => column);

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
      column: $table.balanceAfter, builder: (column) => column);

  GeneratedColumn<DateTime> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalMedicationLogsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalMedicationLogsTable,
    LocalMedicationLog,
    $$LocalMedicationLogsTableFilterComposer,
    $$LocalMedicationLogsTableOrderingComposer,
    $$LocalMedicationLogsTableAnnotationComposer,
    $$LocalMedicationLogsTableCreateCompanionBuilder,
    $$LocalMedicationLogsTableUpdateCompanionBuilder,
    (
      LocalMedicationLog,
      BaseReferences<_$LocalDatabase, $LocalMedicationLogsTable,
          LocalMedicationLog>
    ),
    LocalMedicationLog,
    PrefetchHooks Function()> {
  $$LocalMedicationLogsTableTableManager(
      _$LocalDatabase db, $LocalMedicationLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMedicationLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMedicationLogsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMedicationLogsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> medicationId = const Value.absent(),
            Value<String> changeType = const Value.absent(),
            Value<double> quantityChange = const Value.absent(),
            Value<double> balanceAfter = const Value.absent(),
            Value<DateTime> logDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMedicationLogsCompanion(
            id: id,
            medicationId: medicationId,
            changeType: changeType,
            quantityChange: quantityChange,
            balanceAfter: balanceAfter,
            logDate: logDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String medicationId,
            required String changeType,
            required double quantityChange,
            required double balanceAfter,
            required DateTime logDate,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMedicationLogsCompanion.insert(
            id: id,
            medicationId: medicationId,
            changeType: changeType,
            quantityChange: quantityChange,
            balanceAfter: balanceAfter,
            logDate: logDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalMedicationLogsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalMedicationLogsTable,
    LocalMedicationLog,
    $$LocalMedicationLogsTableFilterComposer,
    $$LocalMedicationLogsTableOrderingComposer,
    $$LocalMedicationLogsTableAnnotationComposer,
    $$LocalMedicationLogsTableCreateCompanionBuilder,
    $$LocalMedicationLogsTableUpdateCompanionBuilder,
    (
      LocalMedicationLog,
      BaseReferences<_$LocalDatabase, $LocalMedicationLogsTable,
          LocalMedicationLog>
    ),
    LocalMedicationLog,
    PrefetchHooks Function()>;
typedef $$LocalAnimalMedicalRecordsTableCreateCompanionBuilder
    = LocalAnimalMedicalRecordsCompanion Function({
  required String id,
  required String animalId,
  required String medicationId,
  required double administeredDose,
  required double cost,
  required DateTime treatmentDate,
  required String diagnosedCondition,
  Value<String?> administeredBy,
  Value<DateTime?> withdrawalEndDate,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$LocalAnimalMedicalRecordsTableUpdateCompanionBuilder
    = LocalAnimalMedicalRecordsCompanion Function({
  Value<String> id,
  Value<String> animalId,
  Value<String> medicationId,
  Value<double> administeredDose,
  Value<double> cost,
  Value<DateTime> treatmentDate,
  Value<String> diagnosedCondition,
  Value<String?> administeredBy,
  Value<DateTime?> withdrawalEndDate,
  Value<String?> notes,
  Value<int> rowid,
});

class $$LocalAnimalMedicalRecordsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalAnimalMedicalRecordsTable> {
  $$LocalAnimalMedicalRecordsTableFilterComposer({
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

  ColumnFilters<String> get medicationId => $composableBuilder(
      column: $table.medicationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get administeredDose => $composableBuilder(
      column: $table.administeredDose,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cost => $composableBuilder(
      column: $table.cost, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get treatmentDate => $composableBuilder(
      column: $table.treatmentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagnosedCondition => $composableBuilder(
      column: $table.diagnosedCondition,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get administeredBy => $composableBuilder(
      column: $table.administeredBy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get withdrawalEndDate => $composableBuilder(
      column: $table.withdrawalEndDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$LocalAnimalMedicalRecordsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalAnimalMedicalRecordsTable> {
  $$LocalAnimalMedicalRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get medicationId => $composableBuilder(
      column: $table.medicationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get administeredDose => $composableBuilder(
      column: $table.administeredDose,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cost => $composableBuilder(
      column: $table.cost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get treatmentDate => $composableBuilder(
      column: $table.treatmentDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnosedCondition => $composableBuilder(
      column: $table.diagnosedCondition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get administeredBy => $composableBuilder(
      column: $table.administeredBy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get withdrawalEndDate => $composableBuilder(
      column: $table.withdrawalEndDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$LocalAnimalMedicalRecordsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalAnimalMedicalRecordsTable> {
  $$LocalAnimalMedicalRecordsTableAnnotationComposer({
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

  GeneratedColumn<String> get medicationId => $composableBuilder(
      column: $table.medicationId, builder: (column) => column);

  GeneratedColumn<double> get administeredDose => $composableBuilder(
      column: $table.administeredDose, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<DateTime> get treatmentDate => $composableBuilder(
      column: $table.treatmentDate, builder: (column) => column);

  GeneratedColumn<String> get diagnosedCondition => $composableBuilder(
      column: $table.diagnosedCondition, builder: (column) => column);

  GeneratedColumn<String> get administeredBy => $composableBuilder(
      column: $table.administeredBy, builder: (column) => column);

  GeneratedColumn<DateTime> get withdrawalEndDate => $composableBuilder(
      column: $table.withdrawalEndDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalAnimalMedicalRecordsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalAnimalMedicalRecordsTable,
    LocalAnimalMedicalRecord,
    $$LocalAnimalMedicalRecordsTableFilterComposer,
    $$LocalAnimalMedicalRecordsTableOrderingComposer,
    $$LocalAnimalMedicalRecordsTableAnnotationComposer,
    $$LocalAnimalMedicalRecordsTableCreateCompanionBuilder,
    $$LocalAnimalMedicalRecordsTableUpdateCompanionBuilder,
    (
      LocalAnimalMedicalRecord,
      BaseReferences<_$LocalDatabase, $LocalAnimalMedicalRecordsTable,
          LocalAnimalMedicalRecord>
    ),
    LocalAnimalMedicalRecord,
    PrefetchHooks Function()> {
  $$LocalAnimalMedicalRecordsTableTableManager(
      _$LocalDatabase db, $LocalAnimalMedicalRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAnimalMedicalRecordsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAnimalMedicalRecordsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAnimalMedicalRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> medicationId = const Value.absent(),
            Value<double> administeredDose = const Value.absent(),
            Value<double> cost = const Value.absent(),
            Value<DateTime> treatmentDate = const Value.absent(),
            Value<String> diagnosedCondition = const Value.absent(),
            Value<String?> administeredBy = const Value.absent(),
            Value<DateTime?> withdrawalEndDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAnimalMedicalRecordsCompanion(
            id: id,
            animalId: animalId,
            medicationId: medicationId,
            administeredDose: administeredDose,
            cost: cost,
            treatmentDate: treatmentDate,
            diagnosedCondition: diagnosedCondition,
            administeredBy: administeredBy,
            withdrawalEndDate: withdrawalEndDate,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required String medicationId,
            required double administeredDose,
            required double cost,
            required DateTime treatmentDate,
            required String diagnosedCondition,
            Value<String?> administeredBy = const Value.absent(),
            Value<DateTime?> withdrawalEndDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalAnimalMedicalRecordsCompanion.insert(
            id: id,
            animalId: animalId,
            medicationId: medicationId,
            administeredDose: administeredDose,
            cost: cost,
            treatmentDate: treatmentDate,
            diagnosedCondition: diagnosedCondition,
            administeredBy: administeredBy,
            withdrawalEndDate: withdrawalEndDate,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalAnimalMedicalRecordsTableProcessedTableManager
    = ProcessedTableManager<
        _$LocalDatabase,
        $LocalAnimalMedicalRecordsTable,
        LocalAnimalMedicalRecord,
        $$LocalAnimalMedicalRecordsTableFilterComposer,
        $$LocalAnimalMedicalRecordsTableOrderingComposer,
        $$LocalAnimalMedicalRecordsTableAnnotationComposer,
        $$LocalAnimalMedicalRecordsTableCreateCompanionBuilder,
        $$LocalAnimalMedicalRecordsTableUpdateCompanionBuilder,
        (
          LocalAnimalMedicalRecord,
          BaseReferences<_$LocalDatabase, $LocalAnimalMedicalRecordsTable,
              LocalAnimalMedicalRecord>
        ),
        LocalAnimalMedicalRecord,
        PrefetchHooks Function()>;
typedef $$LocalStaffTableCreateCompanionBuilder = LocalStaffCompanion Function({
  required String id,
  required String name,
  required String role,
  Value<String?> phone,
  Value<double> baseSalary,
  Value<double> performanceRating,
  Value<bool> isActive,
  Value<String?> profilePic,
  Value<String?> gender,
  Value<DateTime?> dateOfBirth,
  Value<String?> address,
  Value<String?> emergencyContact,
  Value<String?> employmentType,
  Value<int> rowid,
});
typedef $$LocalStaffTableUpdateCompanionBuilder = LocalStaffCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> role,
  Value<String?> phone,
  Value<double> baseSalary,
  Value<double> performanceRating,
  Value<bool> isActive,
  Value<String?> profilePic,
  Value<String?> gender,
  Value<DateTime?> dateOfBirth,
  Value<String?> address,
  Value<String?> emergencyContact,
  Value<String?> employmentType,
  Value<int> rowid,
});

class $$LocalStaffTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalStaffTable> {
  $$LocalStaffTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get baseSalary => $composableBuilder(
      column: $table.baseSalary, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get performanceRating => $composableBuilder(
      column: $table.performanceRating,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profilePic => $composableBuilder(
      column: $table.profilePic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emergencyContact => $composableBuilder(
      column: $table.emergencyContact,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get employmentType => $composableBuilder(
      column: $table.employmentType,
      builder: (column) => ColumnFilters(column));
}

class $$LocalStaffTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalStaffTable> {
  $$LocalStaffTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get baseSalary => $composableBuilder(
      column: $table.baseSalary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get performanceRating => $composableBuilder(
      column: $table.performanceRating,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profilePic => $composableBuilder(
      column: $table.profilePic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emergencyContact => $composableBuilder(
      column: $table.emergencyContact,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get employmentType => $composableBuilder(
      column: $table.employmentType,
      builder: (column) => ColumnOrderings(column));
}

class $$LocalStaffTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalStaffTable> {
  $$LocalStaffTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<double> get baseSalary => $composableBuilder(
      column: $table.baseSalary, builder: (column) => column);

  GeneratedColumn<double> get performanceRating => $composableBuilder(
      column: $table.performanceRating, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get profilePic => $composableBuilder(
      column: $table.profilePic, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get emergencyContact => $composableBuilder(
      column: $table.emergencyContact, builder: (column) => column);

  GeneratedColumn<String> get employmentType => $composableBuilder(
      column: $table.employmentType, builder: (column) => column);
}

class $$LocalStaffTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalStaffTable,
    LocalStaffData,
    $$LocalStaffTableFilterComposer,
    $$LocalStaffTableOrderingComposer,
    $$LocalStaffTableAnnotationComposer,
    $$LocalStaffTableCreateCompanionBuilder,
    $$LocalStaffTableUpdateCompanionBuilder,
    (
      LocalStaffData,
      BaseReferences<_$LocalDatabase, $LocalStaffTable, LocalStaffData>
    ),
    LocalStaffData,
    PrefetchHooks Function()> {
  $$LocalStaffTableTableManager(_$LocalDatabase db, $LocalStaffTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStaffTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStaffTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStaffTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<double> baseSalary = const Value.absent(),
            Value<double> performanceRating = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> profilePic = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> emergencyContact = const Value.absent(),
            Value<String?> employmentType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStaffCompanion(
            id: id,
            name: name,
            role: role,
            phone: phone,
            baseSalary: baseSalary,
            performanceRating: performanceRating,
            isActive: isActive,
            profilePic: profilePic,
            gender: gender,
            dateOfBirth: dateOfBirth,
            address: address,
            emergencyContact: emergencyContact,
            employmentType: employmentType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String role,
            Value<String?> phone = const Value.absent(),
            Value<double> baseSalary = const Value.absent(),
            Value<double> performanceRating = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> profilePic = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> emergencyContact = const Value.absent(),
            Value<String?> employmentType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStaffCompanion.insert(
            id: id,
            name: name,
            role: role,
            phone: phone,
            baseSalary: baseSalary,
            performanceRating: performanceRating,
            isActive: isActive,
            profilePic: profilePic,
            gender: gender,
            dateOfBirth: dateOfBirth,
            address: address,
            emergencyContact: emergencyContact,
            employmentType: employmentType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalStaffTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalStaffTable,
    LocalStaffData,
    $$LocalStaffTableFilterComposer,
    $$LocalStaffTableOrderingComposer,
    $$LocalStaffTableAnnotationComposer,
    $$LocalStaffTableCreateCompanionBuilder,
    $$LocalStaffTableUpdateCompanionBuilder,
    (
      LocalStaffData,
      BaseReferences<_$LocalDatabase, $LocalStaffTable, LocalStaffData>
    ),
    LocalStaffData,
    PrefetchHooks Function()>;
typedef $$LocalStaffQueriesTableCreateCompanionBuilder
    = LocalStaffQueriesCompanion Function({
  required String id,
  required String staffId,
  required String title,
  Value<String?> description,
  Value<double> deductionAmount,
  Value<bool> isResolved,
  Value<String?> resolutionNotes,
  Value<DateTime?> resolvedAt,
  required DateTime issueDate,
  Value<int> rowid,
});
typedef $$LocalStaffQueriesTableUpdateCompanionBuilder
    = LocalStaffQueriesCompanion Function({
  Value<String> id,
  Value<String> staffId,
  Value<String> title,
  Value<String?> description,
  Value<double> deductionAmount,
  Value<bool> isResolved,
  Value<String?> resolutionNotes,
  Value<DateTime?> resolvedAt,
  Value<DateTime> issueDate,
  Value<int> rowid,
});

class $$LocalStaffQueriesTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalStaffQueriesTable> {
  $$LocalStaffQueriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get staffId => $composableBuilder(
      column: $table.staffId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get deductionAmount => $composableBuilder(
      column: $table.deductionAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolutionNotes => $composableBuilder(
      column: $table.resolutionNotes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get issueDate => $composableBuilder(
      column: $table.issueDate, builder: (column) => ColumnFilters(column));
}

class $$LocalStaffQueriesTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalStaffQueriesTable> {
  $$LocalStaffQueriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get staffId => $composableBuilder(
      column: $table.staffId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get deductionAmount => $composableBuilder(
      column: $table.deductionAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolutionNotes => $composableBuilder(
      column: $table.resolutionNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get issueDate => $composableBuilder(
      column: $table.issueDate, builder: (column) => ColumnOrderings(column));
}

class $$LocalStaffQueriesTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalStaffQueriesTable> {
  $$LocalStaffQueriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get deductionAmount => $composableBuilder(
      column: $table.deductionAmount, builder: (column) => column);

  GeneratedColumn<bool> get isResolved => $composableBuilder(
      column: $table.isResolved, builder: (column) => column);

  GeneratedColumn<String> get resolutionNotes => $composableBuilder(
      column: $table.resolutionNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
      column: $table.resolvedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get issueDate =>
      $composableBuilder(column: $table.issueDate, builder: (column) => column);
}

class $$LocalStaffQueriesTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalStaffQueriesTable,
    LocalStaffQuery,
    $$LocalStaffQueriesTableFilterComposer,
    $$LocalStaffQueriesTableOrderingComposer,
    $$LocalStaffQueriesTableAnnotationComposer,
    $$LocalStaffQueriesTableCreateCompanionBuilder,
    $$LocalStaffQueriesTableUpdateCompanionBuilder,
    (
      LocalStaffQuery,
      BaseReferences<_$LocalDatabase, $LocalStaffQueriesTable, LocalStaffQuery>
    ),
    LocalStaffQuery,
    PrefetchHooks Function()> {
  $$LocalStaffQueriesTableTableManager(
      _$LocalDatabase db, $LocalStaffQueriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStaffQueriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStaffQueriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStaffQueriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> staffId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> deductionAmount = const Value.absent(),
            Value<bool> isResolved = const Value.absent(),
            Value<String?> resolutionNotes = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            Value<DateTime> issueDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStaffQueriesCompanion(
            id: id,
            staffId: staffId,
            title: title,
            description: description,
            deductionAmount: deductionAmount,
            isResolved: isResolved,
            resolutionNotes: resolutionNotes,
            resolvedAt: resolvedAt,
            issueDate: issueDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String staffId,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<double> deductionAmount = const Value.absent(),
            Value<bool> isResolved = const Value.absent(),
            Value<String?> resolutionNotes = const Value.absent(),
            Value<DateTime?> resolvedAt = const Value.absent(),
            required DateTime issueDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalStaffQueriesCompanion.insert(
            id: id,
            staffId: staffId,
            title: title,
            description: description,
            deductionAmount: deductionAmount,
            isResolved: isResolved,
            resolutionNotes: resolutionNotes,
            resolvedAt: resolvedAt,
            issueDate: issueDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalStaffQueriesTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalStaffQueriesTable,
    LocalStaffQuery,
    $$LocalStaffQueriesTableFilterComposer,
    $$LocalStaffQueriesTableOrderingComposer,
    $$LocalStaffQueriesTableAnnotationComposer,
    $$LocalStaffQueriesTableCreateCompanionBuilder,
    $$LocalStaffQueriesTableUpdateCompanionBuilder,
    (
      LocalStaffQuery,
      BaseReferences<_$LocalDatabase, $LocalStaffQueriesTable, LocalStaffQuery>
    ),
    LocalStaffQuery,
    PrefetchHooks Function()>;
typedef $$LocalFarmEventsTableCreateCompanionBuilder = LocalFarmEventsCompanion
    Function({
  required String id,
  required String eventType,
  required DateTime eventDate,
  Value<String?> involvedAnimals,
  required String description,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$LocalFarmEventsTableUpdateCompanionBuilder = LocalFarmEventsCompanion
    Function({
  Value<String> id,
  Value<String> eventType,
  Value<DateTime> eventDate,
  Value<String?> involvedAnimals,
  Value<String> description,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LocalFarmEventsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalFarmEventsTable> {
  $$LocalFarmEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get involvedAnimals => $composableBuilder(
      column: $table.involvedAnimals,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LocalFarmEventsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalFarmEventsTable> {
  $$LocalFarmEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get involvedAnimals => $composableBuilder(
      column: $table.involvedAnimals,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalFarmEventsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalFarmEventsTable> {
  $$LocalFarmEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get involvedAnimals => $composableBuilder(
      column: $table.involvedAnimals, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalFarmEventsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalFarmEventsTable,
    LocalFarmEvent,
    $$LocalFarmEventsTableFilterComposer,
    $$LocalFarmEventsTableOrderingComposer,
    $$LocalFarmEventsTableAnnotationComposer,
    $$LocalFarmEventsTableCreateCompanionBuilder,
    $$LocalFarmEventsTableUpdateCompanionBuilder,
    (
      LocalFarmEvent,
      BaseReferences<_$LocalDatabase, $LocalFarmEventsTable, LocalFarmEvent>
    ),
    LocalFarmEvent,
    PrefetchHooks Function()> {
  $$LocalFarmEventsTableTableManager(
      _$LocalDatabase db, $LocalFarmEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFarmEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFarmEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFarmEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<DateTime> eventDate = const Value.absent(),
            Value<String?> involvedAnimals = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFarmEventsCompanion(
            id: id,
            eventType: eventType,
            eventDate: eventDate,
            involvedAnimals: involvedAnimals,
            description: description,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String eventType,
            required DateTime eventDate,
            Value<String?> involvedAnimals = const Value.absent(),
            required String description,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalFarmEventsCompanion.insert(
            id: id,
            eventType: eventType,
            eventDate: eventDate,
            involvedAnimals: involvedAnimals,
            description: description,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalFarmEventsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalFarmEventsTable,
    LocalFarmEvent,
    $$LocalFarmEventsTableFilterComposer,
    $$LocalFarmEventsTableOrderingComposer,
    $$LocalFarmEventsTableAnnotationComposer,
    $$LocalFarmEventsTableCreateCompanionBuilder,
    $$LocalFarmEventsTableUpdateCompanionBuilder,
    (
      LocalFarmEvent,
      BaseReferences<_$LocalDatabase, $LocalFarmEventsTable, LocalFarmEvent>
    ),
    LocalFarmEvent,
    PrefetchHooks Function()>;
typedef $$LocalBreedingEventsTableCreateCompanionBuilder
    = LocalBreedingEventsCompanion Function({
  required String id,
  required String animalId,
  required String eventType,
  required DateTime eventDate,
  Value<String?> sireId,
  Value<String?> semenBatchId,
  Value<String?> technician,
  Value<String?> result,
  Value<String?> notes,
  Value<String?> payload,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$LocalBreedingEventsTableUpdateCompanionBuilder
    = LocalBreedingEventsCompanion Function({
  Value<String> id,
  Value<String> animalId,
  Value<String> eventType,
  Value<DateTime> eventDate,
  Value<String?> sireId,
  Value<String?> semenBatchId,
  Value<String?> technician,
  Value<String?> result,
  Value<String?> notes,
  Value<String?> payload,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LocalBreedingEventsTableFilterComposer
    extends Composer<_$LocalDatabase, $LocalBreedingEventsTable> {
  $$LocalBreedingEventsTableFilterComposer({
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

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sireId => $composableBuilder(
      column: $table.sireId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get semenBatchId => $composableBuilder(
      column: $table.semenBatchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get technician => $composableBuilder(
      column: $table.technician, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LocalBreedingEventsTableOrderingComposer
    extends Composer<_$LocalDatabase, $LocalBreedingEventsTable> {
  $$LocalBreedingEventsTableOrderingComposer({
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

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sireId => $composableBuilder(
      column: $table.sireId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get semenBatchId => $composableBuilder(
      column: $table.semenBatchId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get technician => $composableBuilder(
      column: $table.technician, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalBreedingEventsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $LocalBreedingEventsTable> {
  $$LocalBreedingEventsTableAnnotationComposer({
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

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get sireId =>
      $composableBuilder(column: $table.sireId, builder: (column) => column);

  GeneratedColumn<String> get semenBatchId => $composableBuilder(
      column: $table.semenBatchId, builder: (column) => column);

  GeneratedColumn<String> get technician => $composableBuilder(
      column: $table.technician, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalBreedingEventsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $LocalBreedingEventsTable,
    LocalBreedingEvent,
    $$LocalBreedingEventsTableFilterComposer,
    $$LocalBreedingEventsTableOrderingComposer,
    $$LocalBreedingEventsTableAnnotationComposer,
    $$LocalBreedingEventsTableCreateCompanionBuilder,
    $$LocalBreedingEventsTableUpdateCompanionBuilder,
    (
      LocalBreedingEvent,
      BaseReferences<_$LocalDatabase, $LocalBreedingEventsTable,
          LocalBreedingEvent>
    ),
    LocalBreedingEvent,
    PrefetchHooks Function()> {
  $$LocalBreedingEventsTableTableManager(
      _$LocalDatabase db, $LocalBreedingEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBreedingEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBreedingEventsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBreedingEventsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> animalId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<DateTime> eventDate = const Value.absent(),
            Value<String?> sireId = const Value.absent(),
            Value<String?> semenBatchId = const Value.absent(),
            Value<String?> technician = const Value.absent(),
            Value<String?> result = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalBreedingEventsCompanion(
            id: id,
            animalId: animalId,
            eventType: eventType,
            eventDate: eventDate,
            sireId: sireId,
            semenBatchId: semenBatchId,
            technician: technician,
            result: result,
            notes: notes,
            payload: payload,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String animalId,
            required String eventType,
            required DateTime eventDate,
            Value<String?> sireId = const Value.absent(),
            Value<String?> semenBatchId = const Value.absent(),
            Value<String?> technician = const Value.absent(),
            Value<String?> result = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalBreedingEventsCompanion.insert(
            id: id,
            animalId: animalId,
            eventType: eventType,
            eventDate: eventDate,
            sireId: sireId,
            semenBatchId: semenBatchId,
            technician: technician,
            result: result,
            notes: notes,
            payload: payload,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalBreedingEventsTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $LocalBreedingEventsTable,
    LocalBreedingEvent,
    $$LocalBreedingEventsTableFilterComposer,
    $$LocalBreedingEventsTableOrderingComposer,
    $$LocalBreedingEventsTableAnnotationComposer,
    $$LocalBreedingEventsTableCreateCompanionBuilder,
    $$LocalBreedingEventsTableUpdateCompanionBuilder,
    (
      LocalBreedingEvent,
      BaseReferences<_$LocalDatabase, $LocalBreedingEventsTable,
          LocalBreedingEvent>
    ),
    LocalBreedingEvent,
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
  $$LocalFeedItemsTableTableManager get localFeedItems =>
      $$LocalFeedItemsTableTableManager(_db, _db.localFeedItems);
  $$LocalInventoryLogsTableTableManager get localInventoryLogs =>
      $$LocalInventoryLogsTableTableManager(_db, _db.localInventoryLogs);
  $$LocalHatcheryBatchesTableTableManager get localHatcheryBatches =>
      $$LocalHatcheryBatchesTableTableManager(_db, _db.localHatcheryBatches);
  $$LocalHatcheryEventsTableTableManager get localHatcheryEvents =>
      $$LocalHatcheryEventsTableTableManager(_db, _db.localHatcheryEvents);
  $$LocalFeedFormulasTableTableManager get localFeedFormulas =>
      $$LocalFeedFormulasTableTableManager(_db, _db.localFeedFormulas);
  $$LocalFormulaIngredientsTableTableManager get localFormulaIngredients =>
      $$LocalFormulaIngredientsTableTableManager(
          _db, _db.localFormulaIngredients);
  $$LocalFeedConsumptionLogsTableTableManager get localFeedConsumptionLogs =>
      $$LocalFeedConsumptionLogsTableTableManager(
          _db, _db.localFeedConsumptionLogs);
  $$LocalFeedingPlansTableTableManager get localFeedingPlans =>
      $$LocalFeedingPlansTableTableManager(_db, _db.localFeedingPlans);
  $$LocalMedicationsTableTableManager get localMedications =>
      $$LocalMedicationsTableTableManager(_db, _db.localMedications);
  $$LocalMedicationLogsTableTableManager get localMedicationLogs =>
      $$LocalMedicationLogsTableTableManager(_db, _db.localMedicationLogs);
  $$LocalAnimalMedicalRecordsTableTableManager get localAnimalMedicalRecords =>
      $$LocalAnimalMedicalRecordsTableTableManager(
          _db, _db.localAnimalMedicalRecords);
  $$LocalStaffTableTableManager get localStaff =>
      $$LocalStaffTableTableManager(_db, _db.localStaff);
  $$LocalStaffQueriesTableTableManager get localStaffQueries =>
      $$LocalStaffQueriesTableTableManager(_db, _db.localStaffQueries);
  $$LocalFarmEventsTableTableManager get localFarmEvents =>
      $$LocalFarmEventsTableTableManager(_db, _db.localFarmEvents);
  $$LocalBreedingEventsTableTableManager get localBreedingEvents =>
      $$LocalBreedingEventsTableTableManager(_db, _db.localBreedingEvents);
}
