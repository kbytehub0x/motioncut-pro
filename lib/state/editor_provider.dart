import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/models/effect_model.dart';
import 'package:motioncut_pro/core/di/di_setup.dart';
import 'package:motioncut_pro/core/constants.dart';
import 'package:motioncut_pro/state/editor_state.dart';
import 'package:motioncut_pro/state/timeline_state.dart';
import 'package:motioncut_pro/state/preview_state.dart';
import 'package:motioncut_pro/services/project/undo_redo_service.dart';

class EditorNotifier extends StateNotifier<EditorState> {
  final Ref ref;
  final UndoRedoService _undoRedo = UndoRedoService();
  Timer? _playbackTimer;

  EditorNotifier(this.ref, ProjectModel initialProject)
      : super(EditorState(project: initialProject));

  UndoRedoService get undoRedo => _undoRedo;

  bool get canUndo => _undoRedo.canUndo;
  bool get canRedo => _undoRedo.canRedo;

  /// Seeks the playhead to a target millisecond position
  void seek(int playheadMs) {
    final maxDur = state.project.totalDurationMs;
    final clamped = playheadMs.clamp(0, maxDur > 0 ? maxDur : 60000);
    state = state.copyWith(
      preview: state.preview.copyWith(playheadMs: clamped),
    );
  }

