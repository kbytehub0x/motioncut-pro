import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/core/utils/time_utils.dart';

class TimelineClipView extends StatelessWidget {
  final ClipModel clip;
  final double pixelsPerSecond;
  final bool isSelected;
  final VoidCallback onSelect;
  final Function(int startMs, int durationMs)? onTrimUpdate;

  const TimelineClipView({
    super.key,
    required this.clip,
    required this.pixelsPerSecond,
    required this.isSelected,
    required this.onSelect,
    this.onTrimUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final left = TimeUtils.millisecondsToPixels(clip.startTimeMs, pixelsPerSecond);
    final width = TimeUtils.millisecondsToPixels(clip.durationMs, pixelsPerSecond).clamp(24.0, 99999.0);

    Color clipColor;
    IconData clipIcon;

    switch (clip.type) {
      case ClipType.video:
        clipColor = AppTheme.videoClipColor;
        clipIcon = Icons.videocam;
        break;
      case ClipType.audio:
        clipColor = AppTheme.audioClipColor;
        clipIcon = Icons.music_note;
        break;
      case ClipType.text:
        clipColor = AppTheme.textClipColor;
        clipIcon = Icons.title;
        break;
      case ClipType.image:
        clipColor = AppTheme.overlayClipColor;
        clipIcon = Icons.image;
        break;
    }

    return Positioned(
      left: left,
      width: width,
      top: 4,
      bottom: 4,
      child: GestureDetector(
        onTap: onSelect,
        child: Container(
          decoration: BoxDecoration(
            color: clipColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white12,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Waveform background for audio clips
              if (clip.type == ClipType.audio) _buildWaveformBackground(width),

              // Clip Content Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Icon(clipIcon, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        clip.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (clip.speed != 1.0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '${clip.speed}x',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Trim Handles when selected
              if (isSelected) ...[
                // Left trim handle
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 12,
                  child: Container(
                    color: Colors.white.withOpacity(0.35),
                    child: const Center(
                      child: Icon(Icons.drag_indicator, size: 10, color: Colors.white),
                    ),
                  ),
                ),
                // Right trim handle
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 12,
                  child: Container(
                    color: Colors.white.withOpacity(0.35),
                    child: const Center(
                      child: Icon(Icons.drag_indicator, size: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveformBackground(double width) {
    // Generate mini audio bars across width
    final barCount = (width / 5).clamp(8, 200).toInt();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(barCount, (i) {
            // Realistic height pattern
            final height = (12 + (i % 5) * 2.2 + ((i * 7) % 8)).clamp(4.0, 22.0);
            return Container(
              width: 2.0,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        ),
      ),
    );
  }
}
