import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/services/audio/audio_keyframe_service.dart';

class AudioTool extends StatefulWidget {
  final ClipModel clip;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onClose;

  const AudioTool({
    super.key,
    required this.clip,
    required this.onVolumeChanged,
    required this.onClose,
  });

  @override
  State<AudioTool> createState() => _AudioToolState();
}

class _AudioToolState extends State<AudioTool> {
  late double _volume;
  bool _duckingEnabled = false;

  @override
  void initState() {
    super.initState();
    _volume = widget.clip.volume;
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
              Text(
                'Audio & Volume: ${widget.clip.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: widget.onClose),
            ],
          ),
          const SizedBox(height: 8),

          // Master Clip Volume
          Row(
            children: [
              const Icon(Icons.volume_up, size: 18, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _volume.clamp(0.0, 2.0),
                  min: 0.0,
                  max: 2.0,
                  activeColor: AppTheme.accent,
                  onChanged: (val) {
                    setState(() => _volume = val);
                    widget.onVolumeChanged(val);
                  },
                ),
              ),
              Text(
                '${(_volume * 100).round()}%',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Fade In / Fade Out Quick Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.trending_up, size: 16),
                label: const Text('Fade In (0.5s)'),
                onPressed: () {
                  AudioKeyframeService.generateFadeEnvelope(
                    clipDurationMs: widget.clip.durationMs,
                  );
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.trending_down, size: 16),
                label: const Text('Fade Out (0.5s)'),
                onPressed: () {
                  AudioKeyframeService.generateFadeEnvelope(
                    clipDurationMs: widget.clip.durationMs,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Audio Ducking (Auto-lower volume when voiceover appears)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto Audio Ducking', style: TextStyle(fontSize: 13)),
            subtitle: const Text('Lowers BGM volume under voice tracks', style: TextStyle(fontSize: 11, color: Colors.white54)),
            value: _duckingEnabled,
            activeColor: AppTheme.primary,
            onChanged: (val) => setState(() => _duckingEnabled = val),
          ),
        ],
      ),
    );
  }
}
