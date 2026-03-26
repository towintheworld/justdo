import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  final VoidCallback? onExpired;

  const CountdownTimer({super.key, required this.targetTime, this.onExpired});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime) {
      _timer?.cancel();
      _updateRemaining();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final difference = widget.targetTime.difference(now);

    setState(() {
      if (difference.isNegative) {
        _remaining = Duration.zero;
        if (!_isExpired) {
          _isExpired = true;
          widget.onExpired?.call();
        }
      } else {
        _remaining = difference;
        _isExpired = false;
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}天${duration.inHours % 24}时${duration.inMinutes % 60}分';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}时${duration.inMinutes % 60}分${duration.inSeconds % 60}秒';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分${duration.inSeconds % 60}秒';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  Color _getTimerColor() {
    final minutes = _remaining.inMinutes;
    if (minutes <= 5) return Colors.red;
    if (minutes <= 15) return Colors.orange;
    if (minutes <= 30) return Colors.yellow.shade700;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    if (_isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, size: 14, color: Colors.red.shade700),
            const SizedBox(width: 4),
            Text(
              '已逾期',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final color = _getTimerColor();
    final isUrgent = _remaining.inMinutes <= 15;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: isUrgent ? Border.all(color: color, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _formatDuration(_remaining),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
