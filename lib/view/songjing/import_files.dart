import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import '../../database.dart';
import 'package:drift/drift.dart' hide Column;
import '../../comm/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../comm/pub_tools.dart';
import '../../comm/tip_import_service.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';

class ImportFilesPage extends StatefulWidget {
  const ImportFilesPage({super.key});
  @override
  _ImportFilesPageState createState() => _ImportFilesPageState();
}

class _ImportFilesPageState extends State<ImportFilesPage> {
  String _jingshuType = '';
  final TextEditingController _directoryController =
      TextEditingController(); // 目录选择器
  List<String> _selectedFiles = []; // 选择的文件列表
  bool _isDirectorySelected = false;
  String _title = '';
  String _content = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadSavedPath() async {
    String? savedPath = await getStringValue('import_path_${_jingshuType}');
    if (savedPath != null && savedPath.isNotEmpty) {
      setState(() {
        _directoryController.text = savedPath;
        _isDirectorySelected = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      _jingshuType = args['jingshutype'];
      switch (_jingshuType) {
        case 'jingshu':
          _title = '导入经书文件';
          _content = '请选择经书PDF文件所在目录';
          break;
        case 'shanshu':
          _title = '导入善书文件';
          _content = '请选择善书PDF文件所在目录';
          break;
        case 'kaishi':
          _title = '导入开示文件';
          _content = '请选择开示 JSON 文件（单次最多 15 个）';
          break;
        default:
      }
      if (_jingshuType != 'kaishi') {
        _loadSavedPath();
      }
    } catch (e) {
      print('------------------didChangeDependencies error:${e}');
    }
  }

  Future<void> _selectDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _directoryController.text = result;
        _isDirectorySelected = true;
      });
      await saveStringValue('import_path_${_jingshuType}', result);
    }
  }

  Future<void> _selectFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: _jingshuType == 'kaishi' ? FileType.custom : FileType.custom,
      allowedExtensions: _jingshuType == 'kaishi' ? ['json'] : ['pdf'],
    );

    if (result != null) {
      final paths = result.paths.whereType<String>().toList();
      if (_jingshuType == 'kaishi' &&
          paths.length > TipImportService.maxFilesPerBatch) {
        if (!mounted) return;
        AppToast.warning(context, '单次最多选择 15 个开示文件');
        return;
      }
      setState(() {
        _selectedFiles = paths;
        _isDirectorySelected = _selectedFiles.isNotEmpty;
      });
    }
  }

  Future<void> _confirmTipImport() async {
    if (_selectedFiles.isEmpty) return;
    final sources = <TipImportSource>[];
    for (final filePath in _selectedFiles) {
      final file = File(filePath);
      sources.add(
        TipImportSource(
          fileName: path.basename(filePath),
          bytes: await file.readAsBytes(),
        ),
      );
    }
    final service = TipImportService(globalDB);
    final previews = await service.preview(sources);
    if (!mounted) return;
    var strategy = TipImportConflictStrategy.skip;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('导入预览'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '文件 ${previews.length} 个，冲突 '
                    '${previews.fold<int>(0, (sum, item) => sum + item.conflictCount)} 项',
                  ),
                  const SizedBox(height: 12),
                  ...previews.map(
                    (item) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        item.error == null ? Icons.description : Icons.error,
                        color: item.error == null ? null : Colors.red,
                      ),
                      title: Text(item.bookName ?? item.fileName),
                      subtitle: Text(
                        item.error ??
                            '${item.recordCount} 条记录，${item.conflictCount} 项冲突',
                      ),
                    ),
                  ),
                  const Divider(),
                  DropdownButtonFormField<TipImportConflictStrategy>(
                    initialValue: strategy,
                    decoration: const InputDecoration(labelText: '冲突处理'),
                    items: const [
                      DropdownMenuItem(
                        value: TipImportConflictStrategy.skip,
                        child: Text('跳过（推荐）'),
                      ),
                      DropdownMenuItem(
                        value: TipImportConflictStrategy.updateExisting,
                        child: Text('更新现有（保留个人状态）'),
                      ),
                      DropdownMenuItem(
                        value: TipImportConflictStrategy.saveAsNew,
                        child: Text('另存为新书'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => strategy = value);
                      }
                    },
                  ),
                  if (strategy == TipImportConflictStrategy.updateExisting)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('内容会更新，本机收藏、完成状态、评论和用户排序会保留。'),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('开始导入'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final result = await service.importBatch(sources, strategy: strategy);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('导入结果'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '成功 ${result.imported}，跳过 ${result.skipped}，失败 ${result.failed}',
                ),
                const SizedBox(height: 8),
                ...result.items.map(
                  (item) => Text('${item.fileName}：${item.message}'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, result.imported > 0);
  }

  Future<void> _confirmImport() async {
    if (_jingshuType == 'kaishi') {
      await _confirmTipImport();
      return;
    }
    late List<JingShuData> list;
    int count = 0;
    late List<FileSystemEntity> files;
    //print('-------------------------进入_confirmImport');
    if (Platform.isWindows) {
      if (_directoryController.text.isEmpty) return;
      final directory = Directory(_directoryController.text);
      if (!await directory.exists()) {
        if (!mounted) return;
        AppToast.error(context, '目录不存在');
        return;
      }
      files = directory.listSync();
      //print('------------------查询${directory}所有文件成功${files.length}');
    }
    if (Platform.isAndroid) {
      if (_selectedFiles.isEmpty) return;
      // print(
      //   '------------------查询${_selectedFiles}所有文件成功${_selectedFiles.length}',
      // );
    }

    try {
      final query = globalDB.managers.jingShu
          .filter((f) => f.type.contains(_jingshuType))
          .orderBy((t) => t.favoriteDateTime.desc() & t.name.asc());
      list = await query.get(); // 获取所有记录
    } catch (e) {
      debugPrint('查询所有记录时出错: $e');
      return;
    }
    //print('------------------查询所有经书成功${list.length}');

    if (Platform.isWindows) {
      for (final file in files) {
        //print('------------------${file.path}');
        if (file is File && path.extension(file.path).toLowerCase() == '.pdf') {
          //print('---------------${file.path}');
          //如果当前导入的文件已经存在，则不导入
          String filename_pdf = file.path.split('\\').last;
          String filename_withoutpdf = filename_pdf.replaceAll('.pdf', '');
          bool exists = list.any((o) => o.name == filename_withoutpdf);
          //print('----------- ${filename_withoutpdf}--${exists}');
          if (exists) {
            continue; // 如果已经存在，则跳过插入
          }
          await createJingShu(file.path, _jingshuType, list);
          count++;
        }
      }
    } else {
      for (final filePath in _selectedFiles) {
        if (path.extension(filePath).toLowerCase() != '.pdf') continue;
        final filename = path.basenameWithoutExtension(filePath);
        bool exists = list.any((o) => o.name == filename);
        if (exists) continue;
        await createJingShu(filePath, _jingshuType, list);
        count++;
      }
    }
    if (!mounted) return;
    AppToast.success(context, '导入完成，共导入$count个文件');
    Navigator.pop(context);
  }

  Future<void> createJingShu(
    String filePath,
    String jingshuType,
    List<JingShuData> list,
  ) async {
    // 实现经书创建逻辑
    debugPrint('创建经书: $filePath, 类型: $jingshuType');
    String filename_pdf = path.basename(filePath);
    String filename_withoutpdf = path.basenameWithoutExtension(filePath);
    //print('filename_pdf:${filename_pdf}');
    //print('filename_withoutpdf:${filename_withoutpdf}');
    bool exists = false;

    exists = list.any((o) => o.name == filename_withoutpdf);
    if (exists) {
      return; // 如果已经存在，则跳过插入
    }
    final imagePath = _jingshuType.contains('shanshu')
        ? 'assets/images/shanshu.png'
        : 'assets/images/jingshu.png';
    //print('filename:${filename_withoutpdf}');
    final item = JingShuCompanion(
      name: Value(filename_withoutpdf),
      image: Value(imagePath),
      fileUrl: Value(filePath),
      fileType: Value('pdf'),
      type: Value('external${jingshuType}'),
      remarks: Value(filename_pdf),
      favoriteDateTime: Value(null),
      createDateTime: Value(DateTime.now()),
    );
    await globalDB.into(globalDB.jingShu).insert(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_title),
              Text(
                '${_content}\n后续如果改变目录位置，则需要重新导入',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.centerLeft, // 添加 Align widget
          child: Column(
            children: [
              Platform.isWindows && _jingshuType != 'kaishi'
                  ? TextField(
                      controller: _directoryController,
                      decoration: InputDecoration(
                        labelText: '目录路径',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.folder_open),
                          onPressed: () {
                            _selectDirectory();
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      readOnly: true,
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('已选择文件数: ${_selectedFiles.length}'),
                        Spacer(),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.file_open),
                          label: const Text('选择文件'),
                          onPressed: _selectFiles,
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              if (_isDirectorySelected || _selectedFiles.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: AppButtonStyle.primaryButton,
                      onPressed: _confirmImport,
                      child: const Text('确定导入'),
                    ),
                    ElevatedButton(
                      style: AppButtonStyle.primaryButton,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('退出'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
