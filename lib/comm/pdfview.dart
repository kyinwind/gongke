import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/services.dart';
import 'dart:io'; // 引入 dart:io 来判断平台
import 'package:flutter/foundation.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfFileName;  //带pdf后缀的文件名
  const PdfViewerPage({super.key, required this.pdfFileName});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfDocument? _document;
  PdfController? _pdfController;
  PageController? _pageController;
  ScrollController _thumbnailScrollController = ScrollController();

  int _pages = 0;
  int _currentIndex = 0;
  bool _isDoublePage = true;

  // 全局管理焦点节点
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadPdf();
    _pageController = PageController(initialPage: _currentIndex);
    focusNode.requestFocus();
    // 添加焦点监听
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
      }
    });
  }

  Future<void> _loadPdf() async {
    final doc = await PdfDocument.openAsset(
      'assets/pdfs/${widget.pdfFileName}',
    );
    setState(() {
      _document = doc;
      _pdfController = PdfController(
        document: Future.value(doc),
      ); // Wrap the PdfDocument into a Future
      _pages = doc.pagesCount;
    });
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _pageController?.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Widget _buildDoublePageView() {
    return PageView.builder(
      scrollDirection: Axis.vertical, // 设置滑动方向为垂直方向
      itemCount: (_pages / 2).ceil(),
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final leftPage = index * 2 + 1;
        final rightPage = leftPage + 1;

        return Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox()
              ),
            Expanded(
              flex : 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PdfPageView(
                  pageNumber: leftPage,
                  controller: _pdfController!,
                ),
              ),
            ),
            (rightPage <= _pages) ? 
              Expanded(
                flex : 4,
                child:PdfPageView(
                    pageNumber: rightPage,
                    controller: _pdfController!,
                  ),
              )
              : Expanded(child: SizedBox())
              ,
            Expanded(
              flex: 1,
              child: SizedBox()
              ),
          ],
        );
      },
    );
  }

  Widget _buildSinglePageView() {
    if (_pdfController == null)
      return const Center(child: CircularProgressIndicator());
    return PdfView(
      controller: _pdfController!,
      scrollDirection: Axis.vertical, // 设置滚动方向为垂直方向
    );
  }

  void _handleClickAndJump(int index,int pageNumber) {
    if (_isDoublePage) {
      final doublePageIndex = index ~/ 2;
      //setState(() {
      //  _currentIndex = doublePageIndex;
      //});
      _pageController?.jumpToPage(doublePageIndex); 
    } else {
      _pdfController!.jumpToPage(pageNumber);
    }
  }

  Widget _buildThumbnailList() {
    // 在 Widget 构建完成后，自动定位到当前索引页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_thumbnailScrollController.hasClients) {
        // 计算当前索引对应的滚动位置
        double scrollOffset = _currentIndex * 108.0; // 假设每个缩略图高度为 100，上下边距各 4
        _thumbnailScrollController.animateTo(
          scrollOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
    if (_document == null) return const SizedBox.shrink();
    return SizedBox(
      width: 50,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _pages,
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          return FutureBuilder<PdfPageImage?>(
            future: _document!
                .getPage(pageNumber)
                .then(
                  (page) => page.render(
                    width: 70,
                    height: 100,
                    format: PdfPageImageFormat.jpeg,
                  ),
                ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // 判断是触摸设备还是PC设备
                return (Platform.isIOS || Platform.isAndroid || kIsWeb)
                    // 如果是触摸设备或Web，使用GestureDetector
                    ? GestureDetector(
                      onTap: () {
                        _handleClickAndJump(index,pageNumber);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.memory(snapshot.data!.bytes),
                      ),
                    )
                    // 如果是PC设备，使用MouseRegion来捕捉鼠标点击
                    : MouseRegion(
                      onEnter: (_) {
                        // 可以根据需要处理鼠标悬停事件
                      },
                      onExit: (_) {
                        // 可以根据需要处理鼠标离开事件
                      },
                      onHover: (_) {
                        // 可以处理鼠标悬浮时的效果
                      },
                      child: GestureDetector(
                        onTap: () {
                          _handleClickAndJump(index, pageNumber);
                        },
                        child: Stack(
                          alignment: Alignment.center ,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.memory(snapshot.data!.bytes),
                            ),
                            Container(
                              color: Colors.white.withOpacity(0.7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$pageNumber',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: 70,
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 1),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  void _togglePageMode() {
    setState(() {
      _isDoublePage = !_isDoublePage;
    });
  }

  // 封装上一页逻辑的函数
  void _handlePreviousPage() {
    if (_isDoublePage) {
      setState(() {
        if (_currentIndex > 0) {
          _currentIndex--;
          _pageController?.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ); // 手动更新 PageView
        }
      });
    } else {
      _pdfController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // 使用 FocusScope 确保焦点正确设置
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _handleNextPage() {
    if (_isDoublePage) {
      setState(() {
        print(
          '当前页码索引: $_currentIndex，总组数: ${(_pages / 2).ceil().toInt()}，可以翻到下一页',
        );
        if (_currentIndex < (_pages / 2).ceil() - 1) {
          _currentIndex++;
          _pageController?.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ); // 手动更新 PageView
        }
      });
    } else {
      _pdfController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // 使用 FocusScope 确保焦点正确设置
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == 0) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(
        // 设置 AppBar 的高度
        toolbarHeight: 30, // 可根据需要调整高度
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 点击返回按钮时返回上一个页面
          },
        ),
      ),
      body: KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          //print('这是一个日志消息');
          //print(event);
          //print('捕获到键盘事件，类型: ${event.runtimeType}');
          if (event is KeyDownEvent) {
            //print('已经进入if判断。。。');
            if (event.logicalKey == LogicalKeyboardKey.pageDown ||
                  event.logicalKey == LogicalKeyboardKey.arrowDown ||
                  event.logicalKey == LogicalKeyboardKey.arrowRight) {
              _handleNextPage();
            } else if (event.logicalKey == LogicalKeyboardKey.pageUp || 
                  event.logicalKey == LogicalKeyboardKey.arrowUp ||
                  event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _handlePreviousPage();
            } else if (event.logicalKey == LogicalKeyboardKey.space ||
                  event.logicalKey == LogicalKeyboardKey.enter) {
              _handleNextPage();
            }
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          }
        },
        child: Row(
          children: [
            Expanded(
              child:
                  _isDoublePage
                      ? _buildDoublePageView()
                      : _buildSinglePageView(),
            ),
            Column(
              children: [
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: '上一页',
                  onPressed: () {
                    _handlePreviousPage();
                    focusNode.requestFocus(); // 处理完事件后重新获取焦点
                  },
                ),
                Spacer(),
                IconButton(
                  icon: Icon(_isDoublePage ? Icons.filter_1 : Icons.filter_2),
                  tooltip: _isDoublePage ? '切换为单页显示' : '切换为双页显示',
                  onPressed: _togglePageMode,
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  tooltip: '下一页',
                  onPressed: () {
                    _handleNextPage();
                    focusNode.requestFocus(); // 处理完事件后重新获取焦点
                  },
                ),
                Spacer(),
              ],
            ),
            _buildThumbnailList(),
          ],
        ),
      ),
    );
  }
}

class PdfPageView extends StatelessWidget {
  final int pageNumber;
  final PdfController controller;

  const PdfPageView({
    super.key,
    required this.pageNumber,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PdfPageImage?>(
      // FutureBuilder to render the page
      future: controller.document.then(
        (doc) => doc.getPage(pageNumber).then((page) async {
          final width = await page.width; // Get the actual page width
          final height = await page.height; // Get the actual page height

          // 获取设备像素密度
          final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

          // 根据设备像素密度调整渲染尺寸，乘以一个系数以进一步提高清晰度
          const double clarityFactor = 1.5; // 可根据需要调整此系数
          final double renderWidth = (width * devicePixelRatio * clarityFactor);
          final double renderHeight = (height * devicePixelRatio * clarityFactor);

          // Calculate scale factor to fit the screen while maintaining aspect ratio
          double scaleFactor = MediaQuery.of(context).size.width / (width * clarityFactor);

          // You can adjust the scale factor if needed for better fitting
          if (height * scaleFactor > MediaQuery.of(context).size.height) {
            scaleFactor = MediaQuery.of(context).size.height / (height * clarityFactor);
          }

          // Render the page with the correct scaling
          return page.render(
            width: renderWidth,
            height: renderHeight,
            format: PdfPageImageFormat.jpeg,
          );
        }),
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!.bytes,
            fit: BoxFit.contain, // Ensures the image is contained within bounds
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading page $pageNumber'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
