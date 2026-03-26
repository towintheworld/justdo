import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/todo.dart';

class MindMapView extends StatefulWidget {
  final List<Todo> todos;
  final Function(Todo) onToggle;
  final Function(Todo) onDelete;
  final Function(Todo, Todo) onAddSubtask;
  final Function(Todo, Todo) onDeleteSubtask;
  final Function(Todo, Todo) onToggleSubtask;

  const MindMapView({
    super.key,
    required this.todos,
    required this.onToggle,
    required this.onDelete,
    required this.onAddSubtask,
    required this.onDeleteSubtask,
    required this.onToggleSubtask,
  });

  @override
  State<MindMapView> createState() => _MindMapViewState();
}

class _MindMapViewState extends State<MindMapView> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.todos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('暂无待办事项', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(200),
          minScale: 0.2,
          maxScale: 2.0,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.todos.map((todo) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: _buildBranch(todo),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranch(Todo todo) {
    final hasSubtasks = todo.subtasks.isNotEmpty;
    final color = _getBranchColor(todo);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 主干节点
        _buildMainNode(todo, color),
        // 树枝连接和子任务
        if (hasSubtasks && todo.isExpanded) ...[
          _buildBranchConnection(color, todo.subtasks.length),
          _buildSubtaskBranch(todo, color, 0),
        ],
      ],
    );
  }

  Widget _buildMainNode(Todo todo, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          todo.toggleExpanded();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.85), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => widget.onToggle(todo),
              child: Icon(
                todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              todo.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (todo.subtasks.isNotEmpty) ...[
              const SizedBox(width: 8),
              Icon(
                todo.isExpanded ? Icons.chevron_right : Icons.expand_more,
                color: Colors.white70,
                size: 20,
              ),
            ],
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showAddSubtaskDialog(todo),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => widget.onDelete(todo),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchConnection(Color color, int childCount) {
    return SizedBox(
      width: 40,
      height: childCount * 48 + 20,
      child: CustomPaint(
        painter: BranchPainter(color: color, childCount: childCount),
      ),
    );
  }

  Widget _buildSubtaskBranch(Todo parent, Color parentColor, int depth) {
    final childColor = _lightenColor(parentColor, 0.15 + depth * 0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parent.subtasks.asMap().entries.map((entry) {
        final subtask = entry.value;
        final isFirst = entry.key == 0;
        final isLast = entry.key == parent.subtasks.length - 1;

        return Padding(
          padding: EdgeInsets.only(
            top: isFirst ? 10 : 0,
            bottom: isLast ? 10 : 0,
          ),
          child: _buildSubtaskNode(subtask, parent, childColor, depth),
        );
      }).toList(),
    );
  }

  Widget _buildSubtaskNode(Todo subtask, Todo parent, Color color, int depth) {
    final fontSize = (14 - depth * 0.5).clamp(11, 14).toDouble();
    final padding = EdgeInsets.symmetric(
      horizontal: (14 - depth * 2).clamp(8, 14).toDouble(),
      vertical: (10 - depth * 1.5).clamp(6, 10).toDouble(),
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => widget.onToggleSubtask(parent, subtask),
            child: Icon(
              subtask.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              color: subtask.isCompleted ? Colors.green : color,
              size: (18 - depth).clamp(14, 18).toDouble(),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            subtask.title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: depth == 0 ? FontWeight.w600 : FontWeight.normal,
              decoration: subtask.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
              color: subtask.isCompleted ? Colors.grey : Colors.black87,
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () => widget.onDeleteSubtask(parent, subtask),
            child: const Icon(Icons.close, color: Colors.red, size: 16),
          ),
        ],
      ),
    );
  }

  Color _getBranchColor(Todo todo) {
    if (todo.isCompleted) return Colors.green.shade600;
    if (todo.subtasks.isEmpty) return Colors.blue.shade600;
    final progress = todo.completionProgress;
    if (progress >= 0.75) return Colors.green.shade600;
    if (progress >= 0.5) return Colors.orange.shade600;
    if (progress >= 0.25) return Colors.amber.shade700;
    return Colors.purple.shade600;
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  void _showAddSubtaskDialog(Todo parent) {
    // 检查是否可以添加子任务
    if (!parent.canAddSubtask) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('合理分配任务，充分利用时间'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final titleController = TextEditingController();
    final durationController = TextEditingController();
    DateTime? selectedStartTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加子任务'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoTextField(
                  controller: titleController,
                  placeholder: '子任务名称',
                  autofocus: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: durationController,
                  placeholder: '时长（分钟）',
                  keyboardType: TextInputType.number,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                const SizedBox(height: 16),
                if (parent.startTime != null && parent.endTime != null) ...[
                  Text(
                    '父任务时间范围：${parent.startTime!.year}-${parent.startTime!.month.toString().padLeft(2, '0')}-${parent.startTime!.day.toString().padLeft(2, '0')} ${parent.startTime!.hour.toString().padLeft(2, '0')}:${parent.startTime!.minute.toString().padLeft(2, '0')} - ${parent.endTime!.year}-${parent.endTime!.month.toString().padLeft(2, '0')}-${parent.endTime!.day.toString().padLeft(2, '0')} ${parent.endTime!.hour.toString().padLeft(2, '0')}:${parent.endTime!.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: parent.startTime!,
                        firstDate: parent.startTime!,
                        lastDate: parent.endTime!,
                      );
                      if (picked != null && context.mounted) {
                        final TimeOfDay? timePicked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            parent.startTime!,
                          ),
                        );
                        if (timePicked != null) {
                          setDialogState(() {
                            selectedStartTime = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              timePicked.hour,
                              timePicked.minute,
                            );
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      selectedStartTime != null
                          ? '${selectedStartTime!.year}-${selectedStartTime!.month.toString().padLeft(2, '0')}-${selectedStartTime!.day.toString().padLeft(2, '0')} ${selectedStartTime!.hour.toString().padLeft(2, '0')}:${selectedStartTime!.minute.toString().padLeft(2, '0')}'
                          : '选择开始时间',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  int duration = int.tryParse(durationController.text) ?? 0;
                  int priority = Todo.calculatePriorityFromDuration(duration);

                  final subtask = Todo(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    startTime: selectedStartTime,
                    duration: duration,
                    priority: priority,
                  );
                  parent.addSubtask(subtask);
                  parent.sortSubtasksByPriority();
                  Navigator.pop(context);
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    ).then((_) {
      titleController.dispose();
      durationController.dispose();
    });
  }
}

class BranchPainter extends CustomPainter {
  final Color color;
  final int childCount;

  BranchPainter({required this.color, required this.childCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // 起点（左侧中心）
    final startX = 0.0;
    final startY = size.height / 2;
    // 主分支水平线
    final mainLineEndX = size.width * 0.4;

    path.moveTo(startX, startY);
    path.lineTo(mainLineEndX, startY);

    // 为每个子任务绘制分支
    final childSpacing = size.height / childCount;
    for (int i = 0; i < childCount; i++) {
      final childY = childSpacing * i + childSpacing / 2;
      path.moveTo(mainLineEndX, startY);
      path.lineTo(mainLineEndX, childY);
      path.lineTo(size.width, childY);
    }

    canvas.drawPath(path, paint);

    // 绘制小圆点
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(startX, startY), 4, dotPaint);

    for (int i = 0; i < childCount; i++) {
      final childY = childSpacing * i + childSpacing / 2;
      canvas.drawCircle(Offset(size.width, childY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
