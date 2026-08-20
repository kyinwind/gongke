import 'package:audioplayers/audioplayers.dart';

import '../model/muyu_rhythm_pattern.dart';

class MuyuRhythmAudioPlayer {
  MuyuRhythmAudioPlayer._();

  static final MuyuRhythmAudioPlayer _instance = MuyuRhythmAudioPlayer._();
  factory MuyuRhythmAudioPlayer() => _instance;

  final Map<MuyuSoundVariant, AudioPlayer> _players = {};

  AudioPlayer _playerFor(MuyuSoundVariant variant) => _players.putIfAbsent(
    variant,
    () => AudioPlayer(playerId: 'muyu_rhythm_${variant.name}'),
  );

  Future<void> playMuyu(MuyuSoundVariant variant) async {
    for (final player in _players.values) {
      await player.stop();
    }
    for (final candidate in _fallbacks(variant)) {
      try {
        await _playerFor(candidate).play(AssetSource(candidate.asset));
        return;
      } catch (_) {
        // Try the next lower-pitched available asset.
      }
    }
  }

  Future<void> stopMuyu() async {
    for (final player in _players.values) {
      await player.stop();
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }

  static List<MuyuSoundVariant> _fallbacks(MuyuSoundVariant variant) =>
      switch (variant) {
        MuyuSoundVariant.c => const [
          MuyuSoundVariant.c,
          MuyuSoundVariant.b,
          MuyuSoundVariant.a,
          MuyuSoundVariant.regular,
        ],
        MuyuSoundVariant.b => const [
          MuyuSoundVariant.b,
          MuyuSoundVariant.a,
          MuyuSoundVariant.regular,
        ],
        MuyuSoundVariant.a => const [
          MuyuSoundVariant.a,
          MuyuSoundVariant.regular,
        ],
        MuyuSoundVariant.regular => const [MuyuSoundVariant.regular],
      };
}
