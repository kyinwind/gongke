import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/muyu_rhythm_pattern.dart';

class MuyuRhythmPatternStore {
  static const _snapshotKey = 'gongke.muyuRhythmPreferences';

  List<MuyuRhythmPattern> _patterns = [...MuyuRhythmTemplateCatalog.builtIns];
  final Map<String, Map<String, Object?>> _overrides = {};
  final List<Map<String, Object?>> _customs = [];
  final Map<String, String> _selections = {};
  int revision = 0;

  List<MuyuRhythmPattern> get selectablePatterns =>
      List.unmodifiable(_patterns);

  Future<void> load() async {
    _overrides.clear();
    _customs.clear();
    _selections.clear();
    final raw = (await SharedPreferences.getInstance()).getString(_snapshotKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final root = jsonDecode(raw) as Map<String, dynamic>;
        if ((root['schemaVersion'] as int? ?? 1) <= 1) {
          for (final item in (root['builtInOverrides'] as List? ?? const [])) {
            final map = Map<String, Object?>.from(item as Map);
            final id = map['id'] as String?;
            if (id != null &&
                MuyuRhythmTemplateCatalog.builtInIds.contains(id) &&
                _validSequence(map['sequence'])) {
              _overrides[id] = map;
            }
          }
          for (final item in (root['customPatterns'] as List? ?? const [])) {
            final map = Map<String, Object?>.from(item as Map);
            if ((map['id'] as String? ?? '').startsWith('user.') &&
                _validSequence(map['sequence'])) {
              _customs.add(map);
            }
          }
          for (final item in (root['selections'] as List? ?? const [])) {
            final map = Map<String, Object?>.from(item as Map);
            final type = map['gongKeType'] as String? ?? '';
            final name = map['gongKeName'] as String? ?? '';
            final id = map['patternID'] as String? ?? 'regular';
            _selections[_selectionKey(type, name)] = id;
          }
        }
      } catch (_) {
        // Keep the corrupted snapshot untouched and safely fall back to built-ins.
      }
    }
    _rebuild();
  }

  MuyuRhythmPattern patternFor(String? id) => _patterns.firstWhere(
    (pattern) => pattern.id == id,
    orElse: () => MuyuRhythmTemplateCatalog.regular,
  );

  String selectedPatternId({
    required String gongKeType,
    required String gongKeName,
  }) => patternFor(_selections[_selectionKey(gongKeType, gongKeName)]).id;

  int usageCount(String id) =>
      _selections.values.where((patternId) => patternId == id).length;

  Future<void> select({
    required String patternID,
    required String gongKeType,
    required String gongKeName,
  }) async {
    _selections[_selectionKey(gongKeType, gongKeName)] = patternFor(
      patternID,
    ).id;
    await _persist();
  }

  Future<String?> createCustom({
    required String name,
    required List<MuyuSoundVariant> sequence,
  }) async {
    final error = _validate(name, sequence);
    if (error != null) return error;
    final now = DateTime.now();
    _customs.add({
      'id': 'user.${now.microsecondsSinceEpoch}',
      'name': name.trim(),
      'sequence': sequence.map((variant) => variant.name).toList(),
      'sortOrder': _customs.length,
      'createdAt': now.millisecondsSinceEpoch,
      'updatedAt': now.millisecondsSinceEpoch,
    });
    await _persist();
    return null;
  }

  Future<String?> updateCustom({
    required String id,
    required String name,
    required List<MuyuSoundVariant> sequence,
  }) async {
    final index = _customs.indexWhere((item) => item['id'] == id);
    if (index < 0) return '未找到该十念法';
    final error = _validate(name, sequence, ignoredId: id);
    if (error != null) return error;
    _customs[index] = {
      ..._customs[index],
      'name': name.trim(),
      'sequence': sequence.map((variant) => variant.name).toList(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _persist();
    return null;
  }

  Future<String?> updateBuiltIn({
    required String id,
    required List<MuyuSoundVariant> sequence,
  }) async {
    if (!MuyuRhythmTemplateCatalog.builtInIds.contains(id)) return '不是内置模式';
    if (!_validVariants(sequence)) return '十念法必须为 10 个 A/B/C 声位';
    _overrides[id] = {
      'id': id,
      'sequence': sequence.map((variant) => variant.name).toList(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    await _persist();
    return null;
  }

  Future<void> resetBuiltIn(String id) async {
    _overrides.remove(id);
    await _persist();
  }

  Future<String?> deleteCustom({
    required String id,
    required String replacementID,
  }) async {
    final index = _customs.indexWhere((item) => item['id'] == id);
    if (index < 0) return '未找到该十念法';
    if (replacementID == id || patternFor(replacementID).id != replacementID) {
      return '替代模式无效';
    }
    _selections.updateAll((key, value) => value == id ? replacementID : value);
    _customs.removeAt(index);
    await _persist();
    return null;
  }

  String? _validate(
    String name,
    List<MuyuSoundVariant> sequence, {
    String? ignoredId,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '名称不能为空';
    if (trimmed.length > 20) return '名称最多 20 个字符';
    if (_patterns.any(
      (pattern) =>
          pattern.id != ignoredId &&
          pattern.displayName.toLowerCase() == trimmed.toLowerCase(),
    )) {
      return '名称已存在';
    }
    if (!_validVariants(sequence)) return '十念法必须为 10 个 A/B/C 声位';
    return null;
  }

  static bool _validVariants(List<MuyuSoundVariant> sequence) =>
      sequence.length == 10 &&
      sequence.every(MuyuSoundVariant.editableCases.contains);

  static bool _validSequence(Object? sequence) =>
      sequence is List &&
      sequence.length == 10 &&
      sequence.every((item) => item == 'a' || item == 'b' || item == 'c');

  static String _selectionKey(String type, String name) => '$type\u0000$name';

  void _rebuild() {
    final result = <MuyuRhythmPattern>[];
    for (final builtIn in MuyuRhythmTemplateCatalog.builtIns) {
      final override = _overrides[builtIn.id];
      if (override == null) {
        result.add(builtIn);
      } else {
        result.add(
          MuyuRhythmPattern(
            id: builtIn.id,
            displayName: builtIn.displayName,
            sequence: (override['sequence'] as List)
                .map(MuyuSoundVariant.parse)
                .toList(),
            source: MuyuRhythmPatternSource.builtIn,
            isOverridden: true,
          ),
        );
      }
    }
    _customs.sort(
      (a, b) =>
          (a['sortOrder'] as int? ?? 0).compareTo(b['sortOrder'] as int? ?? 0),
    );
    result.addAll(
      _customs.map(
        (item) => MuyuRhythmPattern(
          id: item['id'] as String,
          displayName: item['name'] as String,
          sequence: (item['sequence'] as List)
              .map(MuyuSoundVariant.parse)
              .toList(),
          source: MuyuRhythmPatternSource.custom,
        ),
      ),
    );
    _patterns = result;
    revision++;
  }

  Future<void> _persist() async {
    final selections = _selections.entries.map((entry) {
      final parts = entry.key.split('\u0000');
      return {
        'gongKeType': parts.first,
        'gongKeName': parts.last,
        'patternID': entry.value,
      };
    }).toList();
    final snapshot = jsonEncode({
      'schemaVersion': 1,
      'builtInOverrides': _overrides.values.toList(),
      'customPatterns': _customs,
      'selections': selections,
    });
    await (await SharedPreferences.getInstance()).setString(
      _snapshotKey,
      snapshot,
    );
    _rebuild();
  }
}

final muyuRhythmStore = MuyuRhythmPatternStore();
