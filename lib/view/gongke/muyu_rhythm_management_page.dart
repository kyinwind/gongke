import 'package:flutter/material.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';

import '../../comm/muyu_rhythm_store.dart';
import '../../model/muyu_rhythm_pattern.dart';
import 'muyu_rhythm_editor_page.dart';

class MuyuRhythmManagementPage extends StatefulWidget {
  const MuyuRhythmManagementPage({super.key});

  @override
  State<MuyuRhythmManagementPage> createState() =>
      _MuyuRhythmManagementPageState();
}

class _MuyuRhythmManagementPageState extends State<MuyuRhythmManagementPage> {
  Future<void> _open(
    MuyuRhythmEditorMode mode, {
    MuyuRhythmPattern? pattern,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MuyuRhythmEditorPage(mode: mode, pattern: pattern),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _delete(MuyuRhythmPattern pattern) async {
    final candidates = muyuRhythmStore.selectablePatterns
        .where((item) => item.id != pattern.id)
        .toList();
    var replacement = candidates.first.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('删除“${pattern.displayName}”'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '该节奏正被 ${muyuRhythmStore.usageCount(pattern.id)} 项功课使用，请选择替代节奏。',
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: replacement,
                isExpanded: true,
                items: candidates
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => replacement = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('删除并替换'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    final error = await muyuRhythmStore.deleteCustom(
      id: pattern.id,
      replacementID: replacement,
    );
    if (!mounted) return;
    if (error != null) {
      AppToast.error(context, error);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final patterns = muyuRhythmStore.selectablePatterns;
    return Scaffold(
      appBar: AppBar(title: const Text('管理十念法')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(MuyuRhythmEditorMode.create),
        icon: const Icon(Icons.add),
        label: const Text('新建'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
        itemCount: patterns.length,
        itemBuilder: (context, index) {
          final pattern = patterns[index];
          final editable = pattern.source != MuyuRhythmPatternSource.regular;
          return Card(
            child: ListTile(
              title: Text(pattern.displayName),
              subtitle: Text(
                '${pattern.groupedDescription}\n使用 ${muyuRhythmStore.usageCount(pattern.id)} 次'
                '${pattern.isOverridden ? ' · 已调整' : ''}',
              ),
              isThreeLine: true,
              onTap: !editable
                  ? null
                  : () => _open(
                      pattern.source == MuyuRhythmPatternSource.builtIn
                          ? MuyuRhythmEditorMode.builtIn
                          : MuyuRhythmEditorMode.custom,
                      pattern: pattern,
                    ),
              trailing: pattern.source == MuyuRhythmPatternSource.custom
                  ? IconButton(
                      tooltip: '删除',
                      onPressed: () => _delete(pattern),
                      icon: const Icon(Icons.delete_outline),
                    )
                  : editable
                  ? const Icon(Icons.chevron_right)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
