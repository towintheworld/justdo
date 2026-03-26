import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/todo.dart';

class TodoMindMapScreen extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onToggle;
  final Function(Todo, Todo) onAddSubtask;
  final Function(Todo, Todo) onDeleteSubtask;
  final Function(Todo, Todo) onToggleSubtask;

  const TodoMindMapScreen({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onAddSubtask,
    required this.onDeleteSubtask,
    required this.onToggleSubtask,
  });

  @override
  State<TodoMindMapScreen> createState() => _TodoMindMapScreenState();
}

class _TodoMindMapScreenState extends State<TodoMindMapScreen> {
  bool _showTimeline = false;
  int _breakDuration = 5; // 默认休息时长（分钟）

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.todo.title,
          style: const TextStyle(decoration: TextDecoration.none),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 设置按钮
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showSettingsDialog,
              child: const Icon(CupertinoIcons.gear, size: 22),
            ),
            if (widget.todo.subtasks.isNotEmpty) ...[
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _showTimeline = !_showTimeline;
                  });
                },
                child: Icon(
                  _showTimeline
                      ? CupertinoIcons.list_bullet
                      : CupertinoIcons.clock,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.todo.completedSubtasksCount}/${widget.todo.totalSubtasksCount}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemBlue,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      child: SafeArea(
        child: _showTimeline ? _buildTimelineView() : _buildTaskView(),
      ),
    );
  }

  Widget _buildTaskView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainTaskCard(),
          const SizedBox(height: 24),
          if (widget.todo.subtasks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                '子任务',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.secondaryLabel,
                  letterSpacing: 0.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            _buildSubtaskTree(widget.todo, 0),
          ],
          const SizedBox(height: 16),
          _buildAddSubtaskButton(widget.todo),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    final subtasksWithTime =
        widget.todo.subtasks
            .where((s) => s.startTime != null && s.duration != null)
            .toList()
          ..sort((a, b) => a.startTime!.compareTo(b.startTime!));

    if (subtasksWithTime.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.clock,
              size: 48,
              color: CupertinoColors.systemGrey3,
            ),
            SizedBox(height: 16),
            Text(
              '暂无时间线数据',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.systemGrey,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '请为子任务设置开始时间和时长',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey2,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subtasksWithTime.length * 2, // 每个子任务后可能有休息时间
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildTimelineHeader();
        }

        // 判断是子任务还是休息时间
        final taskIndex = (index - 1) ~/ 2;
        final isBreak = (index - 1) % 2 == 1;

        if (isBreak && taskIndex < subtasksWithTime.length - 1) {
          // 显示休息时间
          final currentSubtask = subtasksWithTime[taskIndex];
          final nextSubtask = subtasksWithTime[taskIndex + 1];
          return _buildBreakItem(currentSubtask, nextSubtask);
        } else {
          // 显示子任务
          final subtask = subtasksWithTime[taskIndex];
          final isLast = taskIndex == subtasksWithTime.length - 1;
          return _buildTimelineItem(subtask, isLast);
        }
      },
    );
  }

  Widget _buildTimelineHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.clock_fill,
            color: CupertinoColors.systemBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            '时间线',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.secondaryLabel,
              letterSpacing: 0.5,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Text(
            '${widget.todo.subtasks.where((s) => s.startTime != null).length} 个任务',
            style: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Todo subtask, bool isLast) {
    final endTime = subtask.startTime!.add(
      Duration(minutes: subtask.duration ?? 0),
    );
    final color = subtask.isCompleted
        ? CupertinoColors.systemGreen
        : CupertinoColors.systemBlue;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${subtask.startTime!.hour.toString().padLeft(2, '0')}:${subtask.startTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  '${subtask.duration}分钟',
                  style: const TextStyle(
                    fontSize: 11,
                    color: CupertinoColors.systemGrey,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: CupertinoColors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: color.withOpacity(0.3)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtask.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: subtask.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: subtask.isCompleted
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.label,
                            decorationColor: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${subtask.startTime!.hour.toString().padLeft(2, '0')}:${subtask.startTime!.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.onToggleSubtask(widget.todo, subtask);
                      });
                    },
                    child: Icon(
                      subtask.isCompleted
                          ? CupertinoIcons.checkmark_circle_fill
                          : CupertinoIcons.circle,
                      color: color,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakItem(Todo currentSubtask, Todo nextSubtask) {
    final breakStart = currentSubtask.startTime!.add(
      Duration(minutes: currentSubtask.duration ?? 0),
    );
    final breakEnd = nextSubtask.startTime;
    final breakMinutes = breakEnd != null
        ? breakEnd.difference(breakStart).inMinutes
        : _breakDuration;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${breakStart.hour.toString().padLeft(2, '0')}:${breakStart.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.systemOrange,
                    decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  '$breakMinutes分钟',
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.systemGrey,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CupertinoColors.systemOrange,
                    width: 2,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: CupertinoColors.systemOrange.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CupertinoColors.systemOrange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.zzz,
                    size: 16,
                    color: CupertinoColors.systemOrange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '休息 $breakMinutes 分钟',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.systemOrange,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTaskCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.onToggle(widget.todo);
                    });
                  },
                  child: _buildIOSCheckbox(widget.todo.isCompleted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.todo.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: widget.todo.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: widget.todo.isCompleted
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.label,
                      decorationColor: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.todo.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.todo.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.secondaryLabel,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
            // 显示时间范围和时长
            if (widget.todo.startTime != null &&
                widget.todo.endTime != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.clock,
                    size: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.todo.startTime!.month.toString().padLeft(2, '0')}-${widget.todo.startTime!.day.toString().padLeft(2, '0')} ${widget.todo.startTime!.hour.toString().padLeft(2, '0')}:${widget.todo.startTime!.minute.toString().padLeft(2, '0')} - ${widget.todo.endTime!.hour.toString().padLeft(2, '0')}:${widget.todo.endTime!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.todo.endTime!.difference(widget.todo.startTime!).inMinutes}分钟',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (widget.todo.subtasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: widget.todo.completionProgress,
                  backgroundColor: CupertinoColors.systemGrey5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.todo.completionProgress >= 1.0
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemBlue,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '进度: ${(widget.todo.completionProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIOSCheckbox(bool isChecked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked ? CupertinoColors.systemGreen : Colors.transparent,
        border: Border.all(
          color: isChecked
              ? CupertinoColors.systemGreen
              : CupertinoColors.systemGrey3,
          width: 2,
        ),
      ),
      child: isChecked
          ? const Icon(
              CupertinoIcons.check_mark,
              color: CupertinoColors.white,
              size: 18,
            )
          : null,
    );
  }

  Widget _buildSubtaskTree(Todo parent, int depth) {
    if (parent.subtasks.isEmpty) return const SizedBox.shrink();

    final color = _getDepthColor(depth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parent.subtasks.asMap().entries.map((entry) {
        final subtask = entry.value;
        final isLast = entry.key == parent.subtasks.length - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
          child: _buildSubtaskItem(subtask, parent, depth, color, isLast),
        );
      }).toList(),
    );
  }

  Widget _buildSubtaskItem(
    Todo subtask,
    Todo parent,
    int depth,
    Color color,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (depth > 0) _buildTreeLines(depth, isLast),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.onToggleSubtask(parent, subtask);
                      });
                    },
                    child: _buildSmallCheckbox(subtask.isCompleted, color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtask.title,
                          style: TextStyle(
                            fontSize: 15 - depth * 0.5,
                            fontWeight: FontWeight.w500,
                            decoration: subtask.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: subtask.isCompleted
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.label,
                            decorationColor: CupertinoColors.systemGrey,
                          ),
                        ),
                        if (subtask.duration != null &&
                            subtask.duration! > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.timer,
                                size: 12,
                                color: CupertinoColors.systemGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${subtask.duration}分钟',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              if (subtask.startTime != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${subtask.startTime!.hour.toString().padLeft(2, '0')}:${subtask.startTime!.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.onDeleteSubtask(parent, subtask);
                      });
                    },
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: CupertinoColors.systemRed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCheckbox(bool isChecked, Color activeColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked ? activeColor : Colors.transparent,
        border: Border.all(
          color: isChecked ? activeColor : CupertinoColors.systemGrey3,
          width: 2,
        ),
      ),
      child: isChecked
          ? const Icon(
              CupertinoIcons.check_mark,
              color: CupertinoColors.white,
              size: 14,
            )
          : null,
    );
  }

  Widget _buildTreeLines(int depth, bool isLast) {
    return SizedBox(
      width: 24.0 * depth,
      child: Row(
        children: List.generate(depth, (index) {
          final isLastLevel = index == depth - 1;
          return SizedBox(
            width: 24,
            child: CustomPaint(
              size: const Size(24, 48),
              painter: TreeLinePainter(
                isLastLevel: isLastLevel,
                isLastItem: isLast && isLastLevel,
                color: _getDepthColor(index),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAddSubtaskButton(Todo parent) {
    // 检查是否还有剩余时间可以添加子任务
    if (parent.startTime != null && parent.endTime != null) {
      final totalMinutes = parent.endTime!
          .difference(parent.startTime!)
          .inMinutes;
      int usedMinutes = 0;
      int subtaskCount = 0;
      for (final subtask in parent.subtasks) {
        if (subtask.duration != null) {
          usedMinutes += subtask.duration!;
          subtaskCount++;
        }
      }
      // 计算休息时间（每个子任务之间都有休息，除了最后一个）
      // 如果要添加新子任务，需要加上休息时间
      if (subtaskCount > 0) {
        usedMinutes += _breakDuration * subtaskCount;
      }
      // 如果已使用时间 >= 总时间，隐藏添加按钮
      if (usedMinutes >= totalMinutes) {
        return const SizedBox.shrink();
      }
    }

    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: () => _showAddSubtaskDialog(parent),
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.add,
              color: CupertinoColors.systemBlue,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '添加子任务',
              style: TextStyle(
                color: CupertinoColors.systemBlue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDepthColor(int depth) {
    final colors = [
      CupertinoColors.systemBlue,
      CupertinoColors.systemPurple,
      CupertinoColors.systemOrange,
      CupertinoColors.systemTeal,
      CupertinoColors.systemPink,
    ];
    return colors[depth % colors.length];
  }

  void _showSettingsDialog() {
    final breakController = TextEditingController(
      text: _breakDuration.toString(),
    );

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
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
                  const Text(
                    '设置',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        _breakDuration =
                            int.tryParse(breakController.text) ?? 5;
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
                    header: const Text(
                      '休息时长',
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    children: [
                      CupertinoListTile(
                        title: const Text(
                          '子任务间休息时长（分钟）',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: SizedBox(
                          width: 80,
                          child: CupertinoTextField(
                            controller: breakController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '设置子任务之间的休息时间，完成一个子任务后会自动进入休息。',
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
      breakController.dispose();
    });
  }

  void _showAddSubtaskDialog(Todo parent) {
    if (!parent.canAddSubtask) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('提示'),
          content: const Text('合理分配任务，充分利用时间'),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final titleController = TextEditingController();
    final durationController = TextEditingController();

    // 计算建议的开始时间
    DateTime? suggestedStartTime;
    if (parent.startTime != null) {
      if (parent.subtasks.isNotEmpty) {
        // 如果有子任务，找到最后一个子任务的结束时间 + 休息时长
        final lastSubtask = parent.subtasks.last;
        if (lastSubtask.startTime != null && lastSubtask.duration != null) {
          suggestedStartTime = lastSubtask.startTime!.add(
            Duration(minutes: lastSubtask.duration! + _breakDuration),
          );
        } else if (lastSubtask.endTime != null) {
          suggestedStartTime = lastSubtask.endTime!.add(
            Duration(minutes: _breakDuration),
          );
        }
      }
      // 如果没有子任务或无法计算，使用父任务开始时间
      suggestedStartTime ??= parent.startTime;

      // 确保建议时间不早于父任务开始时间
      if (suggestedStartTime!.isBefore(parent.startTime!)) {
        suggestedStartTime = parent.startTime;
      }
    }

    DateTime? selectedStartTime = suggestedStartTime;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: CupertinoColors.systemGroupedBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                    const Text(
                      '添加子任务',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          int duration =
                              int.tryParse(durationController.text) ?? 0;
                          int priority = Todo.calculatePriorityFromDuration(
                            duration,
                          );

                          // 验证时间是否在父任务范围内
                          if (selectedStartTime != null &&
                              parent.startTime != null &&
                              parent.endTime != null) {
                            // 检查开始时间是否早于父任务开始时间
                            if (selectedStartTime!.isBefore(
                              parent.startTime!,
                            )) {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text('时间冲突'),
                                  content: const Text('子任务开始时间不能早于父任务开始时间'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('确定'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            // 检查开始时间是否晚于父任务结束时间
                            if (selectedStartTime!.isAfter(parent.endTime!)) {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text('时间冲突'),
                                  content: const Text('子任务开始时间不能晚于父任务结束时间'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('确定'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            // 检查结束时间是否超过父任务结束时间（只在有时长时检查）
                            if (duration > 0) {
                              final endTime = selectedStartTime!.add(
                                Duration(minutes: duration),
                              );
                              if (endTime.isAfter(parent.endTime!)) {
                                final exceedMinutes = endTime
                                    .difference(parent.endTime!)
                                    .inMinutes;
                                if (exceedMinutes > 0) {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('时间冲突'),
                                      content: Text(
                                        '子任务时间超出父任务范围 $exceedMinutes 分钟',
                                      ),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text('确定'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                              }
                            }
                          } else if (selectedStartTime != null &&
                              parent.startTime != null) {
                            // 如果父任务没有结束时间，只检查开始时间
                            if (selectedStartTime!.isBefore(
                              parent.startTime!,
                            )) {
                              showCupertinoDialog(
                                context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: const Text('时间冲突'),
                                  content: const Text('子任务开始时间不能早于父任务开始时间'),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('确定'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                          }

                          final subtask = Todo(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            title: titleController.text.trim(),
                            startTime: selectedStartTime,
                            duration: duration,
                            priority: priority,
                          );
                          setState(() {
                            parent.addSubtask(subtask);
                            parent.sortSubtasksByPriority();
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('添加'),
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
                          title: CupertinoTextField(
                            controller: titleController,
                            placeholder: '子任务名称',
                            autofocus: true,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: null,
                          ),
                        ),
                        CupertinoListTile(
                          title: CupertinoTextField(
                            controller: durationController,
                            placeholder: '时长（分钟）',
                            keyboardType: TextInputType.number,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: null,
                          ),
                        ),
                      ],
                    ),
                    if (parent.startTime != null && parent.endTime != null) ...[
                      CupertinoListSection.insetGrouped(
                        children: [
                          CupertinoListTile(
                            title: const Text(
                              '父任务时间范围',
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.secondaryLabel,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            additionalInfo: Text(
                              '${parent.startTime!.month.toString().padLeft(2, '0')}-${parent.startTime!.day.toString().padLeft(2, '0')} ${parent.startTime!.hour.toString().padLeft(2, '0')}:${parent.startTime!.minute.toString().padLeft(2, '0')} - ${parent.endTime!.hour.toString().padLeft(2, '0')}:${parent.endTime!.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          CupertinoListTile(
                            title: const Text(
                              '选择开始时间',
                              style: TextStyle(decoration: TextDecoration.none),
                            ),
                            additionalInfo: Text(
                              selectedStartTime != null
                                  ? '${selectedStartTime!.month.toString().padLeft(2, '0')}-${selectedStartTime!.day.toString().padLeft(2, '0')} ${selectedStartTime!.hour.toString().padLeft(2, '0')}:${selectedStartTime!.minute.toString().padLeft(2, '0')}'
                                  : '未选择',
                              style: const TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            trailing: const CupertinoListTileChevron(),
                            onTap: () async {
                              final DateTime? picked =
                                  await showCupertinoModalPopup<DateTime>(
                                    context: context,
                                    builder: (context) => Container(
                                      height: 300,
                                      color: CupertinoColors.systemBackground,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CupertinoButton(
                                                child: const Text('取消'),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                              CupertinoButton(
                                                child: const Text('确定'),
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  selectedStartTime ??
                                                      parent.startTime,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: CupertinoDatePicker(
                                              mode: CupertinoDatePickerMode
                                                  .dateAndTime,
                                              initialDateTime:
                                                  selectedStartTime ??
                                                  parent.startTime,
                                              minimumDate: parent.startTime,
                                              maximumDate: parent.endTime,
                                              onDateTimeChanged:
                                                  (DateTime newDate) {
                                                    setDialogState(() {
                                                      selectedStartTime =
                                                          newDate;
                                                    });
                                                  },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                              if (picked != null) {
                                setDialogState(() {
                                  selectedStartTime = picked;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      titleController.dispose();
      durationController.dispose();
    });
  }
}

class TreeLinePainter extends CustomPainter {
  final bool isLastLevel;
  final bool isLastItem;
  final Color color;

  TreeLinePainter({
    required this.isLastLevel,
    required this.isLastItem,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;

    if (isLastLevel) {
      if (isLastItem) {
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width / 2, centerY)
          ..lineTo(size.width, centerY);
        canvas.drawPath(path, paint);
      } else {
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width / 2, size.height);
        canvas.drawPath(path, paint);
        final hPath = Path()
          ..moveTo(size.width / 2, centerY)
          ..lineTo(size.width, centerY);
        canvas.drawPath(hPath, paint);
      }
    } else {
      final path = Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width / 2, size.height);
      canvas.drawPath(path, paint);
    }

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, centerY), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
