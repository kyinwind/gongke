import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/services.dart';
import 'dart:io'; // 引入 dart:io 来判断平台
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'platform_tools.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'pub_tools.dart';
import 'pdfium_api_tools.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:math';
import 'thumbnail_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pdf_provider.dart';

class PdfViewerPage extends ConsumerStatefulWidget {
  final String pdfFileName; //带pdf后缀的文件名,jingshu的fileUrl字段
  final String pdfType; // 'jingshu' or 'shanshu'

  const PdfViewerPage({
    super.key,
    required this.pdfFileName,
    required this.pdfType,
  });

  @override
  ConsumerState<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends ConsumerState<PdfViewerPage> {
  String _bookName = ''; //经书或善书名称
  PdfDocument? _document;
  PdfController? _pdfController; //这是pdfx的controller
  String? _errorMessage; //报错的信息
  PageController? _pageController; //这是缩略图的controller
  //final ScrollController _thumbnailScrollController = ScrollController();

  int _pages = 0; //文档总页码
  int _currentIndex = 0; //当前读到的双页分组序号
  int _page = 1; //记录单页模式下的页码
  bool _isDoublePage = false; //是否双页模式

  // 全局管理焦点节点
  final FocusNode focusNode = FocusNode();

  //当前页码，即当前阅读到的页码
  late int _curPage = 1; //初始值为1

  final FlutterTts flutterTts = FlutterTts();
  late PdfDocument doc;
  // 添加一个标志来避免重复更新
  bool _isPageChanging = false;

  //添加一个标记，来表明text提取完成。
  bool _isTextDone = false;

  //是否是ipad，是否适合显示双页
  bool _isPad = false;
  //模式显示缩略图
  bool _showThumbnailFlag = true;
  //pdfdoc
  late PDFDoc pdfdoc;
  late WinPDFDoc windoc;
  bool isOnGonging = false; //是否正在播放声音

  // 根据条件得出当前是否显示双页，true需要显示双页
  bool _getIsDoubleFlag() {
    bool result = false; // 默认显示单页

    // 获取当前屏幕方向
    final orientation = MediaQuery.of(context).orientation;
    // 根据屏幕方向设置双页模式标志
    if (Platform.isWindows) {
      // Windows 平台默认显示双页
      result = true;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Android 和 iOS 平台根据屏幕宽度判断
      final screenWidth = MediaQuery.of(context).size.width;
      //print('当前屏幕宽度: $screenWidth');
      if (screenWidth > 600 && orientation == Orientation.landscape) {
        // 如果屏幕宽度大于600，显示双页
        result = true;
      } else {
        // 否则显示单页
        result = false;
      }
    } else {
      // 其他平台默认显示单页
      result = false;
    }
    return result;
  }

  final ValueNotifier<Object?> _taskDataListenable = ValueNotifier(null);
  void _onReceiveTaskData(Object data) {
    //print('--------------------------接收到数据: $data');
    _taskDataListenable.value = data;
    if (data is Map && data['buttonPressed'] == 'btn_stop') {
      flutterTts.stop(); // 页面中你的 TTS 停止方法
      setState(() {
        isOnGonging = false;
      });
    } else if (data is Map && data['buttonPressed'] == 'btn_start') {
      // 开始播放的代码
      _listenText(_page - 1);
      setState(() {
        isOnGonging = true;
      });
    }
  }

  String getBookName() {
    return getJingShuNameByFile(widget.pdfFileName);
  }

  @override
  void initState() {
    super.initState();

    _bookName = getBookName();
    _pageController = PageController(initialPage: _currentIndex);
    isPad().then((value) {
      _isPad = value;
    });
    focusNode.requestFocus();
    // 添加焦点监听
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
      }
    });
    //初始化前台服务
    FlutterForegroundTask.initCommunicationPort();
    // Add a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        requestPermissions();
        initService();

        ref.read(pdfLoadingProvider.notifier).state = true;
        ref.read(pdfControllerProvider.notifier).state = null;

        await _loadPdf();
        print('------------------------------loadpdf加载完成！');

        if (widget.pdfType == 'shanshu' &&
            (Platform.isIOS || Platform.isAndroid || Platform.isWindows)) {
          await _loadPdfText();
          print('------------------------------loadpdftext加载完成！');
        }

        // ✅ 在加载完成后更新 Provider 状态
        ref.read(pdfControllerProvider.notifier).state = _pdfController;
        ref.read(pdfLoadingProvider.notifier).state = false;
        //跳转页面
        _getCurPage();
        _jumpToPage(_curPage);
        _singePageToDoublePage(_curPage);
      } catch (e, st) {
        print('加载 PDF 时出现错误: $e\n$st');
        setState(() {
          _errorMessage = e.toString();
        });
        ref.read(pdfLoadingProvider.notifier).state = false;
      }
    });
    //print('--------------------------initstate 完成');
  }

  Future<void> _loadPdf() async {
    // 为了兼容 Android 14 更为严格的文件权限管理
    try {
      if (Platform.isAndroid) {
        //print(PlatformUtils.isAndroid14Above);
        if (await PlatformUtils.isAndroid14Above) {
          print("执行 Android 14+ 的兼容逻辑");
          doc = await PdfDocument.openAsset('assets/pdfs/${widget.pdfFileName}')
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  print('PDF loading timed out');
                  throw Exception('PDF loading timed out');
                },
              );
        } else {
          //print("执行旧版 Android 的逻辑");
          // 先从 assets 读取
          final byteData = await rootBundle.load(
            'assets/pdfs/${widget.pdfFileName}',
          );
          doc = await PdfDocument.openData(byteData.buffer.asUint8List());
        }
      } else {
        // 非 Android 平台（如 iOS、Web、macOS,windows）
        //print('Opening PDF from assets for non-Android platform');
        doc = await PdfDocument.openAsset('assets/pdfs/${widget.pdfFileName}');
      }
      _getCurPage();
      _pdfController = PdfController(
        document: Future.value(doc),
        initialPage: _curPage,
      );
      print('_pdfController 初始化完成，总页数: ${doc.pagesCount}');
      if (!mounted) return;
      setState(() {
        _document = doc;
        _pages = doc.pagesCount;
      });
    } catch (e, stackTrace) {
      _errorMessage = '加载pdf文件出错！${widget.pdfFileName} \n $e $stackTrace';
      print('加载 PDF 出错: $e $stackTrace');
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
      if (Platform.isWindows) {
        compute(loadPdfAndExtractText, tempFile.path)
            .then((result) {
              // 任务完成后在主线程执行
              if (mounted) {
                setState(() {
                  windoc = result;
                  _isTextDone = true;
                });
              }
            })
            .catchError((error) {
              print('PDF文本处理错误: $error');
            });
        //windoc = await loadPdfAndExtractText(tempFile.path);
      } else {
        pdfdoc = await PDFDoc.fromPath(tempFile.path);
        print('------------------------------------------加载 PDF text ok');
        if (mounted) {
          setState(() {
            _isTextDone = true;
          });
        }
      }
    } catch (e) {
      print('加载 PDF text 出错: $e');
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _pageController?.dispose();
    focusNode.dispose();
    flutterTts.stop();
    // Remove a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    stopService();
    _taskDataListenable.dispose();
    // if (_document != null && !_document!.isClosed) {
    //   _document!.close();
    // }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDoublePage = _getIsDoubleFlag();
    //print('--------------------------didChangeDependencies 完成');
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
              //_pdfController?.jumpToPage(pagenum);
              if (_pdfController != null) {
                final controller = _pdfController!;
                try {
                  print('正在跳转至第$pagenum页,总页数:${controller.pagesCount}');
                  controller.jumpToPage(pagenum);
                } catch (e, stack) {
                  print('页面跳转异常: $e');
                  print('当前页面参数: pagenum=$pagenum');
                  print('控制器状态: isDisposed=${controller.toString()}');
                  print(stack);
                }
              } else {
                // 处理控制器未初始化的情况
                print('PdfController 未初始化，无法跳转到指定页面');
              }
            }
          }
        }
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

  Future<void> _getCurPage() async {
    final shanshu = await globalDB.managers.jingShu
        .filter((f) => f.fileUrl.equals(widget.pdfFileName))
        .getSingle();
    //('get shanshu.curPageNum : ${shanshu.curPageNum}');
    _curPage = shanshu.curPageNum ?? 1;
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
                controller:
                    _pdfController ??
                    PdfController(document: PdfDocument.openData(Uint8List(0))),
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
    //print('------------显示单页-------------------');
    PdfView pdf = PdfView(
      controller: _pdfController!,
      onPageChanged: (page) {
        _page = page;
        _currentIndex = _singePageToDoublePage(page);
      },
      scrollDirection: Axis.vertical,
    );
    return pdf;
  }

  void _handleClickAndJump(int pageNumber) {
    if (_isDoublePage) {
      final doublePageIndex = (pageNumber - 1) ~/ 2;
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
      if (trimmedLine.isEmpty || trimmedLine == '') continue;

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
      int pageCnt = 0;
      String text = '';
      if (Platform.isWindows) {
        pageCnt = windoc.pageCount;
        text = windoc.pages[pagenum].text;
      } else {
        pageCnt = pdfdoc.pages.length;
        text = await pdfdoc.pages[pagenum].text;
      }

      //去掉最后一行页码，去掉换行符
      text = processText(text);
      //print(text);
      if (Platform.isAndroid || Platform.isIOS) {
        startService('正在朗读 ${_bookName}');
      }
      if (pagenum + 2 <= pageCnt) {
        _speak(text, () {
          if (Platform.isAndroid || Platform.isIOS) {
            startService('正在朗读 ${_bookName}');
          }
          _listenText(pagenum + 1);
          //跳往下一页
          _handleNextPage();
        });
      } else {
        _speak(text, () {});
      }
    }
  }

  bool _getShowVoiceButtonFlag() {
    // print('${widget.pdfType}');
    // print('${Platform.isIOS || Platform.isAndroid || Platform.isWindows}');
    // print('${!_isDoublePage}');
    // print('${_isTextDone}');
    // print(
    //   '--------------:${widget.pdfType == 'shanshu' && (Platform.isIOS || Platform.isAndroid || Platform.isWindows) && !_isDoublePage && _isTextDone}',
    // );
    return widget.pdfType == 'shanshu' &&
        (Platform.isIOS || Platform.isAndroid || Platform.isWindows) &&
        !_isDoublePage &&
        _isTextDone;
  }

  Widget _buildNavigatorButton() {
    return Column(
      children: [
        _getShowVoiceButtonFlag()
            ? IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
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
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: const Icon(Icons.arrow_upward, color: Colors.blue),
          tooltip: '上一页',
          onPressed: () {
            _handlePreviousPage();
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          },
        ),
        Spacer(),
        _isPad
            ? IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(
                  _isDoublePage ? Icons.filter_1 : Icons.filter_2,
                  color: Colors.blue,
                ),
                tooltip: _isDoublePage ? '切换为单页显示' : '切换为双页显示',
                onPressed: _togglePageMode,
              )
            : SizedBox(),
        Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: const Icon(Icons.arrow_downward, color: Colors.blue),
          tooltip: '下一页',
          onPressed: () {
            _handleNextPage();
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          },
        ),
        Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Icon(
            Icons.calendar_view_month,
            color: _showThumbnailFlag ? Colors.grey : Colors.blue,
          ),
          tooltip: '隐藏缩略图',
          onPressed: () {
            _showThumbnailFlag = !_showThumbnailFlag;
            setState(() {});
            focusNode.requestFocus(); // 处理完事件后重新获取焦点
          },
        ),
        Spacer(),
      ],
    );
  }

  void _backToParentPage() {
    flutterTts.stop();
    // 检查组件是否还挂载
    //print('--------开始返回 _page:$_page');
    if (mounted) {
      Navigator.pop(context, _page); // 点击返回按钮时返回上一个页面
    }
  }

  Widget _buildBody() {
    final isLoading = ref.watch(pdfLoadingProvider);
    final pdfController = ref.watch(pdfControllerProvider);
    if (isLoading || pdfController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('错误: $_errorMessage'),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        //print('-----------didpop:$didPop,result:$result');
        if (!didPop) {
          _backToParentPage();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 30,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _backToParentPage,
          ),
        ),
        body: KeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
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
              focusNode.requestFocus();
            }
          },
          child: _isDoublePage
              ? Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildDoublePageView(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [Spacer(), _buildNavigatorButton()],
                          ),
                        ],
                      ),
                    ),
                    _showThumbnailFlag
                        ? PdfThumbnailList(
                            document: _document!,
                            currentPage: _page - 1,
                            totalPages: _pages,
                            onPageSelected: (pageIndex) {
                              _handleClickAndJump(pageIndex);
                            },
                            thumbnailWidth: 50,
                          )
                        : SizedBox(),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildSinglePageView(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [Spacer(), _buildNavigatorButton()],
                          ),
                        ],
                      ),
                    ),
                    _showThumbnailFlag
                        ? PdfThumbnailList(
                            document: _document!,
                            currentPage: _page - 1,
                            totalPages: _pages,
                            onPageSelected: (pageIndex) {
                              _handleClickAndJump(pageIndex);
                            },
                            thumbnailWidth: 30,
                            direction: Axis.horizontal,
                          )
                        : SizedBox(),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_pages == 0) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    //print('-----------_document:${_document.toString()}');
    return _buildBody();
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
      future: _renderPage(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(snapshot.data!.bytes, fit: BoxFit.contain);
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

  Future<PdfPageImage?> _renderPage(BuildContext context) async {
    final doc = await controller.document;
    if (pageNumber < 1 || pageNumber > doc.pagesCount) {
      print('无效的 pageNumber: $pageNumber, 页数范围: 1 - ${doc.pagesCount}');
      return null;
    } else {
      print('有效的 doc:${doc.pagesCount}, 尝试获取第 $pageNumber 页');
    }
    try {
      final page = await doc.getPage(pageNumber);
      try {
        final width = page.width;
        final height = page.height;
        if (width == null || height == null) {
          print('PDF page width 或 height 为 null, 无法渲染.');
          return null;
        }
        if (width <= 0 || height <= 0) {
          print('PDF page width 或 height 无效: width=$width, height=$height');
          return null;
        }
        print('---------------有效的page.width:${page.width}.');
        // 获取设备像素密度
        final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        if (devicePixelRatio <= 0) {
          print('设备像素密度无效: devicePixelRatio=$devicePixelRatio');
          return null;
        }
        // 根据设备像素密度调整渲染尺寸，乘以一个系数以进一步提高清晰度
        double clarityFactor = 1;
        if (Platform.isWindows) {
          clarityFactor = 1.5;
        } else {
          // 其他平台的清晰度系数
          clarityFactor = 1.0; // 可以根据需要调整
        }

        final double renderWidth = width * devicePixelRatio * clarityFactor;
        final double renderHeight = height * devicePixelRatio * clarityFactor;

        if (renderWidth <= 0 || renderHeight <= 0) {
          print('渲染尺寸无效: renderWidth=$renderWidth, renderHeight=$renderHeight');
          return null;
        }

        double scaleFactor =
            MediaQuery.of(context).size.width / (width * clarityFactor);
        if (height * scaleFactor > MediaQuery.of(context).size.height) {
          scaleFactor =
              MediaQuery.of(context).size.height / (height * clarityFactor);
        }
        print('---------------开始渲染pdf page $pageNumber.');
        final image = await page.render(
          width: renderWidth,
          height: renderHeight,
          format: PdfPageImageFormat.jpeg,
        );
        if (image == null) {
          print('page.render 返回了 null');
        } else {
          print('page.render正常返回：${image.pageNumber}');
        }
        return image;
      } catch (e, stackTrace) {
        print('渲染页面 $pageNumber 出错: $e');
        print('渲染页面 $pageNumber 出错堆栈: $stackTrace');
        return null;
      } finally {
        await page.close(); // 释放资源，防止白屏/卡死
      }
    } catch (e, stackTrace) {
      print('获取第 $pageNumber 页出错: $e');
      print('获取第 $pageNumber 页出错堆栈: $stackTrace');
      return null;
    }
  }
}

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    // Send data to main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print('onDestroy(isTimeout: $isTimeout)');
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
    FlutterForegroundTask.sendDataToMain({'buttonPressed': id});
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}

