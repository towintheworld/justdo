import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/todo.dart';
import '../models/course.dart';
import '../models/event.dart';
import '../widgets/todo_item.dart';
import 'add_todo_screen.dart';
import 'todo_mind_map_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Course> courses;
  final List<Event> events;
  final int currentWeek;
  final Function(Event) onEventComplete;

  const HomeScreen({
    super.key,
    required this.courses,
    required this.events,
    required this.currentWeek,
    required this.onEventComplete,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Todo> _todos = [];

  void _addTodo() async {
    final result = await Navigator.push<Todo>(
      context,
      MaterialPageRoute(builder: (context) => const AddTodoScreen()),
    );

    if (result != null) {
      setState(() {
        _todos.add(result);
      });
    }
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].toggleComplete();
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _navigateToMindMap(Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoMindMapScreen(
          todo: todo,
          onToggle: (t) {
            setState(() {
              t.toggleComplete();
            });
          },
          onAddSubtask: (parent, subtask) {
            setState(() {
              parent.addSubtask(subtask);
            });
          },
          onDeleteSubtask: (parent, subtask) {
            setState(() {
              parent.removeSubtask(subtask.id);
            });
          },
          onToggleSubtask: (parent, subtask) {
            setState(() {
              subtask.toggleComplete();
            });
          },
        ),
      ),
    );
  }

  int get _completedCount => _todos.where((todo) => todo.isCompleted).length;

  // 获取逾期的待办任务
  List<Todo> _getOverdueTodos() {
    final now = DateTime.now();
    return _todos.where((todo) {
      if (todo.isCompleted || todo.endTime == null) return false;
      return todo.endTime!.isBefore(now);
    }).toList()..sort((a, b) => a.endTime!.compareTo(b.endTime!));
  }

  // 获取即将到期的待办任务（60分钟内）
  List<Todo> _getUpcomingTodos() {
    final now = DateTime.now();
    return _todos.where((todo) {
      if (todo.isCompleted || todo.endTime == null) return false;
      final difference = todo.endTime!.difference(now);
      return difference.inMinutes <= 60 && difference.inMinutes > 0;
    }).toList()..sort((a, b) => a.endTime!.compareTo(b.endTime!));
  }

  // 获取今天的课程
  List<Course> _getTodayCourses() {
    final today = DateTime.now().weekday;
    return widget.courses.where((course) {
      return course.dayOfWeek == today &&
          course.shouldShowInWeek(widget.currentWeek);
    }).toList()..sort((a, b) => a.startSection.compareTo(b.startSection));
  }

  // 获取今天的日历计划
  List<Event> _getTodayEvents() {
    return widget.events.where((event) {
      return event.isToday && !event.isCompleted;
    }).toList()..sort((a, b) {
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  // 获取最近7天的日历计划
  List<Event> _getUpcomingEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekLater = today.add(const Duration(days: 7));

    return widget.events
        .where((event) {
          final eventDate = DateTime(
            event.date.year,
            event.date.month,
            event.date.day,
          );
          return eventDate.isAtSameMomentAs(today) ||
              (eventDate.isAfter(today) && eventDate.isBefore(weekLater));
        })
        .where((event) => !event.isCompleted)
        .toList()
      ..sort((a, b) {
        final dateComparison = a.date.compareTo(b.date);
        if (dateComparison != 0) return dateComparison;
        final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
        final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }

  @override
  Widget build(BuildContext context) {
    final todayCourses = _getTodayCourses();
    final todayEvents = _getTodayEvents();
    final upcomingEvents = _getUpcomingEvents();
    final overdueTodos = _getOverdueTodos();
    final upcomingTodos = _getUpcomingTodos();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('待办事项'),
        trailing: GestureDetector(
          onTap: _addTodo,
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 逾期待办
            if (overdueTodos.isNotEmpty) ...[
              _buildSectionHeader(
                '逾期待办',
                CupertinoIcons.exclamationmark_triangle,
                Colors.red,
              ),
              const SizedBox(height: 8),
              ...overdueTodos.map(
                (todo) => TodoItem(
                  todo: todo,
                  onToggle: () {
                    setState(() {
                      todo.toggleComplete();
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _todos.remove(todo);
                    });
                  },
                  onSettings: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('提示'),
                        content: const Text('设置功能待实现'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('确定'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                  onTap: () => _navigateToMindMap(todo),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 即将到期待办（60分钟内）
            if (upcomingTodos.isNotEmpty) ...[
              _buildSectionHeader('即将到期', CupertinoIcons.timer, Colors.orange),
              const SizedBox(height: 8),
              ...upcomingTodos.map(
                (todo) => TodoItem(
                  todo: todo,
                  onToggle: () {
                    setState(() {
                      todo.toggleComplete();
                    });
                  },
                  onDelete: () {
                    setState(() {
                      _todos.remove(todo);
                    });
                  },
                  onSettings: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('提示'),
                        content: const Text('设置功能待实现'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('确定'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                  onTap: () => _navigateToMindMap(todo),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 今日课程卡片
            if (todayCourses.isNotEmpty) ...[
              _buildSectionHeader('今日课程', CupertinoIcons.book, Colors.blue),
              const SizedBox(height: 8),
              ...todayCourses.map((course) => _buildCourseCard(course)),
              const SizedBox(height: 16),
            ],

            // 今日计划卡片
            if (todayEvents.isNotEmpty) ...[
              _buildSectionHeader(
                '今日计划',
                CupertinoIcons.calendar,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              ...todayEvents.map((event) => _buildEventCard(event)),
              const SizedBox(height: 16),
            ],

            // 近期计划卡片
            if (upcomingEvents.where((e) => !e.isToday).isNotEmpty) ...[
              _buildSectionHeader('近期计划', CupertinoIcons.clock, Colors.green),
              const SizedBox(height: 8),
              ...upcomingEvents
                  .where((e) => !e.isToday)
                  .take(5)
                  .map((event) => _buildEventCard(event)),
              const SizedBox(height: 16),
            ],

            // 待办事项
            _buildSectionHeader(
              '待办事项',
              CupertinoIcons.check_mark_circled,
              Colors.purple,
            ),
            const SizedBox(height: 8),
            if (_todos.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '已完成 $_completedCount / ${_todos.length}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (_todos.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '暂无待办事项',
                    style: TextStyle(color: CupertinoColors.systemGrey),
                  ),
                ),
              )
            else
              ..._todos.asMap().entries.map((entry) {
                return TodoItem(
                  todo: entry.value,
                  onToggle: () => _toggleTodo(entry.key),
                  onDelete: () => _deleteTodo(entry.key),
                  onSettings: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('提示'),
                        content: const Text('设置功能待实现'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('确定'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                  onTap: () => _navigateToMindMap(entry.value),
                );
              }),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: course.color, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.sectionRange,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (course.classroom.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.classroom,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    if (course.teacher.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.teacher,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: course.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  course.dayName,
                  style: TextStyle(
                    color: course.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onEventComplete(event),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: event.color, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: event.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: event.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.timeRangeString,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (!event.isToday)
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event.date.month}月${event.date.day}日 ${event.weekDayName}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      if (event.location.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(
                  event.isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: event.isCompleted ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
