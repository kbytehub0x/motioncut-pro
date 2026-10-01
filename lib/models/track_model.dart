import 'dart:convert';
import 'package:motioncut_pro/models/clip_model.dart';

enum TrackType {
  mainVideo,
  overlayVideo,
  audio,
  text,
}

class TrackModel {
  final String id;
  final String name;
  final TrackType type;
  final int order;
  final bool isMuted;
  final bool isLocked;
  final bool isVisible;
  final List<ClipModel> clips;

  const TrackModel({
    required this.id,
    required this.name,
    required this.type,
    required this.order,
    this.isMuted = false,
    this.isLocked = false,
    this.isVisible = true,
    this.clips = const [],
  });

  TrackModel copyWith({
    String? id,
    String? name,
    TrackType? type,
    int? order,
    bool? isMuted,
    bool? isLocked,
    bool? isVisible,
    List<ClipModel>? clips,
  }) {
    return TrackModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      order: order ?? this.order,
      isMuted: isMuted ?? this.isMuted,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
      clips: clips ?? this.clips,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'order': order,
      'isMuted': isMuted,
      'isLocked': isLocked,
      'isVisible': isVisible,
      'clips': clips.map((x) => x.toMap()).toList(),
    };
  }

  factory TrackModel.fromMap(Map<String, dynamic> map) {
    return TrackModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: TrackType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TrackType.mainVideo,
      ),
      order: map['order'] as int? ?? 0,
      isMuted: map['isMuted'] as bool? ?? false,
      isLocked: map['isLocked'] as bool? ?? false,
      isVisible: map['isVisible'] as bool? ?? true,
      clips: (map['clips'] as List<dynamic>?)
              ?.map((e) => ClipModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory TrackModel.fromJson(String source) =>
      TrackModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
