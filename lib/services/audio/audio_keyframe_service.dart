import 'dart:math';
import 'package:motioncut_pro/models/keyframe_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';

class AudioKeyframeService {
  /// Evaluates effective volume multiplier at a given time offset (in ms) relative to clip start
  static double evaluateVolumeAt(ClipModel clip, int localTimeMs) {
    if (clip.volumeKeyframes.isEmpty) {
      return clip.volume;
    }

    final keyframes = List<KeyframeModel>.from(clip.volumeKeyframes)
      ..sort((a, b) => a.timeMs.compareTo(b.timeMs));

    // Before first keyframe
    if (localTimeMs <= keyframes.first.timeMs) {
      return keyframes.first.value * clip.volume;
    }

    // After last keyframe
    if (localTimeMs >= keyframes.last.timeMs) {
      return keyframes.last.value * clip.volume;
    }

    // Find bounding keyframes
    KeyframeModel k1 = keyframes.first;
    KeyframeModel k2 = keyframes.last;

    for (int i = 0; i < keyframes.length - 1; i++) {
      if (localTimeMs >= keyframes[i].timeMs && localTimeMs <= keyframes[i + 1].timeMs) {
        k1 = keyframes[i];
        k2 = keyframes[i + 1];
        break;
      }
    }

    final duration = k2.timeMs - k1.timeMs;
    if (duration <= 0) return k1.value * clip.volume;

    final progress = (localTimeMs - k1.timeMs) / duration;
    final interpolatedT = _applyInterpolation(progress, k1.interpolation);
    final value = k1.value + (k2.value - k1.value) * interpolatedT;

    return (value * clip.volume).clamp(0.0, 2.0);
  }

  static double _applyInterpolation(double t, KeyframeInterpolation interpolation) {
    switch (interpolation) {
      case KeyframeInterpolation.linear:
        return t;
      case KeyframeInterpolation.easeIn:
        return t * t;
      case KeyframeInterpolation.easeOut:
        return sin(t * pi / 2);
      case KeyframeInterpolation.easeInOut:
        return (1 - cos(t * pi)) / 2;
      case KeyframeInterpolation.hold:
        return 0.0;
    }
  }

  /// Generates automatic fade-in and fade-out keyframes on a clip
  static List<KeyframeModel> generateFadeEnvelope({
    required int clipDurationMs,
    int fadeInMs = 500,
    int fadeOutMs = 500,
  }) {
    final clampedIn = fadeInMs.clamp(0, clipDurationMs ~/ 2);
    final clampedOut = fadeOutMs.clamp(0, clipDurationMs ~/ 2);

    return [
      KeyframeModel(
        id: 'fade_in_start',
        timeMs: 0,
        value: 0.0,
        interpolation: KeyframeInterpolation.easeIn,
      ),
      KeyframeModel(
        id: 'fade_in_end',
        timeMs: clampedIn,
        value: 1.0,
        interpolation: KeyframeInterpolation.linear,
      ),
      KeyframeModel(
        id: 'fade_out_start',
        timeMs: clipDurationMs - clampedOut,
        value: 1.0,
        interpolation: KeyframeInterpolation.easeOut,
      ),
      KeyframeModel(
        id: 'fade_out_end',
        timeMs: clipDurationMs,
        value: 0.0,
        interpolation: KeyframeInterpolation.linear,
      ),
    ];
  }
}
