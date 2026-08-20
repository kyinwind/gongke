import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/muyu_rhythm_audio_player.dart';
import 'package:gongke/model/muyu_rhythm_pattern.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Windows replays the same woodblock source three times', (
    tester,
  ) async {
    if (!Platform.isWindows) return;

    final player = MuyuRhythmAudioPlayer();
    for (var index = 0; index < 3; index++) {
      await player
          .playMuyu(MuyuSoundVariant.b)
          .timeout(const Duration(seconds: 5));
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }
    await player.stopMuyu();
  });
}
