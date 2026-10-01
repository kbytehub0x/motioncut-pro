import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';

class PreviewOverlay extends StatelessWidget {
  final bool showSafeAreas;
  final bool showGrid;

  const PreviewOverlay({
    super.key,
    required this.showSafeAreas,
    required this.showGrid,
  });

  @override
  Widget build(BuildContext context) {
    if (!showSafeAreas && !showGrid) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _OverlayPainter(
          showSafeAreas: showSafeAreas,
          showGrid: showGrid,
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final bool showSafeAreas;
  final bool showGrid;

  _OverlayPainter({required this.showSafeAreas, required this.showGrid});

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      final gridPaint = Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..strokeWidth = 1.0;

      // Vertical 1/3 and 2/3
      canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), gridPaint);
      canvas.drawLine(Offset(size.width * 2 / 3, 0), Offset(size.width * 2 / 3, size.height), gridPaint);

      // Horizontal 1/3 and 2/3
      canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), gridPaint);
      canvas.drawLine(Offset(0, size.height * 2 / 3), Offset(size.width, size.height * 2 / 3), gridPaint);
    }

    if (showSafeAreas) {
      final safePaint = Paint()
        ..color = AppTheme.accent.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      // 90% Title Safe Area
      final titleSafe = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.9,
        height: size.height * 0.9,
      );
      canvas.drawRect(titleSafe, safePaint);

      // 80% Action Safe Area
      final actionPaint = Paint()
        ..color = AppTheme.primary.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      final actionSafe = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.8,
        height: size.height * 0.8,
      );
      canvas.drawRect(actionSafe, actionPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return oldDelegate.showSafeAreas != showSafeAreas || oldDelegate.showGrid != showGrid;
  }
}
