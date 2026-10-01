import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/widgets/common/color_picker.dart';

class TextTool extends StatefulWidget {
  final ClipModel clip;
  final Function(String newText, Color color, double fontSize) onTextChanged;
  final VoidCallback onClose;

  const TextTool({
    super.key,
    required this.clip,
    required this.onTextChanged,
    required this.onClose,
  });

  @override
  State<TextTool> createState() => _TextToolState();
}

class _TextToolState extends State<TextTool> {
  late TextEditingController _textCtrl;
  late Color _textColor;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.clip.textContent ?? 'TITLE');
    _textColor = widget.clip.textColorValue != null
        ? Color(widget.clip.textColorValue!)
        : Colors.white;
    _fontSize = widget.clip.fontSize ?? 26.0;
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onTextChanged(_textCtrl.text, _textColor, _fontSize);
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
                'Edit Text Layer',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: widget.onClose),
            ],
          ),
          const SizedBox(height: 8),

          // Text Input Field
          TextField(
            controller: _textCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surface,
              hintText: 'Enter text...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (_) => _notify(),
          ),
          const SizedBox(height: 12),

          // Font Size Slider
          Row(
            children: [
              const SizedBox(width: 70, child: Text('Font Size', style: TextStyle(fontSize: 12, color: Colors.white70))),
              Expanded(
                child: Slider(
                  value: _fontSize.clamp(14.0, 72.0),
                  min: 14.0,
                  max: 72.0,
                  activeColor: AppTheme.primary,
                  onChanged: (val) {
                    setState(() => _fontSize = val);
                    _notify();
                  },
                ),
              ),
              Text('${_fontSize.round()}px', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),

          // Text Color Picker
          const Text('Text Color', style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 6),
          MotionColorPicker(
            selectedColor: _textColor,
            onColorChanged: (c) {
              setState(() => _textColor = c);
              _notify();
            },
          ),
        ],
      ),
    );
  }
}
