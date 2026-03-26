import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/todo.dart';

class FocusTimerScreen extends StatefulWidget {
  final Todo todo;
  final int focusDuration;
  final int breakDuration;
  final int longBreakDuration;
  final int sessionsBeforeLongBreak;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;

  const FocusTimerScreen({
    super.key,
    required this.todo,
    required this.focusDuration,
    required this.breakDuration,
    required this.longBreakDuration,
    required this.sessionsBeforeLongBreak,
    this.autoStartBreaks = true,
    this.autoStartPomodoros = false,
  });

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedSessions = 0;
  bool _isMinimalMode = false;

  static const List<Color> _cyberpunkColors = [
    Color(0xFF00FF41), // Matrix Green
    Color(0xFF00D4FF), // Cyber Blue
    Color(0xFFFF0080), // Neon Pink
    Color(0xFFFFFF00), // Electric Yellow
    Color(0xFFFF6B00), // Neon Orange
    Color(0xFFBF00FF), // Ultraviolet
    Color(0xFFFF0000), // Danger Red
    Color(0xFFFFFFFF), // Pure White
  ];
  int _colorIndex = 0;
  Color _digitColor = _cyberpunkColors[0];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.focusDuration * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _cycleColor() {
    setState(() {
      _colorIndex = (_colorIndex + 1) % _cyberpunkColors.length;
      _digitColor = _cyberpunkColors[_colorIndex];
    });
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isBreak
          ? (_completedSessions % widget.sessionsBeforeLongBreak == 0
                ? widget.longBreakDuration * 60
                : widget.breakDuration * 60)
          : widget.focusDuration * 60;
    });
  }

  void _onTimerComplete() {
    if (_isBreak) {
      setState(() {
        _isBreak = false;
        _remainingSeconds = widget.focusDuration * 60;
      });

      if (widget.autoStartPomodoros) {
        _startTimer();
      } else {
        _showCompletionDialog('休息结束', '准备开始新的专注');
      }
    } else {
      _completedSessions++;
      setState(() {
        _isBreak = true;
        _remainingSeconds =
            _completedSessions % widget.sessionsBeforeLongBreak == 0
            ? widget.longBreakDuration * 60
            : widget.breakDuration * 60;
      });

      if (widget.autoStartBreaks) {
        _startTimer();
      } else {
        _showCompletionDialog('专注完成', '开始休息');
      }
    }
  }

  void _showCompletionDialog(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text('开始'),
            onPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('跳过'),
            onPressed: () {
              Navigator.pop(context);
              _skipToNext();
            },
          ),
        ],
      ),
    );
  }

  void _skipToNext() {
    setState(() {
      if (_isBreak) {
        _isBreak = false;
        _remainingSeconds = widget.focusDuration * 60;
      } else {
        _completedSessions++;
        _isBreak = true;
        _remainingSeconds =
            _completedSessions % widget.sessionsBeforeLongBreak == 0
            ? widget.longBreakDuration * 60
            : widget.breakDuration * 60;
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildMinimalMode() {
    final timeString = _formatTime(_remainingSeconds);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 扫描线效果
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: ScanLinePainter()),
              ),
            ),
            // 左上角返回按钮
            Positioned(
              top: 20,
              left: 20,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _isMinimalMode = false;
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _digitColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_left,
                    color: _digitColor,
                    size: 20,
                  ),
                ),
              ),
            ),
            // 七段数码管显示 - 横屏居中，点击可更改颜色
            Center(
              child: GestureDetector(
                onTap: _cycleColor,
                child: RotatedBox(
                  quarterTurns: 1,
                  child: _buildSevenSegmentDisplay(timeString),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSevenSegmentDisplay(String timeString) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: timeString.split('').map((char) {
        if (char == ':') {
          return _buildColon();
        }
        return _buildDigit(char);
      }).toList(),
    );
  }

  Widget _buildDigit(String digit) {
    return Container(
      width: 120,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomPaint(
        painter: SevenSegmentPainter(digit: digit, color: _digitColor),
      ),
    );
  }

  Widget _buildColon() {
    return Container(
      width: 40,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _digitColor,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _digitColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isMinimalMode) {
      return _buildMinimalMode();
    }

    final totalTime = _isBreak
        ? (_completedSessions % widget.sessionsBeforeLongBreak == 0
              ? widget.longBreakDuration * 60
              : widget.breakDuration * 60)
        : widget.focusDuration * 60;
    final progress = _remainingSeconds / totalTime;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Stack(
          children: [
            // 左上角极简模式按钮
            Positioned(
              top: 16,
              left: 16,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _isRunning
                    ? () {
                        setState(() {
                          _isMinimalMode = true;
                        });
                      }
                    : null,
                child: Icon(
                  CupertinoIcons.minus_rectangle,
                  color: _isRunning
                      ? CupertinoColors.secondaryLabel
                      : CupertinoColors.secondaryLabel.withOpacity(0.3),
                  size: 28,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // 圆环进度条和时钟
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 圆环进度条
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: CupertinoColors.systemGrey5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isBreak
                              ? CupertinoColors.systemGreen
                              : CupertinoColors.systemBlue,
                        ),
                      ),
                    ),
                    // 电子时钟
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: CupertinoColors.label,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),

                // 控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 重置按钮
                    CupertinoButton(
                      onPressed: _resetTimer,
                      child: const Icon(
                        CupertinoIcons.arrow_counterclockwise,
                        size: 32,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(width: 40),

                    // 播放/暂停按钮
                    CupertinoButton(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRunning
                              ? CupertinoColors.destructiveRed
                              : (_isBreak
                                    ? CupertinoColors.systemGreen
                                    : CupertinoColors.systemBlue),
                        ),
                        child: Icon(
                          _isRunning
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill,
                          color: CupertinoColors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),

                    // 结束按钮
                    CupertinoButton(
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        CupertinoIcons.stop_fill,
                        size: 32,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SevenSegmentPainter extends CustomPainter {
  final String digit;
  final Color color;

  SevenSegmentPainter({required this.digit, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final segments = _getSegments(digit);
    final width = size.width;
    final height = size.height;

    // 段厚度
    final thickness = width * 0.18;
    // 斜面长度
    final bevel = thickness * 0.6;

    // 绘制发光效果
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (final segment in segments) {
      final path = _createSegmentPath(segment, width, height, thickness, bevel);
      if (path != null) {
        canvas.drawPath(path, glowPaint);
      }
    }

    // 绘制主体
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final segment in segments) {
      final path = _createSegmentPath(segment, width, height, thickness, bevel);
      if (path != null) {
        canvas.drawPath(path, mainPaint);
      }
    }
  }

  Path? _createSegmentPath(
    String segment,
    double width,
    double height,
    double thickness,
    double bevel,
  ) {
    final path = Path();
    final halfThick = thickness / 2;

    // 计算各段的位置
    final leftEdge = thickness;
    final rightEdge = width - thickness;
    final topEdge = thickness;
    final bottomEdge = height - thickness;
    final centerY = height / 2;

    switch (segment) {
      case 'a': // 顶部水平段
        final y = topEdge;
        path.moveTo(leftEdge + bevel, y - halfThick);
        path.lineTo(rightEdge - bevel, y - halfThick);
        path.lineTo(rightEdge, y);
        path.lineTo(rightEdge - bevel, y + halfThick);
        path.lineTo(leftEdge + bevel, y + halfThick);
        path.lineTo(leftEdge, y);
        path.close();
        break;

      case 'b': // 右上垂直段
        final x = rightEdge;
        path.moveTo(x + halfThick, topEdge + bevel);
        path.lineTo(x + halfThick, centerY - bevel);
        path.lineTo(x, centerY);
        path.lineTo(x - halfThick, centerY - bevel);
        path.lineTo(x - halfThick, topEdge + bevel);
        path.lineTo(x, topEdge);
        path.close();
        break;

      case 'c': // 右下垂直段
        final x = rightEdge;
        path.moveTo(x + halfThick, centerY + bevel);
        path.lineTo(x + halfThick, bottomEdge - bevel);
        path.lineTo(x, bottomEdge);
        path.lineTo(x - halfThick, bottomEdge - bevel);
        path.lineTo(x - halfThick, centerY + bevel);
        path.lineTo(x, centerY);
        path.close();
        break;

      case 'd': // 底部水平段
        final y = bottomEdge;
        path.moveTo(leftEdge + bevel, y - halfThick);
        path.lineTo(rightEdge - bevel, y - halfThick);
        path.lineTo(rightEdge, y);
        path.lineTo(rightEdge - bevel, y + halfThick);
        path.lineTo(leftEdge + bevel, y + halfThick);
        path.lineTo(leftEdge, y);
        path.close();
        break;

      case 'e': // 左下垂直段
        final x = leftEdge;
        path.moveTo(x + halfThick, centerY + bevel);
        path.lineTo(x + halfThick, bottomEdge - bevel);
        path.lineTo(x, bottomEdge);
        path.lineTo(x - halfThick, bottomEdge - bevel);
        path.lineTo(x - halfThick, centerY + bevel);
        path.lineTo(x, centerY);
        path.close();
        break;

      case 'f': // 左上垂直段
        final x = leftEdge;
        path.moveTo(x + halfThick, topEdge + bevel);
        path.lineTo(x + halfThick, centerY - bevel);
        path.lineTo(x, centerY);
        path.lineTo(x - halfThick, centerY - bevel);
        path.lineTo(x - halfThick, topEdge + bevel);
        path.lineTo(x, topEdge);
        path.close();
        break;

      case 'g': // 中间水平段
        final y = centerY;
        path.moveTo(leftEdge + bevel, y - halfThick);
        path.lineTo(rightEdge - bevel, y - halfThick);
        path.lineTo(rightEdge, y);
        path.lineTo(rightEdge - bevel, y + halfThick);
        path.lineTo(leftEdge + bevel, y + halfThick);
        path.lineTo(leftEdge, y);
        path.close();
        break;
    }

    return path;
  }

  List<String> _getSegments(String digit) {
    switch (digit) {
      case '0':
        return ['a', 'b', 'c', 'd', 'e', 'f'];
      case '1':
        return ['b', 'c'];
      case '2':
        return ['a', 'b', 'd', 'e', 'g'];
      case '3':
        return ['a', 'b', 'c', 'd', 'g'];
      case '4':
        return ['b', 'c', 'f', 'g'];
      case '5':
        return ['a', 'c', 'd', 'f', 'g'];
      case '6':
        return ['a', 'c', 'd', 'e', 'f', 'g'];
      case '7':
        return ['a', 'b', 'c'];
      case '8':
        return ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
      case '9':
        return ['a', 'b', 'c', 'd', 'f', 'g'];
      default:
        return [];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ScanLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
