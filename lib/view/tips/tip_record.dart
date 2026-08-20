import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gongke/comm/tts_tools.dart';
import 'package:gongke/main.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../database.dart';

class TipRecordPage extends StatefulWidget {
  const TipRecordPage({super.key});

  @override
  State<TipRecordPage> createState() => _TipRecordPageState();
}

class _TipRecordPageState extends State<TipRecordPage> {
  final TtsTools _tts = TtsTools();
  List<TipRecordData> _records = const [];
  int _bookId = 0;
  String _bookName = '开示记录';
  int? _speakingRecordId;
  bool _loadedArguments = false;
  bool _sharing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedArguments) return;
    _loadedArguments = true;
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _bookId = arguments['bookId'] as int? ?? 0;
    }
    _load();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _load() async {
    if (_bookId <= 0) return;
    final book = await (globalDB.select(
      globalDB.tipBook,
    )..where((row) => row.id.equals(_bookId))).getSingleOrNull();
    final records =
        await (globalDB.select(globalDB.tipRecord)
              ..where((row) => row.bookId.equals(_bookId))
              ..orderBy([
                (row) => OrderingTerm.asc(row.sortOrder),
                (row) => OrderingTerm.asc(row.id),
              ]))
            .get();
    if (!mounted) return;
    setState(() {
      _bookName = book?.name ?? '开示记录';
      _records = records;
    });
  }

  Future<void> _toggleFavorite(TipRecordData record) async {
    await (globalDB.update(
      globalDB.tipRecord,
    )..where((row) => row.id.equals(record.id))).write(
      TipRecordCompanion(
        favoriteDateTime: Value(
          record.favoriteDateTime == null ? DateTime.now() : null,
        ),
      ),
    );
    await _load();
  }

  Future<void> _toggleCompleted(TipRecordData record) async {
    await (globalDB.update(
      globalDB.tipRecord,
    )..where((row) => row.id.equals(record.id))).write(
      TipRecordCompanion(
        completedDateTime: Value(
          record.completedDateTime == null ? DateTime.now() : null,
        ),
      ),
    );
    await _load();
  }

  Future<void> _editComment(TipRecordData record) async {
    final controller = TextEditingController(text: record.comments);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('评论'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '输入对这条开示的心得或评论',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    await (globalDB.update(globalDB.tipRecord)
          ..where((row) => row.id.equals(record.id)))
        .write(TipRecordCompanion(comments: Value(value.trim())));
    await _load();
  }

  Future<void> _delete(TipRecordData record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除开示'),
        content: const Text('确定删除这条开示吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await (globalDB.delete(
      globalDB.tipRecord,
    )..where((row) => row.id.equals(record.id))).go();
    await _load();
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final reordered = [..._records];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    setState(() => _records = reordered);
    await globalDB.transaction(() async {
      for (var index = 0; index < reordered.length; index++) {
        await (globalDB.update(globalDB.tipRecord)
              ..where((row) => row.id.equals(reordered[index].id)))
            .write(TipRecordCompanion(sortOrder: Value(index)));
      }
    });
    await _load();
  }

  Future<void> _speak(TipRecordData record) async {
    if (_speakingRecordId == record.id) {
      await _tts.stop();
      if (mounted) setState(() => _speakingRecordId = null);
      return;
    }
    await _tts.stop();
    if (!mounted) return;
    setState(() => _speakingRecordId = record.id);
    await _tts.speak(record.content, () {
      if (mounted) setState(() => _speakingRecordId = null);
    });
  }

  Future<void> _copy(TipRecordData record) async {
    await Clipboard.setData(ClipboardData(text: record.content));
    if (!mounted) return;
    AppToast.success(context, '开示文本已复制');
  }

  Future<void> _shareText(TipRecordData record) async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: '${record.content}\n——《$_bookName》'),
      );
    } catch (_) {
      await _copy(record);
    }
  }

  Future<void> _shareImage(TipRecordData record) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final imageBytes = await ScreenshotController().captureFromWidget(
        Material(
          color: Colors.white,
          child: Container(
            width: 720,
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  record.content,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 30,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  '——《$_bookName》',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.black54, fontSize: 22),
                ),
              ],
            ),
          ),
        ),
        pixelRatio: 2,
      );
      if (Platform.isWindows) {
        await Pasteboard.writeImage(imageBytes);
        if (mounted) {
          AppToast.success(context, '开示图片已复制到剪贴板');
        }
        return;
      }
      final directory = await getTemporaryDirectory();
      final file = File(path.join(directory.path, 'tip-${record.id}.png'));
      await file.writeAsBytes(imageBytes, flush: true);
      try {
        await SharePlus.instance.share(
          ShareParams(
            title: _bookName,
            files: [XFile(file.path, mimeType: 'image/png')],
          ),
        );
      } finally {
        if (await file.exists()) await file.delete();
      }
    } catch (_) {
      await _copy(record);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _edit(TipRecordData record) async {
    await Navigator.pushNamed(
      context,
      '/AddTipRecord',
      arguments: {'acttype': 'mod', 'bookId': _bookId, 'recordId': record.id},
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_bookName),
        actions: [
          IconButton(
            tooltip: '新增开示',
            icon: const Icon(Icons.add_circle, color: Colors.blue, size: 32),
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                '/AddTipRecord',
                arguments: {'acttype': 'new', 'bookId': _bookId},
              );
              await _load();
            },
          ),
        ],
      ),
      body: _records.isEmpty
          ? const Center(child: Text('暂无开示记录'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _records.length,
              onReorder: _reorder,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final record = _records[index];
                return Card(
                  key: ValueKey(record.id),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(record.content),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (record.comments.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('评论：${record.comments}'),
                        ],
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              tooltip: record.favoriteDateTime == null
                                  ? '收藏'
                                  : '取消收藏',
                              onPressed: () => _toggleFavorite(record),
                              icon: Icon(
                                record.favoriteDateTime == null
                                    ? Icons.favorite_border
                                    : Icons.favorite,
                                color: Colors.amber,
                              ),
                            ),
                            IconButton(
                              tooltip: record.completedDateTime == null
                                  ? '标记完成'
                                  : '取消完成',
                              onPressed: () => _toggleCompleted(record),
                              icon: Icon(
                                record.completedDateTime == null
                                    ? Icons.check_circle_outline
                                    : Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                            IconButton(
                              tooltip: '评论',
                              onPressed: () => _editComment(record),
                              icon: const Icon(Icons.comment_outlined),
                            ),
                            IconButton(
                              tooltip: _speakingRecordId == record.id
                                  ? '停止朗读'
                                  : '朗读',
                              onPressed: () => _speak(record),
                              icon: Icon(
                                _speakingRecordId == record.id
                                    ? Icons.stop_circle_outlined
                                    : Icons.volume_up_outlined,
                              ),
                            ),
                            IconButton(
                              tooltip: '复制',
                              onPressed: () => _copy(record),
                              icon: const Icon(Icons.copy_outlined),
                            ),
                            IconButton(
                              tooltip: '分享文本',
                              onPressed: () => _shareText(record),
                              icon: const Icon(Icons.share_outlined),
                            ),
                            IconButton(
                              tooltip: '分享图片',
                              onPressed: _sharing
                                  ? null
                                  : () => _shareImage(record),
                              icon: const Icon(Icons.image_outlined),
                            ),
                            IconButton(
                              tooltip: '编辑',
                              onPressed: () => _edit(record),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: '删除',
                              onPressed: () => _delete(record),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.drag_handle),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
