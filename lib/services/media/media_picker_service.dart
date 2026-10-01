import 'package:file_picker/file_picker.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/core/utils/file_utils.dart';

class PickedMediaResult {
  final String path;
  final String name;
  final int size;
  final ClipType type;

  const PickedMediaResult({
    required this.path,
    required this.name,
    required this.size,
    required this.type,
  });
}

class MediaPickerService {
  /// Picks one or more video files
  Future<List<PickedMediaResult>> pickVideoMedia({bool allowMultiple = true}) async {
    try {
      var result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) {
        // Fallback for devices where video intent is restricted
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['mp4', 'mov', 'mkv', 'webm', '3gp', 'avi'],
          allowMultiple: allowMultiple,
        );
      }

      if (result == null || result.files.isEmpty) return [];

      return result.files
          .where((f) => f.path != null)
          .map((f) => PickedMediaResult(
                path: f.path!,
                name: f.name,
                size: f.size,
                type: ClipType.video,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Picks audio files (mp3, wav, aac, flac, ogg, m4a)
  Future<List<PickedMediaResult>> pickAudioMedia({bool allowMultiple = false}) async {
    try {
      // Use native audio intent first for Android audio picker
      var result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: allowMultiple,
      );

      // Fallback to custom extension filter if audio picker was cancelled or unsupported
      if (result == null || result.files.isEmpty) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'],
          allowMultiple: allowMultiple,
        );
      }

      if (result == null || result.files.isEmpty) return [];

      return result.files
          .where((f) => f.path != null)
          .map((f) => PickedMediaResult(
                path: f.path!,
                name: f.name,
                size: f.size,
                type: ClipType.audio,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Picks media of any supported type
  Future<List<PickedMediaResult>> pickAnyMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    final list = <PickedMediaResult>[];
    for (final f in result.files) {
      if (f.path == null) continue;
      ClipType type = ClipType.video;
      if (FileUtils.isAudioExtension(f.path!)) {
        type = ClipType.audio;
      }
      list.add(PickedMediaResult(
        path: f.path!,
        name: f.name,
        size: f.size,
        type: type,
      ));
    }
    return list;
  }
}
