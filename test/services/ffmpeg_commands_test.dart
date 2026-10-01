import 'package:flutter_test/flutter_test.dart';
import 'package:motioncut_pro/services/ffmpeg/ffmpeg_commands.dart';
import 'package:motioncut_pro/services/ffmpeg/ffmpeg_progress_parser.dart';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';

void main() {
  group('FfmpegCommands Tests', () {
    test('buildTrimCommand generates valid FFmpeg arguments', () {
      final cmd = FfmpegCommands.buildTrimCommand(
        inputPath: '/storage/video.mp4',
        startMs: 1500,
        durationMs: 3000,
        outputPath: '/storage/trimmed.mp4',
        frameAccurate: true,
      );

      expect(cmd, contains('-ss'));
      expect(cmd, contains('1.500'));
      expect(cmd, contains('-t'));
      expect(cmd, contains('3.000'));
      expect(cmd, contains('/storage/trimmed.mp4'));
    });

    test('buildSpeedCommand builds filter_complex for slow-motion and audio atempo', () {
      final cmd = FfmpegCommands.buildSpeedCommand(
        inputPath: '/storage/raw.mp4',
        speedMultiplier: 0.5,
        outputPath: '/storage/slowmo.mp4',
      );

      expect(cmd, contains('-filter_complex'));
      final filterArg = cmd[cmd.indexOf('-filter_complex') + 1];
      expect(filterArg, contains('setpts=2.0000*PTS'));
      expect(filterArg, contains('atempo=0.500'));
    });

    test('buildRenderProjectCommand generates master composition pipeline', () {
      const clip = ClipModel(
        id: 'c1',
        trackId: 't1',
        type: ClipType.video,
        name: 'sample.mp4',
        sourcePath: '/videos/sample.mp4',
        startTimeMs: 0,
        durationMs: 5000,
        sourceOutMs: 5000,
      );

      final project = ProjectModel(
        id: 'p1',
        title: 'Test Render',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tracks: const [
          TrackModel(id: 't1', name: 'Main', type: TrackType.mainVideo, order: 0, clips: [clip]),
        ],
      );

      final cmd = FfmpegCommands.buildRenderProjectCommand(
        project: project,
        outputPath: '/exports/final.mp4',
      );

      expect(cmd, contains('-i'));
      expect(cmd, contains('/videos/sample.mp4'));
      expect(cmd, contains('-filter_complex'));
      expect(cmd, contains('/exports/final.mp4'));
    });
  });

  group('FfmpegProgressParser Tests', () {
    test('FfmpegProgressParser parses time and computes percentage', () {
      final parser = FfmpegProgressParser(totalDurationMs: 10000);

      parser.parseLine('frame=120');
      parser.parseLine('fps=30.0');
      final progress = parser.parseLine('out_time_ms=5000');

      expect(progress.currentFrame, 120);
      expect(progress.fps, 30.0);
      expect(progress.percentage, 0.5);
      expect(progress.isCompleted, false);

      final completed = parser.parseLine('progress=end');
      expect(completed.percentage, 1.0);
      expect(completed.isCompleted, true);
    });
  });
}
