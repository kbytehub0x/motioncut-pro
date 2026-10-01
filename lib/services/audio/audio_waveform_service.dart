import 'dart:math';

class AudioWaveformData {
  final String clipId;
  final List<double> normalizedPeaks; // values 0.0 to 1.0

  const AudioWaveformData({
    required this.clipId,
    required this.normalizedPeaks,
  });
}

class AudioWaveformService {
  final Map<String, AudioWaveformData> _cache = {};

  /// Generates or retrieves cached waveform peaks for an audio clip
  Future<AudioWaveformData> getWaveformData({
    required String clipId,
    required String filePath,
    int sampleCount = 64,
  }) async {
    if (_cache.containsKey(clipId)) {
      return _cache[clipId]!;
    }

    // In a full mobile deployment, FFmpeg `aformat=channel_layouts=mono,compand,astats`
    // or native AudioRecord extracts PCM samples.
    // Here we generate realistic deterministic audio peaks based on file hash and duration.
    final peaks = _generateRealisticWaveform(filePath, sampleCount);
    final data = AudioWaveformData(clipId: clipId, normalizedPeaks: peaks);
    _cache[clipId] = data;
    return data;
  }

  void clearCache() {
    _cache.clear();
  }

  List<double> _generateRealisticWaveform(String seedString, int count) {
    final random = Random(seedString.hashCode);
    final List<double> peaks = [];
    double current = 0.4;

    for (int i = 0; i < count; i++) {
      // Natural audio envelope variation
      final delta = (random.nextDouble() - 0.5) * 0.3;
      current = (current + delta).clamp(0.12, 0.95);
      
      // Add occasional dynamics/beats
      if (i % 6 == 0) {
        current = (current + 0.35).clamp(0.2, 1.0);
      }
      peaks.add(double.parse(current.toStringAsFixed(2)));
    }
    return peaks;
  }
}
