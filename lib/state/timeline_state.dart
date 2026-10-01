import 'package:motioncut_pro/core/constants.dart';

class TimelineState {
  final double pixelsPerSecond;
  final double scrollOffsetX;
  final bool isSnappingEnabled;
  final String? selectedTrackId;
  final String? selectedClipId;
  final bool isScrubbing;

  const TimelineState({
    this.pixelsPerSecond = AppConstants.defaultPixelsPerSecond,
    this.scrollOffsetX = 0.0,
    this.isSnappingEnabled = true,
    this.selectedTrackId,
    this.selectedClipId,
    this.isScrubbing = false,
  });

  TimelineState copyWith({
    double? pixelsPerSecond,
    double? scrollOffsetX,
    bool? isSnappingEnabled,
    String? selectedTrackId,
    String? selectedClipId,
    bool? isScrubbing,
    bool clearSelectedClip = false,
  }) {
    return TimelineState(
      pixelsPerSecond: pixelsPerSecond ?? this.pixelsPerSecond,
      scrollOffsetX: scrollOffsetX ?? this.scrollOffsetX,
      isSnappingEnabled: isSnappingEnabled ?? this.isSnappingEnabled,
      selectedTrackId: selectedTrackId ?? this.selectedTrackId,
      selectedClipId: clearSelectedClip ? null : (selectedClipId ?? this.selectedClipId),
      isScrubbing: isScrubbing ?? this.isScrubbing,
    );
  }
}
