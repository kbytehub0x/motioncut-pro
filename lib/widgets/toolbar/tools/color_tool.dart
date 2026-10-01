import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/models/effect_model.dart';

class ColorTool extends StatefulWidget {
  final ClipModel clip;
  final Function(double brightness, double contrast, double saturation) onColorGradeChanged;
  final VoidCallback onClose;

  const ColorTool({
    super.key,
    required this.clip,
    required this.onColorGradeChanged,
    required this.onClose,
  });

  @override
  State<ColorTool> createState() => _ColorToolState();
}

class _ColorToolState extends State<ColorTool> {
  double _brightness = 0.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  String _selectedLut = 'None';

  final List<String> _lutPresets = ['None', 'Teal & Orange', 'Cyber Neon', 'Noir Film', 'Golden Hour'];

  @override
  void initState() {
    super.initState();
    for (final eff in widget.clip.effects) {
      if (eff.type == EffectType.colorAdjust) {
        _brightness = (eff.parameters['brightness'] as num?)?.toDouble() ?? 0.0;
        _contrast = (eff.parameters['contrast'] as num?)?.toDouble() ?? 1.0;
        _saturation = (eff.parameters['saturation'] as num?)?.toDouble() ?? 1.0;
      }
    }
  }

  void _notify() {
    widget.onColorGradeChanged(_brightness, _contrast, _saturation);
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
                'Color Grading & LUTs',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: widget.onClose),
            ],
          ),
          const SizedBox(height: 8),

          // LUT presets horizontal selector
          SizedBox(
            height: 30,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _lutPresets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final lut = _lutPresets[index];
                final isSelected = _selectedLut == lut;
                return ChoiceChip(
                  label: Text(lut),
                  selected: isSelected,
                  selectedColor: AppTheme.accent,
                  onSelected: (_) {
                    setState(() {
                      _selectedLut = lut;
                      if (lut == 'Teal & Orange') {
                        _contrast = 1.25;
                        _saturation = 1.4;
                        _brightness = 0.02;
                      } else if (lut == 'Cyber Neon') {
                        _contrast = 1.35;
                        _saturation = 1.8;
                        _brightness = -0.05;
                      } else if (lut == 'Noir Film') {
                        _contrast = 1.4;
                        _saturation = 0.0;
                        _brightness = 0.0;
                      } else {
                        _brightness = 0.0;
                        _contrast = 1.0;
                        _saturation = 1.0;
                      }
                    });
                    _notify();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Exposure / Brightness
          _buildSliderRow('Exposure', _brightness, -0.5, 0.5, (v) {
            setState(() => _brightness = v);
            _notify();
          }),

          // Contrast
          _buildSliderRow('Contrast', _contrast, 0.5, 2.0, (v) {
            setState(() => _contrast = v);
            _notify();
          }),

          // Saturation
          _buildSliderRow('Saturation', _saturation, 0.0, 2.5, (v) {
            setState(() => _saturation = v);
            _notify();
          }),
        ],
      ),
    );
  }

  Widget _buildSliderRow(String label, double val, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70))),
        Expanded(
          child: Slider(
            value: val.clamp(min, max),
            min: min,
            max: max,
            activeColor: AppTheme.primary,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            val.toStringAsFixed(2),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ],
    );
  }
}
