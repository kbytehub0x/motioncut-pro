import 'package:flutter/material.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/models/project_model.dart';

class ProjectActions {
  /// Shows modal sheet to configure and create a new project
  static Future<Map<String, dynamic>?> showNewProjectDialog(BuildContext context) {
    String title = 'Untitled Project';
    AspectRatioType selectedRatio = AspectRatioType.portrait9_16;
    int selectedFps = 30;

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Project',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Project Name Field
                  TextField(
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Project Name',
                      hintText: 'e.g. TikTok Dance Reel',
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) => title = val.trim(),
                  ),
                  const SizedBox(height: 16),

                  // Aspect Ratio Selector
                  const Text('Canvas Aspect Ratio', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: AspectRatioType.values.map((ratio) {
                      final isSelected = ratio == selectedRatio;
                      return ChoiceChip(
                        label: Text(ratio.label),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        onSelected: (_) {
                          setModalState(() => selectedRatio = ratio);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Frame Rate (FPS) Selector - Alight Motion inspired
                  const Text('Frame Rate (FPS)', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: const [
                      {'fps': 12, 'label': '12 fps'},
                      {'fps': 15, 'label': '15 fps'},
                      {'fps': 24, 'label': '24 fps (Cinema)'},
                      {'fps': 30, 'label': '30 fps (Standard)'},
                      {'fps': 60, 'label': '60 fps (Smooth)'},
                    ].map((item) {
                      final val = item['fps'] as int;
                      final label = item['label'] as String;
                      final isSelected = val == selectedFps;
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        onSelected: (_) {
                          setModalState(() => selectedFps = val);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop({
                          'title': title.isEmpty ? 'Untitled Project' : title,
                          'aspectRatio': selectedRatio,
                          'fps': selectedFps,
                        });
                      },
                      child: const Text('Start Editing', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
