class AppConstants {
  static const String appName = 'MotionCut Pro';
  static const String appTagline = 'Frame-Accurate Mobile Video Workstation';
  static const String appVersion = '1.0.0 (Build 2026)';
  
  // Timeline Metrics
  static const double defaultPixelsPerSecond = 50.0;
  static const double minPixelsPerSecond = 10.0;
  static const double maxPixelsPerSecond = 200.0;
  static const double trackHeightVideo = 64.0;
  static const double trackHeightAudio = 48.0;
  static const double trackHeightOverlay = 56.0;
  static const double trackHeightText = 40.0;
  static const double playheadWidth = 2.0;
  static const int snappingThresholdMs = 200;

  // Platform Channel Keys
  static const String ffmpegMethodChannel = 'com.motioncut.pro/ffmpeg';
  static const String ffmpegEventChannel = 'com.motioncut.pro/ffmpeg_progress';

  // Storage Keys
  static const String prefsRecentProjectsKey = 'motioncut_recent_projects';
  static const String prefsThemeKey = 'motioncut_theme_mode';
  static const String prefsProxyPreviewKey = 'motioncut_proxy_preview';
  static const String prefsStorageDirKey = 'motioncut_storage_dir';

  // Limits
  static const double minClipDurationSec = 0.2; // 200ms
  static const double maxSpeedMultiplier = 10.0;
  static const double minSpeedMultiplier = 0.1;
}
