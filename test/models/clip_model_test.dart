import 'package:flutter_test/flutter_test.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/models/keyframe_model.dart';
import 'package:motioncut_pro/models/effect_model.dart';

void main() {
  group('ClipModel Tests', () {
    test('ClipModel instantiation and calculated properties', () {
      const clip = ClipModel(
        id: 'clip_01',
        trackId: 'track_main',
        type: ClipType.video,
        name: 'test_video.mp4',
        sourcePath: '/path/to/video.mp4',
        startTimeMs: 1000,
        durationMs: 3000,
        sourceInMs: 500,
        sourceOutMs: 3500,
        speed: 1.0,
      );

      expect(clip.endTimeMs, 4000);
      expect(clip.sourceSpanMs, 3000);
      expect(clip.type, ClipType.video);
    });

    test('ClipModel serialization and deserialization (JSON round-trip)', () {
      final clip = ClipModel(
        id: 'clip_json',
        trackId: 'track_audio',
        type: ClipType.audio,
        name: 'beat.mp3',
        sourcePath: '/audio/beat.mp3',
        startTimeMs: 0,
        durationMs: 5000,
        sourceOutMs: 5000,
        volume: 0.8,
        volumeKeyframes: const [
          KeyframeModel(id: 'k1', timeMs: 0, value: 0.0),
          KeyframeModel(id: 'k2', timeMs: 500, value: 1.0),
        ],
        effects: const [
          EffectModel(
            id: 'fx1',
            type: EffectType.colorAdjust,
            name: 'LUT Grade',
            parameters: {'contrast': 1.2},
          ),
        ],
      );

      final jsonStr = clip.toJson();
      final decoded = ClipModel.fromJson(jsonStr);

      expect(decoded.id, clip.id);
      expect(decoded.type, ClipType.audio);
      expect(decoded.volume, 0.8);
      expect(decoded.volumeKeyframes.length, 2);
      expect(decoded.volumeKeyframes.first.timeMs, 0);
      expect(decoded.effects.length, 1);
      expect(decoded.effects.first.parameters['contrast'], 1.2);
    });

    test('ClipModel copyWith properly updates fields without mutating', () {
      const original = ClipModel(
        id: 'c1',
        trackId: 't1',
        type: ClipType.video,
        name: 'intro.mp4',
        sourcePath: '/videos/intro.mp4',
        startTimeMs: 0,
        durationMs: 4000,
        sourceOutMs: 4000,
        speed: 1.0,
      );

      final modified = original.copyWith(
        speed: 2.0,
        durationMs: 2000,
      );

      expect(original.speed, 1.0);
      expect(original.durationMs, 4000);
      expect(modified.speed, 2.0);
      expect(modified.durationMs, 2000);
      expect(modified.id, original.id);
    });
  });
}
