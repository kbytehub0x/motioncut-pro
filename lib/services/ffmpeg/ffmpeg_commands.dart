import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/models/export_profile_model.dart';
import 'package:motioncut_pro/models/effect_model.dart';

class FfmpegCommands {
  /// Builds standard fast trim command using stream copy when possible, or re-encode for frame-accuracy
  static List<String> buildTrimCommand({
    required String inputPath,
    required int startMs,
    required int durationMs,
    required String outputPath,
    bool frameAccurate = true,
  }) {
    final startSec = (startMs / 1000.0).toStringAsFixed(3);
    final durationSec = (durationMs / 1000.0).toStringAsFixed(3);

    if (frameAccurate) {
      return [
        '-y',
        '-ss', startSec,
        '-t', durationSec,
        '-i', inputPath,
        '-c:v', 'libx264',
        '-preset', 'veryfast',
        '-c:a', 'aac',
        outputPath,
      ];
    } else {
      return [
        '-y',
        '-ss', startSec,
        '-i', inputPath,
        '-t', durationSec,
        '-c', 'copy',
        outputPath,
      ];
    }
  }

  /// Builds split command producing two output files
  static List<List<String>> buildSplitCommands({
    required String inputPath,
    required int splitPointMs,
    required int totalDurationMs,
    required String part1Path,
    required String part2Path,
  }) {
    final cmd1 = buildTrimCommand(
      inputPath: inputPath,
      startMs: 0,
      durationMs: splitPointMs,
      outputPath: part1Path,
    );
    final cmd2 = buildTrimCommand(
      inputPath: inputPath,
      startMs: splitPointMs,
      durationMs: totalDurationMs - splitPointMs,
      outputPath: part2Path,
    );
    return [cmd1, cmd2];
  }

  /// Builds speed modification filter with video setpts and audio atempo
  static List<String> buildSpeedCommand({
    required String inputPath,
    required double speedMultiplier,
    required String outputPath,
  }) {
    final clampedSpeed = speedMultiplier.clamp(0.1, 10.0);
    final videoPts = (1.0 / clampedSpeed).toStringAsFixed(4);

    // Audio atempo only accepts 0.5 to 2.0 per filter instance, so chain if needed
    final audioFilter = _buildAtempoChain(clampedSpeed);

    return [
      '-y',
      '-i', inputPath,
      '-filter_complex', '[0:v]setpts=${videoPts}*PTS[v];[0:a]$audioFilter[a]',
      '-map', '[v]',
      '-map', '[a]',
      '-c:v', 'libx264',
      '-preset', 'veryfast',
      '-c:a', 'aac',
      outputPath,
    ];
  }

  /// Helper to chain atempo filters for speeds outside [0.5, 2.0]
  static String _buildAtempoChain(double speed) {
    if (speed >= 0.5 && speed <= 2.0) {
      return 'atempo=${speed.toStringAsFixed(3)}';
    }
    final buffer = StringBuffer();
    double current = speed;
    bool first = true;
    while (current > 2.0) {
      if (!first) buffer.write(',');
      buffer.write('atempo=2.0');
      current /= 2.0;
      first = false;
    }
    while (current < 0.5) {
      if (!first) buffer.write(',');
      buffer.write('atempo=0.5');
      current /= 0.5;
      first = false;
    }
    if (!first) buffer.write(',');
    buffer.write('atempo=${current.toStringAsFixed(3)}');
    return buffer.toString();
  }

