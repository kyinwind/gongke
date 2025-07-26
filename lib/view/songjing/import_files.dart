import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gongke/main.dart';
import '../../database.dart';
import 'package:drift/drift.dart' hide Column;
import '../../comm/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

class ImportFilesPage extends StatefulWidget {
  const ImportFilesPage({super.key});
  @override
  _ImportFilesPageState createState() => _ImportFilesPageState();
}

class _ImportFilesPageState extends State<ImportFilesPage> {
  String _jingshuType = '';
  final TextEditingController _directoryController = TextEditingController();
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
          _content = '请选择开示文件所在目录';
          break;
        default:
      }
      _loadSavedPath();
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

  Future<void> _confirmImport() async {
    late List<JingShuData> list;
    late List<TipBookData> tipList;
    int count = 0;
    if (_directoryController.text.isEmpty) return;

    final directory = Directory(_directoryController.text);
    if (!await directory.exists()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('目录不存在')));
      return;
    }
    if (_jingshuType != 'kaishi') {
      try {
        final query = globalDB.managers.jingShu
            .filter((f) => f.type.contains(_jingshuType))
            .orderBy((t) => t.favoriteDateTime.desc() & t.name.asc());
        list = await query.get(); // 获取所有记录
      } catch (e) {
        print('查询所有记录时出错: $e');
        // 可以在这里设置一个空的 Stream 或者错误提示的 Stream
      }

      final files = directory.listSync();
      for (final file in files) {
        if (file is File && path.extension(file.path).toLowerCase() == '.pdf') {
          print('---------------${file.path}');
          //如果当前导入的文件已经存在，则不导入
          String filename_pdf = file.path.split('\\').last;
          String filename_withoutpdf = filename_pdf.replaceAll('.pdf', '');
          bool exists = list.any((o) => o.name == filename_withoutpdf);
          print('----------- ${filename_withoutpdf}--${exists}');
          if (exists) {
            continue; // 如果已经存在，则跳过插入
          }
          await createJingShu(file.path, _jingshuType, list);
          count++;
        }
      }
    } else {
      //开示文件
      try {
        final query = globalDB.managers.tipBook.orderBy(
          (t) => t.favoriteDateTime.desc() & t.name.asc(),
        );
        tipList = await query.get(); // 获取所有记录
      } catch (e) {
        print('查询所有记录时出错: $e');
        // 可以在这里设置一个空的 Stream 或者错误提示的 Stream
      }
      final files = directory.listSync();
      for (final file in files) {
        if (file is File &&
            path.extension(file.path).toLowerCase() == '.json') {
          print('---------------${file.path}');
          //如果当前导入的文件已经存在，则不导入
          String filename_json = file.path.split('\\').last;
          String filename_withoutjson = filename_json.replaceAll('.json', '');
          bool exists = tipList.any((o) => o.name == filename_withoutjson);
          print('----------- ${filename_withoutjson}--${exists}');
          if (exists) {
            continue; // 如果已经存在，则跳过插入
          }
          await createTipBook(file.path, filename_withoutjson);
          count++;
        }
      }
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('导入完成，共导入${count}个文件')));
    Navigator.pop(context);
  }

  Future<void> createTipBook(String filePath, String name) async {
    // 实现开示创建逻辑
    debugPrint('创建开示: $filePath, 名称: $name');
    String filename_json = filePath.split('\\').last;
    String filename_withoutjson = filename_json.replaceAll('.json', '');
    print('------------------${filePath}');
    final jsonString = await File(filePath).readAsString();
    final jsonData = json.decode(jsonString);
    // 开启事务
    await globalDB.transaction(() async {
      try {
        // 提取 TipBook 数据
        final quotation = jsonData['quotation'];
        final tipBookCompanion = globalDB.tipBook.insertOne(
          TipBookCompanion.insert(
            name: quotation['name'],
            image: quotation['image'],
            remarks: Value(quotation['remarks']),
            favoriteDateTime: const Value(null),
            createDateTime: Value(DateTime.now()),
          ),
        );

        // 插入 TipBook 记录并获取插入的 id
        // 由于 tipBookCompanion 是 Future<int> 类型，需要使用 await 来获取实际的 id 值
        final bookId = await tipBookCompanion;

        // 提取 TipRecord 数据
        final records = quotation['records'] as List<dynamic>;
        for (final recordData in records) {
          final tipRecordCompanion = TipRecordCompanion.insert(
            bookId: bookId,
            content: recordData['content'],
          );

          // 插入 TipRecord 记录
          await globalDB.tipRecord.insertOne(tipRecordCompanion);
        }
      } catch (e) {
        // 出现错误，回滚事务
        //print('导入数据时出错: $e');
        rethrow;
      }
    });
  }

  Future<void> createJingShu(
    String filePath,
    String jingshuType,
    List<JingShuData> list,
  ) async {
    // 实现经书创建逻辑
    debugPrint('创建经书: $filePath, 类型: $jingshuType');
    String filename_pdf = filePath.split('\\').last;
    String filename_withoutpdf = filename_pdf.replaceAll('.pdf', '');
    print('filename_pdf:${filename_pdf}');
    print('filename_withoutpdf:${filename_withoutpdf}');
    bool exists = false;

    exists = list.any((o) => o.name == filename_withoutpdf);
    if (exists) {
      return; // 如果已经存在，则跳过插入
    }
    String? imagePath = _jingshuType.contains('shanshu')
        ? 'assets/images/shanshu.png'
        : 'assets/images/jingshu.png';

    final item = JingShuCompanion(
      name: Value(filename_withoutpdf),
      image: Value(imagePath!),
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
              TextField(
                controller: _directoryController,
                decoration: InputDecoration(
                  labelText: '目录路径',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _selectDirectory,
                  ),
                  border: const OutlineInputBorder(),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 20),
              if (_isDirectorySelected)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _confirmImport,
                      child: const Text('确定导入'),
                    ),
                    ElevatedButton(
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
