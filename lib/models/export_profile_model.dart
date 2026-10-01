import 'dart:convert';

enum VideoContainer {
  mp4,
  mov,
}

enum VideoCodec {
  h264,
  hevc,
}

enum AudioCodec {
  aac,
  mp3,
  pcm,
}

enum ExportResolution {
  res720p(1280, 720, "720p HD"),
  res1080p(1920, 1080, "1080p Full HD"),
  res2k(2560, 1440, "2K QHD"),
  res4k(3840, 2160, "4K UHD");

  final int width;
  final int height;
  final String label;
  const ExportResolution(this.width, this.height, this.label);
}

class ExportProfileModel {
  final String name;
  final VideoContainer container;
  final VideoCodec videoCodec;
  final AudioCodec audioCodec;
  final ExportResolution resolution;
  final int customWidth;
  final int customHeight;
  final int fps;
  final int videoBitrateKbps;
  final int audioBitrateKbps;

  const ExportProfileModel({
    this.name = "Standard YouTube / Reels",
    this.container = VideoContainer.mp4,
    this.videoCodec = VideoCodec.h264,
    this.audioCodec = AudioCodec.aac,
    this.resolution = ExportResolution.res1080p,
    this.customWidth = 1920,
    this.customHeight = 1080,
    this.fps = 30,
    this.videoBitrateKbps = 12000,
    this.audioBitrateKbps = 256,
  });

  int get outputWidth => resolution.width;
  int get outputHeight => resolution.height;

  ExportProfileModel copyWith({
    String? name,
    VideoContainer? container,
    VideoCodec? videoCodec,
    AudioCodec? audioCodec,
    ExportResolution? resolution,
    int? customWidth,
    int? customHeight,
    int? fps,
    int? videoBitrateKbps,
    int? audioBitrateKbps,
  }) {
    return ExportProfileModel(
      name: name ?? this.name,
      container: container ?? this.container,
      videoCodec: videoCodec ?? this.videoCodec,
      audioCodec: audioCodec ?? this.audioCodec,
      resolution: resolution ?? this.resolution,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      fps: fps ?? this.fps,
      videoBitrateKbps: videoBitrateKbps ?? this.videoBitrateKbps,
      audioBitrateKbps: audioBitrateKbps ?? this.audioBitrateKbps,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'container': container.name,
      'videoCodec': videoCodec.name,
      'audioCodec': audioCodec.name,
      'resolution': resolution.name,
      'customWidth': customWidth,
      'customHeight': customHeight,
      'fps': fps,
      'videoBitrateKbps': videoBitrateKbps,
      'audioBitrateKbps': audioBitrateKbps,
    };
  }

  factory ExportProfileModel.fromMap(Map<String, dynamic> map) {
    return ExportProfileModel(
      name: map['name'] as String? ?? "Standard",
      container: VideoContainer.values.firstWhere(
        (e) => e.name == map['container'],
        orElse: () => VideoContainer.mp4,
      ),
      videoCodec: VideoCodec.values.firstWhere(
        (e) => e.name == map['videoCodec'],
        orElse: () => VideoCodec.h264,
      ),
      audioCodec: AudioCodec.values.firstWhere(
        (e) => e.name == map['audioCodec'],
        orElse: () => AudioCodec.aac,
      ),
      resolution: ExportResolution.values.firstWhere(
        (e) => e.name == map['resolution'],
        orElse: () => ExportResolution.res1080p,
      ),
      customWidth: map['customWidth'] as int? ?? 1920,
      customHeight: map['customHeight'] as int? ?? 1080,
      fps: map['fps'] as int? ?? 30,
      videoBitrateKbps: map['videoBitrateKbps'] as int? ?? 12000,
      audioBitrateKbps: map['audioBitrateKbps'] as int? ?? 256,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExportProfileModel.fromJson(String source) =>
      ExportProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
