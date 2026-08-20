import 'dart:convert';
import 'dart:typed_data';

class TipFileFormatException implements Exception {
  const TipFileFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TipBookFileDto {
  const TipBookFileDto({this.schemaVersion = 2, required this.book});

  final int schemaVersion;
  final TipBookDto book;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'quotation': book.toJson(),
  };
}

class TipBookDto {
  const TipBookDto({
    this.sourceId,
    required this.name,
    this.remarks = '',
    this.image = '',
    this.version,
    this.sourceType = 'imported',
    this.productId,
    required this.records,
  });

  final String? sourceId;
  final String name;
  final String remarks;
  final String image;
  final String? version;
  final String sourceType;
  final String? productId;
  final List<TipRecordDto> records;

  Map<String, Object?> toJson() => {
    if (sourceId != null) 'id': sourceId,
    'name': name,
    'remarks': remarks,
    'image': image,
    if (version != null) 'ver': version,
    'sourceType': sourceType,
    if (productId != null) 'productId': productId,
    'records': records.map((record) => record.toJson()).toList(),
  };
}

class TipRecordDto {
  const TipRecordDto({
    required this.jsonId,
    required this.content,
    this.favoriteDateTime,
    this.completedDateTime,
    this.comments = '',
    this.tag,
    this.sortOrder = 0,
  });

  final String jsonId;
  final String content;
  final DateTime? favoriteDateTime;
  final DateTime? completedDateTime;
  final String comments;
  final String? tag;
  final int sortOrder;

  Map<String, Object?> toJson() => {
    'id': jsonId,
    'content': content,
    'isFavorite': favoriteDateTime != null,
    if (favoriteDateTime != null)
      'favoriteDateTime': favoriteDateTime!.toUtc().toIso8601String(),
    'isShow': completedDateTime != null,
    if (completedDateTime != null)
      'completedDate': completedDateTime!.toUtc().toIso8601String(),
    if (comments.isNotEmpty) 'comments': comments,
    if (tag != null) 'tag': tag,
    'sortOrder': sortOrder,
  };
}

class TipFileCodec {
  const TipFileCodec({
    this.maxFileBytes = 10 * 1024 * 1024,
    this.maxDecodedImageBytes = 2 * 1024 * 1024,
  });

  final int maxFileBytes;
  final int maxDecodedImageBytes;

  TipBookFileDto decodeBytes(Uint8List bytes) {
    if (bytes.length > maxFileBytes) {
      throw TipFileFormatException(
        '开示文件超过 ${maxFileBytes ~/ (1024 * 1024)} MiB 限制',
      );
    }
    try {
      return decode(utf8.decode(bytes));
    } on FormatException {
      throw const TipFileFormatException('开示文件不是有效的 UTF-8 JSON');
    }
  }

  TipBookFileDto decode(String source) {
    Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw TipFileFormatException('JSON 格式错误：${error.message}');
    }
    final root = _asMap(decoded, r'$');
    final schemaVersion =
        _optionalInt(root['schemaVersion'], r'$.schemaVersion') ?? 1;
    if (schemaVersion < 1 || schemaVersion > 2) {
      throw TipFileFormatException('不支持的开示文件版本：$schemaVersion');
    }

    // Old files used {quotation: ...}; a few early exports stored the
    // quotation object directly. Both remain readable, while v2 always writes
    // the wrapped form.
    final quotation = root.containsKey('quotation')
        ? _asMap(root['quotation'], r'$.quotation')
        : root;
    final name = _requiredString(quotation['name'], r'$.quotation.name').trim();
    if (name.isEmpty) {
      throw const TipFileFormatException(r'$.quotation.name 不能为空');
    }
    final image =
        _optionalString(quotation['image'], r'$.quotation.image') ?? '';
    _validateImage(image);
    final rawRecords = quotation['records'];
    if (rawRecords is! List) {
      throw const TipFileFormatException(r'$.quotation.records 必须是数组');
    }

    final records = <TipRecordDto>[];
    final seenIds = <String>{};
    for (var index = 0; index < rawRecords.length; index++) {
      final path =
          r'$.quotation.records['
          '${index.toString()}]';
      final record = _asMap(rawRecords[index], path);
      final content = _requiredString(
        record['content'],
        '$path.content',
      ).trim();
      if (content.isEmpty) {
        throw TipFileFormatException('$path.content 不能为空');
      }
      var jsonId = _stringLike(record['id'] ?? record['jsonId'], '$path.id');
      jsonId = jsonId?.trim();
      jsonId = (jsonId == null || jsonId.isEmpty)
          ? 'record-${index + 1}'
          : jsonId;
      if (!seenIds.add(jsonId)) {
        throw TipFileFormatException('$path.id 与同文件中的其他记录重复');
      }
      final isFavorite =
          _optionalBool(record['isFavorite'], '$path.isFavorite') ?? false;
      final explicitFavorite = _optionalDate(
        record['favoriteDateTime'],
        '$path.favoriteDateTime',
      );
      records.add(
        TipRecordDto(
          jsonId: jsonId,
          content: content,
          favoriteDateTime:
              explicitFavorite ?? (isFavorite ? DateTime.now().toUtc() : null),
          completedDateTime: _optionalDate(
            record['completedDate'] ?? record['completedDateTime'],
            '$path.completedDate',
          ),
          comments: _optionalString(record['comments'], '$path.comments') ?? '',
          tag: _optionalString(record['tag'], '$path.tag'),
          sortOrder:
              _optionalInt(record['sortOrder'], '$path.sortOrder') ?? index,
        ),
      );
    }

