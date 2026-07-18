// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JobRecordsTable extends JobRecords
    with TableInfo<$JobRecordsTable, JobRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    stage,
    payloadJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'job_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<JobRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(
        _stageMeta,
        stage.isAcceptableOrUnknown(data['stage']!, _stageMeta),
      );
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JobRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JobRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $JobRecordsTable createAlias(String alias) {
    return $JobRecordsTable(attachedDatabase, alias);
  }
}

class JobRecord extends DataClass implements Insertable<JobRecord> {
  final String id;
  final String name;
  final String stage;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const JobRecord({
    required this.id,
    required this.name,
    required this.stage,
    required this.payloadJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['stage'] = Variable<String>(stage);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  JobRecordsCompanion toCompanion(bool nullToAbsent) {
    return JobRecordsCompanion(
      id: Value(id),
      name: Value(name),
      stage: Value(stage),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory JobRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JobRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stage: serializer.fromJson<String>(json['stage']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'stage': serializer.toJson<String>(stage),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  JobRecord copyWith({
    String? id,
    String? name,
    String? stage,
    String? payloadJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => JobRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    stage: stage ?? this.stage,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  JobRecord copyWithCompanion(JobRecordsCompanion data) {
    return JobRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stage: data.stage.present ? data.stage.value : this.stage,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JobRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stage: $stage, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, stage, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JobRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.stage == this.stage &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class JobRecordsCompanion extends UpdateCompanion<JobRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> stage;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const JobRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stage = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobRecordsCompanion.insert({
    required String id,
    required String name,
    required String stage,
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       stage = Value(stage),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<JobRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? stage,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stage != null) 'stage': stage,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? stage,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return JobRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stage: $stage, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemnantRecordsTable extends RemnantRecords
    with TableInfo<$RemnantRecordsTable, RemnantRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemnantRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorKeyMeta = const VerificationMeta(
    'colorKey',
  );
  @override
  late final GeneratedColumn<String> colorKey = GeneratedColumn<String>(
    'color_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thicknessMmMeta = const VerificationMeta(
    'thicknessMm',
  );
  @override
  late final GeneratedColumn<double> thicknessMm = GeneratedColumn<double>(
    'thickness_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaMm2Meta = const VerificationMeta(
    'areaMm2',
  );
  @override
  late final GeneratedColumn<double> areaMm2 = GeneratedColumn<double>(
    'area_mm2',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minXMeta = const VerificationMeta('minX');
  @override
  late final GeneratedColumn<double> minX = GeneratedColumn<double>(
    'min_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minYMeta = const VerificationMeta('minY');
  @override
  late final GeneratedColumn<double> minY = GeneratedColumn<double>(
    'min_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxXMeta = const VerificationMeta('maxX');
  @override
  late final GeneratedColumn<double> maxX = GeneratedColumn<double>(
    'max_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxYMeta = const VerificationMeta('maxY');
  @override
  late final GeneratedColumn<double> maxY = GeneratedColumn<double>(
    'max_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _polygonJsonMeta = const VerificationMeta(
    'polygonJson',
  );
  @override
  late final GeneratedColumn<String> polygonJson = GeneratedColumn<String>(
    'polygon_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    color,
    colorKey,
    thicknessMm,
    areaMm2,
    minX,
    minY,
    maxX,
    maxY,
    polygonJson,
    location,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'remnant_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<RemnantRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('color_key')) {
      context.handle(
        _colorKeyMeta,
        colorKey.isAcceptableOrUnknown(data['color_key']!, _colorKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_colorKeyMeta);
    }
    if (data.containsKey('thickness_mm')) {
      context.handle(
        _thicknessMmMeta,
        thicknessMm.isAcceptableOrUnknown(
          data['thickness_mm']!,
          _thicknessMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thicknessMmMeta);
    }
    if (data.containsKey('area_mm2')) {
      context.handle(
        _areaMm2Meta,
        areaMm2.isAcceptableOrUnknown(data['area_mm2']!, _areaMm2Meta),
      );
    } else if (isInserting) {
      context.missing(_areaMm2Meta);
    }
    if (data.containsKey('min_x')) {
      context.handle(
        _minXMeta,
        minX.isAcceptableOrUnknown(data['min_x']!, _minXMeta),
      );
    } else if (isInserting) {
      context.missing(_minXMeta);
    }
    if (data.containsKey('min_y')) {
      context.handle(
        _minYMeta,
        minY.isAcceptableOrUnknown(data['min_y']!, _minYMeta),
      );
    } else if (isInserting) {
      context.missing(_minYMeta);
    }
    if (data.containsKey('max_x')) {
      context.handle(
        _maxXMeta,
        maxX.isAcceptableOrUnknown(data['max_x']!, _maxXMeta),
      );
    } else if (isInserting) {
      context.missing(_maxXMeta);
    }
    if (data.containsKey('max_y')) {
      context.handle(
        _maxYMeta,
        maxY.isAcceptableOrUnknown(data['max_y']!, _maxYMeta),
      );
    } else if (isInserting) {
      context.missing(_maxYMeta);
    }
    if (data.containsKey('polygon_json')) {
      context.handle(
        _polygonJsonMeta,
        polygonJson.isAcceptableOrUnknown(
          data['polygon_json']!,
          _polygonJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_polygonJsonMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemnantRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemnantRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      colorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_key'],
      )!,
      thicknessMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}thickness_mm'],
      )!,
      areaMm2: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_mm2'],
      )!,
      minX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_x'],
      )!,
      minY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_y'],
      )!,
      maxX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_x'],
      )!,
      maxY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_y'],
      )!,
      polygonJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}polygon_json'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RemnantRecordsTable createAlias(String alias) {
    return $RemnantRecordsTable(attachedDatabase, alias);
  }
}

class RemnantRecord extends DataClass implements Insertable<RemnantRecord> {
  final String id;
  final String name;
  final String kind;
  final String color;
  final String colorKey;
  final double thicknessMm;
  final double areaMm2;
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;
  final String polygonJson;
  final String location;
  final DateTime createdAt;
  const RemnantRecord({
    required this.id,
    required this.name,
    required this.kind,
    required this.color,
    required this.colorKey,
    required this.thicknessMm,
    required this.areaMm2,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.polygonJson,
    required this.location,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['color'] = Variable<String>(color);
    map['color_key'] = Variable<String>(colorKey);
    map['thickness_mm'] = Variable<double>(thicknessMm);
    map['area_mm2'] = Variable<double>(areaMm2);
    map['min_x'] = Variable<double>(minX);
    map['min_y'] = Variable<double>(minY);
    map['max_x'] = Variable<double>(maxX);
    map['max_y'] = Variable<double>(maxY);
    map['polygon_json'] = Variable<String>(polygonJson);
    map['location'] = Variable<String>(location);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RemnantRecordsCompanion toCompanion(bool nullToAbsent) {
    return RemnantRecordsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      color: Value(color),
      colorKey: Value(colorKey),
      thicknessMm: Value(thicknessMm),
      areaMm2: Value(areaMm2),
      minX: Value(minX),
      minY: Value(minY),
      maxX: Value(maxX),
      maxY: Value(maxY),
      polygonJson: Value(polygonJson),
      location: Value(location),
      createdAt: Value(createdAt),
    );
  }

  factory RemnantRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemnantRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      color: serializer.fromJson<String>(json['color']),
      colorKey: serializer.fromJson<String>(json['colorKey']),
      thicknessMm: serializer.fromJson<double>(json['thicknessMm']),
      areaMm2: serializer.fromJson<double>(json['areaMm2']),
      minX: serializer.fromJson<double>(json['minX']),
      minY: serializer.fromJson<double>(json['minY']),
      maxX: serializer.fromJson<double>(json['maxX']),
      maxY: serializer.fromJson<double>(json['maxY']),
      polygonJson: serializer.fromJson<String>(json['polygonJson']),
      location: serializer.fromJson<String>(json['location']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'color': serializer.toJson<String>(color),
      'colorKey': serializer.toJson<String>(colorKey),
      'thicknessMm': serializer.toJson<double>(thicknessMm),
      'areaMm2': serializer.toJson<double>(areaMm2),
      'minX': serializer.toJson<double>(minX),
      'minY': serializer.toJson<double>(minY),
      'maxX': serializer.toJson<double>(maxX),
      'maxY': serializer.toJson<double>(maxY),
      'polygonJson': serializer.toJson<String>(polygonJson),
      'location': serializer.toJson<String>(location),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RemnantRecord copyWith({
    String? id,
    String? name,
    String? kind,
    String? color,
    String? colorKey,
    double? thicknessMm,
    double? areaMm2,
    double? minX,
    double? minY,
    double? maxX,
    double? maxY,
    String? polygonJson,
    String? location,
    DateTime? createdAt,
  }) => RemnantRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    color: color ?? this.color,
    colorKey: colorKey ?? this.colorKey,
    thicknessMm: thicknessMm ?? this.thicknessMm,
    areaMm2: areaMm2 ?? this.areaMm2,
    minX: minX ?? this.minX,
    minY: minY ?? this.minY,
    maxX: maxX ?? this.maxX,
    maxY: maxY ?? this.maxY,
    polygonJson: polygonJson ?? this.polygonJson,
    location: location ?? this.location,
    createdAt: createdAt ?? this.createdAt,
  );
  RemnantRecord copyWithCompanion(RemnantRecordsCompanion data) {
    return RemnantRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      color: data.color.present ? data.color.value : this.color,
      colorKey: data.colorKey.present ? data.colorKey.value : this.colorKey,
      thicknessMm: data.thicknessMm.present
          ? data.thicknessMm.value
          : this.thicknessMm,
      areaMm2: data.areaMm2.present ? data.areaMm2.value : this.areaMm2,
      minX: data.minX.present ? data.minX.value : this.minX,
      minY: data.minY.present ? data.minY.value : this.minY,
      maxX: data.maxX.present ? data.maxX.value : this.maxX,
      maxY: data.maxY.present ? data.maxY.value : this.maxY,
      polygonJson: data.polygonJson.present
          ? data.polygonJson.value
          : this.polygonJson,
      location: data.location.present ? data.location.value : this.location,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemnantRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('color: $color, ')
          ..write('colorKey: $colorKey, ')
          ..write('thicknessMm: $thicknessMm, ')
          ..write('areaMm2: $areaMm2, ')
          ..write('minX: $minX, ')
          ..write('minY: $minY, ')
          ..write('maxX: $maxX, ')
          ..write('maxY: $maxY, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    color,
    colorKey,
    thicknessMm,
    areaMm2,
    minX,
    minY,
    maxX,
    maxY,
    polygonJson,
    location,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemnantRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.color == this.color &&
          other.colorKey == this.colorKey &&
          other.thicknessMm == this.thicknessMm &&
          other.areaMm2 == this.areaMm2 &&
          other.minX == this.minX &&
          other.minY == this.minY &&
          other.maxX == this.maxX &&
          other.maxY == this.maxY &&
          other.polygonJson == this.polygonJson &&
          other.location == this.location &&
          other.createdAt == this.createdAt);
}

class RemnantRecordsCompanion extends UpdateCompanion<RemnantRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<String> color;
  final Value<String> colorKey;
  final Value<double> thicknessMm;
  final Value<double> areaMm2;
  final Value<double> minX;
  final Value<double> minY;
  final Value<double> maxX;
  final Value<double> maxY;
  final Value<String> polygonJson;
  final Value<String> location;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RemnantRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.color = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.thicknessMm = const Value.absent(),
    this.areaMm2 = const Value.absent(),
    this.minX = const Value.absent(),
    this.minY = const Value.absent(),
    this.maxX = const Value.absent(),
    this.maxY = const Value.absent(),
    this.polygonJson = const Value.absent(),
    this.location = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemnantRecordsCompanion.insert({
    required String id,
    required String name,
    required String kind,
    required String color,
    required String colorKey,
    required double thicknessMm,
    required double areaMm2,
    required double minX,
    required double minY,
    required double maxX,
    required double maxY,
    required String polygonJson,
    required String location,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       color = Value(color),
       colorKey = Value(colorKey),
       thicknessMm = Value(thicknessMm),
       areaMm2 = Value(areaMm2),
       minX = Value(minX),
       minY = Value(minY),
       maxX = Value(maxX),
       maxY = Value(maxY),
       polygonJson = Value(polygonJson),
       location = Value(location),
       createdAt = Value(createdAt);
  static Insertable<RemnantRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? color,
    Expression<String>? colorKey,
    Expression<double>? thicknessMm,
    Expression<double>? areaMm2,
    Expression<double>? minX,
    Expression<double>? minY,
    Expression<double>? maxX,
    Expression<double>? maxY,
    Expression<String>? polygonJson,
    Expression<String>? location,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (color != null) 'color': color,
      if (colorKey != null) 'color_key': colorKey,
      if (thicknessMm != null) 'thickness_mm': thicknessMm,
      if (areaMm2 != null) 'area_mm2': areaMm2,
      if (minX != null) 'min_x': minX,
      if (minY != null) 'min_y': minY,
      if (maxX != null) 'max_x': maxX,
      if (maxY != null) 'max_y': maxY,
      if (polygonJson != null) 'polygon_json': polygonJson,
      if (location != null) 'location': location,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemnantRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<String>? color,
    Value<String>? colorKey,
    Value<double>? thicknessMm,
    Value<double>? areaMm2,
    Value<double>? minX,
    Value<double>? minY,
    Value<double>? maxX,
    Value<double>? maxY,
    Value<String>? polygonJson,
    Value<String>? location,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RemnantRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      color: color ?? this.color,
      colorKey: colorKey ?? this.colorKey,
      thicknessMm: thicknessMm ?? this.thicknessMm,
      areaMm2: areaMm2 ?? this.areaMm2,
      minX: minX ?? this.minX,
      minY: minY ?? this.minY,
      maxX: maxX ?? this.maxX,
      maxY: maxY ?? this.maxY,
      polygonJson: polygonJson ?? this.polygonJson,
      location: location ?? this.location,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (colorKey.present) {
      map['color_key'] = Variable<String>(colorKey.value);
    }
    if (thicknessMm.present) {
      map['thickness_mm'] = Variable<double>(thicknessMm.value);
    }
    if (areaMm2.present) {
      map['area_mm2'] = Variable<double>(areaMm2.value);
    }
    if (minX.present) {
      map['min_x'] = Variable<double>(minX.value);
    }
    if (minY.present) {
      map['min_y'] = Variable<double>(minY.value);
    }
    if (maxX.present) {
      map['max_x'] = Variable<double>(maxX.value);
    }
    if (maxY.present) {
      map['max_y'] = Variable<double>(maxY.value);
    }
    if (polygonJson.present) {
      map['polygon_json'] = Variable<String>(polygonJson.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
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
    return (StringBuffer('RemnantRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('color: $color, ')
          ..write('colorKey: $colorKey, ')
          ..write('thicknessMm: $thicknessMm, ')
          ..write('areaMm2: $areaMm2, ')
          ..write('minX: $minX, ')
          ..write('minY: $minY, ')
          ..write('maxX: $maxX, ')
          ..write('maxY: $maxY, ')
          ..write('polygonJson: $polygonJson, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ToolInvocationRecordsTable extends ToolInvocationRecords
    with TableInfo<$ToolInvocationRecordsTable, ToolInvocationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToolInvocationRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobIdMeta = const VerificationMeta('jobId');
  @override
  late final GeneratedColumn<String> jobId = GeneratedColumn<String>(
    'job_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toolNameMeta = const VerificationMeta(
    'toolName',
  );
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
    'tool_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _argumentsJsonMeta = const VerificationMeta(
    'argumentsJson',
  );
  @override
  late final GeneratedColumn<String> argumentsJson = GeneratedColumn<String>(
    'arguments_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedMillisecondsMeta =
      const VerificationMeta('elapsedMilliseconds');
  @override
  late final GeneratedColumn<int> elapsedMilliseconds = GeneratedColumn<int>(
    'elapsed_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobId,
    toolName,
    argumentsJson,
    status,
    summary,
    elapsedMilliseconds,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tool_invocation_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ToolInvocationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_id')) {
      context.handle(
        _jobIdMeta,
        jobId.isAcceptableOrUnknown(data['job_id']!, _jobIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jobIdMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(
        _toolNameMeta,
        toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta),
      );
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('arguments_json')) {
      context.handle(
        _argumentsJsonMeta,
        argumentsJson.isAcceptableOrUnknown(
          data['arguments_json']!,
          _argumentsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_argumentsJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('elapsed_milliseconds')) {
      context.handle(
        _elapsedMillisecondsMeta,
        elapsedMilliseconds.isAcceptableOrUnknown(
          data['elapsed_milliseconds']!,
          _elapsedMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedMillisecondsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ToolInvocationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ToolInvocationRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_id'],
      )!,
      toolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_name'],
      )!,
      argumentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arguments_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      elapsedMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_milliseconds'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ToolInvocationRecordsTable createAlias(String alias) {
    return $ToolInvocationRecordsTable(attachedDatabase, alias);
  }
}

class ToolInvocationRecord extends DataClass
    implements Insertable<ToolInvocationRecord> {
  final String id;
  final String jobId;
  final String toolName;
  final String argumentsJson;
  final String status;
  final String summary;
  final int elapsedMilliseconds;
  final DateTime createdAt;
  const ToolInvocationRecord({
    required this.id,
    required this.jobId,
    required this.toolName,
    required this.argumentsJson,
    required this.status,
    required this.summary,
    required this.elapsedMilliseconds,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_id'] = Variable<String>(jobId);
    map['tool_name'] = Variable<String>(toolName);
    map['arguments_json'] = Variable<String>(argumentsJson);
    map['status'] = Variable<String>(status);
    map['summary'] = Variable<String>(summary);
    map['elapsed_milliseconds'] = Variable<int>(elapsedMilliseconds);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ToolInvocationRecordsCompanion toCompanion(bool nullToAbsent) {
    return ToolInvocationRecordsCompanion(
      id: Value(id),
      jobId: Value(jobId),
      toolName: Value(toolName),
      argumentsJson: Value(argumentsJson),
      status: Value(status),
      summary: Value(summary),
      elapsedMilliseconds: Value(elapsedMilliseconds),
      createdAt: Value(createdAt),
    );
  }

  factory ToolInvocationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ToolInvocationRecord(
      id: serializer.fromJson<String>(json['id']),
      jobId: serializer.fromJson<String>(json['jobId']),
      toolName: serializer.fromJson<String>(json['toolName']),
      argumentsJson: serializer.fromJson<String>(json['argumentsJson']),
      status: serializer.fromJson<String>(json['status']),
      summary: serializer.fromJson<String>(json['summary']),
      elapsedMilliseconds: serializer.fromJson<int>(
        json['elapsedMilliseconds'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobId': serializer.toJson<String>(jobId),
      'toolName': serializer.toJson<String>(toolName),
      'argumentsJson': serializer.toJson<String>(argumentsJson),
      'status': serializer.toJson<String>(status),
      'summary': serializer.toJson<String>(summary),
      'elapsedMilliseconds': serializer.toJson<int>(elapsedMilliseconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ToolInvocationRecord copyWith({
    String? id,
    String? jobId,
    String? toolName,
    String? argumentsJson,
    String? status,
    String? summary,
    int? elapsedMilliseconds,
    DateTime? createdAt,
  }) => ToolInvocationRecord(
    id: id ?? this.id,
    jobId: jobId ?? this.jobId,
    toolName: toolName ?? this.toolName,
    argumentsJson: argumentsJson ?? this.argumentsJson,
    status: status ?? this.status,
    summary: summary ?? this.summary,
    elapsedMilliseconds: elapsedMilliseconds ?? this.elapsedMilliseconds,
    createdAt: createdAt ?? this.createdAt,
  );
  ToolInvocationRecord copyWithCompanion(ToolInvocationRecordsCompanion data) {
    return ToolInvocationRecord(
      id: data.id.present ? data.id.value : this.id,
      jobId: data.jobId.present ? data.jobId.value : this.jobId,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      argumentsJson: data.argumentsJson.present
          ? data.argumentsJson.value
          : this.argumentsJson,
      status: data.status.present ? data.status.value : this.status,
      summary: data.summary.present ? data.summary.value : this.summary,
      elapsedMilliseconds: data.elapsedMilliseconds.present
          ? data.elapsedMilliseconds.value
          : this.elapsedMilliseconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ToolInvocationRecord(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('toolName: $toolName, ')
          ..write('argumentsJson: $argumentsJson, ')
          ..write('status: $status, ')
          ..write('summary: $summary, ')
          ..write('elapsedMilliseconds: $elapsedMilliseconds, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobId,
    toolName,
    argumentsJson,
    status,
    summary,
    elapsedMilliseconds,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ToolInvocationRecord &&
          other.id == this.id &&
          other.jobId == this.jobId &&
          other.toolName == this.toolName &&
          other.argumentsJson == this.argumentsJson &&
          other.status == this.status &&
          other.summary == this.summary &&
          other.elapsedMilliseconds == this.elapsedMilliseconds &&
          other.createdAt == this.createdAt);
}

class ToolInvocationRecordsCompanion
    extends UpdateCompanion<ToolInvocationRecord> {
  final Value<String> id;
  final Value<String> jobId;
  final Value<String> toolName;
  final Value<String> argumentsJson;
  final Value<String> status;
  final Value<String> summary;
  final Value<int> elapsedMilliseconds;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ToolInvocationRecordsCompanion({
    this.id = const Value.absent(),
    this.jobId = const Value.absent(),
    this.toolName = const Value.absent(),
    this.argumentsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.summary = const Value.absent(),
    this.elapsedMilliseconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ToolInvocationRecordsCompanion.insert({
    required String id,
    required String jobId,
    required String toolName,
    required String argumentsJson,
    required String status,
    required String summary,
    required int elapsedMilliseconds,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jobId = Value(jobId),
       toolName = Value(toolName),
       argumentsJson = Value(argumentsJson),
       status = Value(status),
       summary = Value(summary),
       elapsedMilliseconds = Value(elapsedMilliseconds),
       createdAt = Value(createdAt);
  static Insertable<ToolInvocationRecord> custom({
    Expression<String>? id,
    Expression<String>? jobId,
    Expression<String>? toolName,
    Expression<String>? argumentsJson,
    Expression<String>? status,
    Expression<String>? summary,
    Expression<int>? elapsedMilliseconds,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobId != null) 'job_id': jobId,
      if (toolName != null) 'tool_name': toolName,
      if (argumentsJson != null) 'arguments_json': argumentsJson,
      if (status != null) 'status': status,
      if (summary != null) 'summary': summary,
      if (elapsedMilliseconds != null)
        'elapsed_milliseconds': elapsedMilliseconds,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ToolInvocationRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? jobId,
    Value<String>? toolName,
    Value<String>? argumentsJson,
    Value<String>? status,
    Value<String>? summary,
    Value<int>? elapsedMilliseconds,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ToolInvocationRecordsCompanion(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      toolName: toolName ?? this.toolName,
      argumentsJson: argumentsJson ?? this.argumentsJson,
      status: status ?? this.status,
      summary: summary ?? this.summary,
      elapsedMilliseconds: elapsedMilliseconds ?? this.elapsedMilliseconds,
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
    if (jobId.present) {
      map['job_id'] = Variable<String>(jobId.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (argumentsJson.present) {
      map['arguments_json'] = Variable<String>(argumentsJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (elapsedMilliseconds.present) {
      map['elapsed_milliseconds'] = Variable<int>(elapsedMilliseconds.value);
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
    return (StringBuffer('ToolInvocationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('jobId: $jobId, ')
          ..write('toolName: $toolName, ')
          ..write('argumentsJson: $argumentsJson, ')
          ..write('status: $status, ')
          ..write('summary: $summary, ')
          ..write('elapsedMilliseconds: $elapsedMilliseconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JobRecordsTable jobRecords = $JobRecordsTable(this);
  late final $RemnantRecordsTable remnantRecords = $RemnantRecordsTable(this);
  late final $ToolInvocationRecordsTable toolInvocationRecords =
      $ToolInvocationRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jobRecords,
    remnantRecords,
    toolInvocationRecords,
  ];
}

typedef $$JobRecordsTableCreateCompanionBuilder =
    JobRecordsCompanion Function({
      required String id,
      required String name,
      required String stage,
      required String payloadJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$JobRecordsTableUpdateCompanionBuilder =
    JobRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> stage,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$JobRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $JobRecordsTable> {
  $$JobRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JobRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $JobRecordsTable> {
  $$JobRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stage => $composableBuilder(
    column: $table.stage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JobRecordsTable> {
  $$JobRecordsTableAnnotationComposer({
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

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$JobRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JobRecordsTable,
          JobRecord,
          $$JobRecordsTableFilterComposer,
          $$JobRecordsTableOrderingComposer,
          $$JobRecordsTableAnnotationComposer,
          $$JobRecordsTableCreateCompanionBuilder,
          $$JobRecordsTableUpdateCompanionBuilder,
          (
            JobRecord,
            BaseReferences<_$AppDatabase, $JobRecordsTable, JobRecord>,
          ),
          JobRecord,
          PrefetchHooks Function()
        > {
  $$JobRecordsTableTableManager(_$AppDatabase db, $JobRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobRecordsCompanion(
                id: id,
                name: name,
                stage: stage,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String stage,
                required String payloadJson,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => JobRecordsCompanion.insert(
                id: id,
                name: name,
                stage: stage,
                payloadJson: payloadJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JobRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JobRecordsTable,
      JobRecord,
      $$JobRecordsTableFilterComposer,
      $$JobRecordsTableOrderingComposer,
      $$JobRecordsTableAnnotationComposer,
      $$JobRecordsTableCreateCompanionBuilder,
      $$JobRecordsTableUpdateCompanionBuilder,
      (JobRecord, BaseReferences<_$AppDatabase, $JobRecordsTable, JobRecord>),
      JobRecord,
      PrefetchHooks Function()
    >;
typedef $$RemnantRecordsTableCreateCompanionBuilder =
    RemnantRecordsCompanion Function({
      required String id,
      required String name,
      required String kind,
      required String color,
      required String colorKey,
      required double thicknessMm,
      required double areaMm2,
      required double minX,
      required double minY,
      required double maxX,
      required double maxY,
      required String polygonJson,
      required String location,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RemnantRecordsTableUpdateCompanionBuilder =
    RemnantRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<String> color,
      Value<String> colorKey,
      Value<double> thicknessMm,
      Value<double> areaMm2,
      Value<double> minX,
      Value<double> minY,
      Value<double> maxX,
      Value<double> maxY,
      Value<String> polygonJson,
      Value<String> location,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$RemnantRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RemnantRecordsTable> {
  $$RemnantRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thicknessMm => $composableBuilder(
    column: $table.thicknessMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaMm2 => $composableBuilder(
    column: $table.areaMm2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minX => $composableBuilder(
    column: $table.minX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minY => $composableBuilder(
    column: $table.minY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxX => $composableBuilder(
    column: $table.maxX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxY => $composableBuilder(
    column: $table.maxY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemnantRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RemnantRecordsTable> {
  $$RemnantRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thicknessMm => $composableBuilder(
    column: $table.thicknessMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaMm2 => $composableBuilder(
    column: $table.areaMm2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minX => $composableBuilder(
    column: $table.minX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minY => $composableBuilder(
    column: $table.minY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxX => $composableBuilder(
    column: $table.maxX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxY => $composableBuilder(
    column: $table.maxY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemnantRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemnantRecordsTable> {
  $$RemnantRecordsTableAnnotationComposer({
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

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get colorKey =>
      $composableBuilder(column: $table.colorKey, builder: (column) => column);

  GeneratedColumn<double> get thicknessMm => $composableBuilder(
    column: $table.thicknessMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get areaMm2 =>
      $composableBuilder(column: $table.areaMm2, builder: (column) => column);

  GeneratedColumn<double> get minX =>
      $composableBuilder(column: $table.minX, builder: (column) => column);

  GeneratedColumn<double> get minY =>
      $composableBuilder(column: $table.minY, builder: (column) => column);

  GeneratedColumn<double> get maxX =>
      $composableBuilder(column: $table.maxX, builder: (column) => column);

  GeneratedColumn<double> get maxY =>
      $composableBuilder(column: $table.maxY, builder: (column) => column);

  GeneratedColumn<String> get polygonJson => $composableBuilder(
    column: $table.polygonJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RemnantRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemnantRecordsTable,
          RemnantRecord,
          $$RemnantRecordsTableFilterComposer,
          $$RemnantRecordsTableOrderingComposer,
          $$RemnantRecordsTableAnnotationComposer,
          $$RemnantRecordsTableCreateCompanionBuilder,
          $$RemnantRecordsTableUpdateCompanionBuilder,
          (
            RemnantRecord,
            BaseReferences<_$AppDatabase, $RemnantRecordsTable, RemnantRecord>,
          ),
          RemnantRecord,
          PrefetchHooks Function()
        > {
  $$RemnantRecordsTableTableManager(
    _$AppDatabase db,
    $RemnantRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemnantRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemnantRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemnantRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String> colorKey = const Value.absent(),
                Value<double> thicknessMm = const Value.absent(),
                Value<double> areaMm2 = const Value.absent(),
                Value<double> minX = const Value.absent(),
                Value<double> minY = const Value.absent(),
                Value<double> maxX = const Value.absent(),
                Value<double> maxY = const Value.absent(),
                Value<String> polygonJson = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemnantRecordsCompanion(
                id: id,
                name: name,
                kind: kind,
                color: color,
                colorKey: colorKey,
                thicknessMm: thicknessMm,
                areaMm2: areaMm2,
                minX: minX,
                minY: minY,
                maxX: maxX,
                maxY: maxY,
                polygonJson: polygonJson,
                location: location,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                required String color,
                required String colorKey,
                required double thicknessMm,
                required double areaMm2,
                required double minX,
                required double minY,
                required double maxX,
                required double maxY,
                required String polygonJson,
                required String location,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RemnantRecordsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                color: color,
                colorKey: colorKey,
                thicknessMm: thicknessMm,
                areaMm2: areaMm2,
                minX: minX,
                minY: minY,
                maxX: maxX,
                maxY: maxY,
                polygonJson: polygonJson,
                location: location,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemnantRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemnantRecordsTable,
      RemnantRecord,
      $$RemnantRecordsTableFilterComposer,
      $$RemnantRecordsTableOrderingComposer,
      $$RemnantRecordsTableAnnotationComposer,
      $$RemnantRecordsTableCreateCompanionBuilder,
      $$RemnantRecordsTableUpdateCompanionBuilder,
      (
        RemnantRecord,
        BaseReferences<_$AppDatabase, $RemnantRecordsTable, RemnantRecord>,
      ),
      RemnantRecord,
      PrefetchHooks Function()
    >;
typedef $$ToolInvocationRecordsTableCreateCompanionBuilder =
    ToolInvocationRecordsCompanion Function({
      required String id,
      required String jobId,
      required String toolName,
      required String argumentsJson,
      required String status,
      required String summary,
      required int elapsedMilliseconds,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ToolInvocationRecordsTableUpdateCompanionBuilder =
    ToolInvocationRecordsCompanion Function({
      Value<String> id,
      Value<String> jobId,
      Value<String> toolName,
      Value<String> argumentsJson,
      Value<String> status,
      Value<String> summary,
      Value<int> elapsedMilliseconds,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ToolInvocationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ToolInvocationRecordsTable> {
  $$ToolInvocationRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get argumentsJson => $composableBuilder(
    column: $table.argumentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMilliseconds => $composableBuilder(
    column: $table.elapsedMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ToolInvocationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ToolInvocationRecordsTable> {
  $$ToolInvocationRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobId => $composableBuilder(
    column: $table.jobId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get argumentsJson => $composableBuilder(
    column: $table.argumentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMilliseconds => $composableBuilder(
    column: $table.elapsedMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ToolInvocationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToolInvocationRecordsTable> {
  $$ToolInvocationRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobId =>
      $composableBuilder(column: $table.jobId, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get argumentsJson => $composableBuilder(
    column: $table.argumentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<int> get elapsedMilliseconds => $composableBuilder(
    column: $table.elapsedMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ToolInvocationRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ToolInvocationRecordsTable,
          ToolInvocationRecord,
          $$ToolInvocationRecordsTableFilterComposer,
          $$ToolInvocationRecordsTableOrderingComposer,
          $$ToolInvocationRecordsTableAnnotationComposer,
          $$ToolInvocationRecordsTableCreateCompanionBuilder,
          $$ToolInvocationRecordsTableUpdateCompanionBuilder,
          (
            ToolInvocationRecord,
            BaseReferences<
              _$AppDatabase,
              $ToolInvocationRecordsTable,
              ToolInvocationRecord
            >,
          ),
          ToolInvocationRecord,
          PrefetchHooks Function()
        > {
  $$ToolInvocationRecordsTableTableManager(
    _$AppDatabase db,
    $ToolInvocationRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToolInvocationRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ToolInvocationRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ToolInvocationRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jobId = const Value.absent(),
                Value<String> toolName = const Value.absent(),
                Value<String> argumentsJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<int> elapsedMilliseconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ToolInvocationRecordsCompanion(
                id: id,
                jobId: jobId,
                toolName: toolName,
                argumentsJson: argumentsJson,
                status: status,
                summary: summary,
                elapsedMilliseconds: elapsedMilliseconds,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jobId,
                required String toolName,
                required String argumentsJson,
                required String status,
                required String summary,
                required int elapsedMilliseconds,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ToolInvocationRecordsCompanion.insert(
                id: id,
                jobId: jobId,
                toolName: toolName,
                argumentsJson: argumentsJson,
                status: status,
                summary: summary,
                elapsedMilliseconds: elapsedMilliseconds,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ToolInvocationRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ToolInvocationRecordsTable,
      ToolInvocationRecord,
      $$ToolInvocationRecordsTableFilterComposer,
      $$ToolInvocationRecordsTableOrderingComposer,
      $$ToolInvocationRecordsTableAnnotationComposer,
      $$ToolInvocationRecordsTableCreateCompanionBuilder,
      $$ToolInvocationRecordsTableUpdateCompanionBuilder,
      (
        ToolInvocationRecord,
        BaseReferences<
          _$AppDatabase,
          $ToolInvocationRecordsTable,
          ToolInvocationRecord
        >,
      ),
      ToolInvocationRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JobRecordsTableTableManager get jobRecords =>
      $$JobRecordsTableTableManager(_db, _db.jobRecords);
  $$RemnantRecordsTableTableManager get remnantRecords =>
      $$RemnantRecordsTableTableManager(_db, _db.remnantRecords);
  $$ToolInvocationRecordsTableTableManager get toolInvocationRecords =>
      $$ToolInvocationRecordsTableTableManager(_db, _db.toolInvocationRecords);
}
