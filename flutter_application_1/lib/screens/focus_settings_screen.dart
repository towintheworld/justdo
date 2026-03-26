import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../models/todo.dart';
import 'focus_timer_screen.dart';

class FocusSettingsScreen extends StatefulWidget {
  final Todo todo;

  const FocusSettingsScreen({super.key, required this.todo});

  @override
  State<FocusSettingsScreen> createState() => _FocusSettingsScreenState();
}

class _FocusSettingsScreenState extends State<FocusSettingsScreen> {
  late TextEditingController _focusDurationController;
  late TextEditingController _breakDurationController;
  late TextEditingController _longBreakDurationController;
  late TextEditingController _sessionsController;
  bool _autoStartBreaks = true;
  bool _autoStartPomodoros = false;

  @override
  void initState() {
    super.initState();

    // 获取第一个未完成的子任务
    final pendingSubtasks = widget.todo.subtasks
        .where((s) => !s.isCompleted && s.duration != null)
        .toList();

    // 按开始时间排序
    pendingSubtasks.sort((a, b) {
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return a.startTime!.compareTo(b.startTime!);
    });

    // 获取第一个子任务的时长作为专注时长
    int focusDuration = 25;
    int breakDuration = 0;

    if (pendingSubtasks.isNotEmpty) {
      focusDuration = pendingSubtasks.first.duration ?? 25;

      // 计算子任务之间的时间差作为休息时间
      if (pendingSubtasks.length >= 2) {
        final first = pendingSubtasks[0];
        final second = pendingSubtasks[1];

        if (first.startTime != null && second.startTime != null) {
          final firstEnd = first.startTime!.add(
            Duration(minutes: first.duration ?? 0),
          );
          final diff = second.startTime!.difference(firstEnd).inMinutes;
          breakDuration = diff > 0 ? diff : 0;
        }
      }
    }

    _focusDurationController = TextEditingController(
      text: focusDuration.toString(),
    );
    _breakDurationController = TextEditingController(
      text: breakDuration.toString(),
    );
    _longBreakDurationController = TextEditingController(text: '15');
    _sessionsController = TextEditingController(text: '4');
  }

  @override
  void dispose() {
    _focusDurationController.dispose();
    _breakDurationController.dispose();
    _longBreakDurationController.dispose();
    _sessionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('专注设置'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _startFocus,
          child: const Text('开始'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // 当前任务
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: Text(
                    widget.todo.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 显示子任务列表
                ...widget.todo.subtasks.map((subtask) {
                  return CupertinoListTile(
                    leading: Icon(
                      subtask.isCompleted
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.circle,
                      color: subtask.isCompleted
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemGrey,
                      size: 20,
                    ),
                    title: Text(
                      subtask.title,
                      style: TextStyle(
                        fontSize: 15,
                        decoration: subtask.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: subtask.isCompleted
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.label,
                      ),
                    ),
                    additionalInfo: subtask.duration != null
                        ? Text(
                            '${subtask.duration}分钟',
                            style: const TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey,
                            ),
                          )
                        : null,
                  );
                }),
              ],
            ),

            // 专注时长设置
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('专注时长（分钟）', style: TextStyle(fontSize: 14)),
                  trailing: SizedBox(
                    width: 80,
                    child: CupertinoTextField(
                      controller: _focusDurationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      style: const TextStyle(fontSize: 14),
                      decoration: BoxDecoration(
                        color: CupertinoColors.tertiarySystemFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('短休息（分钟）', style: TextStyle(fontSize: 14)),
                  trailing: SizedBox(
                    width: 80,
                    child: CupertinoTextField(
                      controller: _breakDurationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      style: const TextStyle(fontSize: 14),
                      decoration: BoxDecoration(
                        color: CupertinoColors.tertiarySystemFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('长休息（分钟）', style: TextStyle(fontSize: 14)),
                  trailing: SizedBox(
                    width: 80,
                    child: CupertinoTextField(
                      controller: _longBreakDurationController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      style: const TextStyle(fontSize: 14),
                      decoration: BoxDecoration(
                        color: CupertinoColors.tertiarySystemFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('长休息前专注次数', style: TextStyle(fontSize: 14)),
                  trailing: SizedBox(
                    width: 80,
                    child: CupertinoTextField(
                      controller: _sessionsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      style: const TextStyle(fontSize: 14),
                      decoration: BoxDecoration(
                        color: CupertinoColors.tertiarySystemFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 自动开始设置
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('自动开始休息', style: TextStyle(fontSize: 14)),
                  trailing: CupertinoSwitch(
                    value: _autoStartBreaks,
                    onChanged: (value) =>
                        setState(() => _autoStartBreaks = value),
                  ),
                ),
                CupertinoListTile(
                  title: const Text(
                    '自动开始下一个专注',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: CupertinoSwitch(
                    value: _autoStartPomodoros,
                    onChanged: (value) =>
                        setState(() => _autoStartPomodoros = value),
                  ),
                ),
              ],
            ),

            // 开始按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoButton.filled(
                onPressed: _startFocus,
                child: const Text('开始专注'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startFocus() {
    final focusDuration = int.tryParse(_focusDurationController.text) ?? 25;
    final breakDuration = int.tryParse(_breakDurationController.text) ?? 5;
    final longBreakDuration =
        int.tryParse(_longBreakDurationController.text) ?? 15;
    final sessions = int.tryParse(_sessionsController.text) ?? 4;

    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (context) => FocusTimerScreen(
          todo: widget.todo,
          focusDuration: focusDuration,
          breakDuration: breakDuration,
          longBreakDuration: longBreakDuration,
          sessionsBeforeLongBreak: sessions,
          autoStartBreaks: _autoStartBreaks,
          autoStartPomodoros: _autoStartPomodoros,
        ),
      ),
    );
  }
}
