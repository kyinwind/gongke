// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $JingShuTable extends JingShu with TableInfo<$JingShuTable, JingShuData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JingShuTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createDateTimeMeta = const VerificationMeta(
    'createDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> createDateTime =
      GeneratedColumn<DateTime>(
        'create_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileUrlMeta = const VerificationMeta(
    'fileUrl',
  );
  @override
  late final GeneratedColumn<String> fileUrl = GeneratedColumn<String>(
    'file_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoriteDateTimeMeta = const VerificationMeta(
    'favoriteDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> favoriteDateTime =
      GeneratedColumn<DateTime>(
        'favorite_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _muyuMeta = const VerificationMeta('muyu');
  @override
  late final GeneratedColumn<bool> muyu = GeneratedColumn<bool>(
    'muyu',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("muyu" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bkMusicMeta = const VerificationMeta(
    'bkMusic',
  );
  @override
  late final GeneratedColumn<bool> bkMusic = GeneratedColumn<bool>(
    'bk_music',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bk_music" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _bkMusicnameMeta = const VerificationMeta(
    'bkMusicname',
  );
  @override
  late final GeneratedColumn<String> bkMusicname = GeneratedColumn<String>(
    'bk_musicname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuNameMeta = const VerificationMeta(
    'muyuName',
  );
  @override
  late final GeneratedColumn<String> muyuName = GeneratedColumn<String>(
    'muyu_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuImageMeta = const VerificationMeta(
    'muyuImage',
  );
  @override
  late final GeneratedColumn<String> muyuImage = GeneratedColumn<String>(
    'muyu_image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuTypeMeta = const VerificationMeta(
    'muyuType',
  );
  @override
  late final GeneratedColumn<String> muyuType = GeneratedColumn<String>(
    'muyu_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuCountMeta = const VerificationMeta(
    'muyuCount',
  );
  @override
  late final GeneratedColumn<int> muyuCount = GeneratedColumn<int>(
    'muyu_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuIntervalMeta = const VerificationMeta(
    'muyuInterval',
  );
  @override
  late final GeneratedColumn<double> muyuInterval = GeneratedColumn<double>(
    'muyu_interval',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muyuDurationMeta = const VerificationMeta(
    'muyuDuration',
  );
  @override
  late final GeneratedColumn<double> muyuDuration = GeneratedColumn<double>(
    'muyu_duration',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createDateTime,
    remarks,
    name,
    type,
    image,
    fileUrl,
    fileType,
    favoriteDateTime,
    muyu,
    bkMusic,
    bkMusicname,
    muyuName,
    muyuImage,
    muyuType,
    muyuCount,
    muyuInterval,
    muyuDuration,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jing_shu';
  @override
  VerificationContext validateIntegrity(
    Insertable<JingShuData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('create_date_time')) {
      context.handle(
        _createDateTimeMeta,
        createDateTime.isAcceptableOrUnknown(
          data['create_date_time']!,
          _createDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    } else if (isInserting) {
      context.missing(_remarksMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('file_url')) {
      context.handle(
        _fileUrlMeta,
        fileUrl.isAcceptableOrUnknown(data['file_url']!, _fileUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_fileUrlMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('favorite_date_time')) {
      context.handle(
        _favoriteDateTimeMeta,
        favoriteDateTime.isAcceptableOrUnknown(
          data['favorite_date_time']!,
          _favoriteDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('muyu')) {
      context.handle(
        _muyuMeta,
        muyu.isAcceptableOrUnknown(data['muyu']!, _muyuMeta),
      );
    }
    if (data.containsKey('bk_music')) {
      context.handle(
        _bkMusicMeta,
        bkMusic.isAcceptableOrUnknown(data['bk_music']!, _bkMusicMeta),
      );
    }
    if (data.containsKey('bk_musicname')) {
      context.handle(
        _bkMusicnameMeta,
        bkMusicname.isAcceptableOrUnknown(
          data['bk_musicname']!,
          _bkMusicnameMeta,
        ),
      );
    }
    if (data.containsKey('muyu_name')) {
      context.handle(
        _muyuNameMeta,
        muyuName.isAcceptableOrUnknown(data['muyu_name']!, _muyuNameMeta),
      );
    }
    if (data.containsKey('muyu_image')) {
      context.handle(
        _muyuImageMeta,
        muyuImage.isAcceptableOrUnknown(data['muyu_image']!, _muyuImageMeta),
      );
    }
    if (data.containsKey('muyu_type')) {
      context.handle(
        _muyuTypeMeta,
        muyuType.isAcceptableOrUnknown(data['muyu_type']!, _muyuTypeMeta),
      );
    }
    if (data.containsKey('muyu_count')) {
      context.handle(
        _muyuCountMeta,
        muyuCount.isAcceptableOrUnknown(data['muyu_count']!, _muyuCountMeta),
      );
    }
    if (data.containsKey('muyu_interval')) {
      context.handle(
        _muyuIntervalMeta,
        muyuInterval.isAcceptableOrUnknown(
          data['muyu_interval']!,
          _muyuIntervalMeta,
        ),
      );
    }
    if (data.containsKey('muyu_duration')) {
      context.handle(
        _muyuDurationMeta,
        muyuDuration.isAcceptableOrUnknown(
          data['muyu_duration']!,
          _muyuDurationMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JingShuData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JingShuData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      createDateTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}create_date_time'],
          )!,
      remarks:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remarks'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      image:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}image'],
          )!,
      fileUrl:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_url'],
          )!,
      fileType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_type'],
          )!,
      favoriteDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}favorite_date_time'],
      ),
      muyu:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}muyu'],
          )!,
      bkMusic:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}bk_music'],
          )!,
      bkMusicname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bk_musicname'],
      ),
      muyuName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muyu_name'],
      ),
      muyuImage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muyu_image'],
      ),
      muyuType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muyu_type'],
      ),
      muyuCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}muyu_count'],
      ),
      muyuInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}muyu_interval'],
      ),
      muyuDuration: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}muyu_duration'],
      ),
    );
  }

  @override
  $JingShuTable createAlias(String alias) {
    return $JingShuTable(attachedDatabase, alias);
  }
}

