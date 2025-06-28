import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfThumbnailList extends StatefulWidget {
  final PdfDocument document;
  final int currentPage;
  final int totalPages;
  final void Function(int pageIndex) onPageSelected; //pageIndex从1开始
  final double thumbnailWidth;
  final Axis direction; // 新增

  const PdfThumbnailList({
    super.key,
    required this.document,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    this.thumbnailWidth = 50,
    this.direction = Axis.vertical, // 默认纵向
  });

  @override
  State<PdfThumbnailList> createState() => _PdfThumbnailListState();
}

class _PdfThumbnailListState extends State<PdfThumbnailList> {
  List<Future<PdfPageImage?>>? thumbnails;
  List<int> pageIndexes = [];
  int? _previewPage;

  @override
  void initState() {
    super.initState();
    int displayCount = widget.totalPages <= 10 ? widget.totalPages : 10;
    pageIndexes = List.generate(
      displayCount,
      (i) => ((i * widget.totalPages) / displayCount).floor(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<Future<PdfPageImage?>> tempThumbnails = [];
      for (var index in pageIndexes) {
        if (!mounted) return;
        final page = await widget.document.getPage(index + 1);
        final pageWidth = page.width.toDouble();
        final pageHeight = page.height.toDouble();
        final calculatedHeight = widget.thumbnailWidth * pageHeight / pageWidth;
        tempThumbnails.add(
          page.render(
            width: widget.thumbnailWidth,
            height: calculatedHeight,
            format: PdfPageImageFormat.jpeg,
          ),
        );
        page.close();
      }
      if (mounted) {
        setState(() {
          thumbnails = tempThumbnails;
        });
      }
    });
  }

  void _handleTouch(Offset localPos, Size size) {
    final percent = widget.direction == Axis.vertical
        ? (localPos.dy / size.height).clamp(0.0, 1.0)
        : (localPos.dx / size.width).clamp(0.0, 1.0);

    final actualPage = (percent * widget.totalPages).floor().clamp(
      0,
      widget.totalPages - 1,
    );

    setState(() {
      _previewPage = actualPage + 1;
    });

    // ⚠️ 不再调用 widget.onPageSelected 以避免实时跳转
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                _handleTouch(details.localPosition, size);
                if (_previewPage != null) {
                  widget.onPageSelected(_previewPage!);
                  setState(() => _previewPage = null);
                }
              },
              onPanUpdate: (details) =>
                  _handleTouch(details.localPosition, size),
              onPanEnd: (_) {
                if (_previewPage != null) {
                  widget.onPageSelected(_previewPage!);
                  setState(() => _previewPage = null);
                }
              },
              child: thumbnails == null
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 1),
                    )
                  : Flex(
                      direction: widget.direction,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(pageIndexes.length, (i) {
                        return FutureBuilder<PdfPageImage?>(
                          future: thumbnails![i],
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final image = snapshot.data!;
                              final aspectRatio = image.width! / image.height!;
                              final width = widget.thumbnailWidth;
                              final height = width / aspectRatio;
                              return Container(
                                padding: const EdgeInsets.all(2.0),
                                child: Image.memory(
                                  image.bytes,
                                  width: width,
                                  height: height,
                                  fit: BoxFit.contain,
                                ),
                              );
                            } else {
                              return SizedBox(
                                width: widget.thumbnailWidth,
                                height: widget.thumbnailWidth * 1.4,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }),
                    ),
            );
          },
        ),
        if (_previewPage != null)
          Positioned(
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_previewPage/${widget.totalPages}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
