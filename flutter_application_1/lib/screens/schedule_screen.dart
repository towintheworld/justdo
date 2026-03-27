import 'package:flutter/cupertino.dart';
import '../models/course.dart';
import '../models/schedule_settings.dart';
import 'add_course_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final ScheduleSettings settings;
  final VoidCallback? onSettingsPressed;
  final List<Course> courses;
  final Function(Course) onAddCourse;
  final Function(Course) onRemoveCourse;

  const ScheduleScreen({
    super.key,
    required this.settings,
    this.onSettingsPressed,
    required this.courses,
    required this.onAddCourse,
    required this.onRemoveCourse,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentWeek = 1;

  final List<String> _dayNames = ['', '一', '二', '三', '四', '五', '六', '日'];

  void _addCourse() async {
    final result = await Navigator.push<Course>(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            AddCourseScreen(totalSections: widget.settings.totalSections),
      ),
    );

    if (result != null) {
      widget.onAddCourse(result);
    }
  }

  void _deleteCourse(Course course) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除课程'),
        content: Text('确定要删除"${course.name}"吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              widget.onRemoveCourse(course);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showWeekPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
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
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: _currentWeek - 1,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _currentWeek = index + 1;
                  });
                },
                children: List.generate(20, (index) {
                  final week = index + 1;
                  return Center(
                    child: Text(
                      '第$week周${week % 2 == 1 ? '(单周)' : '(双周)'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Course> _getCoursesForDayAndWeek(int day) {
    return widget.courses.where((course) {
      return course.dayOfWeek == day && course.shouldShowInWeek(_currentWeek);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    final displayDays = settings.displayDays;
    final sectionTimes = settings.sectionTimes;
    final now = DateTime.now();
    final today = now.weekday;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('我的课表'),
        leading: Navigator.canPop(context)
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Icon(CupertinoIcons.back, size: 22),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: widget.onSettingsPressed,
                child: const Icon(CupertinoIcons.gear, size: 22),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addCourse,
              child: const Icon(CupertinoIcons.add, size: 26),
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showWeekPicker,
              child: const Icon(CupertinoIcons.calendar, size: 22),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          color: CupertinoColors.systemGroupedBackground,
          child: Column(
            children: [
              // 周次选择器
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: CupertinoColors.systemBackground,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _currentWeek > 1
                          ? () => setState(() => _currentWeek--)
                          : null,
                      child: const Icon(CupertinoIcons.chevron_left, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '第$_currentWeek周${_currentWeek % 2 == 1 ? '(单周)' : '(双周)'}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemBlue,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _currentWeek < 20
                          ? () => setState(() => _currentWeek++)
                          : null,
                      child: const Icon(CupertinoIcons.chevron_right, size: 20),
                    ),
                  ],
                ),
              ),
              // 课表内容
              Expanded(
                child: widget.courses.isEmpty
                    ? _buildEmptyState()
                    : _buildScheduleGrid(
                        settings,
                        displayDays,
                        sectionTimes,
                        today,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              CupertinoIcons.calendar,
              size: 40,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无课程',
            style: TextStyle(
              fontSize: 17,
              color: CupertinoColors.secondaryLabel,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右上角 + 添加课程',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.tertiaryLabel,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleGrid(
    ScheduleSettings settings,
    int displayDays,
    Map<int, String> sectionTimes,
    int today,
  ) {
    return Column(
      children: [
        // 固定的星期标题行 - iOS风格
        Container(
          color: CupertinoColors.systemBackground,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              // 左侧日期显示
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      '${DateTime.now().month}/${DateTime.now().day}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      '第$_currentWeek周',
                      style: const TextStyle(
                        fontSize: 10,
                        color: CupertinoColors.systemGrey,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              // 星期标题
              ...List.generate(displayDays, (dayIndex) {
                final day = dayIndex + 1;
                final isToday = day == today;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isToday
                          ? CupertinoColors.systemBlue
                          : CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _dayNames[day],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isToday
                                ? CupertinoColors.white
                                : CupertinoColors.label,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        // 可滚动的课程内容
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧节次列
                SizedBox(
                  width: 50,
                  child: Column(
                    children: List.generate(settings.totalSections, (index) {
                      final section = index + 1;
                      return Container(
                        height: settings.cardHeight,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: CupertinoColors.separator,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$section',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: settings.sectionNumberFontSize,
                                color: CupertinoColors.label,
                              ),
                            ),
                            if (settings.showTime)
                              Text(
                                sectionTimes[section] ?? '',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                // 右侧课程
                Expanded(
                  child: Row(
                    children: List.generate(displayDays, (dayIndex) {
                      final day = dayIndex + 1;
                      final dayCourses = _getCoursesForDayAndWeek(day);

                      return Expanded(
                        child: SizedBox(
                          height: settings.totalSections * settings.cardHeight,
                          child: Stack(
                            children: [
                              // 背景网格
                              ...List.generate(settings.totalSections, (
                                sectionIndex,
                              ) {
                                return Positioned(
                                  top: sectionIndex * settings.cardHeight,
                                  left: 0,
                                  right: 0,
                                  height: settings.cardHeight,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: CupertinoColors.separator,
                                          width: 0.5,
                                        ),
                                        right: BorderSide(
                                          color: CupertinoColors.separator,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              // 课程卡片
                              ...dayCourses.map((course) {
                                final top =
                                    (course.startSection - 1) *
                                    settings.cardHeight;
                                final height =
                                    (course.endSection -
                                        course.startSection +
                                        1) *
                                    settings.cardHeight;
                                final timeRange = settings.timeTable
                                    .getTimeRange(
                                      course.startSection,
                                      course.endSection,
                                    );

                                return Positioned(
                                  top: top,
                                  left: 3,
                                  right: 3,
                                  height: height - 6,
                                  child: GestureDetector(
                                    onTap: () => _deleteCourse(course),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: course.color.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: course.color.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            course.name,
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              decoration: TextDecoration.none,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (settings.showCourseTeacher &&
                                              course.teacher.isNotEmpty)
                                            Text(
                                              course.teacher,
                                              style: const TextStyle(
                                                color: CupertinoColors.white,
                                                fontSize: 11,
                                                decoration: TextDecoration.none,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          if (course.classroom.isNotEmpty)
                                            Text(
                                              '@${course.classroom}',
                                              style: TextStyle(
                                                color: CupertinoColors.white
                                                    .withOpacity(0.8),
                                                fontSize: 10,
                                                decoration: TextDecoration.none,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          if (settings.showTime && height > 80)
                                            Text(
                                              timeRange,
                                              style: TextStyle(
                                                color: CupertinoColors.white
                                                    .withOpacity(0.7),
                                                fontSize: 9,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
