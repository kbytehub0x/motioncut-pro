import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/state/preview_state.dart';

class PreviewControls extends StatelessWidget {
  final bool isPlaying;
  final bool showSafeAreas;
  final bool showGrid;
  final PreviewQuality quality;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onTogglePlay;
  final VoidCallback onStepBackward;
  final VoidCallback onStepForward;
  final VoidCallback onToggleSafeAreas;
  final VoidCallback onToggleGrid;
  final ValueChanged<PreviewQuality> onQualityChanged;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  const PreviewControls({
    super.key,
    required this.isPlaying,
    required this.showSafeAreas,
    required this.showGrid,
    required this.quality,
    required this.canUndo,
    required this.canRedo,
    required this.onTogglePlay,
    required this.onStepBackward,
    required this.onStepForward,
    required this.onToggleSafeAreas,
    required this.onToggleGrid,
    required this.onQualityChanged,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: AppTheme.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: History & overlays
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.undo, size: 20),
                color: canUndo ? Colors.white : Colors.white24,
                onPressed: canUndo ? onUndo : null,
                tooltip: 'Undo',
              ),
              IconButton(
                icon: const Icon(Icons.redo, size: 20),
                color: canRedo ? Colors.white : Colors.white24,
                onPressed: canRedo ? onRedo : null,
                tooltip: 'Redo',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.grid_3x3,
                  size: 20,
                  color: showGrid ? AppTheme.accent : Colors.white54,
                ),
                onPressed: onToggleGrid,
                tooltip: 'Toggle Grid',
              ),
              IconButton(
                icon: Icon(
                  Icons.crop_free,
                  size: 20,
                  color: showSafeAreas ? AppTheme.primary : Colors.white54,
                ),
                onPressed: onToggleSafeAreas,
                tooltip: 'Safe Area Overlay',
              ),
            ],
          ),

          // Center: Playback Transport
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 22),
                color: Colors.white70,
                onPressed: onStepBackward,
                tooltip: '-1 Frame',
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onTogglePlay,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 22),
                color: Colors.white70,
                onPressed: onStepForward,
                tooltip: '+1 Frame',
              ),
            ],
          ),

          // Right: Quality resolution selector
          PopupMenuButton<PreviewQuality>(
            initialValue: quality,
            tooltip: 'Preview Quality',
            onSelected: onQualityChanged,
            color: AppTheme.surfaceElevated,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    quality.label.split(' ').first,
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down, size: 14, color: AppTheme.accent),
                ],
              ),
            ),
            itemBuilder: (context) => [
              for (final q in PreviewQuality.values)
                PopupMenuItem(
                  value: q,
                  child: Text(
                    q.label,
                    style: TextStyle(
                      color: q == quality ? AppTheme.accent : Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
