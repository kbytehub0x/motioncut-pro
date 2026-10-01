import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  /// Returns app working directory for project files and exports
  static Future<Directory> getAppProjectDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final projectDir = Directory('${docs.path}/motioncut_projects');
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }
    return projectDir;
  }

  /// Returns temporary cache directory for proxy files and waveform caches
  static Future<Directory> getCacheDirectory() async {
    final temp = await getTemporaryDirectory();
    final cacheDir = Directory('${temp.path}/motioncut_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Returns exports directory
  static Future<Directory> getExportDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${docs.path}/motioncut_exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  /// Formats byte size into human readable string (KB, MB, GB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Checks if file extension belongs to supported video format
  static bool isVideoExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'm4v', 'mkv', 'webm', '3gp', 'avi'].contains(ext);
  }

  /// Checks if file extension belongs to supported audio format
  static bool isAudioExtension(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'].contains(ext);
  }
}
