import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/core/utils/time_utils.dart';

class TrimTool extends StatelessWidget {
  final ClipModel clip;
  final Function(int newStartMs, int newDurationMs, int newInMs, int newOutMs) onApplyTrim;
  final VoidCallback onClose;

  const TrimTool({
    super.key,
    required this.clip,
    required this.onApplyTrim,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surfaceElevated,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trim Clip: ${clip.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Trim Head
              Column(
                children: [
                  const Text('Trim Start', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: () {
                          if (clip.durationMs > 200) {
                            onApplyTrim(
                              clip.startTimeMs + 33,
                              clip.durationMs - 33,
                              clip.sourceInMs + 33,
                              clip.sourceOutMs,
                            );
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          TimeUtils.formatTimecode(clip.sourceInMs),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () {
                          if (clip.sourceInMs >= 33 && clip.startTimeMs >= 33) {
                            onApplyTrim(
                              clip.startTimeMs - 33,
                              clip.durationMs + 33,
                              clip.sourceInMs - 33,
                              clip.sourceOutMs,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Trim Tail
              Column(
                children: [
                  const Text('Trim End', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: () {
                          if (clip.durationMs > 200) {
                            onApplyTrim(
                              clip.startTimeMs,
                              clip.durationMs - 33,
                              clip.sourceInMs,
                              clip.sourceOutMs - 33,
                            );
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          TimeUtils.formatTimecode(clip.sourceOutMs),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () {
                          onApplyTrim(
                            clip.startTimeMs,
                            clip.durationMs + 33,
                            clip.sourceInMs,
                            clip.sourceOutMs + 33,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
