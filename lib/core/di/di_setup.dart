import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motioncut_pro/core/storage/local_storage.dart';
import 'package:motioncut_pro/core/storage/project_repository.dart';
import 'package:motioncut_pro/services/ffmpeg/ffmpeg_service.dart';
import 'package:motioncut_pro/services/audio/audio_waveform_service.dart';
import 'package:motioncut_pro/services/media/media_picker_service.dart';
import 'package:motioncut_pro/services/media/media_cache_service.dart';
import 'package:motioncut_pro/services/media/media_analyzer_service.dart';
import 'package:motioncut_pro/services/project/project_manager_service.dart';

/// Must be overridden in main() after LocalStorage.create()
final localStorageProvider = Provider<LocalStorage>((ref) {
  throw UnimplementedError('localStorageProvider must be initialized before runApp');
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ProjectRepository(storage);
});

final projectManagerServiceProvider = Provider<ProjectManagerService>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return ProjectManagerService(repo);
});

final ffmpegServiceProvider = Provider<FfmpegService>((ref) {
  return FfmpegService();
});

final audioWaveformServiceProvider = Provider<AudioWaveformService>((ref) {
  return AudioWaveformService();
});

final mediaPickerServiceProvider = Provider<MediaPickerService>((ref) {
  return MediaPickerService();
});

final mediaCacheServiceProvider = Provider<MediaCacheService>((ref) {
  return MediaCacheService();
});

final mediaAnalyzerServiceProvider = Provider<MediaAnalyzerService>((ref) {
  return MediaAnalyzerService();
});
