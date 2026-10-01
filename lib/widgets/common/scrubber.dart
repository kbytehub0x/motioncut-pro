import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/core/utils/time_utils.dart';

class Scrubber extends StatelessWidget {
  final int currentMs;
  final int totalMs;
  final ValueChanged<int> onSeek;

  const Scrubber({
    super.key,
    required this.currentMs,
    required this.totalMs,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final double maxVal = totalMs > 0 ? totalMs.toDouble() : 1.0;
    final double currentVal = currentMs.clamp(0, maxVal.toInt()).toDouble();

    return Row(
      children: [
        Text(
          TimeUtils.formatTimecode(currentMs),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Slider(
            value: currentVal,
            min: 0,
            max: maxVal,
            activeColor: AppTheme.primary,
            inactiveColor: AppTheme.surfaceHighlight,
            onChanged: (val) => onSeek(val.round()),
          ),
        ),
        Text(
          TimeUtils.formatTimecode(totalMs),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