class JingShuData extends DataClass implements Insertable<JingShuData> {
  final int id;
  final DateTime createDateTime;
  final String remarks;
  final String name;
  final String type;
  final String image;
  final String fileUrl;
  final String fileType;
  final DateTime? favoriteDateTime;
  final bool muyu;
  final bool bkMusic;
  final String? bkMusicname;
  final String? muyuName;
  final String? muyuImage;
  final String? muyuType;
  final int? muyuCount;
  final double? muyuInterval;
  final double? muyuDuration;
  const JingShuData({
    required this.id,
    required this.createDateTime,
    required this.remarks,
    required this.name,
    required this.type,
    required this.image,
    required this.fileUrl,
    required this.fileType,
    this.favoriteDateTime,
    required this.muyu,
    required this.bkMusic,
    this.bkMusicname,
    this.muyuName,
    this.muyuImage,
    this.muyuType,
    this.muyuCount,
    this.muyuInterval,
    this.muyuDuration,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['create_date_time'] = Variable<DateTime>(createDateTime);
    map['remarks'] = Variable<String>(remarks);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['image'] = Variable<String>(image);
    map['file_url'] = Variable<String>(fileUrl);
    map['file_type'] = Variable<String>(fileType);
    if (!nullToAbsent || favoriteDateTime != null) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime);
    }
    map['muyu'] = Variable<bool>(muyu);
    map['bk_music'] = Variable<bool>(bkMusic);
    if (!nullToAbsent || bkMusicname != null) {
      map['bk_musicname'] = Variable<String>(bkMusicname);
    }
    if (!nullToAbsent || muyuName != null) {
      map['muyu_name'] = Variable<String>(muyuName);
    }
    if (!nullToAbsent || muyuImage != null) {
      map['muyu_image'] = Variable<String>(muyuImage);
    }
    if (!nullToAbsent || muyuType != null) {
      map['muyu_type'] = Variable<String>(muyuType);
    }
    if (!nullToAbsent || muyuCount != null) {
      map['muyu_count'] = Variable<int>(muyuCount);
    }
    if (!nullToAbsent || muyuInterval != null) {
      map['muyu_interval'] = Variable<double>(muyuInterval);
    }
    if (!nullToAbsent || muyuDuration != null) {
      map['muyu_duration'] = Variable<double>(muyuDuration);
    }
    return map;
  }

  JingShuCompanion toCompanion(bool nullToAbsent) {
    return JingShuCompanion(
      id: Value(id),
      createDateTime: Value(createDateTime),
      remarks: Value(remarks),
      name: Value(name),
      type: Value(type),
      image: Value(image),
      fileUrl: Value(fileUrl),
      fileType: Value(fileType),
      favoriteDateTime:
          favoriteDateTime == null && nullToAbsent
              ? const Value.absent()
              : Value(favoriteDateTime),
      muyu: Value(muyu),
      bkMusic: Value(bkMusic),
      bkMusicname:
          bkMusicname == null && nullToAbsent
              ? const Value.absent()
              : Value(bkMusicname),
      muyuName:
          muyuName == null && nullToAbsent
              ? const Value.absent()
              : Value(muyuName),
      muyuImage:
          muyuImage == null && nullToAbsent
              ? const Value.absent()
              : Value(muyuImage),
      muyuType:
          muyuType == null && nullToAbsent
              ? const Value.absent()
              : Value(muyuType),
      muyuCount:
          muyuCount == null && nullToAbsent
              ? const Value.absent()
              : Value(muyuCount),
      muyuInterval:
          muyuInterval == null && nullToAbsent
              ? const Value.absent()
              : Value(muyuInterval),
      muyuDuration:
          muyuDuration == null && nullToAbsent
              ? const Value.absent()
              : Value(muyuDuration),
    );
  }

  factory JingShuData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JingShuData(
      id: serializer.fromJson<int>(json['id']),
      createDateTime: serializer.fromJson<DateTime>(json['createDateTime']),
      remarks: serializer.fromJson<String>(json['remarks']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      image: serializer.fromJson<String>(json['image']),
      fileUrl: serializer.fromJson<String>(json['fileUrl']),
      fileType: serializer.fromJson<String>(json['fileType']),
      favoriteDateTime: serializer.fromJson<DateTime?>(
        json['favoriteDateTime'],
      ),
      muyu: serializer.fromJson<bool>(json['muyu']),
      bkMusic: serializer.fromJson<bool>(json['bkMusic']),
      bkMusicname: serializer.fromJson<String?>(json['bkMusicname']),
      muyuName: serializer.fromJson<String?>(json['muyuName']),
      muyuImage: serializer.fromJson<String?>(json['muyuImage']),
      muyuType: serializer.fromJson<String?>(json['muyuType']),
      muyuCount: serializer.fromJson<int?>(json['muyuCount']),
      muyuInterval: serializer.fromJson<double?>(json['muyuInterval']),
      muyuDuration: serializer.fromJson<double?>(json['muyuDuration']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createDateTime': serializer.toJson<DateTime>(createDateTime),
      'remarks': serializer.toJson<String>(remarks),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'image': serializer.toJson<String>(image),
      'fileUrl': serializer.toJson<String>(fileUrl),
      'fileType': serializer.toJson<String>(fileType),
      'favoriteDateTime': serializer.toJson<DateTime?>(favoriteDateTime),
      'muyu': serializer.toJson<bool>(muyu),
      'bkMusic': serializer.toJson<bool>(bkMusic),
      'bkMusicname': serializer.toJson<String?>(bkMusicname),
      'muyuName': serializer.toJson<String?>(muyuName),
      'muyuImage': serializer.toJson<String?>(muyuImage),
      'muyuType': serializer.toJson<String?>(muyuType),
      'muyuCount': serializer.toJson<int?>(muyuCount),
      'muyuInterval': serializer.toJson<double?>(muyuInterval),
      'muyuDuration': serializer.toJson<double?>(muyuDuration),
    };
  }

  JingShuData copyWith({
    int? id,
    DateTime? createDateTime,
    String? remarks,
    String? name,
    String? type,
    String? image,
    String? fileUrl,
    String? fileType,
    Value<DateTime?> favoriteDateTime = const Value.absent(),
    bool? muyu,
    bool? bkMusic,
    Value<String?> bkMusicname = const Value.absent(),
    Value<String?> muyuName = const Value.absent(),
    Value<String?> muyuImage = const Value.absent(),
    Value<String?> muyuType = const Value.absent(),
    Value<int?> muyuCount = const Value.absent(),
    Value<double?> muyuInterval = const Value.absent(),
    Value<double?> muyuDuration = const Value.absent(),
  }) => JingShuData(
    id: id ?? this.id,
    createDateTime: createDateTime ?? this.createDateTime,
    remarks: remarks ?? this.remarks,
    name: name ?? this.name,
    type: type ?? this.type,
    image: image ?? this.image,
    fileUrl: fileUrl ?? this.fileUrl,
    fileType: fileType ?? this.fileType,
    favoriteDateTime:
        favoriteDateTime.present
            ? favoriteDateTime.value
            : this.favoriteDateTime,
    muyu: muyu ?? this.muyu,
    bkMusic: bkMusic ?? this.bkMusic,
    bkMusicname: bkMusicname.present ? bkMusicname.value : this.bkMusicname,
    muyuName: muyuName.present ? muyuName.value : this.muyuName,
    muyuImage: muyuImage.present ? muyuImage.value : this.muyuImage,
    muyuType: muyuType.present ? muyuType.value : this.muyuType,
    muyuCount: muyuCount.present ? muyuCount.value : this.muyuCount,
    muyuInterval: muyuInterval.present ? muyuInterval.value : this.muyuInterval,
    muyuDuration: muyuDuration.present ? muyuDuration.value : this.muyuDuration,
  );
  JingShuData copyWithCompanion(JingShuCompanion data) {
    return JingShuData(
      id: data.id.present ? data.id.value : this.id,
      createDateTime:
          data.createDateTime.present
              ? data.createDateTime.value
              : this.createDateTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      image: data.image.present ? data.image.value : this.image,
      fileUrl: data.fileUrl.present ? data.fileUrl.value : this.fileUrl,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      favoriteDateTime:
          data.favoriteDateTime.present
              ? data.favoriteDateTime.value
              : this.favoriteDateTime,
      muyu: data.muyu.present ? data.muyu.value : this.muyu,
      bkMusic: data.bkMusic.present ? data.bkMusic.value : this.bkMusic,
      bkMusicname:
          data.bkMusicname.present ? data.bkMusicname.value : this.bkMusicname,
      muyuName: data.muyuName.present ? data.muyuName.value : this.muyuName,
      muyuImage: data.muyuImage.present ? data.muyuImage.value : this.muyuImage,
      muyuType: data.muyuType.present ? data.muyuType.value : this.muyuType,
      muyuCount: data.muyuCount.present ? data.muyuCount.value : this.muyuCount,
      muyuInterval:
          data.muyuInterval.present
              ? data.muyuInterval.value
              : this.muyuInterval,
      muyuDuration:
          data.muyuDuration.present
              ? data.muyuDuration.value
              : this.muyuDuration,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JingShuData(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('image: $image, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileType: $fileType, ')
          ..write('favoriteDateTime: $favoriteDateTime, ')
          ..write('muyu: $muyu, ')
          ..write('bkMusic: $bkMusic, ')
          ..write('bkMusicname: $bkMusicname, ')
          ..write('muyuName: $muyuName, ')
          ..write('muyuImage: $muyuImage, ')
          ..write('muyuType: $muyuType, ')
          ..write('muyuCount: $muyuCount, ')
          ..write('muyuInterval: $muyuInterval, ')
          ..write('muyuDuration: $muyuDuration')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createDateTime,
    remarks,
    name,
    type,
    image,
    fileUrl,
    fileType,
    favoriteDateTime,
    muyu,
    bkMusic,
    bkMusicname,
    muyuName,
    muyuImage,
    muyuType,
    muyuCount,
    muyuInterval,
    muyuDuration,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JingShuData &&
          other.id == this.id &&
          other.createDateTime == this.createDateTime &&
          other.remarks == this.remarks &&
          other.name == this.name &&
          other.type == this.type &&
          other.image == this.image &&
          other.fileUrl == this.fileUrl &&
          other.fileType == this.fileType &&
          other.favoriteDateTime == this.favoriteDateTime &&
          other.muyu == this.muyu &&
          other.bkMusic == this.bkMusic &&
          other.bkMusicname == this.bkMusicname &&
          other.muyuName == this.muyuName &&
          other.muyuImage == this.muyuImage &&
          other.muyuType == this.muyuType &&
          other.muyuCount == this.muyuCount &&
          other.muyuInterval == this.muyuInterval &&
          other.muyuDuration == this.muyuDuration);
}

class JingShuCompanion extends UpdateCompanion<JingShuData> {
  final Value<int> id;
  final Value<DateTime> createDateTime;
  final Value<String> remarks;
  final Value<String> name;
  final Value<String> type;
  final Value<String> image;
  final Value<String> fileUrl;
  final Value<String> fileType;
  final Value<DateTime?> favoriteDateTime;
  final Value<bool> muyu;
  final Value<bool> bkMusic;
  final Value<String?> bkMusicname;
  final Value<String?> muyuName;
  final Value<String?> muyuImage;
  final Value<String?> muyuType;
  final Value<int?> muyuCount;
  final Value<double?> muyuInterval;
  final Value<double?> muyuDuration;
  const JingShuCompanion({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.image = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.fileType = const Value.absent(),
    this.favoriteDateTime = const Value.absent(),
    this.muyu = const Value.absent(),
    this.bkMusic = const Value.absent(),
    this.bkMusicname = const Value.absent(),
    this.muyuName = const Value.absent(),
    this.muyuImage = const Value.absent(),
    this.muyuType = const Value.absent(),
    this.muyuCount = const Value.absent(),
    this.muyuInterval = const Value.absent(),
    this.muyuDuration = const Value.absent(),
  });
  JingShuCompanion.insert({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    required String remarks,
    required String name,
    required String type,
    required String image,
    required String fileUrl,
    required String fileType,
    this.favoriteDateTime = const Value.absent(),
    this.muyu = const Value.absent(),
    this.bkMusic = const Value.absent(),
    this.bkMusicname = const Value.absent(),
    this.muyuName = const Value.absent(),
    this.muyuImage = const Value.absent(),
    this.muyuType = const Value.absent(),
    this.muyuCount = const Value.absent(),
    this.muyuInterval = const Value.absent(),
    this.muyuDuration = const Value.absent(),
  }) : remarks = Value(remarks),
       name = Value(name),
       type = Value(type),
       image = Value(image),
       fileUrl = Value(fileUrl),
       fileType = Value(fileType);
  static Insertable<JingShuData> custom({
    Expression<int>? id,
    Expression<DateTime>? createDateTime,
    Expression<String>? remarks,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? image,
    Expression<String>? fileUrl,
    Expression<String>? fileType,
    Expression<DateTime>? favoriteDateTime,
    Expression<bool>? muyu,
    Expression<bool>? bkMusic,
    Expression<String>? bkMusicname,
    Expression<String>? muyuName,
    Expression<String>? muyuImage,
    Expression<String>? muyuType,
    Expression<int>? muyuCount,
    Expression<double>? muyuInterval,
    Expression<double>? muyuDuration,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createDateTime != null) 'create_date_time': createDateTime,
      if (remarks != null) 'remarks': remarks,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (image != null) 'image': image,
      if (fileUrl != null) 'file_url': fileUrl,
      if (fileType != null) 'file_type': fileType,
      if (favoriteDateTime != null) 'favorite_date_time': favoriteDateTime,
      if (muyu != null) 'muyu': muyu,
      if (bkMusic != null) 'bk_music': bkMusic,
      if (bkMusicname != null) 'bk_musicname': bkMusicname,
      if (muyuName != null) 'muyu_name': muyuName,
      if (muyuImage != null) 'muyu_image': muyuImage,
      if (muyuType != null) 'muyu_type': muyuType,
      if (muyuCount != null) 'muyu_count': muyuCount,
      if (muyuInterval != null) 'muyu_interval': muyuInterval,
      if (muyuDuration != null) 'muyu_duration': muyuDuration,
    });
  }

  JingShuCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createDateTime,
    Value<String>? remarks,
    Value<String>? name,
    Value<String>? type,
    Value<String>? image,
    Value<String>? fileUrl,
    Value<String>? fileType,
    Value<DateTime?>? favoriteDateTime,
    Value<bool>? muyu,
    Value<bool>? bkMusic,
    Value<String?>? bkMusicname,
    Value<String?>? muyuName,
    Value<String?>? muyuImage,
    Value<String?>? muyuType,
    Value<int?>? muyuCount,
    Value<double?>? muyuInterval,
    Value<double?>? muyuDuration,
  }) {
    return JingShuCompanion(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      remarks: remarks ?? this.remarks,
      name: name ?? this.name,
      type: type ?? this.type,
      image: image ?? this.image,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      favoriteDateTime: favoriteDateTime ?? this.favoriteDateTime,
      muyu: muyu ?? this.muyu,
      bkMusic: bkMusic ?? this.bkMusic,
      bkMusicname: bkMusicname ?? this.bkMusicname,
      muyuName: muyuName ?? this.muyuName,
      muyuImage: muyuImage ?? this.muyuImage,
      muyuType: muyuType ?? this.muyuType,
      muyuCount: muyuCount ?? this.muyuCount,
      muyuInterval: muyuInterval ?? this.muyuInterval,
      muyuDuration: muyuDuration ?? this.muyuDuration,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createDateTime.present) {
      map['create_date_time'] = Variable<DateTime>(createDateTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (fileUrl.present) {
      map['file_url'] = Variable<String>(fileUrl.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (favoriteDateTime.present) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime.value);
    }
    if (muyu.present) {
      map['muyu'] = Variable<bool>(muyu.value);
    }
    if (bkMusic.present) {
      map['bk_music'] = Variable<bool>(bkMusic.value);
    }
    if (bkMusicname.present) {
      map['bk_musicname'] = Variable<String>(bkMusicname.value);
    }
    if (muyuName.present) {
      map['muyu_name'] = Variable<String>(muyuName.value);
    }
    if (muyuImage.present) {
      map['muyu_image'] = Variable<String>(muyuImage.value);
    }
    if (muyuType.present) {
      map['muyu_type'] = Variable<String>(muyuType.value);
    }
    if (muyuCount.present) {
      map['muyu_count'] = Variable<int>(muyuCount.value);
    }
    if (muyuInterval.present) {
      map['muyu_interval'] = Variable<double>(muyuInterval.value);
    }
    if (muyuDuration.present) {
      map['muyu_duration'] = Variable<double>(muyuDuration.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JingShuCompanion(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('image: $image, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('fileType: $fileType, ')
          ..write('favoriteDateTime: $favoriteDateTime, ')
          ..write('muyu: $muyu, ')
          ..write('bkMusic: $bkMusic, ')
          ..write('bkMusicname: $bkMusicname, ')
          ..write('muyuName: $muyuName, ')
          ..write('muyuImage: $muyuImage, ')
          ..write('muyuType: $muyuType, ')
          ..write('muyuCount: $muyuCount, ')
          ..write('muyuInterval: $muyuInterval, ')
          ..write('muyuDuration: $muyuDuration')
          ..write(')'))
        .toString();
  }
}

class $TipBookTable extends TipBook with TableInfo<$TipBookTable, TipBookData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TipBookTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createDateTimeMeta = const VerificationMeta(
    'createDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> createDateTime =
      GeneratedColumn<DateTime>(
        'create_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
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
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoriteDateTimeMeta = const VerificationMeta(
    'favoriteDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> favoriteDateTime =
      GeneratedColumn<DateTime>(
        'favorite_date_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createDateTime,
    remarks,
    name,
    image,
    favoriteDateTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tip_book';
  @override
  VerificationContext validateIntegrity(
    Insertable<TipBookData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('create_date_time')) {
      context.handle(
        _createDateTimeMeta,
        createDateTime.isAcceptableOrUnknown(
          data['create_date_time']!,
          _createDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    } else if (isInserting) {
      context.missing(_remarksMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    if (data.containsKey('favorite_date_time')) {
      context.handle(
        _favoriteDateTimeMeta,
        favoriteDateTime.isAcceptableOrUnknown(
          data['favorite_date_time']!,
          _favoriteDateTimeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TipBookData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TipBookData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      createDateTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}create_date_time'],
          )!,
      remarks:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remarks'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      image:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}image'],
          )!,
      favoriteDateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}favorite_date_time'],
      ),
    );
  }

  @override
  $TipBookTable createAlias(String alias) {
    return $TipBookTable(attachedDatabase, alias);
  }
}

class TipBookData extends DataClass implements Insertable<TipBookData> {
  final int id;
  final DateTime createDateTime;
  final String remarks;
  final String name;
  final String image;
  final DateTime? favoriteDateTime;
  const TipBookData({
    required this.id,
    required this.createDateTime,
    required this.remarks,
    required this.name,
    required this.image,
    this.favoriteDateTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['create_date_time'] = Variable<DateTime>(createDateTime);
    map['remarks'] = Variable<String>(remarks);
    map['name'] = Variable<String>(name);
    map['image'] = Variable<String>(image);
    if (!nullToAbsent || favoriteDateTime != null) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime);
    }
    return map;
  }

  TipBookCompanion toCompanion(bool nullToAbsent) {
    return TipBookCompanion(
      id: Value(id),
      createDateTime: Value(createDateTime),
      remarks: Value(remarks),
      name: Value(name),
      image: Value(image),
      favoriteDateTime:
          favoriteDateTime == null && nullToAbsent
              ? const Value.absent()
              : Value(favoriteDateTime),
    );
  }

  factory TipBookData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TipBookData(
      id: serializer.fromJson<int>(json['id']),
      createDateTime: serializer.fromJson<DateTime>(json['createDateTime']),
      remarks: serializer.fromJson<String>(json['remarks']),
      name: serializer.fromJson<String>(json['name']),
      image: serializer.fromJson<String>(json['image']),
      favoriteDateTime: serializer.fromJson<DateTime?>(
        json['favoriteDateTime'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createDateTime': serializer.toJson<DateTime>(createDateTime),
      'remarks': serializer.toJson<String>(remarks),
      'name': serializer.toJson<String>(name),
      'image': serializer.toJson<String>(image),
      'favoriteDateTime': serializer.toJson<DateTime?>(favoriteDateTime),
    };
  }

  TipBookData copyWith({
    int? id,
    DateTime? createDateTime,
    String? remarks,
    String? name,
    String? image,
    Value<DateTime?> favoriteDateTime = const Value.absent(),
  }) => TipBookData(
    id: id ?? this.id,
    createDateTime: createDateTime ?? this.createDateTime,
    remarks: remarks ?? this.remarks,
    name: name ?? this.name,
    image: image ?? this.image,
    favoriteDateTime:
        favoriteDateTime.present
            ? favoriteDateTime.value
            : this.favoriteDateTime,
  );
  TipBookData copyWithCompanion(TipBookCompanion data) {
    return TipBookData(
      id: data.id.present ? data.id.value : this.id,
      createDateTime:
          data.createDateTime.present
              ? data.createDateTime.value
              : this.createDateTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      name: data.name.present ? data.name.value : this.name,
      image: data.image.present ? data.image.value : this.image,
      favoriteDateTime:
          data.favoriteDateTime.present
              ? data.favoriteDateTime.value
              : this.favoriteDateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TipBookData(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('name: $name, ')
          ..write('image: $image, ')
          ..write('favoriteDateTime: $favoriteDateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createDateTime, remarks, name, image, favoriteDateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TipBookData &&
          other.id == this.id &&
          other.createDateTime == this.createDateTime &&
          other.remarks == this.remarks &&
          other.name == this.name &&
          other.image == this.image &&
          other.favoriteDateTime == this.favoriteDateTime);
}

class TipBookCompanion extends UpdateCompanion<TipBookData> {
  final Value<int> id;
  final Value<DateTime> createDateTime;
  final Value<String> remarks;
  final Value<String> name;
  final Value<String> image;
  final Value<DateTime?> favoriteDateTime;
  const TipBookCompanion({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.name = const Value.absent(),
    this.image = const Value.absent(),
    this.favoriteDateTime = const Value.absent(),
  });
  TipBookCompanion.insert({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    required String remarks,
    required String name,
    required String image,
    this.favoriteDateTime = const Value.absent(),
  }) : remarks = Value(remarks),
       name = Value(name),
       image = Value(image);
  static Insertable<TipBookData> custom({
    Expression<int>? id,
    Expression<DateTime>? createDateTime,
    Expression<String>? remarks,
    Expression<String>? name,
    Expression<String>? image,
    Expression<DateTime>? favoriteDateTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createDateTime != null) 'create_date_time': createDateTime,
      if (remarks != null) 'remarks': remarks,
      if (name != null) 'name': name,
      if (image != null) 'image': image,
      if (favoriteDateTime != null) 'favorite_date_time': favoriteDateTime,
    });
  }

  TipBookCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createDateTime,
    Value<String>? remarks,
    Value<String>? name,
    Value<String>? image,
    Value<DateTime?>? favoriteDateTime,
  }) {
    return TipBookCompanion(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      remarks: remarks ?? this.remarks,
      name: name ?? this.name,
      image: image ?? this.image,
      favoriteDateTime: favoriteDateTime ?? this.favoriteDateTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createDateTime.present) {
      map['create_date_time'] = Variable<DateTime>(createDateTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (favoriteDateTime.present) {
      map['favorite_date_time'] = Variable<DateTime>(favoriteDateTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TipBookCompanion(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('name: $name, ')
          ..write('image: $image, ')
          ..write('favoriteDateTime: $favoriteDateTime')
          ..write(')'))
        .toString();
  }
}

class $TipRecordTable extends TipRecord
    with TableInfo<$TipRecordTable, TipRecordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TipRecordTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createDateTimeMeta = const VerificationMeta(
    'createDateTime',
  );
  @override
  late final GeneratedColumn<DateTime> createDateTime =
      GeneratedColumn<DateTime>(
        'create_date_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createDateTime,
    remarks,
    content,
    bookId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tip_record';
  @override
  VerificationContext validateIntegrity(
    Insertable<TipRecordData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('create_date_time')) {
      context.handle(
        _createDateTimeMeta,
        createDateTime.isAcceptableOrUnknown(
          data['create_date_time']!,
          _createDateTimeMeta,
        ),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    } else if (isInserting) {
      context.missing(_remarksMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TipRecordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TipRecordData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      createDateTime:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}create_date_time'],
          )!,
      remarks:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}remarks'],
          )!,
      content:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}content'],
          )!,
      bookId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}book_id'],
          )!,
    );
  }

  @override
  $TipRecordTable createAlias(String alias) {
    return $TipRecordTable(attachedDatabase, alias);
  }
}

class TipRecordData extends DataClass implements Insertable<TipRecordData> {
  final int id;
  final DateTime createDateTime;
  final String remarks;
  final String content;
  final int bookId;
  const TipRecordData({
    required this.id,
    required this.createDateTime,
    required this.remarks,
    required this.content,
    required this.bookId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['create_date_time'] = Variable<DateTime>(createDateTime);
    map['remarks'] = Variable<String>(remarks);
    map['content'] = Variable<String>(content);
    map['book_id'] = Variable<int>(bookId);
    return map;
  }

  TipRecordCompanion toCompanion(bool nullToAbsent) {
    return TipRecordCompanion(
      id: Value(id),
      createDateTime: Value(createDateTime),
      remarks: Value(remarks),
      content: Value(content),
      bookId: Value(bookId),
    );
  }

  factory TipRecordData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TipRecordData(
      id: serializer.fromJson<int>(json['id']),
      createDateTime: serializer.fromJson<DateTime>(json['createDateTime']),
      remarks: serializer.fromJson<String>(json['remarks']),
      content: serializer.fromJson<String>(json['content']),
      bookId: serializer.fromJson<int>(json['bookId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createDateTime': serializer.toJson<DateTime>(createDateTime),
      'remarks': serializer.toJson<String>(remarks),
      'content': serializer.toJson<String>(content),
      'bookId': serializer.toJson<int>(bookId),
    };
  }

  TipRecordData copyWith({
    int? id,
    DateTime? createDateTime,
    String? remarks,
    String? content,
    int? bookId,
  }) => TipRecordData(
    id: id ?? this.id,
    createDateTime: createDateTime ?? this.createDateTime,
    remarks: remarks ?? this.remarks,
    content: content ?? this.content,
    bookId: bookId ?? this.bookId,
  );
  TipRecordData copyWithCompanion(TipRecordCompanion data) {
    return TipRecordData(
      id: data.id.present ? data.id.value : this.id,
      createDateTime:
          data.createDateTime.present
              ? data.createDateTime.value
              : this.createDateTime,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      content: data.content.present ? data.content.value : this.content,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TipRecordData(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('content: $content, ')
          ..write('bookId: $bookId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createDateTime, remarks, content, bookId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TipRecordData &&
          other.id == this.id &&
          other.createDateTime == this.createDateTime &&
          other.remarks == this.remarks &&
          other.content == this.content &&
          other.bookId == this.bookId);
}

class TipRecordCompanion extends UpdateCompanion<TipRecordData> {
  final Value<int> id;
  final Value<DateTime> createDateTime;
  final Value<String> remarks;
  final Value<String> content;
  final Value<int> bookId;
  const TipRecordCompanion({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    this.remarks = const Value.absent(),
    this.content = const Value.absent(),
    this.bookId = const Value.absent(),
  });
  TipRecordCompanion.insert({
    this.id = const Value.absent(),
    this.createDateTime = const Value.absent(),
    required String remarks,
    required String content,
    required int bookId,
  }) : remarks = Value(remarks),
       content = Value(content),
       bookId = Value(bookId);
  static Insertable<TipRecordData> custom({
    Expression<int>? id,
    Expression<DateTime>? createDateTime,
    Expression<String>? remarks,
    Expression<String>? content,
    Expression<int>? bookId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createDateTime != null) 'create_date_time': createDateTime,
      if (remarks != null) 'remarks': remarks,
      if (content != null) 'content': content,
      if (bookId != null) 'book_id': bookId,
    });
  }

  TipRecordCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createDateTime,
    Value<String>? remarks,
    Value<String>? content,
    Value<int>? bookId,
  }) {
    return TipRecordCompanion(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      remarks: remarks ?? this.remarks,
      content: content ?? this.content,
      bookId: bookId ?? this.bookId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createDateTime.present) {
      map['create_date_time'] = Variable<DateTime>(createDateTime.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TipRecordCompanion(')
          ..write('id: $id, ')
          ..write('createDateTime: $createDateTime, ')
          ..write('remarks: $remarks, ')
          ..write('content: $content, ')
          ..write('bookId: $bookId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JingShuTable jingShu = $JingShuTable(this);
  late final $TipBookTable tipBook = $TipBookTable(this);
  late final $TipRecordTable tipRecord = $TipRecordTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jingShu,
    tipBook,
    tipRecord,
  ];
}

typedef $$JingShuTableCreateCompanionBuilder =
    JingShuCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      required String remarks,
      required String name,
      required String type,
      required String image,
      required String fileUrl,
      required String fileType,
      Value<DateTime?> favoriteDateTime,
      Value<bool> muyu,
      Value<bool> bkMusic,
      Value<String?> bkMusicname,
      Value<String?> muyuName,
      Value<String?> muyuImage,
      Value<String?> muyuType,
      Value<int?> muyuCount,
      Value<double?> muyuInterval,
      Value<double?> muyuDuration,
    });
typedef $$JingShuTableUpdateCompanionBuilder =
    JingShuCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<String> remarks,
      Value<String> name,
      Value<String> type,
      Value<String> image,
      Value<String> fileUrl,
      Value<String> fileType,
      Value<DateTime?> favoriteDateTime,
      Value<bool> muyu,
      Value<bool> bkMusic,
      Value<String?> bkMusicname,
      Value<String?> muyuName,
      Value<String?> muyuImage,
      Value<String?> muyuType,
      Value<int?> muyuCount,
      Value<double?> muyuInterval,
      Value<double?> muyuDuration,
    });

class $$JingShuTableFilterComposer
    extends Composer<_$AppDatabase, $JingShuTable> {
  $$JingShuTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get muyu => $composableBuilder(
    column: $table.muyu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bkMusic => $composableBuilder(
    column: $table.bkMusic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bkMusicname => $composableBuilder(
    column: $table.bkMusicname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muyuName => $composableBuilder(
    column: $table.muyuName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muyuImage => $composableBuilder(
    column: $table.muyuImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muyuType => $composableBuilder(
    column: $table.muyuType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get muyuCount => $composableBuilder(
    column: $table.muyuCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get muyuInterval => $composableBuilder(
    column: $table.muyuInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get muyuDuration => $composableBuilder(
    column: $table.muyuDuration,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JingShuTableOrderingComposer
    extends Composer<_$AppDatabase, $JingShuTable> {
  $$JingShuTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get muyu => $composableBuilder(
    column: $table.muyu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bkMusic => $composableBuilder(
    column: $table.bkMusic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bkMusicname => $composableBuilder(
    column: $table.bkMusicname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muyuName => $composableBuilder(
    column: $table.muyuName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muyuImage => $composableBuilder(
    column: $table.muyuImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muyuType => $composableBuilder(
    column: $table.muyuType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get muyuCount => $composableBuilder(
    column: $table.muyuCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get muyuInterval => $composableBuilder(
    column: $table.muyuInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get muyuDuration => $composableBuilder(
    column: $table.muyuDuration,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JingShuTableAnnotationComposer
    extends Composer<_$AppDatabase, $JingShuTable> {
  $$JingShuTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get fileUrl =>
      $composableBuilder(column: $table.fileUrl, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get muyu =>
      $composableBuilder(column: $table.muyu, builder: (column) => column);

  GeneratedColumn<bool> get bkMusic =>
      $composableBuilder(column: $table.bkMusic, builder: (column) => column);

  GeneratedColumn<String> get bkMusicname => $composableBuilder(
    column: $table.bkMusicname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get muyuName =>
      $composableBuilder(column: $table.muyuName, builder: (column) => column);

  GeneratedColumn<String> get muyuImage =>
      $composableBuilder(column: $table.muyuImage, builder: (column) => column);

  GeneratedColumn<String> get muyuType =>
      $composableBuilder(column: $table.muyuType, builder: (column) => column);

  GeneratedColumn<int> get muyuCount =>
      $composableBuilder(column: $table.muyuCount, builder: (column) => column);

  GeneratedColumn<double> get muyuInterval => $composableBuilder(
    column: $table.muyuInterval,
    builder: (column) => column,
  );

  GeneratedColumn<double> get muyuDuration => $composableBuilder(
    column: $table.muyuDuration,
    builder: (column) => column,
  );
}

class $$JingShuTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JingShuTable,
          JingShuData,
          $$JingShuTableFilterComposer,
          $$JingShuTableOrderingComposer,
          $$JingShuTableAnnotationComposer,
          $$JingShuTableCreateCompanionBuilder,
          $$JingShuTableUpdateCompanionBuilder,
          (
            JingShuData,
            BaseReferences<_$AppDatabase, $JingShuTable, JingShuData>,
          ),
          JingShuData,
          PrefetchHooks Function()
        > {
  $$JingShuTableTableManager(_$AppDatabase db, $JingShuTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$JingShuTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$JingShuTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$JingShuTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<String> remarks = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<String> fileUrl = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<DateTime?> favoriteDateTime = const Value.absent(),
                Value<bool> muyu = const Value.absent(),
                Value<bool> bkMusic = const Value.absent(),
                Value<String?> bkMusicname = const Value.absent(),
                Value<String?> muyuName = const Value.absent(),
                Value<String?> muyuImage = const Value.absent(),
                Value<String?> muyuType = const Value.absent(),
                Value<int?> muyuCount = const Value.absent(),
                Value<double?> muyuInterval = const Value.absent(),
                Value<double?> muyuDuration = const Value.absent(),
              }) => JingShuCompanion(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                name: name,
                type: type,
                image: image,
                fileUrl: fileUrl,
                fileType: fileType,
                favoriteDateTime: favoriteDateTime,
                muyu: muyu,
                bkMusic: bkMusic,
                bkMusicname: bkMusicname,
                muyuName: muyuName,
                muyuImage: muyuImage,
                muyuType: muyuType,
                muyuCount: muyuCount,
                muyuInterval: muyuInterval,
                muyuDuration: muyuDuration,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                required String remarks,
                required String name,
                required String type,
                required String image,
                required String fileUrl,
                required String fileType,
                Value<DateTime?> favoriteDateTime = const Value.absent(),
                Value<bool> muyu = const Value.absent(),
                Value<bool> bkMusic = const Value.absent(),
                Value<String?> bkMusicname = const Value.absent(),
                Value<String?> muyuName = const Value.absent(),
                Value<String?> muyuImage = const Value.absent(),
                Value<String?> muyuType = const Value.absent(),
                Value<int?> muyuCount = const Value.absent(),
                Value<double?> muyuInterval = const Value.absent(),
                Value<double?> muyuDuration = const Value.absent(),
              }) => JingShuCompanion.insert(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                name: name,
                type: type,
                image: image,
                fileUrl: fileUrl,
                fileType: fileType,
                favoriteDateTime: favoriteDateTime,
                muyu: muyu,
                bkMusic: bkMusic,
                bkMusicname: bkMusicname,
                muyuName: muyuName,
                muyuImage: muyuImage,
                muyuType: muyuType,
                muyuCount: muyuCount,
                muyuInterval: muyuInterval,
                muyuDuration: muyuDuration,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JingShuTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JingShuTable,
      JingShuData,
      $$JingShuTableFilterComposer,
      $$JingShuTableOrderingComposer,
      $$JingShuTableAnnotationComposer,
      $$JingShuTableCreateCompanionBuilder,
      $$JingShuTableUpdateCompanionBuilder,
      (JingShuData, BaseReferences<_$AppDatabase, $JingShuTable, JingShuData>),
      JingShuData,
      PrefetchHooks Function()
    >;
typedef $$TipBookTableCreateCompanionBuilder =
    TipBookCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      required String remarks,
      required String name,
      required String image,
      Value<DateTime?> favoriteDateTime,
    });
typedef $$TipBookTableUpdateCompanionBuilder =
    TipBookCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<String> remarks,
      Value<String> name,
      Value<String> image,
      Value<DateTime?> favoriteDateTime,
    });

class $$TipBookTableFilterComposer
    extends Composer<_$AppDatabase, $TipBookTable> {
  $$TipBookTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TipBookTableOrderingComposer
    extends Composer<_$AppDatabase, $TipBookTable> {
  $$TipBookTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TipBookTableAnnotationComposer
    extends Composer<_$AppDatabase, $TipBookTable> {
  $$TipBookTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<DateTime> get favoriteDateTime => $composableBuilder(
    column: $table.favoriteDateTime,
    builder: (column) => column,
  );
}

class $$TipBookTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TipBookTable,
          TipBookData,
          $$TipBookTableFilterComposer,
          $$TipBookTableOrderingComposer,
          $$TipBookTableAnnotationComposer,
          $$TipBookTableCreateCompanionBuilder,
          $$TipBookTableUpdateCompanionBuilder,
          (
            TipBookData,
            BaseReferences<_$AppDatabase, $TipBookTable, TipBookData>,
          ),
          TipBookData,
          PrefetchHooks Function()
        > {
  $$TipBookTableTableManager(_$AppDatabase db, $TipBookTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TipBookTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TipBookTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TipBookTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<String> remarks = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> image = const Value.absent(),
                Value<DateTime?> favoriteDateTime = const Value.absent(),
              }) => TipBookCompanion(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                name: name,
                image: image,
                favoriteDateTime: favoriteDateTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                required String remarks,
                required String name,
                required String image,
                Value<DateTime?> favoriteDateTime = const Value.absent(),
              }) => TipBookCompanion.insert(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                name: name,
                image: image,
                favoriteDateTime: favoriteDateTime,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TipBookTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TipBookTable,
      TipBookData,
      $$TipBookTableFilterComposer,
      $$TipBookTableOrderingComposer,
      $$TipBookTableAnnotationComposer,
      $$TipBookTableCreateCompanionBuilder,
      $$TipBookTableUpdateCompanionBuilder,
      (TipBookData, BaseReferences<_$AppDatabase, $TipBookTable, TipBookData>),
      TipBookData,
      PrefetchHooks Function()
    >;
typedef $$TipRecordTableCreateCompanionBuilder =
    TipRecordCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      required String remarks,
      required String content,
      required int bookId,
    });
typedef $$TipRecordTableUpdateCompanionBuilder =
    TipRecordCompanion Function({
      Value<int> id,
      Value<DateTime> createDateTime,
      Value<String> remarks,
      Value<String> content,
      Value<int> bookId,
    });

class $$TipRecordTableFilterComposer
    extends Composer<_$AppDatabase, $TipRecordTable> {
  $$TipRecordTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TipRecordTableOrderingComposer
    extends Composer<_$AppDatabase, $TipRecordTable> {
  $$TipRecordTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bookId => $composableBuilder(
    column: $table.bookId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TipRecordTableAnnotationComposer
    extends Composer<_$AppDatabase, $TipRecordTable> {
  $$TipRecordTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createDateTime => $composableBuilder(
    column: $table.createDateTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);
}

class $$TipRecordTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TipRecordTable,
          TipRecordData,
          $$TipRecordTableFilterComposer,
          $$TipRecordTableOrderingComposer,
          $$TipRecordTableAnnotationComposer,
          $$TipRecordTableCreateCompanionBuilder,
          $$TipRecordTableUpdateCompanionBuilder,
          (
            TipRecordData,
            BaseReferences<_$AppDatabase, $TipRecordTable, TipRecordData>,
          ),
          TipRecordData,
          PrefetchHooks Function()
        > {
  $$TipRecordTableTableManager(_$AppDatabase db, $TipRecordTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$TipRecordTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$TipRecordTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$TipRecordTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                Value<String> remarks = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> bookId = const Value.absent(),
              }) => TipRecordCompanion(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                content: content,
                bookId: bookId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createDateTime = const Value.absent(),
                required String remarks,
                required String content,
                required int bookId,
              }) => TipRecordCompanion.insert(
                id: id,
                createDateTime: createDateTime,
                remarks: remarks,
                content: content,
                bookId: bookId,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TipRecordTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TipRecordTable,
      TipRecordData,
      $$TipRecordTableFilterComposer,
      $$TipRecordTableOrderingComposer,
      $$TipRecordTableAnnotationComposer,
      $$TipRecordTableCreateCompanionBuilder,
      $$TipRecordTableUpdateCompanionBuilder,
      (
        TipRecordData,
        BaseReferences<_$AppDatabase, $TipRecordTable, TipRecordData>,
      ),
      TipRecordData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JingShuTableTableManager get jingShu =>
      $$JingShuTableTableManager(_db, _db.jingShu);
  $$TipBookTableTableManager get tipBook =>
      $$TipBookTableTableManager(_db, _db.tipBook);
  $$TipRecordTableTableManager get tipRecord =>
      $$TipRecordTableTableManager(_db, _db.tipRecord);
}
