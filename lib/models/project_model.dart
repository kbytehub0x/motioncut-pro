import 'dart:convert';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/export_profile_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';

enum AspectRatioType {
  landscape16_9("16:9", 16 / 9, 1920, 1080),
  portrait9_16("9:16", 9 / 16, 1080, 1920),
  square1_1("1:1", 1 / 1, 1080, 1080),
  portrait4_5("4:5", 4 / 5, 1080, 1350),
  cinema21_9("21:9", 21 / 9, 2560, 1080);

  final String label;
  final double ratio;
  final int defaultWidth;
  final int defaultHeight;
  const AspectRatioType(this.label, this.ratio, this.defaultWidth, this.defaultHeight);
}

class ProjectModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AspectRatioType aspectRatio;
  final int fps;
  final List<TrackModel> tracks;
  final String? thumbnailPath;
  final ExportProfileModel exportProfile;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.aspectRatio = AspectRatioType.portrait9_16,
    this.fps = 30,
    this.tracks = const [],
    this.thumbnailPath,
    this.exportProfile = const ExportProfileModel(),
  });

  /// Computes the overall timeline duration in ms based on all clips
  int get totalDurationMs {
    int maxEnd = 0;
    for (final track in tracks) {
      for (final clip in track.clips) {
        if (clip.endTimeMs > maxEnd) {
          maxEnd = clip.endTimeMs;
        }
      }
    }
    return maxEnd;
  }

  /// Finds any clip across all tracks by id
  ClipModel? findClip(String clipId) {
    for (final track in tracks) {
      for (final clip in track.clips) {
        if (clip.id == clipId) return clip;
      }
    }
    return null;
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    AspectRatioType? aspectRatio,
    int? fps,
    List<TrackModel>? tracks,
    String? thumbnailPath,
    ExportProfileModel? exportProfile,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      fps: fps ?? this.fps,
      tracks: tracks ?? this.tracks,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      exportProfile: exportProfile ?? this.exportProfile,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'aspectRatio': aspectRatio.name,
      'fps': fps,
      'tracks': tracks.map((x) => x.toMap()).toList(),
      'thumbnailPath': thumbnailPath,
      'exportProfile': exportProfile.toMap(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      aspectRatio: AspectRatioType.values.firstWhere(
        (e) => e.name == map['aspectRatio'],
        orElse: () => AspectRatioType.portrait9_16,
      ),
      fps: map['fps'] as int? ?? 30,
      tracks: (map['tracks'] as List<dynamic>?)
              ?.map((e) => TrackModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      thumbnailPath: map['thumbnailPath'] as String?,
      exportProfile: map['exportProfile'] != null
          ? ExportProfileModel.fromMap(map['exportProfile'] as Map<String, dynamic>)
          : const ExportProfileModel(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectModel.fromJson(String source) =>
      ProjectModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
