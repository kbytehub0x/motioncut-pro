import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/services/audio/audio_keyframe_service.dart';

class AudioTool extends StatefulWidget {
  final ClipModel clip;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<List<KeyframeModel>>? onKeyframesChanged;
  final VoidCallback? onExtractAudio;
  final VoidCallback onClose;

  const AudioTool({
    super.key,
    required this.clip,
    required this.onVolumeChanged,
    this.onKeyframesChanged,
    this.onExtractAudio,
    required this.onClose,
  });

  @override
  State<AudioTool> createState() => _AudioToolState();
}

class _AudioToolState extends State<AudioTool> {
  late double _volume;
  double _prevVolume = 1.0;
  bool _duckingEnabled = false;
  int _fadeDurationMs = 500;
  bool _hasFadeIn = false;
  bool _hasFadeOut = false;

  @override
  void initState() {
    super.initState();
    _volume = widget.clip.volume;
    _hasFadeIn = widget.clip.volumeKeyframes.any((k) => k.id.contains('fade_in'));
    _hasFadeOut = widget.clip.volumeKeyframes.any((k) => k.id.contains('fade_out'));
  }

  void _applyFadeEnvelope() {
    if (widget.onKeyframesChanged == null) return;
    final kfs = AudioKeyframeService.generateFadeEnvelope(
      clipDurationMs: widget.clip.durationMs,
      fadeInMs: _hasFadeIn ? _fadeDurationMs : 0,
      fadeOutMs: _hasFadeOut ? _fadeDurationMs : 0,
    );
    widget.onKeyframesChanged!(kfs);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied Audio Fade Envelope (${_fadeDurationMs / 1000}s)'),
        duration: const Duration(seconds: 1),
      ),
    );
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
                  const Icon(Icons.graphic_eq, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Audio & Volume: ${widget.clip.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: widget.onClose),
            ],
          ),
          const SizedBox(height: 8),

          // Master Clip Volume Slider & Mute Toggle
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _volume == 0.0 ? Icons.volume_off : Icons.volume_up,
                  size: 20,
                  color: _volume == 0.0 ? Colors.redAccent : Colors.white70,
                ),
                tooltip: _volume == 0.0 ? 'Unmute' : 'Mute',
                onPressed: () {
                  if (_volume > 0.0) {
                    _prevVolume = _volume;
                    setState(() => _volume = 0.0);
                    widget.onVolumeChanged(0.0);
                  } else {
                    final restore = _prevVolume > 0.0 ? _prevVolume : 1.0;
                    setState(() => _volume = restore);
                    widget.onVolumeChanged(restore);
                  }
                },
              ),
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
              SizedBox(
                width: 45,
                child: Text(
                  '${(_volume * 100).round()}%',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Alight Motion Style: Fade In / Fade Out Envelopes
          Row(
            children: [
              const Text('Fade Duration: ', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(width: 4),
              for (final dur in [250, 500, 1000, 2000])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text('${dur / 1000}s', style: const TextStyle(fontSize: 11)),
                    selected: _fadeDurationMs == dur,
                    selectedColor: AppTheme.primary,
                    onSelected: (_) {
                      setState(() => _fadeDurationMs = dur);
                      if (_hasFadeIn || _hasFadeOut) _applyFadeEnvelope();
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterChip(
                avatar: const Icon(Icons.trending_up, size: 16),
                label: const Text('Fade In'),
                selected: _hasFadeIn,
                selectedColor: AppTheme.primary.withOpacity(0.4),
                onSelected: (val) {
                  setState(() => _hasFadeIn = val);
                  _applyFadeEnvelope();
                },
              ),
              FilterChip(
                avatar: const Icon(Icons.trending_down, size: 16),
                label: const Text('Fade Out'),
                selected: _hasFadeOut,
                selectedColor: AppTheme.primary.withOpacity(0.4),
                onSelected: (val) {
                  setState(() => _hasFadeOut = val);
                  _applyFadeEnvelope();
                },
              ),
              if (widget.onExtractAudio != null)
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  icon: const Icon(Icons.call_split, size: 16),
                  label: const Text('Extract Audio', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    widget.onExtractAudio!();
                    widget.onClose();
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Audio Ducking Switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text('Auto Audio Ducking', style: TextStyle(fontSize: 13)),
            subtitle: const Text('Lowers volume under voiceover/dialogue tracks', style: TextStyle(fontSize: 11, color: Colors.white54)),
            value: _duckingEnabled,
            activeColor: AppTheme.primary,
            onChanged: (val) => setState(() => _duckingEnabled = val),
          ),
        ],
      ),
    );
  }
}
