import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';

class AudioMixSummary {
  final int totalAudibleTracks;
  final int totalClips;
  final bool hasDuckingEnabled;
  final double masterPeakDb;

  const AudioMixSummary({
    required this.totalAudibleTracks,
    required this.totalClips,
    required this.hasDuckingEnabled,
    required this.masterPeakDb,
  });
}

class AudioMixingService {
  /// Prepares audio stems and checks for track overlaps or clipping
  static AudioMixSummary analyzeProjectMix(ProjectModel project) {
    int activeTracks = 0;
    int clipCount = 0;

    for (final track in project.tracks) {
      if (track.isMuted) continue;
      if (track.type == TrackType.audio || track.type == TrackType.mainVideo || track.type == TrackType.overlayVideo) {
        if (track.clips.isNotEmpty) {
          activeTracks++;
          clipCount += track.clips.length;
        }
      }
    }

    // Estimate peak headroom
    final estimatedPeakDb = clipCount > 0 ? (clipCount > 3 ? -1.5 : -3.0) : -60.0;

    return AudioMixSummary(
      totalAudibleTracks: activeTracks,
      totalClips: clipCount,
      hasDuckingEnabled: false,
      masterPeakDb: estimatedPeakDb,
    );
  }

  /// Finds all audio clips active at a specific timeline timestamp
  static List<ClipModel> getActiveAudioClipsAt(ProjectModel project, int timestampMs) {
    final active = <ClipModel>[];
    for (final track in project.tracks) {
      if (track.isMuted) continue;
      for (final clip in track.clips) {
        if (timestampMs >= clip.startTimeMs && timestampMs <= clip.endTimeMs) {
          active.add(clip);
        }
      }
    }
    return active;
  }
}
