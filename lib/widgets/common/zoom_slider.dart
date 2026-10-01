import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/constants.dart';
import 'package:motioncut_pro/core/theme.dart';

class ZoomSlider extends StatelessWidget {
  final double currentPps;
  final ValueChanged<double> onZoomChanged;

  const ZoomSlider({
    super.key,
    required this.currentPps,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.zoom_out, size: 16, color: Colors.white54),
          SizedBox(
            width: 90,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: currentPps.clamp(
                  AppConstants.minPixelsPerSecond,
                  AppConstants.maxPixelsPerSecond,
                ),
                min: AppConstants.minPixelsPerSecond,
                max: AppConstants.maxPixelsPerSecond,
                activeColor: AppTheme.accent,
                inactiveColor: Colors.white24,
                onChanged: onZoomChanged,
              ),
            ),
          ),
          const Icon(Icons.zoom_in, size: 16, color: Colors.white54),
        ],
      ),
    );
  }
}
