import 'package:flutter/material.dart';
import 'package:gongke/main.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:drift/drift.dart' hide Column;
import '../../comm/pub_tools.dart';
import '../../database.dart';

class AddTipRecordPage extends StatefulWidget {
  const AddTipRecordPage({super.key});

  @override
  State<AddTipRecordPage> createState() => _AddTipRecordPageState();
}

class _AddTipRecordPageState extends State<AddTipRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  late int bookId; // 默认值，实际使用时可能需要从路由参数获取
  late String acttype;
  int? _recordId;
  bool _loadedArguments = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    acttype = 'new'; // 设置默认值
    bookId = 0; // 默认值，实际使用时可能需要从路由参数获取
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedArguments) return;
    _loadedArguments = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args['bookId'] != null) {
      acttype = args['acttype'];
      bookId = args['bookId'];
      _recordId = args['recordId'] as int?;
      if (acttype == 'mod' && _recordId != null) {
        _loadRecord();
      }
    }
  }

  Future<void> _loadRecord() async {
    final record = await (globalDB.select(
      globalDB.tipRecord,
    )..where((row) => row.id.equals(_recordId!))).getSingleOrNull();
    if (!mounted || record == null) return;
    _contentController.text = record.content;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (acttype == 'new') {
        final existing =
            await (globalDB.select(globalDB.tipRecord)
                  ..where((row) => row.bookId.equals(bookId))
                  ..orderBy([(row) => OrderingTerm.desc(row.sortOrder)])
                  ..limit(1))
                .getSingleOrNull();
        await globalDB
            .into(globalDB.tipRecord)
            .insert(
              TipRecordCompanion.insert(
                content: _contentController.text.trim(),
                bookId: bookId,
                jsonId: Value('local-${DateTime.now().microsecondsSinceEpoch}'),
                sortOrder: Value((existing?.sortOrder ?? -1) + 1),
              ),
            );
      } else if (_recordId != null) {
        await (globalDB.update(
          globalDB.tipRecord,
        )..where((row) => row.id.equals(_recordId!))).write(
          TipRecordCompanion(content: Value(_contentController.text.trim())),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(acttype == 'new' ? '新增开示' : '修改开示'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saving ? null : _submitForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '请输入开示内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: null, // null表示无限行数
                minLines: 5, // 最小显示3行
                keyboardType: TextInputType.multiline, // 多行文本键盘类型
                textInputAction: TextInputAction.newline, // 回车键变成换行
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入开示内容';
                  }
                  return null;
                },
              ).padding(bottom: 16),
              ElevatedButton(
                style: AppButtonStyle.primaryButton,
                onPressed: _saving ? null : _submitForm,
                child: Text(_saving ? '保存中…' : '提交'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
