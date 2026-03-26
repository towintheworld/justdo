import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'countdown_timer.dart';

class TodoItem extends StatefulWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onSettings;
  final VoidCallback? onTap;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.onSettings,
    this.onTap,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  double _offset = 0;
  final double _buttonWidth = 80;
  bool _isOpen = false;

  bool _shouldShowCountdown() {
    if (widget.todo.endTime == null || widget.todo.isCompleted) return false;
    final now = DateTime.now();
    final difference = widget.todo.endTime!.difference(now);
    return difference.inMinutes <= 60;
  }

  bool _isOverdue() {
    if (widget.todo.endTime == null || widget.todo.isCompleted) return false;
    return widget.todo.endTime!.isBefore(DateTime.now());
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta.dx;
      _offset = _offset.clamp(-_buttonWidth, _buttonWidth);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_offset < -_buttonWidth / 2) {
      if (widget.todo.isCompleted) {
        widget.onDelete();
      } else {
        widget.onToggle();
      }
      setState(() {
        _offset = 0;
        _isOpen = false;
      });
    } else if (_offset > _buttonWidth / 2) {
      widget.onSettings?.call();
      setState(() {
        _offset = 0;
        _isOpen = false;
      });
    } else {
      setState(() {
        _offset = 0;
        _isOpen = false;
      });
    }
  }

  void _close() {
    setState(() {
      _offset = 0;
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showCountdown = _shouldShowCountdown();
    final isOverdue = _isOverdue();

    return Transform.translate(
      offset: Offset(_offset, 0),
      child: GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        onTap: () {
          if (_isOpen) {
            _close();
          } else {
            widget.onTap?.call();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isOverdue
                ? CupertinoColors.systemRed.withOpacity(0.1)
                : CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_isOpen) {
                    _close();
                  } else {
                    widget.onTap?.call();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // iOS风格复选框
                      _buildIOSCheckbox(),
                      const SizedBox(width: 12),
                      // 内容区域
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题行
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.todo.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: widget.todo.isCompleted
                                          ? FontWeight.w400
                                          : FontWeight.w600,
                                      decoration: widget.todo.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: widget.todo.isCompleted
                                          ? CupertinoColors.systemGrey
                                          : CupertinoColors.label,
                                    ),
                                  ),
                                ),
                                if (showCountdown)
                                  CountdownTimer(
                                    targetTime: widget.todo.endTime!,
                                  ),
                              ],
                            ),
                            // 描述
                            if (widget.todo.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.todo.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            // 时间信息
                            if (widget.todo.startTime != null ||
                                widget.todo.endTime != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _buildTimeInfo(),
                              ),
                            // 进度信息
                            if (widget.todo.subtasks.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _buildProgressInfo(),
                              ),
                          ],
                        ),
                      ),
                      // 右侧指示器
                      if (widget.todo.subtasks.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildSubtaskBadge(),
                      ],
                      const SizedBox(width: 4),
                      // iOS风格箭头
                      const Icon(
                        CupertinoIcons.chevron_right,
                        color: CupertinoColors.systemGrey3,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIOSCheckbox() {
    return GestureDetector(
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.todo.isCompleted
              ? _getPriorityColor(widget.todo.priority)
              : Colors.transparent,
          border: Border.all(
            color: widget.todo.isCompleted
                ? _getPriorityColor(widget.todo.priority)
                : CupertinoColors.systemGrey3,
            width: 2,
          ),
        ),
        child: widget.todo.isCompleted
            ? const Icon(
                CupertinoIcons.check_mark,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildTimeInfo() {
    final List<Widget> timeWidgets = [];

    if (widget.todo.startTime != null) {
      timeWidgets.add(
        _buildTimeChip(
          CupertinoIcons.play_fill,
          _formatTime(widget.todo.startTime!),
        ),
      );
    }

    if (widget.todo.endTime != null) {
      timeWidgets.add(
        _buildTimeChip(
          CupertinoIcons.clock,
          _formatTime(widget.todo.endTime!),
          isOverdue: _isOverdue(),
        ),
      );
    }

    if (widget.todo.duration != null) {
      timeWidgets.add(
        _buildTimeChip(CupertinoIcons.timer, '${widget.todo.duration}分钟'),
      );
    }

    if (widget.todo.priority != null && widget.todo.priority! > 1) {
      timeWidgets.add(_buildPriorityBadge());
    }

    return Wrap(spacing: 8, runSpacing: 4, children: timeWidgets);
  }

  Widget _buildTimeChip(IconData icon, String text, {bool isOverdue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue
            ? CupertinoColors.systemRed.withOpacity(0.1)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isOverdue
                ? CupertinoColors.systemRed
                : CupertinoColors.secondaryLabel,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isOverdue
                  ? CupertinoColors.systemRed
                  : CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final color = _getPriorityColor(widget.todo.priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.flag_fill, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            'P${widget.todo.priority}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskBadge() {
    final progress = widget.todo.completionProgress;
    final color = progress >= 1.0
        ? CupertinoColors.systemGreen
        : CupertinoColors.systemBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${widget.todo.completedSubtasksCount}/${widget.todo.totalSubtasksCount}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProgressInfo() {
    final progress = widget.todo.completionProgress;
    final color = progress >= 1.0
        ? CupertinoColors.systemGreen
        : CupertinoColors.systemBlue;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: CupertinoColors.systemGrey5,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.secondaryLabel,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(int? priority) {
    switch (priority) {
      case 5:
        return CupertinoColors.systemRed;
      case 4:
        return CupertinoColors.systemOrange;
      case 3:
        return CupertinoColors.systemYellow;
      case 2:
        return CupertinoColors.systemBlue;
      case 1:
        return CupertinoColors.systemGrey;
      default:
        return CupertinoColors.systemBlue;
    }
  }
}
