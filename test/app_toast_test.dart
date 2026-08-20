import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';

void main() {
  testWidgets('AppToast uses the root overlay and dismisses automatically', (
    tester,
  ) async {
    AppToast.configure(
      const AppToastConfig(
        successDuration: Duration(milliseconds: 50),
        animationDuration: Duration(milliseconds: 1),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => AppToast.success(context, '保存成功'),
              child: const Text('显示通知'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('显示通知'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('保存成功'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('保存成功'), findsNothing);

    AppToast.clear();
    await tester.pump(const Duration(milliseconds: 1));
  });
}
