enum MuyuSoundVariant {
  regular,
  a,
  b,
  c;

  static const editableCases = [a, b, c];

  String get asset => switch (this) {
    regular => 'mp3/muyu.wav',
    a => 'mp3/muyu_a.mp3',
    b => 'mp3/muyu_b.mp3',
    c => 'mp3/muyu_c.mp3',
  };

  String get shortName => name.toUpperCase();

  static MuyuSoundVariant parse(Object? value) => switch (value) {
    'a' => a,
    'b' => b,
    'c' => c,
    _ => regular,
  };
}

enum MuyuRhythmPatternSource { regular, builtIn, custom }

class MuyuRhythmPattern {
  const MuyuRhythmPattern({
    required this.id,
    required this.displayName,
    required this.sequence,
    required this.source,
    this.isOverridden = false,
  });

  final String id;
  final String displayName;
  final List<MuyuSoundVariant> sequence;
  final MuyuRhythmPatternSource source;
  final bool isOverridden;

  MuyuSoundVariant variantForZeroBasedStrikeIndex(int index) {
    if (index < 0 || sequence.isEmpty) return MuyuSoundVariant.regular;
    return sequence[index % sequence.length];
  }

  String get groupedDescription => source == MuyuRhythmPatternSource.regular
      ? '使用普通木鱼声'
      : sequence.map((variant) => variant.shortName).join(' ');
}

class MuyuRhythmTemplateCatalog {
  static const regular = MuyuRhythmPattern(
    id: 'regular',
    displayName: '普通模式',
    sequence: [MuyuSoundVariant.regular],
    source: MuyuRhythmPatternSource.regular,
  );

  static const masterYinguang = MuyuRhythmPattern(
    id: 'masterYinguangTenRecitation',
    displayName: '印光大师推荐十念法',
    sequence: [
      MuyuSoundVariant.b,
      MuyuSoundVariant.b,
      MuyuSoundVariant.b,
      MuyuSoundVariant.c,
      MuyuSoundVariant.c,
      MuyuSoundVariant.c,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
    ],
    source: MuyuRhythmPatternSource.builtIn,
  );

  static const antiDrowsiness = MuyuRhythmPattern(
    id: 'alternatingTenRecitation',
    displayName: '防昏沉十念法',
    sequence: [
      MuyuSoundVariant.b,
      MuyuSoundVariant.c,
      MuyuSoundVariant.b,
      MuyuSoundVariant.c,
      MuyuSoundVariant.b,
      MuyuSoundVariant.c,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
      MuyuSoundVariant.a,
    ],
    source: MuyuRhythmPatternSource.builtIn,
  );

  static const builtIns = [regular, masterYinguang, antiDrowsiness];
  static const builtInIds = {
    'masterYinguangTenRecitation',
    'alternatingTenRecitation',
  };
}
