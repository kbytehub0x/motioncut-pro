import 'package:motioncut_pro/core/constants.dart';
import 'package:motioncut_pro/models/project_model.dart';

class TimelineGestureHelper {
  /// Snaps a proposed millisecond position to nearby clip start/end markers
  static int applySnapping({
    required int targetMs,
    required ProjectModel project,
    int thresholdMs = AppConstants.snappingThresholdMs,
  }) {
    int closestDiff = thresholdMs + 1;
    int snappedTarget = targetMs;

    for (final track in project.tracks) {
      for (final clip in track.clips) {
        // Snap to start
        final diffStart = (clip.startTimeMs - targetMs).abs();
        if (diffStart < closestDiff) {
          closestDiff = diffStart;
          snappedTarget = clip.startTimeMs;
        }

        // Snap to end
        final diffEnd = (clip.endTimeMs - targetMs).abs();
        if (diffEnd < closestDiff) {
          closestDiff = diffEnd;
          snappedTarget = clip.endTimeMs;
        }
      }
    }

    if (closestDiff <= thresholdMs) {
      return snappedTarget;
    }
    return targetMs;
  }

  /// Calculates scaled pixels-per-second on pinch zoom gesture
  static double computeZoomScale({
    required double basePps,
    required double scaleFactor,
  }) {
    final newPps = basePps * scaleFactor;
    return newPps.clamp(
      AppConstants.minPixelsPerSecond,
      AppConstants.maxPixelsPerSecond,
    );
  }
}
