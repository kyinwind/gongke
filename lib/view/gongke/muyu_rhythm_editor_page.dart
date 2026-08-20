import 'package:flutter/material.dart';
import 'package:my_flutter_app_tools/my_flutter_app_tools.dart';

import '../../comm/muyu_rhythm_preview_controller.dart';
import '../../comm/muyu_rhythm_store.dart';
import '../../model/muyu_rhythm_pattern.dart';

enum MuyuRhythmEditorMode { create, builtIn, custom }

class MuyuRhythmEditorPage extends StatefulWidget {
  const MuyuRhythmEditorPage({super.key, required this.mode, this.pattern});

  final MuyuRhythmEditorMode mode;
  final MuyuRhythmPattern? pattern;

  @override
  State<MuyuRhythmEditorPage> createState() => _MuyuRhythmEditorPageState();
}

class _MuyuRhythmEditorPageState extends State<MuyuRhythmEditorPage> {
  final _nameController = TextEditingController();
  final _preview = MuyuRhythmPreviewController();
  late List<MuyuSoundVariant> _sequence;
  bool _saving = false;

  bool get _isBuiltIn => widget.mode == MuyuRhythmEditorMode.builtIn;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.pattern?.displayName ?? '';
    _sequence = [
      ...(widget.pattern?.sequence ??
          MuyuRhythmTemplateCatalog.masterYinguang.sequence),
    ];
  }

  @override
  void dispose() {
    _preview.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final String? error;
    switch (widget.mode) {
      case MuyuRhythmEditorMode.create:
        error = await muyuRhythmStore.createCustom(
          name: _nameController.text,
          sequence: _sequence,
        );
      case MuyuRhythmEditorMode.builtIn:
        error = await muyuRhythmStore.updateBuiltIn(
          id: widget.pattern!.id,
          sequence: _sequence,
        );
      case MuyuRhythmEditorMode.custom:
        error = await muyuRhythmStore.updateCustom(
          id: widget.pattern!.id,
          name: _nameController.text,
          sequence: _sequence,
        );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      AppToast.error(context, error);
      return;
    }
    Navigator.pop(context, true);
  }

  Future<void> _reset() async {
    await muyuRhythmStore.resetBuiltIn(widget.pattern!.id);
    if (mounted) Navigator.pop(context, true);
  }

  void _togglePreview() {
    if (_preview.isPlaying) {
      _preview.stop();
    } else {
      _preview.start(
        pattern: MuyuRhythmPattern(
          id: 'preview',
          displayName: '试听',
          sequence: _sequence,
          source: MuyuRhythmPatternSource.custom,
        ),
        interval: 0.7,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == MuyuRhythmEditorMode.create ? '新建十念法' : '编辑十念法',
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? '保存中…' : '保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            enabled: !_isBuiltIn,
            maxLength: 20,
            decoration: const InputDecoration(
              labelText: '名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('每 10 声一组，分别选择 A / B / C 音色'),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 10,
            itemBuilder: (context, index) => InputDecorator(
              decoration: InputDecoration(
                labelText: '第 ${index + 1} 声',
                border: const OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MuyuSoundVariant>(
                  value: _sequence[index],
                  isExpanded: true,
                  items: MuyuSoundVariant.editableCases
                      .map(
                        (variant) => DropdownMenuItem(
                          value: variant,
                          child: Text(variant.shortName),
                        ),
                      )
                      .toList(),
                  onChanged: (variant) {
                    if (variant == null) return;
                    _preview.stop();
                    setState(() => _sequence[index] = variant);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(_sequence.map((variant) => variant.shortName).join(' ')),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _togglePreview,
            icon: Icon(_preview.isPlaying ? Icons.stop : Icons.play_arrow),
            label: Text(_preview.isPlaying ? '停止试听' : '试听（最多 20 声）'),
          ),
          if (_isBuiltIn) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _reset, child: const Text('恢复默认值')),
          ],
        ],
      ),
    );
  }
}
