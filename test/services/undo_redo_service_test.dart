import 'package:flutter_test/flutter_test.dart';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/services/project/undo_redo_service.dart';

void main() {
  group('UndoRedoService Tests', () {
    late ProjectModel initialProject;
    late UndoRedoService undoRedo;

    setUp(() {
      undoRedo = UndoRedoService();
      const clip = ClipModel(
        id: 'clip_original',
        trackId: 'track_1',
        type: ClipType.video,
        name: 'clip.mp4',
        sourcePath: '/path/video.mp4',
        startTimeMs: 0,
        durationMs: 4000,
        sourceInMs: 0,
        sourceOutMs: 4000,
      );

      initialProject = ProjectModel(
        id: 'proj_test',
        title: 'Undo Redo Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tracks: const [
          TrackModel(
            id: 'track_1',
            name: 'Main Video',
            type: TrackType.mainVideo,
            order: 0,
            clips: [clip],
          ),
        ],
      );
    });

    test('SplitClipCommand divides clip and can be undone and redone', () {
      expect(initialProject.tracks.first.clips.length, 1);

      // Execute Split at 1500ms
      final splitCmd = SplitClipCommand(
        clipId: 'clip_original',
        splitTimelineMs: 1500,
      );

      final splitProject = undoRedo.execute(splitCmd, initialProject);
      final clipsAfterSplit = splitProject.tracks.first.clips;

      expect(clipsAfterSplit.length, 2);
      expect(clipsAfterSplit[0].durationMs, 1500);
      expect(clipsAfterSplit[0].sourceOutMs, 1500);
      expect(clipsAfterSplit[1].startTimeMs, 1500);
      expect(clipsAfterSplit[1].durationMs, 2500);

      expect(undoRedo.canUndo, true);
      expect(undoRedo.canRedo, false);

      // Undo the split
      final undoneProject = undoRedo.undo(splitProject);
      final clipsAfterUndo = undoneProject.tracks.first.clips;

      expect(clipsAfterUndo.length, 1);
      expect(clipsAfterUndo[0].id, 'clip_original');
      expect(clipsAfterUndo[0].durationMs, 4000);
      expect(undoRedo.canRedo, true);

      // Redo the split
      final redoneProject = undoRedo.redo(undoneProject);
      expect(redoneProject.tracks.first.clips.length, 2);
    });

    test('DeleteClipCommand removes clip and can be cleanly restored via undo', () {
      final deleteCmd = DeleteClipCommand(clipId: 'clip_original');
      final deletedProject = undoRedo.execute(deleteCmd, initialProject);

      expect(deletedProject.tracks.first.clips.isEmpty, true);

      // Undo delete
      final restoredProject = undoRedo.undo(deletedProject);
      expect(restoredProject.tracks.first.clips.length, 1);
      expect(restoredProject.tracks.first.clips.first.id, 'clip_original');
    });
  });
}
