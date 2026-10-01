import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/state/timeline_state.dart';
import 'package:motioncut_pro/core/utils/time_utils.dart';
import 'package:motioncut_pro/widgets/timeline/timeline_ruler.dart';
import 'package:motioncut_pro/widgets/timeline/timeline_track_view.dart';
import 'package:motioncut_pro/widgets/timeline/timeline_playhead.dart';
import 'package:motioncut_pro/widgets/timeline/timeline_gestures.dart';
import 'package:motioncut_pro/widgets/common/zoom_slider.dart';

class TimelineDock extends StatefulWidget {
  final ProjectModel project;
  final TimelineState timelineState;
  final int playheadMs;
  final ValueChanged<int> onSeek;
  final ValueChanged<double> onZoomChanged;
  final Function(String clipId, String trackId) onSelectClip;
  final VoidCallback onClearSelection;
  final VoidCallback onAddTrackMedia;

  const TimelineDock({
    super.key,
    required this.project,
    required this.timelineState,
    required this.playheadMs,
    required this.onSeek,
    required this.onZoomChanged,
    required this.onSelectClip,
    required this.onClearSelection,
    required this.onAddTrackMedia,
  });

  @override
  State<TimelineDock> createState() => _TimelineDockState();
}

class _TimelineDockState extends State<TimelineDock> {
  final ScrollController _scrollController = ScrollController();
  double _basePps = 50.0;

  @override
  void initState() {
    super.initState();
    _basePps = widget.timelineState.pixelsPerSecond;
  }

  @override
  void didUpdateWidget(covariant TimelineDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll timeline to follow playhead during playback
    if (widget.playheadMs != oldWidget.playheadMs && _scrollController.hasClients) {
      final playheadX = TimeUtils.millisecondsToPixels(
        widget.playheadMs,
        widget.timelineState.pixelsPerSecond,
      );
      final currentOffset = _scrollController.offset;
      final viewportWidth = _scrollController.position.viewportDimension;

      // If playhead wanders beyond 80% of current viewport, gently scroll forward
      if (playheadX > currentOffset + viewportWidth * 0.8) {
        _scrollController.jumpTo((playheadX - viewportWidth * 0.2).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pps = widget.timelineState.pixelsPerSecond;
    final totalDuration = widget.project.totalDurationMs > 0
        ? widget.project.totalDurationMs
        : 60000;
    final contentWidth = (totalDuration / 1000.0) * pps + 500;

    return Container(
      color: AppTheme.surface,
      child: Column(
        children: [
          // Sub-header: Track info & Zoom control
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceElevated,
              border: Border(bottom: BorderSide(color: AppTheme.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${widget.project.tracks.length} Tracks',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.timelineState.isSnappingEnabled
                            ? AppTheme.primary.withOpacity(0.2)
                            : Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.magnet_outlined,
                            size: 12,
                            color: widget.timelineState.isSnappingEnabled
                                ? AppTheme.primary
                                : Colors.white38,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'SNAP',
                            style: TextStyle(
                              color: widget.timelineState.isSnappingEnabled
                                  ? AppTheme.primary
                                  : Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ZoomSlider(
                  currentPps: pps,
                  onZoomChanged: widget.onZoomChanged,
                ),
              ],
            ),
          ),

          // Multi-track Canvas with horizontal scroll
          Expanded(
            child: GestureDetector(
              onTap: widget.onClearSelection,
              onScaleStart: (_) {
                _basePps = widget.timelineState.pixelsPerSecond;
              },
              onScaleUpdate: (details) {
                if (details.scale != 1.0) {
                  final newPps = TimelineGestureHelper.computeZoomScale(
                    basePps: _basePps,
                    scaleFactor: details.scale,
                  );
                  widget.onZoomChanged(newPps);
                }
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: contentWidth,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ruler on top
                          TimelineRuler(
                            totalDurationMs: totalDuration,
                            pixelsPerSecond: pps,
                            onSeek: (ms) {
                              final snapped = widget.timelineState.isSnappingEnabled
                                  ? TimelineGestureHelper.applySnapping(
                                      targetMs: ms,
                                      project: widget.project,
                                    )
                                  : ms;
                              widget.onSeek(snapped);
                            },
                          ),

                          // Tracks List
                          for (final track in widget.project.tracks)
                            TimelineTrackView(
                              track: track,
                              pixelsPerSecond: pps,
                              selectedClipId: widget.timelineState.selectedClipId,
                              onSelectClip: (clipId) =>
                                  widget.onSelectClip(clipId, track.id),
                            ),
                        ],
                      ),

                      // Synchronized Playhead Marker
                      TimelinePlayhead(
                        playheadMs: widget.playheadMs,
                        pixelsPerSecond: pps,
                        totalHeight: 300,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
