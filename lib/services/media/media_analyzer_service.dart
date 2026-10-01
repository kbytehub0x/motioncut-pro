import 'dart:io';

class MediaMetadata {
  final int durationMs;
  final int width;
  final int height;
  final double fps;
  final String videoCodec;
  final String audioCodec;
  final int bitrate;

  const MediaMetadata({
    required this.durationMs,
    required this.width,
    required this.height,
    required this.fps,
    required this.videoCodec,
    required this.audioCodec,
    required this.bitrate,
  });
}

class MediaAnalyzerService {
  /// Probes media file metadata (in full app calls FFprobe or video_player controller)
  Future<MediaMetadata> analyzeMedia(String filePath) async {
    final file = File(filePath);
    final exists = await file.exists();
    final fileSize = exists ? await file.length() : 0;

    // Default sensible video metadata for newly picked clips
    // In production, FFprobe json output extracts these exact stream properties.
    int estimatedDurationMs = 10000;
    if (fileSize > 0) {
      // Estimate ~2MB per 5 seconds of 1080p video as realistic baseline
      estimatedDurationMs = ((fileSize / (2 * 1024 * 1024)) * 5000).clamp(2000, 600000).round();
    }

    return MediaMetadata(
      durationMs: estimatedDurationMs,
      width: 1920,
      height: 1080,
      fps: 30.0,
      videoCodec: 'h264',
      audioCodec: 'aac',
      bitrate: 8000000,
    );
  }
}
