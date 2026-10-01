import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/core/utils/time_utils.dart';

class SplitTool extends StatelessWidget {
  final ClipModel clip;
  final int playheadMs;
  final VoidCallback onSplitAtPlayhead;
  final VoidCallback onClose;

  const SplitTool({
    super.key,
    required this.clip,
    required this.playheadMs,
    required this.onSplitAtPlayhead,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final canSplit = playheadMs > clip.startTimeMs && playheadMs < clip.endTimeMs;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceElevated,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Split: ${clip.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            canSplit
                ? 'Playhead is at ${TimeUtils.formatTimecode(playheadMs)}'
                : 'Move playhead inside the clip to split.',
            style: TextStyle(
              color: canSplit ? AppTheme.accent : Colors.orangeAccent,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: canSplit ? AppTheme.primary : Colors.white12,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.content_cut, size: 18),
            label: const Text('Split at Playhead'),
            onPressed: canSplit ? onSplitAtPlayhead : null,
          ),
        ],
      ),
    );
  }
}
