import 'package:flutter/cupertino.dart';
import '../models/event.dart';
import 'add_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  final List<Event> events;
  final Function(Event) onAddEvent;
  final Function(Event) onRemoveEvent;
  final Function(Event) onToggleComplete;

  const CalendarScreen({
    super.key,
    required this.events,
    required this.onAddEvent,
    required this.onRemoveEvent,
    required this.onToggleComplete,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  final List<String> _weekDayNames = ['一', '二', '三', '四', '五', '六', '日'];

  void _addEvent() async {
    final result = await Navigator.push<Event>(
      context,
      CupertinoPageRoute(
        builder: (context) => AddEventScreen(initialDate: _selectedDate),
      ),
    );

    if (result != null) {
      widget.onAddEvent(result);
    }
  }

  void _deleteEvent(Event event) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除计划'),
        content: Text('确定要删除"${event.title}"吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              widget.onRemoveEvent(event);
              Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  List<Event> _getEventsForDate(DateTime date) {
    return widget.events.where((event) => event.isSameDate(date)).toList();
  }

  List<Event> _getEventsForSelectedDate() {
    return _getEventsForDate(_selectedDate);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _goToToday() {
    setState(() {
      _focusedMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('日历计划'),
        leading: Navigator.canPop(context)
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Icon(CupertinoIcons.back, size: 22),
              )
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _goToToday,
                child: const Text('今天'),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Navigator.canPop(context))
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _goToToday,
                child: const Text('今天'),
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _addEvent,
              child: const Icon(CupertinoIcons.add, size: 26),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          color: CupertinoColors.systemGroupedBackground,
          child: Column(
            children: [
              // 月份导航
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
                      onPressed: _previousMonth,
                      child: const Icon(CupertinoIcons.chevron_left, size: 20),
                    ),
                    const SizedBox(width: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_focusedMonth.year}年${_focusedMonth.month}月',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemBlue,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _nextMonth,
                      child: const Icon(CupertinoIcons.chevron_right, size: 20),
                    ),
                  ],
                ),
              ),
              // 星期标题
              Container(
                color: CupertinoColors.systemBackground,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: _weekDayNames.map((name) {
                    final isWeekend = name == '六' || name == '日';
                    return Expanded(
                      child: Center(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isWeekend
                                ? CupertinoColors.systemRed
                                : CupertinoColors.secondaryLabel,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // 日历网格
              Container(
                color: CupertinoColors.systemBackground,
                child: _buildCalendarGrid(),
              ),
              // 当日计划列表
              Expanded(child: _buildEventList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    final List<Widget> dayWidgets = [];

    // 填充月初空白
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }

    // 填充日期
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isToday =
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;
      final isSelected =
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final eventsOnDay = _getEventsForDate(date);
      final isWeekend = date.weekday == 6 || date.weekday == 7;

      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            onDoubleTap: () {
              setState(() {
                _selectedDate = date;
              });
              _addEvent();
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? CupertinoColors.systemBlue
                    : isToday
                    ? CupertinoColors.systemBlue.withOpacity(0.1)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected
                          ? CupertinoColors.white
                          : isWeekend
                          ? CupertinoColors.systemRed
                          : CupertinoColors.label,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (eventsOnDay.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CupertinoColors.white
                            : CupertinoColors.systemOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 组织成行
    final List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final rowChildren = dayWidgets.sublist(
        i,
        i + 7 > dayWidgets.length ? dayWidgets.length : i + 7,
      );
      while (rowChildren.length < 7) {
        rowChildren.add(const Expanded(child: SizedBox()));
      }
      rows.add(SizedBox(height: 48, child: Row(children: rowChildren)));
    }

    return Column(children: rows);
  }

  Widget _buildEventList() {
    final events = _getEventsForSelectedDate();

    if (events.isEmpty) {
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
            Text(
              '${_selectedDate.month}月${_selectedDate.day}日 暂无计划',
              style: const TextStyle(
                fontSize: 17,
                color: CupertinoColors.secondaryLabel,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击右上角 + 添加计划',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () => widget.onToggleComplete(event),
      onLongPress: () => _deleteEvent(event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左侧颜色条
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: event.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // 时间
                    SizedBox(
                      width: 55,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          Text(
                            '${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 分隔线
                    Container(
                      width: 1,
                      height: 40,
                      color: CupertinoColors.separator,
                    ),
                    const SizedBox(width: 12),
                    // 内容
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              decoration: event.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: event.isCompleted
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.label,
                              decorationColor: CupertinoColors.systemGrey,
                            ),
                          ),
                          if (event.location.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.location,
                                    size: 12,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      event.location,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.systemGrey,
                                        decoration: TextDecoration.none,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (event.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                event.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                  decoration: TextDecoration.none,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 完成状态
                    Icon(
                      event.isCompleted
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.circle,
                      color: event.isCompleted
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemGrey3,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
