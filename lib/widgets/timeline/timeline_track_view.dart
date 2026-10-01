import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/core/constants.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/widgets/timeline/timeline_clip_view.dart';

class TimelineTrackView extends StatelessWidget {
  final TrackModel track;
  final double pixelsPerSecond;
  final String? selectedClipId;
  final Function(String clipId) onSelectClip;

  const TimelineTrackView({
    super.key,
    required this.track,
    required this.pixelsPerSecond,
    required this.selectedClipId,
    required this.onSelectClip,
  });

  @override
  Widget build(BuildContext context) {
    double trackHeight = AppConstants.trackHeightVideo;
    if (track.type == TrackType.audio) {
      trackHeight = AppConstants.trackHeightAudio;
    } else if (track.type == TrackType.text) {
      trackHeight = AppConstants.trackHeightText;
    }

    return Container(
      height: trackHeight,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: AppTheme.divider.withOpacity(0.5)),
        ),
      ),
      child: Stack(
        children: [
          // Clips Stack
          for (final clip in track.clips)
            TimelineClipView(
              clip: clip,
              pixelsPerSecond: pixelsPerSecond,
              isSelected: clip.id == selectedClipId,
              onSelect: () => onSelectClip(clip.id),
            ),
        ],
      ),
    );
  }
}
