import 'dart:io';
import 'package:motioncut_pro/core/utils/file_utils.dart';

class MediaCacheService {
  final Map<String, String> _thumbnailCache = {};

  /// Retrieves or sets cached thumbnail path for a media clip
  String? getCachedThumbnail(String mediaPath) {
    return _thumbnailCache[mediaPath];
  }

  void setCachedThumbnail(String mediaPath, String thumbnailPath) {
    _thumbnailCache[mediaPath] = thumbnailPath;
  }

  /// Returns total disk size of the cache directory
  Future<int> getCacheSizeInBytes() async {
    final cacheDir = await FileUtils.getCacheDirectory();
    int total = 0;
    try {
      final entities = cacheDir.listSync(recursive: true);
      for (final e in entities) {
        if (e is File) {
          total += await e.length();
        }
      }
    } catch (_) {}
    return total;
  }

  /// Clears proxy videos and cached frames to save mobile storage
  Future<void> clearAllCache() async {
    _thumbnailCache.clear();
    final cacheDir = await FileUtils.getCacheDirectory();
    try {
      if (await cacheDir.exists()) {
        final entities = cacheDir.listSync();
        for (final e in entities) {
          await e.delete(recursive: true);
        }
      }
    } catch (_) {}
  }
}
