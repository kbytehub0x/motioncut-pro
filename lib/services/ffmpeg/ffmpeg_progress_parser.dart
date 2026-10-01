class FfmpegProgress {
  final double percentage; // 0.0 to 1.0
  final int currentFrame;
  final double fps;
  final int outTimeMs;
  final double speed;
  final int totalSize;
  final bool isCompleted;

  const FfmpegProgress({
    this.percentage = 0.0,
    this.currentFrame = 0,
    this.fps = 0.0,
    this.outTimeMs = 0,
    this.speed = 1.0,
    this.totalSize = 0,
    this.isCompleted = false,
  });

  FfmpegProgress copyWith({
    double? percentage,
    int? currentFrame,
    double? fps,
    int? outTimeMs,
    double? speed,
    int? totalSize,
    bool? isCompleted,
  }) {
    return FfmpegProgress(
      percentage: percentage ?? this.percentage,
      currentFrame: currentFrame ?? this.currentFrame,
      fps: fps ?? this.fps,
      outTimeMs: outTimeMs ?? this.outTimeMs,
      speed: speed ?? this.speed,
      totalSize: totalSize ?? this.totalSize,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class FfmpegProgressParser {
  final int totalDurationMs;
  int _lastOutTimeMs = 0;
  int _frame = 0;
  double _fps = 0.0;
  double _speed = 1.0;
  int _size = 0;

  FfmpegProgressParser({required this.totalDurationMs});

  FfmpegProgress parseLine(String line) {
    final clean = line.trim();
    if (clean.isEmpty) {
      return _buildCurrent(false);
    }

    // FFmpeg key=value progress output
    if (clean.contains('=')) {
      final parts = clean.split('=');
      final key = parts[0].trim();
      final val = parts.length > 1 ? parts.sublist(1).join('=').trim() : '';

      switch (key) {
        case 'frame':
          _frame = int.tryParse(val) ?? _frame;
          break;
        case 'fps':
          _fps = double.tryParse(val) ?? _fps;
          break;
        case 'total_size':
          _size = int.tryParse(val) ?? _size;
          break;
        case 'out_time_us':
          final us = int.tryParse(val);
          if (us != null) {
            _lastOutTimeMs = us ~/ 1000;
          }
          break;
        case 'out_time_ms':
          _lastOutTimeMs = int.tryParse(val) ?? _lastOutTimeMs;
          break;
        case 'out_time':
          _lastOutTimeMs = _parseTimeStringToMs(val);
          break;
        case 'speed':
          final speedStr = val.replaceAll('x', '').trim();
          _speed = double.tryParse(speedStr) ?? _speed;
          break;
        case 'progress':
          if (val == 'end') {
            return _buildCurrent(true);
          }
          break;
      }
    }

    return _buildCurrent(false);
  }

  FfmpegProgress _buildCurrent(bool isCompleted) {
    double progress = 0.0;
    if (totalDurationMs > 0) {
      progress = (_lastOutTimeMs / totalDurationMs).clamp(0.0, 1.0);
    }
    if (isCompleted) progress = 1.0;

    return FfmpegProgress(
      percentage: progress,
      currentFrame: _frame,
      fps: _fps,
      outTimeMs: _lastOutTimeMs,
      speed: _speed,
      totalSize: _size,
      isCompleted: isCompleted,
    );
  }

  int _parseTimeStringToMs(String timeStr) {
    try {
      // Format 00:01:23.456
      final parts = timeStr.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final secondsWithMs = double.parse(parts[2]);
        final totalSeconds = hours * 3600 + minutes * 60 + secondsWithMs;
        return (totalSeconds * 1000).round();
      }
    } catch (_) {}
    return _lastOutTimeMs;
  }
}