    return TipBookFileDto(
      schemaVersion: schemaVersion,
      book: TipBookDto(
        sourceId: _stringLike(
          quotation['id'] ?? quotation['sourceId'],
          r'$.quotation.id',
        ),
        name: name,
        remarks:
            _optionalString(quotation['remarks'], r'$.quotation.remarks') ?? '',
        image: image,
        version: _stringLike(
          quotation['ver'] ?? quotation['version'],
          r'$.quotation.ver',
        ),
        sourceType:
            _optionalString(
              quotation['sourceType'],
              r'$.quotation.sourceType',
            ) ??
            'imported',
        productId: _stringLike(
          quotation['productId'],
          r'$.quotation.productId',
        ),
        records: records,
      ),
    );
  }

  Uint8List encodeBytes(TipBookFileDto file) =>
      Uint8List.fromList(utf8.encode(encode(file)));

  String encode(TipBookFileDto file) =>
      const JsonEncoder.withIndent('  ').convert(file.toJson());

  void _validateImage(String image) {
    if (image.isEmpty) return;
    final payload = image.contains(',')
        ? image.substring(image.indexOf(',') + 1)
        : image;
    Uint8List bytes;
    try {
      bytes = base64Decode(payload);
    } on FormatException {
      throw const TipFileFormatException(r'$.quotation.image 不是有效的 Base64 图片');
    }
    if (bytes.length > maxDecodedImageBytes) {
      throw TipFileFormatException(
        r'$.quotation.image 解码后超过 '
        '${maxDecodedImageBytes ~/ (1024 * 1024)} MiB 限制',
      );
    }
    if (bytes.isNotEmpty && !_hasImageSignature(bytes)) {
      throw const TipFileFormatException(r'$.quotation.image 内容不是受支持的图片');
    }
  }

  bool _hasImageSignature(Uint8List bytes) {
    bool starts(List<int> signature) =>
        bytes.length >= signature.length &&
        Iterable<int>.generate(
          signature.length,
        ).every((i) => bytes[i] == signature[i]);
    return starts(const [0x89, 0x50, 0x4e, 0x47]) ||
        starts(const [0xff, 0xd8, 0xff]) ||
        starts(const [0x47, 0x49, 0x46, 0x38]) ||
        (bytes.length >= 12 &&
            starts(const [0x52, 0x49, 0x46, 0x46]) &&
            bytes[8] == 0x57 &&
            bytes[9] == 0x45 &&
            bytes[10] == 0x42 &&
            bytes[11] == 0x50);
  }

  Map<String, Object?> _asMap(Object? value, String path) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    throw TipFileFormatException('$path 必须是对象');
  }

  String _requiredString(Object? value, String path) {
    if (value is String) return value;
    throw TipFileFormatException('$path 必须是字符串');
  }

  String? _optionalString(Object? value, String path) {
    if (value == null) return null;
    if (value is String) return value;
    throw TipFileFormatException('$path 必须是字符串');
  }

  String? _stringLike(Object? value, String path) {
    if (value == null) return null;
    if (value is String || value is num) return value.toString();
    throw TipFileFormatException('$path 必须是字符串或数字');
  }

  int? _optionalInt(Object? value, String path) {
    if (value == null) return null;
    if (value is int) return value;
    throw TipFileFormatException('$path 必须是整数');
  }

  bool? _optionalBool(Object? value, String path) {
    if (value == null) return null;
    if (value is bool) return value;
    throw TipFileFormatException('$path 必须是布尔值');
  }

  DateTime? _optionalDate(Object? value, String path) {
    if (value == null || value == '') return null;
    if (value is num && value.isFinite) {
      final number = value.toDouble();
      if (number.abs() >= 100000000000) {
        return DateTime.fromMillisecondsSinceEpoch(number.round(), isUtc: true);
      }
      if (number.abs() >= 1200000000) {
        return DateTime.fromMillisecondsSinceEpoch(
          (number * 1000).round(),
          isUtc: true,
        );
      }
      return DateTime.utc(
        2001,
      ).add(Duration(milliseconds: (number * 1000).round()));
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw TipFileFormatException('$path 不是有效的秒/毫秒/ISO 8601/Swift Codable 日期');
  }
}
