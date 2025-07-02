import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../providers/pdf_provider.dart';

class PdfThumbnailList extends StatefulWidget {
  final List<PageCache> pageCaches; // 使用缓存数据
  final int currentPage;
  final void Function(int pageIndex) onPageSelected; //pageIndex从1开始
  final double thumbnailWidth;
  final Axis direction; // 新增

  const PdfThumbnailList({
    super.key,
    required this.pageCaches,
    required this.currentPage,
    required this.onPageSelected,
    this.thumbnailWidth = 50,
    this.direction = Axis.vertical,
  });

  @override
  State<PdfThumbnailList> createState() => _PdfThumbnailListState();
}

class _PdfThumbnailListState extends State<PdfThumbnailList> {
  int? _previewPage;

  void _handleTouch(Offset localPos, Size size) {
    final percent = widget.direction == Axis.vertical
        ? (localPos.dy / size.height).clamp(0.0, 1.0)
        : (localPos.dx / size.width).clamp(0.0, 1.0);

    final actualPage = (percent * widget.pageCaches.length).floor().clamp(
      0,
      widget.pageCaches.length - 1,
    );

    setState(() {
      _previewPage = actualPage + 1;
    });
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
              onPanEnd: (details) {
                if (_previewPage != null) {
                  widget.onPageSelected(_previewPage!);
                  setState(() => _previewPage = null);
                }
              },
              onPanCancel: () {
                if (_previewPage != null) {
                  widget.onPageSelected(_previewPage!);
                  setState(() => _previewPage = null);
                }
              },
              child: widget.direction == Axis.vertical
                  ? Column(children: _buildThumbnails())
                  : Row(children: _buildThumbnails()),
            );
          },
        ),
        if (_previewPage != null)
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_previewPage/${widget.pageCaches.length}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }

  /// ✅ 返回根据需求筛选出的要显示的缩略图列表
  List<PageCache> _buildDisplayCaches() {
    final totalPages = widget.pageCaches.length;

    if (totalPages <= 10) {
      // 总页数不超过 10 页，显示全部
      return widget.pageCaches;
    }

    List<PageCache> selected = [];

    // 保证第一页和最后一页一定出现
    selected.add(widget.pageCaches[0]);

    int samplesNeeded = 8; // 除去首尾，最多可显示的中间页数
    double interval = (totalPages - 2) / (samplesNeeded + 1);

    for (int i = 1; i <= samplesNeeded; i++) {
      int pageIndex = (i * interval).round(); // 获取接近中间平均分布的索引
      // 防止越界
      pageIndex = pageIndex.clamp(1, totalPages - 2);
      selected.add(widget.pageCaches[pageIndex]);
    }

    selected.add(widget.pageCaches[totalPages - 1]);

    return selected;
  }

  List<Widget> _buildThumbnails() {
    final displayCaches = _buildDisplayCaches();

    return displayCaches.map((cache) {
      final isSelected = widget.currentPage == cache.pageIndex;
      final thumbImage = Image.memory(
        cache.thumbnail.bytes,
        width: widget.thumbnailWidth,
        fit: BoxFit.fitWidth,
      );

      return GestureDetector(
        onTap: () => widget.onPageSelected(cache.pageIndex),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
          child: thumbImage,
        ),
      );
    }).toList();
  }
}
