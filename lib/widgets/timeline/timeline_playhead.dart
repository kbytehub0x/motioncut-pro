import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/core/utils/time_utils.dart';

class TimelinePlayhead extends StatelessWidget {
  final int playheadMs;
  final double pixelsPerSecond;
  final double totalHeight;

  const TimelinePlayhead({
    super.key,
    required this.playheadMs,
    required this.pixelsPerSecond,
    required this.totalHeight,
  });

  @override
  Widget build(BuildContext context) {
    final xPos = TimeUtils.millisecondsToPixels(playheadMs, pixelsPerSecond);

    return Positioned(
      left: xPos - 8, // center needle
      top: 0,
      bottom: 0,
      width: 16,
      child: IgnorePointer(
        child: Column(
          children: [
            // Triangular top marker
            CustomPaint(
              size: const Size(16, 12),
              painter: _PlayheadMarkerPainter(),
            ),
            // Glowing vertical needle line
            Expanded(
              child: Container(
                width: 2.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.8),
                      blurRadius: 4,
                      spreadRadius: 1,
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

class _PlayheadMarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 4)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, 4)
      ..close();

    canvas.drawPath(path, paint);

    // Accent inner dot
    final dotPaint = Paint()..color = AppTheme.primary;
    canvas.drawCircle(Offset(size.width / 2, 4), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
