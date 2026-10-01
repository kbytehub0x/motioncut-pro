enum PreviewQuality {
  proxy360p("360p Proxy"),
  half720p("720p Draft"),
  full1080p("1080p Full");

  final String label;
  const PreviewQuality(this.label);
}

class PreviewState {
  final int playheadMs;
  final bool isPlaying;
  final bool showSafeAreas;
  final bool showGrid;
  final PreviewQuality quality;
  final double masterVolume;

  const PreviewState({
    this.playheadMs = 0,
    this.isPlaying = false,
    this.showSafeAreas = false,
    this.showGrid = false,
    this.quality = PreviewQuality.half720p,
    this.masterVolume = 1.0,
  });

  PreviewState copyWith({
    int? playheadMs,
    bool? isPlaying,
    bool? showSafeAreas,
    bool? showGrid,
    PreviewQuality? quality,
    double? masterVolume,
  }) {
    return PreviewState(
      playheadMs: playheadMs ?? this.playheadMs,
      isPlaying: isPlaying ?? this.isPlaying,
      showSafeAreas: showSafeAreas ?? this.showSafeAreas,
      showGrid: showGrid ?? this.showGrid,
      quality: quality ?? this.quality,
      masterVolume: masterVolume ?? this.masterVolume,
    );
  }
}
