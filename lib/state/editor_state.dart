import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/state/timeline_state.dart';
import 'package:motioncut_pro/state/preview_state.dart';

enum ActiveToolSheet {
  none,
  trim,
  split,
  speed,
  audio,
  color,
  blend,
  text,
  crop,
}

class EditorState {
  final ProjectModel project;
  final TimelineState timeline;
  final PreviewState preview;
  final ActiveToolSheet activeTool;
  final bool isExporting;
  final bool isDirty;

  const EditorState({
    required this.project,
    this.timeline = const TimelineState(),
    this.preview = const PreviewState(),
    this.activeTool = ActiveToolSheet.none,
    this.isExporting = false,
    this.isDirty = false,
  });

  EditorState copyWith({
    ProjectModel? project,
    TimelineState? timeline,
    PreviewState? preview,
    ActiveToolSheet? activeTool,
    bool? isExporting,
    bool? isDirty,
  }) {
    return EditorState(
      project: project ?? this.project,
      timeline: timeline ?? this.timeline,
      preview: preview ?? this.preview,
      activeTool: activeTool ?? this.activeTool,
      isExporting: isExporting ?? this.isExporting,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}
