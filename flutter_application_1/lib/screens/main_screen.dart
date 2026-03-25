import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../models/schedule_settings.dart';
import '../models/course.dart';
import '../models/event.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  ScheduleSettings _settings = ScheduleSettings();

  // 共享数据
  final List<Course> _courses = [];
  final List<Event> _events = [];

  void _openSettings() async {
    final result = await Navigator.push<ScheduleSettings>(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(settings: _settings),
      ),
    );

    if (result != null) {
      setState(() {
        _settings = result;
      });
    }
  }

  void _addCourse(Course course) {
    setState(() {
      _courses.add(course);
    });
  }

  void _removeCourse(Course course) {
    setState(() {
      _courses.remove(course);
    });
  }

  void _addEvent(Event event) {
    setState(() {
      _events.add(event);
      _sortEvents();
    });
  }

  void _removeEvent(Event event) {
    setState(() {
      _events.remove(event);
    });
  }

  void _toggleEventComplete(Event event) {
    setState(() {
      event.isCompleted = !event.isCompleted;
    });
  }

  void _sortEvents() {
    _events.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;
      final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
      final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.check_mark_circled),
            activeIcon: Icon(CupertinoIcons.check_mark_circled_solid),
            label: '待办',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            activeIcon: Icon(CupertinoIcons.calendar_today),
            label: '课表',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            activeIcon: Icon(CupertinoIcons.clock_solid),
            label: '日历',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_solid),
            label: '我的',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => HomeScreen(
                courses: _courses,
                events: _events,
                currentWeek: 1,
                onEventComplete: _toggleEventComplete,
              ),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => ScheduleScreen(
                settings: _settings,
                onSettingsPressed: _openSettings,
                courses: _courses,
                onAddCourse: _addCourse,
                onRemoveCourse: _removeCourse,
              ),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => CalendarScreen(
                events: _events,
                onAddEvent: _addEvent,
                onRemoveEvent: _removeEvent,
                onToggleComplete: _toggleEventComplete,
              ),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => const ProfileScreen(),
            );
          default:
            return CupertinoTabView(
              builder: (context) => HomeScreen(
                courses: _courses,
                events: _events,
                currentWeek: 1,
                onEventComplete: _toggleEventComplete,
              ),
            );
        }
      },
    );
  }
}
