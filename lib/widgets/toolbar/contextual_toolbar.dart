import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/state/editor_state.dart';
import 'package:motioncut_pro/widgets/toolbar/toolbar_button.dart';

class ContextualToolbar extends StatelessWidget {
  final ClipModel? selectedClip;
  final ActiveToolSheet activeTool;
  final Function(ActiveToolSheet tool) onOpenTool;
  final VoidCallback onSplit;
  final VoidCallback onDelete;
  final VoidCallback onAddMedia;
  final VoidCallback onAddText;
  final VoidCallback onAddAudio;
  final VoidCallback onExport;

  const ContextualToolbar({
    super.key,
    required this.selectedClip,
    required this.activeTool,
    required this.onOpenTool,
    required this.onSplit,
    required this.onDelete,
    required this.onAddMedia,
    required this.onAddText,
    required this.onAddAudio,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: selectedClip != null ? _buildClipSelectedBar() : _buildDefaultBar(),
    );
  }

  Widget _buildDefaultBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          ToolbarButton(
            icon: Icons.video_library_outlined,
            label: 'Add Video',
            onTap: onAddMedia,
          ),
          ToolbarButton(
            icon: Icons.title,
            label: 'Add Text',
            onTap: onAddText,
          ),
          ToolbarButton(
            icon: Icons.audiotrack_outlined,
            label: 'Add Audio',
            onTap: onAddAudio,
          ),
          ToolbarButton(
            icon: Icons.content_cut,
            label: 'Split',
            onTap: onSplit,
          ),
          ToolbarButton(
            icon: Icons.file_upload_outlined,
            label: 'Export',
            isActive: true,
            onTap: onExport,
          ),
        ],
      ),
    );
  }

  Widget _buildClipSelectedBar() {
    final clip = selectedClip!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          ToolbarButton(
            icon: Icons.content_cut,
            label: 'Split',
            isActive: activeTool == ActiveToolSheet.split,
            onTap: onSplit,
          ),
          ToolbarButton(
            icon: Icons.straighten,
            label: 'Trim',
            isActive: activeTool == ActiveToolSheet.trim,
            onTap: () => onOpenTool(ActiveToolSheet.trim),
          ),
          ToolbarButton(
            icon: Icons.speed,
            label: 'Speed',
            isActive: activeTool == ActiveToolSheet.speed,
            onTap: () => onOpenTool(ActiveToolSheet.speed),
          ),
          ToolbarButton(
            icon: Icons.volume_up,
            label: 'Volume',
            isActive: activeTool == ActiveToolSheet.audio,
            onTap: () => onOpenTool(ActiveToolSheet.audio),
          ),
          if (clip.type == ClipType.video || clip.type == ClipType.image) ...[
            ToolbarButton(
              icon: Icons.crop,
              label: 'Crop',
              isActive: activeTool == ActiveToolSheet.crop,
              onTap: () => onOpenTool(ActiveToolSheet.crop),
            ),
            ToolbarButton(
              icon: Icons.palette_outlined,
              label: 'Color / LUT',
              isActive: activeTool == ActiveToolSheet.color,
              onTap: () => onOpenTool(ActiveToolSheet.color),
            ),
            ToolbarButton(
              icon: Icons.layers_outlined,
              label: 'Blend',
              isActive: activeTool == ActiveToolSheet.blend,
              onTap: () => onOpenTool(ActiveToolSheet.blend),
            ),
          ],
          if (clip.type == ClipType.text)
            ToolbarButton(
              icon: Icons.edit_note,
              label: 'Edit Text',
              isActive: activeTool == ActiveToolSheet.text,
              onTap: () => onOpenTool(ActiveToolSheet.text),
            ),
          ToolbarButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            isDestructive: true,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
