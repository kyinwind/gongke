import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
//import '../../database.dart';
import '../../main.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../comm/date_tools.dart';
import '../../comm/shared_preferences.dart';

enum GongKeType {
  songjing('诵经'),
  nianzhou('念咒'),
  nianshenghao('念圣号'),
  ketou('磕头'),
  baichan('拜忏'),
  dazuo('打坐'),
  others('其他');

  final String label;
  const GongKeType(this.label);
}

class VMFaYuanData {
  String? name; // 发愿名称
  String? fodiziName; // 佛弟子名称
  DateTime? startDate; // 开始日期
  DateTime? endDate; // 结束日期
  List<VMGongKeItemOneDayData> gkiODList = []; // 每日功课列表
  String? yuanwang; // 愿望内容
  String? fayuanwen; // 发愿文

  bool isBaseValid() {
    return name?.isNotEmpty == true && fodiziName?.isNotEmpty == true;
  }

  bool isDateValid() {
    return startDate != null && endDate != null;
  }

  bool isGongKeValid() {
    return gkiODList.isNotEmpty;
  }

  int getDurationDays() {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }
}

class VMGongKeItemOneDayData {
  GongKeType gongketype; // 功课类型
  String name; // 功课名称
  int cnt; // 数量
  int idx; // 序号，表示在每日功课中的位置

  VMGongKeItemOneDayData({
    required this.gongketype,
    required this.name,
    required this.cnt,
    required this.idx,
  });
}

class FaYuanWizardPage extends StatefulWidget {
  const FaYuanWizardPage({super.key});

  @override
  State<FaYuanWizardPage> createState() => _FaYuanWizardPageState();
}

class _FaYuanWizardPageState extends State<FaYuanWizardPage> {
  String? actType; // 'A'表示新增，'M'表示修改
  int? fayuanId;

  int _currentStep = 0;
  final VMFaYuanData _data = VMFaYuanData();
  final _formKey = GlobalKey<FormState>();
  final List<int> _monthOptions = List.generate(12, (i) => i + 1);

  // 修改控制器的初始化方式
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  // 添加状态变量跟踪时长
  int _durationDays = 0;

