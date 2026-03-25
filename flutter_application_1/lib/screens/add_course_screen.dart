import 'package:flutter/material.dart';
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
  final _formKey = GlobalKey<FormState>();

  int _selectedDay = 1;
  int _startSection = 1;
  int _endSection = 2;
  int _startWeek = 1;
  int _endWeek = 16;
  Color _selectedColor = Colors.blue;
  WeekType _weekType = WeekType.every;

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
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
    // 如果星期几不同，不冲突
    if (a.dayOfWeek != b.dayOfWeek) {
      return false;
    }
    // 如果周次范围没有交集，不冲突
    if (a.endWeek < b.startWeek || b.endWeek < a.startWeek) {
      return false;
    }
    // 计算交集范围
    final start = a.startWeek > b.startWeek ? a.startWeek : b.startWeek;
    final end = a.endWeek < b.endWeek ? a.endWeek : b.endWeek;
    // 检查在交集范围内，是否存在一周使得两个课程同时显示
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_endSection < _startSection) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('结束节次不能小于开始节次')));
        return;
      }
      if (_endWeek < _startWeek) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('结束周次不能小于开始周次')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('该课程时间与已有课程冲突，请调整时间')));
        return;
      }
      Navigator.pop(context, course);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加课程')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoTextField(
              controller: _nameController,
              placeholder: '课程名称',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(CupertinoIcons.book, size: 20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _classroomController,
              placeholder: '教室',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(CupertinoIcons.location, size: 20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _teacherController,
              placeholder: '教师',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(CupertinoIcons.person, size: 20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<int>(
                  value: _selectedDay,
                  decoration: const InputDecoration(
                    labelText: '星期',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    prefixIcon: Icon(CupertinoIcons.calendar),
                  ),
                  items: List.generate(7, (index) {
                    final day = index + 1;
                    return DropdownMenuItem(
                      value: day,
                      child: Text(_dayNames[day]),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemGrey4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<int>(
                        value: _startSection,
                        decoration: const InputDecoration(
                          labelText: '开始节次',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: List.generate(widget.totalSections, (index) {
                          final section = index + 1;
                          return DropdownMenuItem(
                            value: section,
                            child: Text('第$section节'),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _startSection = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemGrey4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<int>(
                        value: _endSection,
                        decoration: const InputDecoration(
                          labelText: '结束节次',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: List.generate(widget.totalSections, (index) {
                          final section = index + 1;
                          return DropdownMenuItem(
                            value: section,
                            child: Text('第$section节'),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _endSection = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    placeholder: '开始周次',
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    onChanged: (value) {
                      _startWeek = int.tryParse(value) ?? 1;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CupertinoTextField(
                    placeholder: '结束周次',
                    keyboardType: TextInputType.number,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    onChanged: (value) {
                      _endWeek = int.tryParse(value) ?? 16;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.systemGrey4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<WeekType>(
                  value: _weekType,
                  decoration: const InputDecoration(
                    labelText: '周次类型',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    prefixIcon: Icon(CupertinoIcons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(value: WeekType.every, child: Text('每周')),
                    DropdownMenuItem(value: WeekType.odd, child: Text('单周')),
                    DropdownMenuItem(value: WeekType.even, child: Text('双周')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _weekType = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('课程颜色:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('添加课程'),
            ),
          ],
        ),
      ),
    );
  }
}
