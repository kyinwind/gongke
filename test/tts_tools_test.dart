import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/tts_tools.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_tts');

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'speak reports completion when its awaited native result completes',
    () async {
      final speechResult = Completer<int>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'speak') return speechResult.future;
            return 1;
          });

      final tts = TtsTools();
      var completionCount = 0;
      final speaking = tts.speak('测试', () => completionCount++);

      await Future<void>.delayed(Duration.zero);
      expect(completionCount, 0);

      speechResult.complete(1);
      await speaking;

      expect(completionCount, 1);
    },
  );
}
