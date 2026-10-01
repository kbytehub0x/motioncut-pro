import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';

class SpeedTool extends StatefulWidget {
  final ClipModel clip;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onClose;

  const SpeedTool({
    super.key,
    required this.clip,
    required this.onSpeedChanged,
    required this.onClose,
  });

  @override
  State<SpeedTool> createState() => _SpeedToolState();
}

class _SpeedToolState extends State<SpeedTool> {
  late double _currentSpeed;
  bool _isCurveMode = false;

  final List<double> _presets = [0.1, 0.25, 0.5, 1.0, 1.5, 2.0, 4.0, 8.0];

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.clip.speed;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceElevated,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Speed Control',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_currentSpeed.toStringAsFixed(2)}x',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: widget.onClose),
            ],
          ),
          const SizedBox(height: 12),

          // Presets
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = _presets[index];
                final isSelected = (_currentSpeed - preset).abs() < 0.05;
                return ChoiceChip(
                  label: Text('${preset}x'),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  onSelected: (val) {
                    setState(() => _currentSpeed = preset);
                    widget.onSpeedChanged(preset);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Continuous Slider
          Slider(
            value: _currentSpeed.clamp(0.1, 10.0),
            min: 0.1,
            max: 10.0,
            activeColor: AppTheme.primary,
            onChanged: (val) {
              setState(() => _currentSpeed = val);
              widget.onSpeedChanged(val);
            },
          ),

          // Speed Ramp / Curve Mode Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Speed Curve (Ramping)', style: TextStyle(fontSize: 12, color: Colors.white70)),
              Switch(
                value: _isCurveMode,
                activeColor: AppTheme.accent,
                onChanged: (val) {
                  setState(() => _isCurveMode = val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
