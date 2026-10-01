import 'dart:convert';
import 'package:motioncut_pro/models/keyframe_model.dart';
import 'package:motioncut_pro/models/effect_model.dart';

enum ClipType {
  video,
  audio,
  text,
  image,
}

class ClipModel {
  final String id;
  final String trackId;
  final ClipType type;
  final String name;
  final String sourcePath;
  
  /// Timeline placement in milliseconds
  final int startTimeMs;
  /// Duration on the timeline in milliseconds
  final int durationMs;

  /// Trim point in original media source (in ms)
  final int sourceInMs;
  /// Out point in original media source (in ms)
  final int sourceOutMs;

  /// Playback speed multiplier (e.g. 1.0, 0.5 for slow-mo, 2.0 for fast)
  final double speed;

  /// Base volume multiplier (0.0 to 2.0)
  final double volume;

  /// Base visual opacity (0.0 to 1.0)
  final double opacity;

  final BlendModeType blendMode;

  /// Keyframes for dynamic parameter automation
  final List<KeyframeModel> volumeKeyframes;
  final List<KeyframeModel> opacityKeyframes;
  final List<KeyframeModel> scaleKeyframes;

  /// Applied visual/audio effects
  final List<EffectModel> effects;

  /// Specific to Text clips
  final String? textContent;
  final int? textColorValue;
  final double? fontSize;

  const ClipModel({
    required this.id,
    required this.trackId,
    required this.type,
    required this.name,
    required this.sourcePath,
    required this.startTimeMs,
    required this.durationMs,
    this.sourceInMs = 0,
    required this.sourceOutMs,
    this.speed = 1.0,
    this.volume = 1.0,
    this.opacity = 1.0,
    this.blendMode = BlendModeType.normal,
    this.volumeKeyframes = const [],
    this.opacityKeyframes = const [],
    this.scaleKeyframes = const [],
    this.effects = const [],
    this.textContent,
    this.textColorValue,
    this.fontSize,
  });

  int get endTimeMs => startTimeMs + durationMs;

  /// Source duration represented on this clip
  int get sourceSpanMs => sourceOutMs - sourceInMs;

  ClipModel copyWith({
    String? id,
    String? trackId,
    ClipType? type,
    String? name,
    String? sourcePath,
    int? startTimeMs,
    int? durationMs,
    int? sourceInMs,
    int? sourceOutMs,
    double? speed,
    double? volume,
    double? opacity,
    BlendModeType? blendMode,
    List<KeyframeModel>? volumeKeyframes,
    List<KeyframeModel>? opacityKeyframes,
    List<KeyframeModel>? scaleKeyframes,
    List<EffectModel>? effects,
    String? textContent,
    int? textColorValue,
    double? fontSize,
  }) {
    return ClipModel(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      type: type ?? this.type,
      name: name ?? this.name,
      sourcePath: sourcePath ?? this.sourcePath,
      startTimeMs: startTimeMs ?? this.startTimeMs,
      durationMs: durationMs ?? this.durationMs,
      sourceInMs: sourceInMs ?? this.sourceInMs,
      sourceOutMs: sourceOutMs ?? this.sourceOutMs,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
      volumeKeyframes: volumeKeyframes ?? this.volumeKeyframes,
      opacityKeyframes: opacityKeyframes ?? this.opacityKeyframes,
      scaleKeyframes: scaleKeyframes ?? this.scaleKeyframes,
      effects: effects ?? this.effects,
      textContent: textContent ?? this.textContent,
      textColorValue: textColorValue ?? this.textColorValue,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trackId': trackId,
      'type': type.name,
      'name': name,
      'sourcePath': sourcePath,
      'startTimeMs': startTimeMs,
      'durationMs': durationMs,
      'sourceInMs': sourceInMs,
      'sourceOutMs': sourceOutMs,
      'speed': speed,
      'volume': volume,
      'opacity': opacity,
      'blendMode': blendMode.name,
      'volumeKeyframes': volumeKeyframes.map((x) => x.toMap()).toList(),
      'opacityKeyframes': opacityKeyframes.map((x) => x.toMap()).toList(),
      'scaleKeyframes': scaleKeyframes.map((x) => x.toMap()).toList(),
      'effects': effects.map((x) => x.toMap()).toList(),
      'textContent': textContent,
      'textColorValue': textColorValue,
      'fontSize': fontSize,
    };
  }

  factory ClipModel.fromMap(Map<String, dynamic> map) {
    return ClipModel(
      id: map['id'] as String,
      trackId: map['trackId'] as String,
      type: ClipType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ClipType.video,
      ),
      name: map['name'] as String,
      sourcePath: map['sourcePath'] as String,
      startTimeMs: map['startTimeMs'] as int,
      durationMs: map['durationMs'] as int,
      sourceInMs: map['sourceInMs'] as int? ?? 0,
      sourceOutMs: map['sourceOutMs'] as int,
      speed: (map['speed'] as num?)?.toDouble() ?? 1.0,
      volume: (map['volume'] as num?)?.toDouble() ?? 1.0,
      opacity: (map['opacity'] as num?)?.toDouble() ?? 1.0,
      blendMode: BlendModeType.values.firstWhere(
        (e) => e.name == map['blendMode'],
        orElse: () => BlendModeType.normal,
      ),
      volumeKeyframes: (map['volumeKeyframes'] as List<dynamic>?)
              ?.map((e) => KeyframeModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      opacityKeyframes: (map['opacityKeyframes'] as List<dynamic>?)
              ?.map((e) => KeyframeModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      scaleKeyframes: (map['scaleKeyframes'] as List<dynamic>?)
              ?.map((e) => KeyframeModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      effects: (map['effects'] as List<dynamic>?)
              ?.map((e) => EffectModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      textContent: map['textContent'] as String?,
      textColorValue: map['textColorValue'] as int?,
      fontSize: (map['fontSize'] as num?)?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ClipModel.fromJson(String source) =>
      ClipModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
