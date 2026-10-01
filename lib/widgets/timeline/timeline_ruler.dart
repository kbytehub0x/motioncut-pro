import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/core/utils/time_utils.dart';

class TimelineRuler extends StatelessWidget {
  final int totalDurationMs;
  final double pixelsPerSecond;
  final ValueChanged<int> onSeek;

  const TimelineRuler({
    super.key,
    required this.totalDurationMs,
    required this.pixelsPerSecond,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = (totalDurationMs / 1000.0) * pixelsPerSecond;
    final displayWidth = totalWidth < 800 ? 800.0 : totalWidth + 400;

    return GestureDetector(
      onTapDown: (details) {
        final localX = details.localPosition.dx;
        final seekMs = TimeUtils.pixelsToMilliseconds(localX, pixelsPerSecond);
        onSeek(seekMs);
      },
      onHorizontalDragUpdate: (details) {
        final localX = details.localPosition.dx;
        final seekMs = TimeUtils.pixelsToMilliseconds(localX, pixelsPerSecond);
        onSeek(seekMs);
      },
      child: Container(
        height: 28,
        width: displayWidth,
        color: AppTheme.surface,
        child: CustomPaint(
          size: Size(displayWidth, 28),
          painter: _RulerPainter(
            pixelsPerSecond: pixelsPerSecond,
            totalDurationMs: totalDurationMs,
          ),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double pixelsPerSecond;
  final int totalDurationMs;

  _RulerPainter({required this.pixelsPerSecond, required this.totalDurationMs});

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;

    final majorTickPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.2;

    const textStyle = TextStyle(
      color: Colors.white60,
      fontSize: 9,
      fontFamily: 'monospace',
    );

    // Dynamic interval based on zoom
    double intervalSec = 1.0;
    if (pixelsPerSecond < 25) intervalSec = 5.0;
    if (pixelsPerSecond > 100) intervalSec = 0.5;

    final totalSeconds = (size.width / pixelsPerSecond).ceil();

    for (double s = 0; s <= totalSeconds; s += intervalSec) {
      final x = s * pixelsPerSecond;
      final isMajor = s % 5 == 0 || s == 0;

      if (isMajor) {
        canvas.drawLine(Offset(x, 12), Offset(x, 28), majorTickPaint);
        final tp = TextPainter(
          text: TextSpan(text: '${s.toInt()}s', style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + 3, 2));
      } else {
        canvas.drawLine(Offset(x, 18), Offset(x, 28), tickPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) {
    return oldDelegate.pixelsPerSecond != pixelsPerSecond ||
        oldDelegate.totalDurationMs != totalDurationMs;
  }
}
