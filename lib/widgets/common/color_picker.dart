import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';

class MotionColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  static const List<Color> presetColors = [
    Colors.white,
    Color(0xFFFF2A6D), // Cyber Rose
    Color(0xFF05D9E8), // Cyan
    Color(0xFFFF8B26), // Orange
    Color(0xFF00E676), // Green
    Color(0xFFFFEA00), // Yellow
    Color(0xFF9D4EDD), // Purple
    Colors.black,
  ];

  const MotionColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presetColors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final color = presetColors[index];
          final isSelected = selectedColor.value == color.value;

          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : AppTheme.divider,
                  width: isSelected ? 2.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