//前台服务请求权限
Future<void> requestPermissions() async {
  // Android 13+, you need to allow notification permission to display foreground service notification.
  //
  // iOS: If you need notification, ask for permission.
  if (Platform.isAndroid || Platform.isIOS) {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    } else {
      print('--------------NotificationPermission ok');
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      } else {
        print('--------------isIgnoringBatteryOptimizations ok');
      }

      // Use this utility only if you provide services that require long-term survival,
      // such as exact alarm service, healthcare service, or Bluetooth communication.
      //
      // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // Using this permission may make app distribution difficult due to Google policy.
      // if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      //   // When you call this function, will be gone to the settings page.
      //   // So you need to explain to the user why set it.
      //   await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      // } else {
      //   print('--------------openAlarmsAndRemindersSettings ok');
      // }
    }
  }
}

void initService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'foreground_service',
      channelName: 'Foreground Service Notification',
      channelDescription:
          'This notification appears when the foreground service is running.',
      onlyAlertOnce: true,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

Future<ServiceRequestResult> startService(String msg) async {
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      // You can manually specify the foregroundServiceType for the service
      // to be started, as shown in the comment below.
      // serviceTypes: [
      //   ForegroundServiceTypes.dataSync,
      //   ForegroundServiceTypes.remoteMessaging,
      // ],
      serviceId: 256,
      notificationTitle: '功课助手',
      notificationText: '${msg}',
      notificationIcon: null,
      notificationButtons: [
        const NotificationButton(id: 'btn_stop', text: '停止播放'),
        const NotificationButton(id: 'btn_start', text: '开始播放'),
      ],
      notificationInitialRoute: '/second',
      callback: startCallback,
    );
  }
}

Future<ServiceRequestResult> stopService() {
  return FlutterForegroundTask.stopService();
}

Future<bool> isPad() async {
  if (Platform.isIOS) {
    final iosInfo = await DeviceInfoPlugin().iosInfo;
    return iosInfo.model.toLowerCase().contains('ipad');
  } else if (Platform.isAndroid) {
    //final androidInfo = await DeviceInfoPlugin().androidInfo;
    // 安卓平板通常屏幕密度和尺寸较大
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);
    return diagonal > 10 * 160; // 10 英寸约为 1600 点
  } else if (Platform.isWindows) {
    return true;
  }
  return false;
}

//使用状态，在pdf加载完毕再显示pdf页面
class PdfLoadProvider with ChangeNotifier {
  bool _isPdfLoaded = false;

  bool get isLoaded => _isPdfLoaded;

  void markLoaded() {
    _isPdfLoaded = true;
    notifyListeners();
  }

  void reset() {
    _isPdfLoaded = false;
    notifyListeners();
  }
}
