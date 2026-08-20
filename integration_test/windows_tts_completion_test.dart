import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Windows speech completes on the Flutter platform thread', (
    tester,
  ) async {
    if (!Platform.isWindows) return;

    final tts = FlutterTts();
    await tts.setLanguage('zh-CN');
    await tts.setSpeechRate(0.5);
    await tts.awaitSpeakCompletion(true);

    final result = await tts
        .speak('测试朗读完成')
        .timeout(const Duration(seconds: 15));

    expect(result, 1);
  });
}
