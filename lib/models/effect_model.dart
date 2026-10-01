import 'dart:convert';

enum EffectType {
  colorAdjust,
  blur,
  vignette,
  chromaKey,
  speedRamp,
  lut,
  audioEqualizer,
  audioDucking,
}

enum BlendModeType {
  normal,
  screen,
  multiply,
  overlay,
  softLight,
  hardLight,
  colorDodge,
}

class EffectModel {
  final String id;
  final EffectType type;
  final String name;
  final bool isEnabled;
  final Map<String, dynamic> parameters;

  const EffectModel({
    required this.id,
    required this.type,
    required this.name,
    this.isEnabled = true,
    this.parameters = const {},
  });

  EffectModel copyWith({
    String? id,
    EffectType? type,
    String? name,
    bool? isEnabled,
    Map<String, dynamic>? parameters,
  }) {
    return EffectModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'isEnabled': isEnabled,
      'parameters': parameters,
    };
  }

  factory EffectModel.fromMap(Map<String, dynamic> map) {
    return EffectModel(
      id: map['id'] as String,
      type: EffectType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => EffectType.colorAdjust,
      ),
      name: map['name'] as String,
      isEnabled: map['isEnabled'] as bool? ?? true,
      parameters: Map<String, dynamic>.from(map['parameters'] as Map? ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory EffectModel.fromJson(String source) =>
      EffectModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
