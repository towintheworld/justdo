import 'package:flutter/material.dart';
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
    Colors.white,
    Colors.grey.shade100,
    Colors.blue.shade50,
    Colors.green.shade50,
    Colors.yellow.shade50,
    Colors.pink.shade50,
    Colors.purple.shade50,
    Colors.orange.shade50,
  ];

  final List<Color> _highlightColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('第$section节时间'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startController,
              decoration: const InputDecoration(
                labelText: '开始时间 (HH:MM)',
                border: OutlineInputBorder(),
                hintText: '08:00',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endController,
              decoration: const InputDecoration(
                labelText: '结束时间 (HH:MM)',
                border: OutlineInputBorder(),
                hintText: '08:45',
              ),
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
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _resetTimeTable() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置时间表'),
        content: const Text('确定要将时间表重置为默认方案吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _settings = _settings.copyWith(timeTable: CustomTimeTable());
              });
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课表设置'),
        actions: [TextButton(onPressed: _save, child: const Text('保存'))],
      ),
      body: ListView(
        children: [
          // 显示设置
          _buildSectionTitle('显示设置'),
          SwitchListTile(
            title: const Text('显示周末'),
            subtitle: const Text('显示周六和周日'),
            value: _settings.showWeekend,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(showWeekend: value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('显示时间'),
            subtitle: const Text('在节次旁显示上课时间'),
            value: _settings.showTime,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(showTime: value);
              });
            },
          ),
          ListTile(
            title: const Text('每日节数'),
            subtitle: Text('${_settings.totalSections}节'),
            trailing: Container(
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey4),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _settings.totalSections,
                  items: [8, 10, 12].map((e) {
                    return DropdownMenuItem(value: e, child: Text('$e节'));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _settings = _settings.copyWith(totalSections: value);
                    });
                  },
                ),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('显示教师'),
            subtitle: const Text('在课程卡片上显示教师姓名'),
            value: _settings.showCourseTeacher,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(showCourseTeacher: value);
              });
            },
          ),
          const Divider(),

          // 时间表设置
          _buildSectionTitle('上课时间设置'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('自定义每节上课时间'),
                TextButton(
                  onPressed: _resetTimeTable,
                  child: const Text('重置默认'),
                ),
              ],
            ),
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
            return ListTile(
              title: Text('第$section节'),
              subtitle: Text(
                '${sectionTime.startTime} - ${sectionTime.endTime}',
              ),
              trailing: const Icon(Icons.edit, size: 20),
              onTap: () => _editSectionTime(section),
            );
          }),
          const Divider(),

          // 样式设置
          _buildSectionTitle('样式设置'),
          ListTile(
            title: const Text('卡片圆角'),
            subtitle: Slider(
              value: _settings.cardBorderRadius,
              min: 0,
              max: 16,
              divisions: 16,
              label: '${_settings.cardBorderRadius.toInt()}px',
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(cardBorderRadius: value);
                });
              },
            ),
          ),
          ListTile(
            title: const Text('卡片高度'),
            subtitle: Slider(
              value: _settings.cardHeight,
              min: 40,
              max: 80,
              divisions: 8,
              label: '${_settings.cardHeight.toInt()}px',
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(cardHeight: value);
                });
              },
            ),
          ),
          SwitchListTile(
            title: const Text('卡片阴影'),
            subtitle: const Text('为课程卡片添加阴影效果'),
            value: _settings.enableCardShadow,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(enableCardShadow: value);
              });
            },
          ),
          const Divider(),

          // 字体设置
          _buildSectionTitle('字体设置'),
          ListTile(
            title: const Text('课程名称字号'),
            subtitle: Slider(
              value: _settings.courseNameFontSize,
              min: 10,
              max: 18,
              divisions: 8,
              label: '${_settings.courseNameFontSize.toInt()}',
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(courseNameFontSize: value);
                });
              },
            ),
          ),
          ListTile(
            title: const Text('教室字号'),
            subtitle: Slider(
              value: _settings.classroomFontSize,
              min: 8,
              max: 14,
              divisions: 6,
              label: '${_settings.classroomFontSize.toInt()}',
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(classroomFontSize: value);
                });
              },
            ),
          ),
          const Divider(),

          // 颜色设置
          _buildSectionTitle('颜色设置'),
          ListTile(
            title: const Text('背景颜色'),
            subtitle: const Text('课表背景色'),
            trailing: _buildColorPicker(
              currentColor: _settings.backgroundColor,
              colors: _presetColors,
              onColorSelected: (color) {
                setState(() {
                  _settings = _settings.copyWith(backgroundColor: color);
                });
              },
            ),
          ),
          ListTile(
            title: const Text('今天高亮颜色'),
            subtitle: const Text('当天星期标题的高亮色'),
            trailing: _buildColorPicker(
              currentColor: _settings.todayHighlightColor,
              colors: _highlightColors,
              onColorSelected: (color) {
                setState(() {
                  _settings = _settings.copyWith(todayHighlightColor: color);
                });
              },
            ),
          ),
          const Divider(),

          // 预览
          _buildSectionTitle('预览'),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _settings.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _settings.todayHighlightColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      '周一',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: _settings.cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(
                      _settings.cardBorderRadius,
                    ),
                    boxShadow: _settings.enableCardShadow
                        ? [
                            BoxShadow(
                              color: _settings.cardShadowColor,
                              blurRadius: 4,
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
                            color: Colors.white,
                            fontSize: _settings.courseNameFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_settings.showCourseTeacher)
                          Text(
                            '张老师',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: _settings.classroomFontSize,
                            ),
                          ),
                        Text(
                          '@A101',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: _settings.classroomFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildColorPicker({
    required Color currentColor,
    required List<Color> colors,
    required ValueChanged<Color> onColorSelected,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('选择颜色'),
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: currentColor == color
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: currentColor == color ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: currentColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
