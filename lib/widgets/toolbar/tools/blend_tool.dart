import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/models/effect_model.dart';

class BlendTool extends StatefulWidget {
  final ClipModel clip;
  final Function(double opacity, BlendModeType blendMode) onBlendChanged;
  final VoidCallback onClose;

  const BlendTool({
    super.key,
    required this.clip,
    required this.onBlendChanged,
    required this.onClose,
  });

  @override
  State<BlendTool> createState() => _BlendToolState();
}

class _BlendToolState extends State<BlendTool> {
  late double _opacity;
  late BlendModeType _blendMode;

  @override
  void initState() {
    super.initState();
    _opacity = widget.clip.opacity;
    _blendMode = widget.clip.blendMode;
  }

  void _notify() {
    widget.onBlendChanged(_opacity, _blendMode);
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
              const Text(
                'Blending & Opacity',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: widget.onClose),
            ],
          ),
          const SizedBox(height: 8),

          // Opacity Slider
          Row(
            children: [
              const SizedBox(width: 60, child: Text('Opacity', style: TextStyle(fontSize: 12, color: Colors.white70))),
              Expanded(
                child: Slider(
                  value: _opacity.clamp(0.0, 1.0),
                  min: 0.0,
                  max: 1.0,
                  activeColor: AppTheme.accent,
                  onChanged: (val) {
                    setState(() => _opacity = val);
                    _notify();
                  },
                ),
              ),
              Text('${(_opacity * 100).round()}%', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          // Blend Mode Chips
          const Text('Blend Mode', style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: BlendModeType.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final mode = BlendModeType.values[index];
                final isSelected = _blendMode == mode;
                return ChoiceChip(
                  label: Text(mode.name),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  onSelected: (val) {
                    setState(() => _blendMode = mode);
                    _notify();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
