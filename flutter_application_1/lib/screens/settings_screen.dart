import 'package:flutter/cupertino.dart';
import '../models/schedule_settings.dart';
import '../models/time_table.dart';

class SettingsScreen extends StatefulWidget {
  final ScheduleSettings settings;

  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ScheduleSettings _settings;

  final List<Color> _presetColors = [
    const Color(0xFFFFFFFF),
    const Color(0xFFF5F5F5),
    const Color(0xFFE3F2FD),
    const Color(0xFFE8F5E9),
    const Color(0xFFFFFDE7),
    const Color(0xFFFCE4EC),
    const Color(0xFFF3E5F5),
    const Color(0xFFFFF3E0),
  ];

  final List<Color> _highlightColors = [
    const Color(0xFF2196F3),
    const Color(0xFFF44336),
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
    const Color(0xFF009688),
    const Color(0xFFE91E63),
    const Color(0xFF3F51B5),
  ];

  @override
  void initState() {
    super.initState();
    _settings = widget.settings.copyWith();
  }

  void _save() {
    Navigator.pop(context, _settings);
  }

  void _editSectionTime(int section) {
    final sectionTime = _settings.timeTable.sections.firstWhere(
      (s) => s.section == section,
      orElse: () =>
          SectionTime(section: section, startTime: '08:00', endTime: '08:45'),
    );

    final startController = TextEditingController(text: sectionTime.startTime);
    final endController = TextEditingController(text: sectionTime.endTime);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 350,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemGroupedBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  Text(
                    '第$section节时间',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      final newTimeTable = _settings.timeTable.updateSection(
                        section,
                        startController.text,
                        endController.text,
                      );
                      setState(() {
                        _settings = _settings.copyWith(timeTable: newTimeTable);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('完成'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  CupertinoListSection.insetGrouped(
                    children: [
                      CupertinoListTile(
                        title: const Text('开始时间'),
                        trailing: SizedBox(
                          width: 120,
                          child: CupertinoTextField(
                            controller: startController,
                            placeholder: '08:00',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      CupertinoListTile(
                        title: const Text('结束时间'),
                        trailing: SizedBox(
                          width: 120,
                          child: CupertinoTextField(
                            controller: endController,
                            placeholder: '08:45',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '格式: HH:MM（如 08:00）',
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.systemGrey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      startController.dispose();
      endController.dispose();
    });
  }

  void _resetTimeTable() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('重置时间表'),
        content: const Text('确定要将时间表重置为默认方案吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              setState(() {
                _settings = _settings.copyWith(timeTable: CustomTimeTable());
              });
              Navigator.pop(context);
            },
            child: const Text('重置'),
          ),
        ],
      ),
    );
  }

  void _showColorPicker({
    required Color currentColor,
    required List<Color> colors,
    required ValueChanged<Color> onColorSelected,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemGroupedBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '选择颜色',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors[index];
                    final isSelected = currentColor == color;
                    return GestureDetector(
                      onTap: () {
                        onColorSelected(color);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.separator,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                color: CupertinoColors.systemBlue,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('课表设置'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),

            // 显示设置
            CupertinoListSection.insetGrouped(
              header: const Text('显示设置'),
              children: [
                CupertinoListTile(
                  title: const Text('显示周末'),
                  subtitle: const Text('显示周六和周日'),
                  trailing: CupertinoSwitch(
                    value: _settings.showWeekend,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(showWeekend: value);
                      });
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text('显示时间'),
                  subtitle: const Text('在节次旁显示上课时间'),
                  trailing: CupertinoSwitch(
                    value: _settings.showTime,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(showTime: value);
                      });
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text('每日节数'),
                  additionalInfo: Text('${_settings.totalSections}节'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => Container(
                        height: 200,
                        color: CupertinoColors.systemBackground,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CupertinoButton(
                                  child: const Text('取消'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoButton(
                                  child: const Text('确定'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                itemExtent: 40,
                                scrollController: FixedExtentScrollController(
                                  initialItem: [
                                    8,
                                    10,
                                    12,
                                  ].indexOf(_settings.totalSections),
                                ),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _settings = _settings.copyWith(
                                      totalSections: [8, 10, 12][index],
                                    );
                                  });
                                },
                                children: const [
                                  Center(child: Text('8节')),
                                  Center(child: Text('10节')),
                                  Center(child: Text('12节')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                CupertinoListTile(
                  title: const Text('显示教师'),
                  subtitle: const Text('在课程卡片上显示教师姓名'),
                  trailing: CupertinoSwitch(
                    value: _settings.showCourseTeacher,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(
                          showCourseTeacher: value,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),

            // 时间表设置
            CupertinoListSection.insetGrouped(
              header: const Text('上课时间设置'),
              footer: const Text('点击可编辑每节课程的时间'),
              children: [
                CupertinoListTile(
                  title: const Text('重置为默认'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: _resetTimeTable,
                ),
                ...List.generate(_settings.totalSections, (index) {
                  final section = index + 1;
                  final sectionTime = _settings.timeTable.sections.firstWhere(
                    (s) => s.section == section,
                    orElse: () => SectionTime(
                      section: section,
                      startTime: '08:00',
                      endTime: '08:45',
                    ),
                  );
                  return CupertinoListTile(
                    title: Text('第$section节'),
                    additionalInfo: Text(
                      '${sectionTime.startTime} - ${sectionTime.endTime}',
                    ),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => _editSectionTime(section),
                  );
                }),
              ],
            ),

            // 颜色设置
            CupertinoListSection.insetGrouped(
              header: const Text('颜色设置'),
              children: [
                CupertinoListTile(
                  title: const Text('背景颜色'),
                  subtitle: const Text('课表背景色'),
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _settings.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CupertinoColors.separator),
                    ),
                  ),
                  onTap: () {
                    _showColorPicker(
                      currentColor: _settings.backgroundColor,
                      colors: _presetColors,
                      onColorSelected: (color) {
                        setState(() {
                          _settings = _settings.copyWith(
                            backgroundColor: color,
                          );
                        });
                      },
                    );
                  },
                ),
                CupertinoListTile(
                  title: const Text('今天高亮颜色'),
                  subtitle: const Text('当天星期标题的高亮色'),
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _settings.todayHighlightColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: CupertinoColors.separator),
                    ),
                  ),
                  onTap: () {
                    _showColorPicker(
                      currentColor: _settings.todayHighlightColor,
                      colors: _highlightColors,
                      onColorSelected: (color) {
                        setState(() {
                          _settings = _settings.copyWith(
                            todayHighlightColor: color,
                          );
                        });
                      },
                    );
                  },
                ),
              ],
            ),

            // 预览
            CupertinoListSection.insetGrouped(
              header: const Text('预览'),
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _settings.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CupertinoColors.separator),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _settings.todayHighlightColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '周一',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: _settings.cardHeight,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(
                            _settings.cardBorderRadius,
                          ),
                          boxShadow: _settings.enableCardShadow
                              ? [
                                  BoxShadow(
                                    color: _settings.cardShadowColor,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '高等数学',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: _settings.courseNameFontSize,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              if (_settings.showCourseTeacher)
                                Text(
                                  '张老师',
                                  style: TextStyle(
                                    color: CupertinoColors.white.withOpacity(
                                      0.8,
                                    ),
                                    fontSize: _settings.classroomFontSize,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              Text(
                                '@A101',
                                style: TextStyle(
                                  color: CupertinoColors.white.withOpacity(0.8),
                                  fontSize: _settings.classroomFontSize,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
