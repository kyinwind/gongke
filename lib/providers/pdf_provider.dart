import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

// PDF 控制器
final pdfControllerProvider = StateProvider<PdfController?>((ref) => null);
final pdfLoadingDoneProvider = StateProvider<bool>((ref) => false); //pdf加载状态
final pdfTextDoneProvider = StateProvider<bool>((ref) => false); //pdf文本提取完成状态

class PageCache {
  final int pageIndex; // 页码（从 1 开始）
  String text;
  final PdfPageImage thumbnail;

  PageCache({
    required this.pageIndex,
    required this.text,
    required this.thumbnail,
  });
}
