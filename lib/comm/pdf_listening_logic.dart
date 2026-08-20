class PdfListeningLogic {
  const PdfListeningLogic._();

  static Iterable<int> pagesFrom({
    required int startPage,
    required int pageCount,
  }) sync* {
    if (startPage < 1 || pageCount < startPage) return;
    for (var page = startPage; page <= pageCount; page++) {
      yield page;
    }
  }

  static int doublePageIndex(int pageNumber) {
    if (pageNumber < 1) {
      throw ArgumentError.value(pageNumber, 'pageNumber', '必须从 1 开始');
    }
    return (pageNumber - 1) ~/ 2;
  }
}
