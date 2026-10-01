import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:uuid/uuid.dart';

abstract class EditorCommand {
  String get title;
  ProjectModel execute(ProjectModel current);
  ProjectModel undo(ProjectModel current);
}

/// Concrete Command: Splits a clip at playhead time into two adjacent clips
class SplitClipCommand implements EditorCommand {
  final String clipId;
  final int splitTimelineMs;
  late final String _newClipId;

  SplitClipCommand({
    required this.clipId,
    required this.splitTimelineMs,
  }) {
    _newClipId = const Uuid().v4();
  }

  @override
  String get title => 'Split Clip';

  @override
  ProjectModel execute(ProjectModel current) {
    final updatedTracks = <TrackModel>[];

    for (final track in current.tracks) {
      final clipIdx = track.clips.indexWhere((c) => c.id == clipId);
      if (clipIdx == -1) {
        updatedTracks.add(track);
        continue;
      }

      final targetClip = track.clips[clipIdx];
      // Validate split position lies strictly within clip bounds
      if (splitTimelineMs <= targetClip.startTimeMs ||
          splitTimelineMs >= targetClip.endTimeMs) {
        updatedTracks.add(track);
        continue;
      }

      final splitDeltaMs = splitTimelineMs - targetClip.startTimeMs;
      final sourceSplitMs = targetClip.sourceInMs + (splitDeltaMs * targetClip.speed).round();

      // First half (original modified)
      final firstHalf = targetClip.copyWith(
        durationMs: splitDeltaMs,
        sourceOutMs: sourceSplitMs,
      );

      // Second half (new clip)
      final secondHalf = targetClip.copyWith(
        id: _newClipId,
        startTimeMs: splitTimelineMs,
        durationMs: targetClip.durationMs - splitDeltaMs,
        sourceInMs: sourceSplitMs,
        sourceOutMs: targetClip.sourceOutMs,
      );

      final newClips = List<ClipModel>.from(track.clips);
      newClips[clipIdx] = firstHalf;
      newClips.insert(clipIdx + 1, secondHalf);

      updatedTracks.add(track.copyWith(clips: newClips));
    }

    return current.copyWith(
      tracks: updatedTracks,
      updatedAt: DateTime.now(),
    );
  }

  @override
  ProjectModel undo(ProjectModel current) {
    final updatedTracks = <TrackModel>[];

    for (final track in current.tracks) {
      final firstIdx = track.clips.indexWhere((c) => c.id == clipId);
      final secondIdx = track.clips.indexWhere((c) => c.id == _newClipId);

      if (firstIdx == -1 || secondIdx == -1) {
        updatedTracks.add(track);
        continue;
      }

      final firstClip = track.clips[firstIdx];
      final secondClip = track.clips[secondIdx];

      // Merge back into original span
      final merged = firstClip.copyWith(
        durationMs: firstClip.durationMs + secondClip.durationMs,
        sourceOutMs: secondClip.sourceOutMs,
      );

      final newClips = List<ClipModel>.from(track.clips);
      newClips[firstIdx] = merged;
      newClips.removeAt(secondIdx);

      updatedTracks.add(track.copyWith(clips: newClips));
    }

    return current.copyWith(
      tracks: updatedTracks,
      updatedAt: DateTime.now(),
    );
  }
}

/// Concrete Command: Delete Clip (with ripple or fixed gap option)
class DeleteClipCommand implements EditorCommand {
  final String clipId;
  ClipModel? _deletedClip;
  String? _trackId;
  int? _originalIndex;

  DeleteClipCommand({required this.clipId});

  @override
  String get title => 'Delete Clip';

  @override
  ProjectModel execute(ProjectModel current) {
    final updatedTracks = <TrackModel>[];

    for (final track in current.tracks) {
      final idx = track.clips.indexWhere((c) => c.id == clipId);
      if (idx != -1) {
        _deletedClip = track.clips[idx];
        _trackId = track.id;
        _originalIndex = idx;
        final newClips = List<ClipModel>.from(track.clips)..removeAt(idx);
        updatedTracks.add(track.copyWith(clips: newClips));
      } else {
        updatedTracks.add(track);
      }
    }

    return current.copyWith(tracks: updatedTracks, updatedAt: DateTime.now());
  }

  @override
  ProjectModel undo(ProjectModel current) {
    if (_deletedClip == null || _trackId == null || _originalIndex == null) {
      return current;
    }

    final updatedTracks = <TrackModel>[];
    for (final track in current.tracks) {
      if (track.id == _trackId) {
        final newClips = List<ClipModel>.from(track.clips);
        final safeIdx = _originalIndex!.clamp(0, newClips.length);
        newClips.insert(safeIdx, _deletedClip!);
        updatedTracks.add(track.copyWith(clips: newClips));
      } else {
        updatedTracks.add(track);
      }
    }

    return current.copyWith(tracks: updatedTracks, updatedAt: DateTime.now());
  }
}

/// Robust multi-step Undo/Redo stack manager
class UndoRedoService {
  final List<EditorCommand> _undoStack = [];
  final List<EditorCommand> _redoStack = [];
  final int maxHistory;

  UndoRedoService({this.maxHistory = 50});

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  int get undoCount => _undoStack.length;
  int get redoCount => _redoStack.length;

  ProjectModel execute(EditorCommand command, ProjectModel current) {
    final updated = command.execute(current);
    _undoStack.add(command);
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    return updated;
  }

  ProjectModel undo(ProjectModel current) {
    if (!canUndo) return current;
    final cmd = _undoStack.removeLast();
    final updated = cmd.undo(current);
    _redoStack.add(cmd);
    return updated;
  }

  ProjectModel redo(ProjectModel current) {
    if (!canRedo) return current;
    final cmd = _redoStack.removeLast();
    final updated = cmd.execute(current);
    _undoStack.add(cmd);
    return updated;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}
