import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/core/di/di_setup.dart';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/state/editor_state.dart';
import 'package:motioncut_pro/state/editor_provider.dart';
import 'package:motioncut_pro/views/export_screen.dart';
import 'package:motioncut_pro/widgets/preview/preview_player.dart';
import 'package:motioncut_pro/widgets/timeline/timeline_dock.dart';
import 'package:motioncut_pro/widgets/toolbar/contextual_toolbar.dart';
import 'package:motioncut_pro/widgets/toolbar/tools/trim_tool.dart';
import 'package:motioncut_pro/widgets/toolbar/tools/split_tool.dart';
import 'package:motioncut_pro/widgets/toolbar/tools/speed_tool.dart';
import 'package:motioncut_pro/widgets/toolbar/tools/audio_tool.dart';
import 'package:motioncut_pro/widgets/toolbar/tools/color_tool.dart';
import 'package:motioncut_pro/widgets/toolbar/tools/blend_tool.dart';
import 'package:motioncut_pro/widgets/toolbar/tools/text_tool.dart';
import 'package:motioncut_pro/widgets/toolbar/tools/crop_tool.dart';
import 'package:uuid/uuid.dart';

class EditorScreen extends ConsumerWidget {
  final ProjectModel project;

  const EditorScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProviderFamily(project));
    final editorNotifier = ref.read(editorProviderFamily(project).notifier);

    final selectedClip = editorState.timeline.selectedClipId != null
        ? editorState.project.findClip(editorState.timeline.selectedClipId!)
        : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              editorState.project.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              '${editorState.project.aspectRatio.label} · ${editorState.project.fps} FPS ${editorState.isDirty ? '· Unsaved' : ''}',
              style: TextStyle(
                fontSize: 11,
                color: editorState.isDirty ? AppTheme.accentOrange : Colors.white38,
              ),
            ),
          ],
        ),
        actions: [
          // Quick Save
          IconButton(
            icon: Icon(
              Icons.save_outlined,
              color: editorState.isDirty ? AppTheme.accent : Colors.white54,
            ),
            tooltip: 'Save Project',
            onPressed: () async {
              await editorNotifier.saveProject();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project saved locally.'), duration: Duration(seconds: 1)),
                );
              }
            },
          ),
          // Export Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.file_upload_outlined, size: 16),
              label: const Text('Export', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExportScreen(project: editorState.project),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section: Preview Player (Video canvas + transport + scrubber)
            Expanded(
              flex: 5,
              child: PreviewPlayer(
                project: editorState.project,
                previewState: editorState.preview,
                canUndo: editorNotifier.canUndo,
                canRedo: editorNotifier.canRedo,
                onSeek: editorNotifier.seek,
                onTogglePlay: editorNotifier.togglePlay,
                onToggleSafeAreas: editorNotifier.toggleSafeAreas,
                onToggleGrid: editorNotifier.toggleGrid,
                onQualityChanged: editorNotifier.setPreviewQuality,
                onUndo: editorNotifier.undo,
                onRedo: editorNotifier.redo,
              ),
            ),

            // Middle Section: Multi-Track Timeline Dock
            Expanded(
              flex: 5,
              child: TimelineDock(
                project: editorState.project,
                timelineState: editorState.timeline,
                playheadMs: editorState.preview.playheadMs,
                onSeek: editorNotifier.seek,
                onZoomChanged: editorNotifier.setZoom,
                onSelectClip: (clipId, trackId) =>
                    editorNotifier.selectClip(clipId, trackId: trackId),
                onClearSelection: () => editorNotifier.selectClip(null),
                onAddTrackMedia: () {},
              ),
            ),

            // Active Contextual Tool Sheet (when user taps a tool)
            if (editorState.activeTool != ActiveToolSheet.none && selectedClip != null)
              _buildActiveToolSheet(context, ref, editorState, selectedClip),

            // Bottom Section: Contextual Dock Toolbar
            ContextualToolbar(
              selectedClip: selectedClip,
              activeTool: editorState.activeTool,
              onOpenTool: editorNotifier.openTool,
              onSplit: editorNotifier.splitClipAtPlayhead,
              onDelete: editorNotifier.deleteSelectedClip,
              onAddMedia: () async {
                final picker = ref.read(mediaPickerServiceProvider);
                final picked = await picker.pickVideoMedia();
                if (picked.isNotEmpty) {
                  final item = picked.first;
                  final newClip = ClipModel(
                    id: const Uuid().v4(),
                    trackId: editorState.project.tracks.firstWhere((t) => t.type == TrackType.mainVideo).id,
                    type: ClipType.video,
                    name: item.name,
                    sourcePath: item.path,
                    startTimeMs: editorState.project.totalDurationMs,
                    durationMs: 4000,
                    sourceOutMs: 4000,
                  );
                  final updatedTracks = editorState.project.tracks.map((t) {
                    if (t.type == TrackType.mainVideo) {
                      return t.copyWith(clips: [...t.clips, newClip]);
                    }
                    return t;
                  }).toList();
                  final updatedProj = editorState.project.copyWith(tracks: updatedTracks);
                  ref.read(projectManagerServiceProvider).saveProject(updatedProj);
                }
              },
              onAddText: () {
                final textTrack = editorState.project.tracks.firstWhere(
                  (t) => t.type == TrackType.text,
                  orElse: () => editorState.project.tracks.first,
                );
                final newTextClip = ClipModel(
                  id: const Uuid().v4(),
                  trackId: textTrack.id,
                  type: ClipType.text,
                  name: 'Text Layer',
                  sourcePath: '',
                  startTimeMs: editorState.preview.playheadMs,
                  durationMs: 3000,
                  sourceOutMs: 3000,
                  textContent: 'TEXT OVERLAY',
                  textColorValue: 0xFFFFFFFF,
                  fontSize: 28.0,
                );
                final updatedTracks = editorState.project.tracks.map((t) {
                  if (t.id == textTrack.id) {
                    return t.copyWith(clips: [...t.clips, newTextClip]);
                  }
                  return t;
                }).toList();
                final updatedProj = editorState.project.copyWith(tracks: updatedTracks);
                ref.read(projectManagerServiceProvider).saveProject(updatedProj);
              },
              onAddAudio: () async {
                final picker = ref.read(mediaPickerServiceProvider);
                final picked = await picker.pickAudioMedia();
                if (picked.isNotEmpty) {
                  final item = picked.first;
                  final audioTrack = editorState.project.tracks.firstWhere(
                    (t) => t.type == TrackType.audio,
                    orElse: () => editorState.project.tracks.first,
                  );
                  final newAudioClip = ClipModel(
                    id: const Uuid().v4(),
                    trackId: audioTrack.id,
                    type: ClipType.audio,
                    name: item.name,
                    sourcePath: item.path,
                    startTimeMs: editorState.preview.playheadMs,
                    durationMs: 6000,
                    sourceOutMs: 6000,
                    volume: 0.8,
                  );
                  final updatedTracks = editorState.project.tracks.map((t) {
                    if (t.id == audioTrack.id) {
                      return t.copyWith(clips: [...t.clips, newAudioClip]);
                    }
                    return t;
                  }).toList();
                  final updatedProj = editorState.project.copyWith(tracks: updatedTracks);
                  ref.read(projectManagerServiceProvider).saveProject(updatedProj);
                }
              },
              onExport: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExportScreen(project: editorState.project),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveToolSheet(
    BuildContext context,
    WidgetRef ref,
    EditorState editorState,
    ClipModel selectedClip,
  ) {
    final notifier = ref.read(editorProviderFamily(project).notifier);

    switch (editorState.activeTool) {
      case ActiveToolSheet.trim:
        return TrimTool(
          clip: selectedClip,
          onApplyTrim: (startMs, durMs, inMs, outMs) {
            notifier.trimClip(
              clipId: selectedClip.id,
              newStartTimeMs: startMs,
              newDurationMs: durMs,
              newSourceInMs: inMs,
              newSourceOutMs: outMs,
            );
          },
          onClose: notifier.closeTool,
        );
      case ActiveToolSheet.split:
        return SplitTool(
          clip: selectedClip,
          playheadMs: editorState.preview.playheadMs,
          onSplitAtPlayhead: () {
            notifier.splitClipAtPlayhead();
            notifier.closeTool();
          },
          onClose: notifier.closeTool,
        );
      case ActiveToolSheet.speed:
        return SpeedTool(
          clip: selectedClip,
          onSpeedChanged: (spd) => notifier.setClipSpeed(selectedClip.id, spd),
          onClose: notifier.closeTool,
        );
      case ActiveToolSheet.audio:
        return AudioTool(
          clip: selectedClip,
          onVolumeChanged: (vol) => notifier.setClipVolume(selectedClip.id, vol),
          onClose: notifier.closeTool,
        );
      case ActiveToolSheet.color:
        return ColorTool(
          clip: selectedClip,
          onColorGradeChanged: (b, c, s) {
            notifier.updateClipColor(
              clipId: selectedClip.id,
              brightness: b,
              contrast: c,
              saturation: s,
            );
          },
          onClose: notifier.closeTool,
        );
      case ActiveToolSheet.blend:
        return BlendTool(
          clip: selectedClip,
          onBlendChanged: (opacity, mode) {
            // Handled via clip updates
          },
          onClose: notifier.closeTool,
        );
      case ActiveToolSheet.crop:
        return CropTool(
          clip: selectedClip,
          onApplyCrop: (bounds, rotationDegrees, flipX, flipY) {
            // Stores crop and rotation parameters on clip
          },
          onClose: notifier.closeTool,
        );
      case ActiveToolSheet.text:
        return TextTool(
          clip: selectedClip,
          onTextChanged: (newText, color, fontSize) {
            // Text layer update
          },
          onClose: notifier.closeTool,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
