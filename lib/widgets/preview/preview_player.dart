import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/models/effect_model.dart';
import 'package:motioncut_pro/state/preview_state.dart';
import 'package:motioncut_pro/widgets/preview/preview_overlay.dart';
import 'package:motioncut_pro/widgets/preview/preview_controls.dart';
import 'package:motioncut_pro/widgets/common/scrubber.dart';

class PreviewPlayer extends StatelessWidget {
  final ProjectModel project;
  final PreviewState previewState;
  final bool canUndo;
  final bool canRedo;
  final ValueChanged<int> onSeek;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleSafeAreas;
  final VoidCallback onToggleGrid;
  final ValueChanged<PreviewQuality> onQualityChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const PreviewPlayer({
    super.key,
    required this.project,
    required this.previewState,
    required this.canUndo,
    required this.canRedo,
    required this.onSeek,
    required this.onTogglePlay,
    required this.onToggleSafeAreas,
    required this.onToggleGrid,
    required this.onQualityChanged,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    final playhead = previewState.playheadMs;

    // Find active clips across tracks at playhead
    ClipModel? activeMainVideo;
    ClipModel? activeOverlay;
    ClipModel? activeText;

    for (final track in project.tracks) {
      if (!track.isVisible) continue;
      for (final clip in track.clips) {
        if (playhead >= clip.startTimeMs && playhead <= clip.endTimeMs) {
          if (track.type == TrackType.mainVideo && activeMainVideo == null) {
            activeMainVideo = clip;
          } else if (track.type == TrackType.overlayVideo && activeOverlay == null) {
            activeOverlay = clip;
          } else if (track.type == TrackType.text && activeText == null) {
            activeText = clip;
          }
        }
      }
    }

    return Container(
      color: AppTheme.background,
      child: Column(
        children: [
          // Main Preview Viewport
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: project.aspectRatio.ratio,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Video Base Frame Layer
                      _buildVideoCanvas(activeMainVideo),

                      // Overlay / B-Roll Layer (with blend mode & opacity)
                      if (activeOverlay != null) _buildOverlayCanvas(activeOverlay),

                      // Animated Text / Subtitle Layer
                      if (activeText != null) _buildTextCanvas(activeText),

                      // Safe Area & Grid Overlays
                      PreviewOverlay(
                        showSafeAreas: previewState.showSafeAreas,
                        showGrid: previewState.showGrid,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Mini Scrubber
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Scrubber(
              currentMs: previewState.playheadMs,
              totalMs: project.totalDurationMs,
              onSeek: onSeek,
            ),
          ),

          // Transport & Control Bar
          PreviewControls(
            isPlaying: previewState.isPlaying,
            showSafeAreas: previewState.showSafeAreas,
            showGrid: previewState.showGrid,
            quality: previewState.quality,
            canUndo: canUndo,
            canRedo: canRedo,
            onTogglePlay: onTogglePlay,
            onStepBackward: () => onSeek(previewState.playheadMs - 33),
            onStepForward: () => onSeek(previewState.playheadMs + 33),
            onToggleSafeAreas: onToggleSafeAreas,
            onToggleGrid: onToggleGrid,
            onQualityChanged: onQualityChanged,
            onUndo: onUndo,
            onRedo: onRedo,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCanvas(ClipModel? clip) {
    if (clip == null) {
      return Container(
        color: const Color(0xFF0A0A0D),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.movie_creation_outlined, color: Colors.white24, size: 36),
              SizedBox(height: 6),
              Text(
                'No Media at Playhead',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Color grading simulation
    double brightness = 0.0;
    double contrast = 1.0;
    double saturation = 1.0;

    for (final eff in clip.effects) {
      if (eff.type == EffectType.colorAdjust && eff.isEnabled) {
        brightness = (eff.parameters['brightness'] as num?)?.toDouble() ?? 0.0;
        contrast = (eff.parameters['contrast'] as num?)?.toDouble() ?? 1.0;
        saturation = (eff.parameters['saturation'] as num?)?.toDouble() ?? 1.0;
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF1E2638), Colors.white, brightness.clamp(0, 0.5))!,
            Color.lerp(const Color(0xFF0F172A), Colors.black, contrast > 1 ? 0.3 : 0.0)!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                clip.name,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Speed: ${clip.speed}x  ·  Sat: ${saturation.toStringAsFixed(1)}',
              style: const TextStyle(color: AppTheme.accent, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayCanvas(ClipModel clip) {
    return Opacity(
      opacity: clip.opacity.clamp(0.0, 1.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.18),
          border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 1),
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'PIP: ${clip.name}',
              style: const TextStyle(color: AppTheme.accent, fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextCanvas(ClipModel clip) {
    final text = clip.textContent ?? 'TITLE';
    final color = clip.textColorValue != null
        ? Color(clip.textColorValue!)
        : Colors.white;
    final fontSize = clip.fontSize ?? 26.0;

    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 8,
              offset: const Offset(1, 2),
            ),
          ],
        ),
      ),
    );
  }
}
