import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';

enum CropAspectRatioPreset {
  freeform("Free", null),
  portrait9_16("9:16", 9 / 16),
  landscape16_9("16:9", 16 / 9),
  square1_1("1:1", 1.0),
  portrait4_5("4:5", 4 / 5),
  classic4_3("4:3", 4 / 3),
  cinema21_9("21:9", 21 / 9);

  final String label;
  final double? ratio;
  const CropAspectRatioPreset(this.label, this.ratio);
}

class CropBounds {
  final double left; // Normalized 0.0 to 1.0
  final double top;
  final double right;
  final double bottom;

  const CropBounds({
    this.left = 0.0,
    this.top = 0.0,
    this.right = 1.0,
    this.bottom = 1.0,
  });

  double get width => (right - left).clamp(0.1, 1.0);
  double get height => (bottom - top).clamp(0.1, 1.0);

  CropBounds copyWith({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return CropBounds(
      left: left ?? this.left,
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
    );
  }
}

class CropTool extends StatefulWidget {
  final ClipModel clip;
  final Function(CropBounds bounds, double rotationDegrees, bool flipX, bool flipY) onApplyCrop;
  final VoidCallback onClose;

  const CropTool({
    super.key,
    required this.clip,
    required this.onApplyCrop,
    required this.onClose,
  });

  @override
  State<CropTool> createState() => _CropToolState();
}

class _CropToolState extends State<CropTool> {
  CropBounds _bounds = const CropBounds();
  CropAspectRatioPreset _selectedPreset = CropAspectRatioPreset.freeform;
  double _rotationDegrees = 0.0;
  bool _flipHorizontal = false;
  bool _flipVertical = false;

  void _applyAspectRatio(CropAspectRatioPreset preset) {
    setState(() {
      _selectedPreset = preset;
      if (preset.ratio == null) {
        // Freeform: keep current or reset to full
        return;
      }

      final ratio = preset.ratio!;
      if (ratio >= 1.0) {
        // Landscape or Square
        final h = 1.0 / ratio;
        final top = (1.0 - h) / 2;
        _bounds = CropBounds(left: 0.0, top: top, right: 1.0, bottom: top + h);
      } else {
        // Portrait
        final w = ratio;
        final left = (1.0 - w) / 2;
        _bounds = CropBounds(left: left, top: 0.0, right: left + w, bottom: 1.0);
      }
    });
    _notify();
  }

  void _rotateQuarter() {
    setState(() {
      _rotationDegrees = (_rotationDegrees + 90) % 360;
    });
    _notify();
  }

  void _notify() {
    widget.onApplyCrop(_bounds, _rotationDegrees, _flipHorizontal, _flipVertical);
  }

  void _reset() {
    setState(() {
      _bounds = const CropBounds();
      _selectedPreset = CropAspectRatioPreset.freeform;
      _rotationDegrees = 0.0;
      _flipHorizontal = false;
      _flipVertical = false;
    });
    _notify();
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
          // Header with Reset and Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.crop, size: 18, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Crop & Transform: ${widget.clip.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Reset', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Aspect Ratio Presets
          const Text(
            'Aspect Ratio',
            style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: CropAspectRatioPreset.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = CropAspectRatioPreset.values[index];
                final isSelected = _selectedPreset == preset;
                return ChoiceChip(
                  label: Text(preset.label),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  onSelected: (_) => _applyAspectRatio(preset),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Interactive Freeform Crop Boundaries
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Width Crop', style: TextStyle(fontSize: 11, color: Colors.white60)),
                        Text('${(_bounds.width * 100).round()}%',
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                      ],
                    ),
                    Slider(
                      value: _bounds.width.clamp(0.2, 1.0),
                      min: 0.2,
                      max: 1.0,
                      activeColor: AppTheme.accent,
                      onChanged: (val) {
                        final halfDiff = (1.0 - val) / 2;
                        setState(() {
                          _bounds = CropBounds(
                            left: halfDiff,
                            top: _bounds.top,
                            right: 1.0 - halfDiff,
                            bottom: _bounds.bottom,
                          );
                        });
                        _notify();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Height Crop', style: TextStyle(fontSize: 11, color: Colors.white60)),
                        Text('${(_bounds.height * 100).round()}%',
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                      ],
                    ),
                    Slider(
                      value: _bounds.height.clamp(0.2, 1.0),
                      min: 0.2,
                      max: 1.0,
                      activeColor: AppTheme.accent,
                      onChanged: (val) {
                        final halfDiff = (1.0 - val) / 2;
                        setState(() {
                          _bounds = CropBounds(
                            left: _bounds.left,
                            top: halfDiff,
                            right: _bounds.right,
                            bottom: 1.0 - halfDiff,
                          );
                        });
                        _notify();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rotation & Flips
          Row(
            children: [
              // 90-degree step rotate
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: const BorderSide(color: AppTheme.divider),
                ),
                icon: const Icon(Icons.rotate_90_degrees_cw, size: 16, color: Colors.white),
                label: Text('${_rotationDegrees.round()}°', style: const TextStyle(fontSize: 11)),
                onPressed: _rotateQuarter,
              ),
              const SizedBox(width: 8),

              // Flip Horizontal
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: _flipHorizontal ? AppTheme.primary.withOpacity(0.3) : AppTheme.surface,
                ),
                icon: const Icon(Icons.flip, size: 18),
                tooltip: 'Flip Horizontal',
                onPressed: () {
                  setState(() => _flipHorizontal = !_flipHorizontal);
                  _notify();
                },
              ),

              // Flip Vertical
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: _flipVertical ? AppTheme.primary.withOpacity(0.3) : AppTheme.surface,
                ),
                icon: const RotatedBox(
                  quarterTurns: 1,
                  child: Icon(Icons.flip, size: 18),
                ),
                tooltip: 'Flip Vertical',
                onPressed: () {
                  setState(() => _flipVertical = !_flipVertical);
                  _notify();
                },
              ),

              // Fine-tuning angle slider (-45° to +45°)
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.straighten, size: 16, color: Colors.white54),
                    Expanded(
                      child: Slider(
                        value: (_rotationDegrees % 90 > 45 ? _rotationDegrees % 90 - 90 : _rotationDegrees % 90)
                            .clamp(-45.0, 45.0),
                        min: -45.0,
                        max: 45.0,
                        activeColor: AppTheme.accentOrange,
                        onChanged: (val) {
                          final base = ((_rotationDegrees / 90).floor() * 90).toDouble();
                          setState(() {
                            _rotationDegrees = base + val;
                          });
                          _notify();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
