import 'package:flutter_test/flutter_test.dart';
import 'package:gongke/comm/pdf_listening_logic.dart';

void main() {
  test('listening continues from the current page through the final page', () {
    expect(PdfListeningLogic.pagesFrom(startPage: 3, pageCount: 6).toList(), [
      3,
      4,
      5,
      6,
    ]);
    expect(PdfListeningLogic.pagesFrom(startPage: 7, pageCount: 6), isEmpty);
  });

  test('single pages map to the correct double-page group', () {
    expect(PdfListeningLogic.doublePageIndex(1), 0);
    expect(PdfListeningLogic.doublePageIndex(2), 0);
    expect(PdfListeningLogic.doublePageIndex(3), 1);
    expect(PdfListeningLogic.doublePageIndex(4), 1);
    expect(() => PdfListeningLogic.doublePageIndex(0), throwsArgumentError);
  });
}