  /// Toggles playback simulation
  void togglePlay() {
    if (state.preview.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    _playbackTimer?.cancel();
    state = state.copyWith(preview: state.preview.copyWith(isPlaying: true));

    _playbackTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      final current = state.preview.playheadMs;
      final maxDur = state.project.totalDurationMs;
      if (current >= maxDur && maxDur > 0) {
        pause();
        seek(0);
        return;
      }
      seek(current + 33);
    });
  }

  void pause() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    state = state.copyWith(preview: state.preview.copyWith(isPlaying: false));
  }

  /// Sets timeline zoom (pixels per second)
  void setZoom(double pixelsPerSecond) {
    final clamped = pixelsPerSecond.clamp(
      AppConstants.minPixelsPerSecond,
      AppConstants.maxPixelsPerSecond,
    );
    state = state.copyWith(
      timeline: state.timeline.copyWith(pixelsPerSecond: clamped),
    );
  }

  /// Selects a clip on the timeline
  void selectClip(String? clipId, {String? trackId}) {
    if (clipId == null) {
      state = state.copyWith(
        timeline: state.timeline.copyWith(clearSelectedClip: true),
        activeTool: ActiveToolSheet.none,
      );
      return;
    }
    state = state.copyWith(
      timeline: state.timeline.copyWith(
        selectedClipId: clipId,
        selectedTrackId: trackId,
      ),
    );
  }

  /// Splits currently selected clip or the clip under playhead
  void splitClipAtPlayhead() {
    final playhead = state.preview.playheadMs;
    ClipModel? targetClip;

    if (state.timeline.selectedClipId != null) {
      targetClip = state.project.findClip(state.timeline.selectedClipId!);
    }

    if (targetClip == null) {
      // Find clip intersecting playhead on main video track
      for (final track in state.project.tracks) {
        for (final clip in track.clips) {
          if (playhead > clip.startTimeMs && playhead < clip.endTimeMs) {
            targetClip = clip;
            break;
          }
        }
        if (targetClip != null) break;
      }
    }

    if (targetClip == null) return;
    if (playhead <= targetClip.startTimeMs || playhead >= targetClip.endTimeMs) return;

    final cmd = SplitClipCommand(
      clipId: targetClip.id,
      splitTimelineMs: playhead,
    );

    final updatedProject = _undoRedo.execute(cmd, state.project);
    state = state.copyWith(project: updatedProject, isDirty: true);
  }

  /// Deletes currently selected clip
  void deleteSelectedClip() {
    final clipId = state.timeline.selectedClipId;
    if (clipId == null) return;

    final cmd = DeleteClipCommand(clipId: clipId);
    final updatedProject = _undoRedo.execute(cmd, state.project);

    state = state.copyWith(
      project: updatedProject,
      timeline: state.timeline.copyWith(clearSelectedClip: true),
      activeTool: ActiveToolSheet.none,
      isDirty: true,
    );
  }

  /// Modifies clip duration / in / out for trimming
  void trimClip({
    required String clipId,
    required int newStartTimeMs,
    required int newDurationMs,
    required int newSourceInMs,
    required int newSourceOutMs,
  }) {
    final updatedTracks = state.project.tracks.map((track) {
      final idx = track.clips.indexWhere((c) => c.id == clipId);
      if (idx == -1) return track;

      final updatedClips = List<ClipModel>.from(track.clips);
      updatedClips[idx] = updatedClips[idx].copyWith(
        startTimeMs: newStartTimeMs,
        durationMs: newDurationMs,
        sourceInMs: newSourceInMs,
        sourceOutMs: newSourceOutMs,
      );
      return track.copyWith(clips: updatedClips);
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks, updatedAt: DateTime.now()),
      isDirty: true,
    );
  }

  /// Sets clip playback speed
  void setClipSpeed(String clipId, double speed) {
    final updatedTracks = state.project.tracks.map((track) {
      final idx = track.clips.indexWhere((c) => c.id == clipId);
      if (idx == -1) return track;

      final oldClip = track.clips[idx];
      final newDurationMs = (oldClip.sourceSpanMs / speed).round();

      final updatedClips = List<ClipModel>.from(track.clips);
      updatedClips[idx] = oldClip.copyWith(
        speed: speed,
        durationMs: newDurationMs,
      );
      return track.copyWith(clips: updatedClips);
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks, updatedAt: DateTime.now()),
      isDirty: true,
    );
  }

  /// Adds a clip to the active project and updates state reactively
  void addClip(ClipModel clip) {
    bool trackFound = false;
    final updatedTracks = state.project.tracks.map((track) {
      if (track.id == clip.trackId) {
        trackFound = true;
        return track.copyWith(clips: [...track.clips, clip]);
      }
      return track;
    }).toList();

    if (!trackFound) {
      final targetType = clip.type == ClipType.audio
          ? TrackType.audio
          : (clip.type == ClipType.text ? TrackType.text : TrackType.mainVideo);
      final idx = updatedTracks.indexWhere((t) => t.type == targetType);
      if (idx != -1) {
        final targetTrack = updatedTracks[idx];
        updatedTracks[idx] = targetTrack.copyWith(
          clips: [...targetTrack.clips, clip.copyWith(trackId: targetTrack.id)],
        );
      }
    }

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks, updatedAt: DateTime.now()),
      isDirty: true,
    );
  }

  /// Extracts the audio stream from a video clip onto the dedicated audio track (Alight Motion feature)
  void extractAudioFromClip(String clipId) {
    final clip = state.project.findClip(clipId);
    if (clip == null || clip.type != ClipType.video) return;

    final audioTrack = state.project.tracks.firstWhere(
      (t) => t.type == TrackType.audio,
      orElse: () => state.project.tracks.first,
    );

    final extractedAudio = ClipModel(
      id: 'audio_extract_${DateTime.now().millisecondsSinceEpoch}',
      trackId: audioTrack.id,
      type: ClipType.audio,
      name: '${clip.name} (Audio)',
      sourcePath: clip.sourcePath,
      startTimeMs: clip.startTimeMs,
      durationMs: clip.durationMs,
      sourceInMs: clip.sourceInMs,
      sourceOutMs: clip.sourceOutMs,
      volume: clip.volume,
    );

    // Mute original video clip audio to prevent duplicate audio playback
    setClipVolume(clipId, 0.0);
    addClip(extractedAudio);
    selectClip(extractedAudio.id, trackId: audioTrack.id);
  }

  /// Sets clip volume
  void setClipVolume(String clipId, double volume) {
    final updatedTracks = state.project.tracks.map((track) {
      final idx = track.clips.indexWhere((c) => c.id == clipId);
      if (idx == -1) return track;

      final updatedClips = List<ClipModel>.from(track.clips);
      updatedClips[idx] = updatedClips[idx].copyWith(volume: volume);
      return track.copyWith(clips: updatedClips);
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks),
      isDirty: true,
    );
  }

  /// Sets volume keyframes on a clip (for Fade In, Fade Out, and Alight Motion envelopes)
  void setClipVolumeKeyframes(String clipId, List<KeyframeModel> keyframes) {
    final updatedTracks = state.project.tracks.map((track) {
      final idx = track.clips.indexWhere((c) => c.id == clipId);
      if (idx == -1) return track;

      final updatedClips = List<ClipModel>.from(track.clips);
      updatedClips[idx] = updatedClips[idx].copyWith(volumeKeyframes: keyframes);
      return track.copyWith(clips: updatedClips);
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks, updatedAt: DateTime.now()),
      isDirty: true,
    );
  }

  /// Adjusts color grade parameters for a clip
  void updateClipColor({
    required String clipId,
    required double brightness,
    required double contrast,
    required double saturation,
  }) {
    final updatedTracks = state.project.tracks.map((track) {
      final idx = track.clips.indexWhere((c) => c.id == clipId);
      if (idx == -1) return track;

      final clip = track.clips[idx];
      final effects = List<EffectModel>.from(clip.effects);
      final effIdx = effects.indexWhere((e) => e.type == EffectType.colorAdjust);

      final colorEff = EffectModel(
        id: effIdx != -1 ? effects[effIdx].id : 'color_fx_${clip.id}',
        type: EffectType.colorAdjust,
        name: 'Color Adjustment',
        parameters: {
          'brightness': brightness,
          'contrast': contrast,
          'saturation': saturation,
        },
      );

      if (effIdx != -1) {
        effects[effIdx] = colorEff;
      } else {
        effects.add(colorEff);
      }

      final updatedClips = List<ClipModel>.from(track.clips);
      updatedClips[idx] = clip.copyWith(effects: effects);
      return track.copyWith(clips: updatedClips);
    }).toList();

    state = state.copyWith(
      project: state.project.copyWith(tracks: updatedTracks),
      isDirty: true,
    );
  }

  /// Reversible Undo
  void undo() {
    if (!_undoRedo.canUndo) return;
    final revertedProject = _undoRedo.undo(state.project);
    state = state.copyWith(project: revertedProject, isDirty: true);
  }

  /// Reversible Redo
  void redo() {
    if (!_undoRedo.canRedo) return;
    final updatedProject = _undoRedo.redo(state.project);
    state = state.copyWith(project: updatedProject, isDirty: true);
  }

  /// Saves current project to local storage
  Future<void> saveProject() async {
    final pm = ref.read(projectManagerServiceProvider);
    await pm.saveProject(state.project);
    state = state.copyWith(isDirty: false);
  }

  void openTool(ActiveToolSheet tool) {
    state = state.copyWith(activeTool: tool);
  }

  void closeTool() {
    state = state.copyWith(activeTool: ActiveToolSheet.none);
  }

  void toggleSafeAreas() {
    state = state.copyWith(
      preview: state.preview.copyWith(showSafeAreas: !state.preview.showSafeAreas),
    );
  }

  void toggleGrid() {
    state = state.copyWith(
      preview: state.preview.copyWith(showGrid: !state.preview.showGrid),
    );
  }

  void setPreviewQuality(PreviewQuality quality) {
    state = state.copyWith(
      preview: state.preview.copyWith(quality: quality),
    );
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}

final editorProviderFamily = StateNotifierProvider.family<EditorNotifier, EditorState, ProjectModel>(
  (ref, project) => EditorNotifier(ref, project),
);
