import 'package:flutter/cupertino.dart';
import '../models/course.dart';

class AddCourseScreen extends StatefulWidget {
  final int totalSections;
  final List<Course> existingCourses;

  const AddCourseScreen({
    super.key,
    this.totalSections = 10,
    this.existingCourses = const [],
  });

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _nameController = TextEditingController();
  final _classroomController = TextEditingController();
  final _teacherController = TextEditingController();

  int _selectedDay = 1;
  int _startSection = 1;
  int _endSection = 2;
  int _startWeek = 1;
  int _endWeek = 16;
  Color _selectedColor = const Color(0xFF2196F3);
  WeekType _weekType = WeekType.every;

  final List<Color> _colors = [
    const Color(0xFF2196F3),
    const Color(0xFFF44336),
    const Color(0xFF4CAF50),
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
    const Color(0xFF009688),
    const Color(0xFFE91E63),
    const Color(0xFF3F51B5),
  ];

  final List<String> _dayNames = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void dispose() {
    _nameController.dispose();
    _classroomController.dispose();
    _teacherController.dispose();
    super.dispose();
  }

  bool _sectionsOverlap(int start1, int end1, int start2, int end2) {
    return !(end1 < start2 || end2 < start1);
  }

  bool _weeksOverlap(Course a, Course b) {
    if (a.dayOfWeek != b.dayOfWeek) return false;
    if (a.endWeek < b.startWeek || b.endWeek < a.startWeek) return false;
    final start = a.startWeek > b.startWeek ? a.startWeek : b.startWeek;
    final end = a.endWeek < b.endWeek ? a.endWeek : b.endWeek;
    for (int week = start; week <= end; week++) {
      if (a.shouldShowInWeek(week) && b.shouldShowInWeek(week)) {
        return true;
      }
    }
    return false;
  }

  bool _hasConflict(Course newCourse) {
    for (final existing in widget.existingCourses) {
      if (_weeksOverlap(newCourse, existing) &&
          _sectionsOverlap(
            newCourse.startSection,
            newCourse.endSection,
            existing.startSection,
            existing.endSection,
          )) {
        return true;
      }
    }
    return false;
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty) {
      _showError('请输入课程名称');
      return;
    }
    if (_endSection < _startSection) {
      _showError('结束节次不能小于开始节次');
      return;
    }
    if (_endWeek < _startWeek) {
      _showError('结束周次不能小于开始周次');
      return;
    }

    final course = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      classroom: _classroomController.text.trim(),
      teacher: _teacherController.text.trim(),
      dayOfWeek: _selectedDay,
      startSection: _startSection,
      endSection: _endSection,
      color: _selectedColor,
      startWeek: _startWeek,
      endWeek: _endWeek,
      weekType: _weekType,
    );

    if (_hasConflict(course)) {
      _showError('该课程时间与已有课程冲突，请调整时间');
      return;
    }

    Navigator.pop(context, course);
  }

  void _showDayPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
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
                  initialItem: _selectedDay - 1,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedDay = index + 1;
                  });
                },
                children: List.generate(7, (index) {
                  return Center(child: Text(_dayNames[index + 1]));
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSectionPicker(bool isStart) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
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
                  initialItem: (isStart ? _startSection : _endSection) - 1,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    if (isStart) {
                      _startSection = index + 1;
                    } else {
                      _endSection = index + 1;
                    }
                  });
                },
                children: List.generate(widget.totalSections, (index) {
                  return Center(child: Text('第${index + 1}节'));
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeekTypePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
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
                  initialItem: _weekType.index,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _weekType = WeekType.values[index];
                  });
                },
                children: const [
                  Center(child: Text('每周')),
                  Center(child: Text('单周')),
                  Center(child: Text('双周')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
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
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? CupertinoColors.white
                                : CupertinoColors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: isSelected ? 10 : 4,
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                CupertinoIcons.checkmark,
                                color: CupertinoColors.white,
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

  String _getWeekTypeText(WeekType type) {
    switch (type) {
      case WeekType.every:
        return '每周';
      case WeekType.odd:
        return '单周';
      case WeekType.even:
        return '双周';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('添加课程'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _submit,
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),

            // 基本信息
            CupertinoListSection.insetGrouped(
              header: const Text('基本信息'),
              children: [
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: '课程名称',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.book,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  autofocus: true,
                  decoration: null,
                ),
                CupertinoTextField(
                  controller: _classroomController,
                  placeholder: '教室（选填）',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.location,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: null,
                ),
                CupertinoTextField(
                  controller: _teacherController,
                  placeholder: '教师（选填）',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.person,
                      color: CupertinoColors.systemGrey,
                      size: 20,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: null,
                ),
              ],
            ),

            // 时间设置
            CupertinoListSection.insetGrouped(
              header: const Text('时间设置'),
              children: [
                CupertinoListTile(
                  title: const Text('上课星期'),
                  additionalInfo: Text(_dayNames[_selectedDay]),
                  trailing: const CupertinoListTileChevron(),
                  onTap: _showDayPicker,
                ),
                CupertinoListTile(
                  title: const Text('开始节次'),
                  additionalInfo: Text('第$_startSection节'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _showSectionPicker(true),
                ),
                CupertinoListTile(
                  title: const Text('结束节次'),
                  additionalInfo: Text('第$_endSection节'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _showSectionPicker(false),
                ),
              ],
            ),

            // 周次设置
            CupertinoListSection.insetGrouped(
              header: const Text('周次设置'),
              children: [
                CupertinoListTile(
                  title: const Text('开始周次'),
                  additionalInfo: SizedBox(
                    width: 60,
                    child: CupertinoTextField(
                      controller: TextEditingController(text: '$_startWeek'),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.tertiarySystemFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onChanged: (value) {
                        _startWeek = int.tryParse(value) ?? 1;
                      },
                    ),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('结束周次'),
                  additionalInfo: SizedBox(
                    width: 60,
                    child: CupertinoTextField(
                      controller: TextEditingController(text: '$_endWeek'),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.tertiarySystemFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onChanged: (value) {
                        _endWeek = int.tryParse(value) ?? 16;
                      },
                    ),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('周次类型'),
                  additionalInfo: Text(_getWeekTypeText(_weekType)),
                  trailing: const CupertinoListTileChevron(),
                  onTap: _showWeekTypePicker,
                ),
              ],
            ),

            // 颜色设置
            CupertinoListSection.insetGrouped(
              header: const Text('课程颜色'),
              children: [
                CupertinoListTile(
                  title: const Text('选择颜色'),
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedColor.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  onTap: _showColorPicker,
                ),
              ],
            ),

            // 提交按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoButton.filled(
                onPressed: _submit,
                child: const Text('添加课程'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