  /// Generates the master multi-track filter graph and command for the whole project export
  static List<String> buildRenderProjectCommand({
    required ProjectModel project,
    required String outputPath,
  }) {
    final inputs = <String>[];
    final inputIndices = <String, int>{}; // clipId -> input index
    final filterSegments = <String>[];
    final profile = project.exportProfile;
    final targetW = profile.resolution.width;
    final targetH = profile.resolution.height;

    // 1. Gather all unique clip media inputs
    int currentIndex = 0;
    for (final track in project.tracks) {
      if (!track.isVisible) continue;
      for (final clip in track.clips) {
        if (clip.sourcePath.isNotEmpty && !inputs.contains(clip.sourcePath)) {
          inputs.add(clip.sourcePath);
          inputIndices[clip.id] = currentIndex;
          currentIndex++;
        } else if (inputs.contains(clip.sourcePath)) {
          inputIndices[clip.id] = inputs.indexOf(clip.sourcePath);
        }
      }
    }

    // Fallback if project is completely empty
    if (inputs.isEmpty) {
      return [
        '-y',
        '-f', 'lavfi',
        '-i', 'color=c=black:s=${targetW}x${targetH}:d=5',
        '-f', 'lavfi',
        '-i', 'anullsrc=channel_layout=stereo:sample_rate=44100',
        '-t', '5',
        '-c:v', 'libx264',
        outputPath,
      ];
    }

    final cmd = <String>['-y'];

    // Add inputs
    for (final path in inputs) {
      cmd.addAll(['-i', path]);
    }

    // 2. Build Filter Complex
    final videoTracks = project.tracks.where((t) => t.isVisible && t.type != TrackType.audio).toList();
    final audioTracks = project.tracks.where((t) => !t.isMuted).toList();

    // Base background canvas
    filterSegments.add('color=c=black:s=${targetW}x${targetH}:d=${(project.totalDurationMs / 1000.0).toStringAsFixed(2)}[base_bg]');
    String currentBase = '[base_bg]';

    int vSegIndex = 0;
    for (final track in videoTracks) {
      for (final clip in track.clips) {
        final inIdx = inputIndices[clip.id];
        if (inIdx == null) continue;

        final trimStart = (clip.sourceInMs / 1000.0).toStringAsFixed(3);
        final trimDur = ((clip.sourceOutMs - clip.sourceInMs) / 1000.0).toStringAsFixed(3);
        final startDelay = (clip.startTimeMs / 1000.0).toStringAsFixed(3);

        String clipLabel = 'clip_v_$vSegIndex';
        String colorFilter = _buildColorAdjustFilter(clip.effects);
        
        // Trim, scale, pad and time-shift
        filterSegments.add(
          '[$inIdx:v]trim=start=$trimStart:duration=$trimDur,setpts=PTS-STARTPTS,'
          'scale=${targetW}:${targetH}:force_original_aspect_ratio=decrease,'
          'pad=${targetW}:${targetH}:(ow-iw)/2:(oh-ih)/2$colorFilter[$clipLabel]'
        );

        String nextBase = '[v_comp_$vSegIndex]';
        filterSegments.add(
          '$currentBase[$clipLabel]overlay=enable=\'between(t,$startDelay,${(clip.endTimeMs / 1000.0).toStringAsFixed(3)})\'$nextBase'
        );
        currentBase = nextBase;
        vSegIndex++;
      }
    }

    // Audio mixing
    final audioInputsToMix = <String>[];
    int aSegIndex = 0;
    for (final track in audioTracks) {
      for (final clip in track.clips) {
        final inIdx = inputIndices[clip.id];
        if (inIdx == null) continue;

        final trimStart = (clip.sourceInMs / 1000.0).toStringAsFixed(3);
        final trimDur = (clip.durationMs / 1000.0).toStringAsFixed(3);
        final delayMs = clip.startTimeMs;
        final vol = clip.volume.toStringAsFixed(2);

        String aLabel = 'a_seg_$aSegIndex';
        filterSegments.add(
          '[$inIdx:a]atrim=start=$trimStart:duration=$trimDur,asetpts=PTS-STARTPTS,'
          'volume=$vol,adelay=$delayMs|$delayMs[$aLabel]'
        );
        audioInputsToMix.add('[$aLabel]');
        aSegIndex++;
      }
    }

    String audioOutLabel = '[final_a]';
    if (audioInputsToMix.isNotEmpty) {
      final mixCount = audioInputsToMix.length;
      filterSegments.add('${audioInputsToMix.join('')}amix=inputs=$mixCount:duration=longest:dropout_transition=2$audioOutLabel');
    }

    // Assemble final filter complex
    if (filterSegments.isNotEmpty) {
      cmd.addAll(['-filter_complex', filterSegments.join(';')]);
      cmd.addAll(['-map', currentBase]);
      if (audioInputsToMix.isNotEmpty) {
        cmd.addAll(['-map', audioOutLabel]);
      }
    }

    // Encoding settings from ExportProfile
    final vCodec = profile.videoCodec == VideoCodec.hevc ? 'libx265' : 'libx264';
    cmd.addAll([
      '-c:v', vCodec,
      '-b:v', '${profile.videoBitrateKbps}k',
      '-r', '${profile.fps}',
      '-c:a', 'aac',
      '-b:a', '${profile.audioBitrateKbps}k',
      '-pix_fmt', 'yuv420p',
      '-progress', 'pipe:1',
      outputPath,
    ]);

    return cmd;
  }

  static String _buildColorAdjustFilter(List<EffectModel> effects) {
    for (final eff in effects) {
      if (eff.type == EffectType.colorAdjust && eff.isEnabled) {
        final brightness = (eff.parameters['brightness'] as num?)?.toDouble() ?? 0.0;
        final contrast = (eff.parameters['contrast'] as num?)?.toDouble() ?? 1.0;
        final saturation = (eff.parameters['saturation'] as num?)?.toDouble() ?? 1.0;
        return ',eq=brightness=${brightness.toStringAsFixed(2)}:contrast=${contrast.toStringAsFixed(2)}:saturation=${saturation.toStringAsFixed(2)}';
      }
    }
    return '';
  }

  /// Builds sidechain audio ducking filter between voiceover and background music
  static String buildAudioDuckingFilter({
    required String voiceoverLabel,
    required String bgmLabel,
    double duckRatio = 0.2,
  }) {
    return '$voiceoverLabel$bgmLabel'
        'sidechaincompress=threshold=0.08:ratio=4:attack=20:release=350:makeup=1';
  }
}
