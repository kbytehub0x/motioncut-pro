import 'dart:convert';

enum KeyframeInterpolation {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  hold,
}

/// Represents a single keyframe on a clip parameter (e.g. scale, opacity, volume, position)
class KeyframeModel {
  final String id;
  /// Time in milliseconds relative to clip start
  final int timeMs;
  /// Normalized or raw value (e.g. 0.0 - 1.0 for opacity/volume, >0 for scale)
  final double value;
  final KeyframeInterpolation interpolation;

  const KeyframeModel({
    required this.id,
    required this.timeMs,
    required this.value,
    this.interpolation = KeyframeInterpolation.linear,
  });

  KeyframeModel copyWith({
    String? id,
    int? timeMs,
    double? value,
    KeyframeInterpolation? interpolation,
  }) {
    return KeyframeModel(
      id: id ?? this.id,
      timeMs: timeMs ?? this.timeMs,
      value: value ?? this.value,
      interpolation: interpolation ?? this.interpolation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timeMs': timeMs,
      'value': value,
      'interpolation': interpolation.name,
    };
  }

  factory KeyframeModel.fromMap(Map<String, dynamic> map) {
    return KeyframeModel(
      id: map['id'] as String,
      timeMs: map['timeMs'] as int,
      value: (map['value'] as num).toDouble(),
      interpolation: KeyframeInterpolation.values.firstWhere(
        (e) => e.name == map['interpolation'],
        orElse: () => KeyframeInterpolation.linear,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory KeyframeModel.fromJson(String source) =>
      KeyframeModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