  @override
  void initState() {
    super.initState();
    // 不需要在这里初始化控制器了
    _data.startDate = DateTime.now();
    _updateDateControllers(); // 初始化时更新控制器的值
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> &&
        args['acttype'] != null &&
        args['fayuanId'] != null) {
      actType = args['acttype'];
      fayuanId = args['fayuanId'];
      _loadExistingData();
    } else {
      actType = 'A';
      fayuanId = null;
      _loadInitialValues();
    }
  }

  @override
  void dispose() {
    // 释放 controller
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  // 在加载数据后更新控制器的值
  Future<void> _loadExistingData() async {
    print('--------------------------------_loadExistingData----');
    final fayuan = await globalDB.managers.faYuan
        .filter((t) => t.id(fayuanId!))
        .getSingle();

    setState(() {
      _data.name = fayuan.name;
      _data.fodiziName = fayuan.fodiziname;
      _data.startDate = fayuan.startDate;
      _data.endDate = fayuan.endDate;
      _data.yuanwang = fayuan.yuanwang;
      _updateDateControllers(); // 加载数据后更新控制器
    });

    final items = await globalDB.managers.gongKeItemsOneDay
        .filter((t) => t.fayuanId(fayuanId!))
        .get();

    setState(() {
      _data.gkiODList = items
          .map(
            (item) => VMGongKeItemOneDayData(
              gongketype: GongKeType.values.firstWhere(
                (t) => t.name == item.gongketype,
              ),
              name: item.name,
              cnt: item.cnt,
              idx: item.idx,
            ),
          )
          .toList();
      print(_data.name);
      print(_data.fodiziName);
      print(_data.startDate);
      print(_data.endDate);
      print(_data.yuanwang);
    });
  }

  Future<void> _loadInitialValues() async {
    _data.name = await getStringValue('fayuanName');
    _data.fodiziName = await getStringValue('fodiziName');
    _data.yuanwang = await getStringValue('yuanwang');
    _data.startDate = DateTools.getDateByString(
      await getDateValue('startDate') ?? DateTime.now().toString(),
      'yyyy-MM-dd',
    );
    _data.endDate = DateTools.getDateByString(
      await getDateValue('endDate') ??
          DateTools.getDateAfterDays(DateTime.now(), 30).toString(),
      'yyyy-MM-dd',
    );
    setState(() {});
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            // 使用 controller 替代 initialValue
            controller: TextEditingController(text: _data.name),
            decoration: const InputDecoration(labelText: '发愿名称'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '请输入发愿名称';
              }
              return null;
            },
            onSaved: (value) {
              _data.name = value;
              saveStringValue('fayuanName', _data.name ?? '');
            },
          ),
          TextFormField(
            // 使用 controller 替代 initialValue
            controller: TextEditingController(text: _data.fodiziName),
            decoration: const InputDecoration(labelText: '佛弟子名称'),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return '请输入佛弟子名称';
              }
              return null;
            },
            onSaved: (value) {
              _data.fodiziName = value;
              saveStringValue('fodiziName', _data.fodiziName ?? '');
            },
          ),
        ],
      ),
    );
  }

  // 修改 _updateDateControllers 方法
  void _updateDateControllers() {
    startDateController.text = _data.startDate != null
        ? DateTools.getDateStringByDate(_data.startDate!)
        : '';
    endDateController.text = _data.endDate != null
        ? DateTools.getDateStringByDate(_data.endDate!)
        : '';
    _durationDays = _data.getDurationDays(); // 更新时长
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                readOnly: true,
                controller: startDateController,
                decoration: const InputDecoration(labelText: '起始日期'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _data.startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _data.startDate = date;
                      _updateDateControllers(); // 更新显示
                    });
                    print(_data.startDate);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: '持续月数'),
                items: _monthOptions.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text('$month个月'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && _data.startDate != null) {
                    setState(() {
                      _data.endDate = DateTime(
                        _data.startDate!.year,
                        _data.startDate!.month + value,
                        _data.startDate!.day - 1,
                      );
                      _updateDateControllers(); // 更新结束日期显示
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          readOnly: true,
          controller: endDateController,
          decoration: const InputDecoration(labelText: '截止日期'),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _data.endDate ?? DateTime.now(),
              firstDate: _data.startDate ?? DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _data.endDate = date;
                _updateDateControllers(); // 更新显示
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Builder(
          builder: (context) {
            _durationDays = _data.getDurationDays();
            return Text('发愿时长：$_durationDays天'); // 直接使用状态变量
          },
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _data.gkiODList.length,
          itemBuilder: (context, index) {
            final item = _data.gkiODList[index];
            return Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      setState(() {
                        _data.gkiODList.removeAt(index);
                      });
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: '删除',
                  ),
                ],
              ),
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('${item.gongketype.label} x ${item.cnt}'),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _showAddGongKeDialog(),
              child: const Text('新增功课'),
            ),
            ElevatedButton(
              onPressed: () {}, // TODO: 实现复制功能
              child: const Text('复制功课'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showAddGongKeDialog() async {
    GongKeType? selectedType;
    String? name;
    int? count;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增功课'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<GongKeType>(
              decoration: const InputDecoration(labelText: '功课类型'),
              items: GongKeType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.label));
              }).toList(),
              onChanged: (value) => selectedType = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '功课名称'),
              onChanged: (value) => name = value,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '数量'),
              keyboardType: TextInputType.number,
              onChanged: (value) => count = int.tryParse(value) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (selectedType != null &&
                  name?.isNotEmpty == true &&
                  count != null &&
                  count! > 0) {
                setState(() {
                  _data.gkiODList.add(
                    VMGongKeItemOneDayData(
                      gongketype: selectedType!,
                      name: name!,
                      cnt: count!,
                      idx: _data.gkiODList.length + 1, // 序号从1开始
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return TextFormField(
      // 使用 controller 替代 initialValue
      controller: TextEditingController(text: _data.yuanwang),
      decoration: const InputDecoration(
        labelText: '发愿',
        hintText: '请输入您的愿望...',
      ),
      maxLines: 5,
      onChanged: (value) => _data.yuanwang = value,
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('发愿名称：${_data.name}'),
        Text('佛弟子名称：${_data.fodiziName}'),
        Text('起始日期：${_data.startDate?.toString().split(' ')[0]}'),
        Text('截止日期：${_data.endDate?.toString().split(' ')[0]}'),
        Text('发愿时长：${_data.getDurationDays()}天'),
        const Divider(),
        const Text('每日功课：'),
        ..._data.gkiODList.map(
          (item) =>
              Text('${item.gongketype.label} - ${item.name} x ${item.cnt}'),
        ),
        const Divider(),
        Text('愿望：${_data.yuanwang}'),
      ],
    );
  }

  Future<void> _handleSave() async {
    // 开启事务
    await globalDB.transaction(() async {
      if (actType == 'M' && fayuanId != null) {
        // 删除原有记录
        await globalDB.managers.gongKeItem
            .filter((t) => t.fayuanId(fayuanId!))
            .delete();
        await globalDB.managers.gongKeItemsOneDay
            .filter((t) => t.fayuanId(fayuanId!))
            .delete();
      }

      // 插入或更新发愿记录
      final newFaYuanId = await globalDB.managers.faYuan.create(
        (o) => o(
          name: _data.name!,
          fodiziname: _data.fodiziName!,
          startDate: _data.startDate!,
          endDate: _data.endDate!,
          yuanwang: _data.yuanwang ?? '',
          fayuanwen: _data.fayuanwen ?? '',
          remarks: Value(''),
        ),
      );

      // 插入每日功课
      for (var item in _data.gkiODList) {
        await globalDB.managers.gongKeItemsOneDay.create(
          (o) => o(
            fayuanId: newFaYuanId,
            gongketype: Value(item.gongketype.name),
            name: item.name,
            cnt: Value(item.cnt),
            idx: Value(_data.gkiODList.indexOf(item) + 1), // 序号从1开始
          ),
        );
      }
      // 插入具体功课记录
      for (var day = 0; day < _data.getDurationDays(); day++) {
        for (var item in _data.gkiODList) {
          await globalDB.managers.gongKeItem.create(
            (o) => o(
              fayuanId: newFaYuanId,
              gongKeDay: DateTools.getDateStringByDate(
                DateTools.getDateAfterDays(
                  _data.startDate ?? DateTime.now(),
                  day,
                ),
              ),
              gongketype: item.gongketype.name,
              name: item.name,
              cnt: Value(item.cnt),
              isComplete: Value(false),
              idx: Value(item.idx), // 每天的功课项序号
            ),
          );
        }
      }
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('发愿${actType == 'A' ? '新增' : '修改'}')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            switch (_currentStep) {
              case 0:
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  setState(() => _currentStep++);
                }
                break;
              case 1:
                if (_data.isDateValid()) {
                  setState(() => _currentStep++);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请选择起止日期和截止日期')));
                }
                break;
              case 2:
                if (_data.isGongKeValid()) {
                  setState(() => _currentStep++);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请至少添加一个功课')));
                }
                break;
              default:
                setState(() => _currentStep++);
            }
          } else {
            _handleSave();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          Step(title: const Text('基本信息'), content: _buildStep1()),
          Step(title: const Text('时间选择'), content: _buildStep2()),
          Step(title: const Text('功课设定'), content: _buildStep3()),
          Step(title: const Text('愿望'), content: _buildStep4()),
          Step(title: const Text('发愿确认'), content: _buildStep5()),
        ],
        controlsBuilder: (context, controls) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              const Spacer(),
              if (_currentStep > 0) ...[
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controls.onStepCancel,
                  child: const Text('上一步'),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: controls.onStepContinue,
                child: Text(_currentStep < 4 ? '下一步' : '保存'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
