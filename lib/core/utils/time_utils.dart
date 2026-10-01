class TimeUtils {
  /// Formats milliseconds into standard SMPTE timecode (HH:MM:SS:FF) or MM:SS:ff
  static String formatTimecode(int milliseconds, {int fps = 30}) {
    if (milliseconds < 0) milliseconds = 0;
    
    final totalSeconds = milliseconds / 1000.0;
    final minutes = (totalSeconds / 60).floor();
    final seconds = (totalSeconds % 60).floor();
    final frames = ((totalSeconds - totalSeconds.floor()) * fps).floor();

    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    final fStr = frames.toString().padLeft(2, '0');

    return '$mStr:$sStr:$fStr';
  }

  /// Formats milliseconds to standard MM:SS for user badges
  static String formatDuration(int milliseconds) {
    if (milliseconds < 0) milliseconds = 0;
    final totalSeconds = (milliseconds / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Converts timeline X coordinate into milliseconds given pixelsPerSecond
  static int pixelsToMilliseconds(double pixels, double pixelsPerSecond) {
    if (pixelsPerSecond <= 0) return 0;
    final seconds = pixels / pixelsPerSecond;
    return (seconds * 1000).round();
  }

  /// Converts milliseconds into timeline X pixels given pixelsPerSecond
  static double millisecondsToPixels(int milliseconds, double pixelsPerSecond) {
    final seconds = milliseconds / 1000.0;
    return seconds * pixelsPerSecond;
  }
}
