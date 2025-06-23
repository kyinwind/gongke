import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/services.dart';
import 'dart:io'; // 引入 dart:io 来判断平台
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'platform_tools.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfFileName; //带pdf后缀的文件名,jingshu的fileUrl字段
  final String pdfType; // 'jingshu' or 'shanshu'
  const PdfViewerPage({
    super.key,
    required this.pdfFileName,
    required this.pdfType,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfDocument? _document;
  PdfController? _pdfController; //这是pdfx的controller

  PageController? _pageController; //这是缩略图的controller
  final ScrollController _thumbnailScrollController = ScrollController();

  int _pages = 0; //文档总页码
  int _currentIndex = 0; //当前读到的双页分组序号
  int _page = 1; //记录单页模式下的页码
  bool _isDoublePage = false; //是否双页模式

  // 全局管理焦点节点
  final FocusNode focusNode = FocusNode();

  //当前页码，即当前阅读到的页码
  late int curPage = 1; //初始值为1

  final FlutterTts flutterTts = FlutterTts();

  //pdfdoc
  late PDFDoc pdfdoc;
  bool isOnGonging = false; //是否正在播放声音

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    focusNode.requestFocus();
    // 添加焦点监听
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
      }
    });
  }

  void _togglePageMode() {
    if (!_isDoublePage) {
      //单转双
      _currentIndex = _pdfController!.page.toInt() ~/ 2;
    } else {
      //双转单
      _currentIndex = _currentIndex * 2 + 1;
    }
    setState(() {
      _isDoublePage = !_isDoublePage;
      //print('切换到 ${_isDoublePage ? '双页' : '单页'} 模式');
      //print('------ _page:${_page},_currentIndex:${_currentIndex}-------');
      _jumpToPage(_page);
    });
  }

  void _jumpToPage(int pagenum) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 增加额外延迟，确保 PageView 完全构建
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        if (mounted) {
          //print(' ------ _jumpToPage开始跳转页面 $pagenum -------- ');
          if (pagenum != 1 && _pdfController != null) {
            if (_isDoublePage) {
              final doublePageIndex = _singePageToDoublePage(pagenum);
              // print(
              //   '---------开始跳转页面doublePageIndex $doublePageIndex---------------',
              // );
              if (_pageController != null && _pageController!.hasClients) {
                _pageController?.jumpToPage(doublePageIndex);
                setState(() {
                  _currentIndex = doublePageIndex;
                });
              } else {
                print('_pageController 未关联到 PageView，无法跳转');
              }
            } else {
              // 使用可选链式调用避免空值异常
              //print('单页模式，跳转至 $pagenum');
              _pdfController?.jumpToPage(pagenum);
            }
          }
        }
      });
    });
  }

  @override
  // ... 已有代码 ...
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      _isDoublePage = true; // 如果打开 app 时是横屏的，默认显示双页
    }
    _loadPdf().then((_) {
      _loadPdfText();
      _getCurPage().then((_) {
        _jumpToPage(curPage);
      });
    });
  }

  //从单页码转为双页码
  int _singePageToDoublePage(int page) {
    int returnvalue = 0;
    int tempvalue = page;
    if (page % 2 == 0) {
      tempvalue = page - 1;
    }
    returnvalue = ((tempvalue ~/ 2));
    return returnvalue;
  }

  int _doublePageToSinglePage(int page) {
    return page * 2 + 1;
  }

  Future<void> _loadPdf() async {
    // 为了兼容 Android 14 更为严格的文件权限管理
    late PdfDocument doc;
    try {
      if (Platform.isAndroid) {
        print(PlatformUtils.isAndroid14Above);
        if (await PlatformUtils.isAndroid14Above) {
          print("执行 Android 14+ 的兼容逻辑");
          doc = await PdfDocument.openAsset('assets/pdfs/${widget.pdfFileName}')
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception('PDF loading timed out');
                },
              );
        } else {
          print("执行旧版 Android 的逻辑");
          // 先从 assets 读取
          final byteData = await rootBundle.load(
            'assets/pdfs/${widget.pdfFileName}',
          );
          // 写入临时文件
          final tempDir = await getTemporaryDirectory();
          final tempFilePath = '${tempDir.path}/${widget.pdfFileName}';
          final file = File(tempFilePath);
          if (!await file.exists()) {
            final byteData = await rootBundle.load(
              'assets/pdfs/${widget.pdfFileName}',
            );
            await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
          }
          print('PDF file path: $tempDir');
          print('File exists: ${await file.exists()}');
          print('File size: ${await file.length()}');
          // 打开 PDF
          doc = await PdfDocument.openFile(tempFilePath);
        }
      } else {
        // 非 Android 平台（如 iOS、Web、macOS,windows）
        doc = await PdfDocument.openAsset('assets/pdfs/${widget.pdfFileName}');
      }

      if (!mounted) return;
      setState(() {
        _document = doc;
        _pdfController = PdfController(
          document: Future.value(doc),
          initialPage: curPage,
        );
        _pages = doc.pagesCount;
        //print('_pdfController 初始化完成，总页数: $_pages');
      });
    } catch (e) {
      print('加载 PDF 出错: $e');
    }
  }

  Future<void> _loadPdfText() async {
    try {
      // 1. 从 assets 加载 pdf 文件为字节流
      ByteData data = await rootBundle.load(
        'assets/pdfs/${widget.pdfFileName}',
      );
      Uint8List bytes = data.buffer.asUint8List();

      // 2. 把 PDF 文件写入临时文件（因为 flutter_pdf_text 需要文件路径）
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp.pdf');
      await tempFile.writeAsBytes(bytes, flush: true);

      // 3. 加载 PDF 文本
      pdfdoc = await PDFDoc.fromPath(tempFile.path);
      //final text = await doc.text;  // 这是读取整个pdf文本
    } catch (e) {
      print('加载 PDF text 出错: $e');
    }
  }

  Future<void> _getCurPage() async {
    final shanshu = await globalDB.managers.jingShu
        .filter((f) => f.fileUrl.equals(widget.pdfFileName))
        .getSingle();
    //('get shanshu.curPageNum : ${shanshu.curPageNum}');
    curPage = shanshu.curPageNum ?? 1;
  }

  Future<void> _speak(String text, VoidCallback onDone) async {
    await flutterTts.setLanguage("zh-CN");
    await flutterTts.setSpeechRate(0.5);
    isOnGonging = true;
    await flutterTts.speak(text);
    flutterTts.setCompletionHandler(() {
      onDone();
    });
  }

  Future<void> _stop() async {
    isOnGonging = false;
    await flutterTts.stop();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _pageController?.dispose();
    focusNode.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Widget _buildDoublePageView() {
    return PageView.builder(
      scrollDirection: Axis.vertical, // 设置滑动方向为垂直方向
      itemCount: (_pages / 2).ceil(),
      controller: _pageController,
      onPageChanged: (index) {
        //这个index是双页分组的索引,从0开始
        _page = _doublePageToSinglePage(index);
        //_jumpToPage((index * 2 + 1));
        setState(() {
          _currentIndex = index;
        });
        //print('------双页分组index: $index------');
      },
      itemBuilder: (context, index) {
        final leftPage = index * 2 + 1;
        final rightPage = leftPage + 1;

        return Row(
          children: [
            Expanded(flex: 4, child: SizedBox()),
            Expanded(
              flex: 10,
              child: PdfPageView(
                pageNumber: leftPage,
                controller: _pdfController!,
              ),
            ),
            Expanded(flex: 1, child: SizedBox()),
            (rightPage <= _pages)
                ? Expanded(
                    flex: 10,
                    child: PdfPageView(
                      pageNumber: rightPage,
                      controller: _pdfController!,
                    ),
                  )
                : Expanded(child: SizedBox()),
            Expanded(flex: 4, child: SizedBox()),
          ],
        );
      },
    );
  }

  Widget _buildSinglePageView() {
    if (_pdfController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return PdfView(
      controller: _pdfController!,
      onPageChanged: (page) {
        _page = page;
        _currentIndex = _singePageToDoublePage(page);
        // print(
        //   '------单页模式下页面变动page:${_page}，_currentIndex: ${_currentIndex}------',
        // );
      },
      scrollDirection: Axis.vertical, // 设置滚动方向为垂直方向
    );
  }

  void _handleClickAndJump(int index, int pageNumber) {
    if (_isDoublePage) {
      final doublePageIndex = index ~/ 2;
      _pageController?.jumpToPage(doublePageIndex);
    } else {
      _pdfController!.jumpToPage(pageNumber);
    }
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
        if (_currentIndex < (_pages / 2).ceil() - 1) {
          _currentIndex++;
          // print(
          //   '当前页码索引: $_currentIndex，总组数: ${(_pages / 2).ceil().toInt()}，翻到下一页',
          // );
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

  String processText(String input) {
    List<String> lines = input.split('\n');

    List<String> processedLines = [];

    for (var line in lines) {
      String trimmedLine = line.trim();

      // 跳过空行
      if (trimmedLine.isEmpty) continue;

      // 跳过页码行：包含 "of"，前后都是数字（可带 "page"）
      final pageNumRegex = RegExp(
        r'^(page\s*)?(\d+\s*(of|\/)\s*\d+)$',
        caseSensitive: false,
      );

      if (pageNumRegex.hasMatch(trimmedLine)) continue;

      processedLines.add(trimmedLine);
    }

    return processedLines.join();
  }

  void _listenText(int pagenum) async {
    if (!_isDoublePage && pagenum > 0) {
      final pagecount = pdfdoc.pages.length;
      String text = await pdfdoc.pages[pagenum].text;
      print(text);
      //去掉最后一行页码，去掉换行符
      text = processText(text);
      if (pagenum + 2 <= pagecount) {
        _speak(text, () {
          _listenText(pagenum + 1);
        });
      } else {
        _speak(text, () {});
      }
    }
  }

  Widget _buildNavigatorButton() {
    return Column(
      children: [
        widget.pdfType == 'shanshu'
            ? IconButton(
                icon: !isOnGonging
                    ? const Icon(Icons.record_voice_over, color: Colors.blue)
                    : const Icon(Icons.stop_circle, color: Colors.red),
                tooltip: '听书',
                onPressed: () {
                  setState(() {
                    if (!isOnGonging) {
                      isOnGonging = true;
                      _listenText(_page - 1);
                    } else {
                      _stop();
                      isOnGonging = false;
                    }
                  });
                  focusNode.requestFocus(); // 处理完事件后重新获取焦点
                },
              )
            : SizedBox(),
        Spacer(),
        IconButton(
          icon: const Icon(Icons.arrow_upward, color: Colors.blue),
          tooltip: '上一页',
          onPressed: () {
            _handlePreviousPage();
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          },
        ),
        Spacer(),
        IconButton(
          icon: Icon(
            _isDoublePage ? Icons.filter_1 : Icons.filter_2,
            color: Colors.blue,
          ),
          tooltip: _isDoublePage ? '切换为单页显示' : '切换为双页显示',
          onPressed: _togglePageMode,
        ),
        Spacer(),
        IconButton(
          icon: const Icon(Icons.arrow_downward, color: Colors.blue),
          tooltip: '下一页',
          onPressed: () {
            _handleNextPage();
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          },
        ),
        Spacer(),
      ],
    );
  }

  void _backToParentPage() {
    // 检查组件是否还挂载
    if (mounted) {
      Navigator.pop(context, _page); // 点击返回按钮时返回上一个页面
    }
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
            _backToParentPage();
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
        child: MediaQuery.of(context).orientation == Orientation.landscape
            ? Row(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _isDoublePage
                            ? _buildDoublePageView()
                            : _buildSinglePageView(),
                        Row(children: [Spacer(), _buildNavigatorButton()]),
                      ],
                    ),
                  ),
                  _buildThumbnailList(Axis.vertical),
                ],
              )
            : Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _isDoublePage
                        ? _buildDoublePageView()
                        : _buildSinglePageView(),
                    Row(children: [Spacer(), _buildNavigatorButton()]),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildThumbnailList(Axis direction) {
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
        scrollDirection: direction,
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
                          _handleClickAndJump(index, pageNumber);
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
                            alignment: Alignment.center,
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
          final width = page.width; // Get the actual page width
          final height = page.height; // Get the actual page height

          // 获取设备像素密度
          final double devicePixelRatio = MediaQuery.of(
            context,
          ).devicePixelRatio;

          // 根据设备像素密度调整渲染尺寸，乘以一个系数以进一步提高清晰度
          const double clarityFactor = 1.5; // 可根据需要调整此系数
          final double renderWidth = (width * devicePixelRatio * clarityFactor);
          final double renderHeight =
              (height * devicePixelRatio * clarityFactor);

          // Calculate scale factor to fit the screen while maintaining aspect ratio
          double scaleFactor =
              MediaQuery.of(context).size.width / (width * clarityFactor);

          // You can adjust the scale factor if needed for better fitting
          if (height * scaleFactor > MediaQuery.of(context).size.height) {
            scaleFactor =
                MediaQuery.of(context).size.height / (height * clarityFactor);
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
          print('Error loading page $pageNumber: ${snapshot.error}');
          return Center(
            child: Text('Error loading page $pageNumber: ${snapshot.error}'),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
