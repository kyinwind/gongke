import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/date_tools.dart';

void main() {
  test('historical dates accept seconds, milliseconds and ISO strings', () {
    final expected = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    expect(DateTools.tryParseFlexibleDate(1700000000), expected);
    expect(DateTools.tryParseFlexibleDate(1700000000000), expected);
    expect(DateTools.tryParseFlexibleDate('1700000000'), expected);
    expect(
      DateTools.tryParseFlexibleDate('2026-08-20T00:00:00Z')?.toUtc(),
      DateTime.utc(2026, 8, 20),
    );
    expect(DateTools.tryParseFlexibleDate('invalid'), isNull);
  });
}
