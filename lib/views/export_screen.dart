import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/core/di/di_setup.dart';
import 'package:motioncut_pro/core/utils/file_utils.dart';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/export_profile_model.dart';
import 'package:motioncut_pro/services/ffmpeg/ffmpeg_progress_parser.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const ExportScreen({super.key, required this.project});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  late ExportProfileModel _profile;
  bool _isExporting = false;
  FfmpegProgress? _progress;
  String? _exportedFilePath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profile = widget.project.exportProfile;
  }

  Future<void> _startExport() async {
    setState(() {
      _isExporting = true;
      _progress = const FfmpegProgress();
      _errorMessage = null;
      _exportedFilePath = null;
    });

    final ffmpeg = ref.read(ffmpegServiceProvider);
    final exportDir = await FileUtils.getExportDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = _profile.container == VideoContainer.mp4 ? 'mp4' : 'mov';
    final outputPath = '${exportDir.path}/export_${widget.project.id}_$timestamp.$extension';

    // Update project with active profile
    final updatedProject = widget.project.copyWith(exportProfile: _profile);

    final success = await ffmpeg.renderProject(
      project: updatedProject,
      outputPath: outputPath,
      onProgress: (p) {
        if (mounted) {
          setState(() => _progress = p);
        }
      },
    );

    if (mounted) {
      setState(() {
        _isExporting = false;
        if (success) {
          _exportedFilePath = outputPath;
        } else {
          _errorMessage = 'Export failed or was cancelled.';
        }
      });
    }
  }

  Future<void> _cancelExport() async {
    final ffmpeg = ref.read(ffmpegServiceProvider);
    await ffmpeg.cancelCurrentTask();
    setState(() {
      _isExporting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Export & Render Video'),
        actions: [
          if (!_isExporting && _exportedFilePath == null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.movie_creation, size: 18),
                label: const Text('Export'),
                onPressed: _startExport,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Section during Export
            if (_isExporting) _buildProgressCard(),

            // Success Card
            if (_exportedFilePath != null) _buildSuccessCard(),

            // Error Card
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.white70))),
                  ],
                ),
              ),

            // Profile Options
            _buildProfileSettings(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final p = _progress ?? const FfmpegProgress();
    final pct = (p.percentage * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Rendering via FFmpeg ($pct%)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              TextButton(
                onPressed: _cancelExport,
                child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: p.percentage,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('FPS: ${p.fps.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
              Text('Frame: ${p.currentFrame}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
              Text('Speed: ${p.speed.toStringAsFixed(2)}x', style: const TextStyle(fontSize: 11, color: AppTheme.accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success),
              SizedBox(width: 8),
              Text(
                'Render Completed Successfully!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Saved to: $_exportedFilePath',
            style: const TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Output Format & Resolution',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 12),

        // Resolution choices
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ExportResolution.values.map((res) {
            final isSelected = _profile.resolution == res;
            return ChoiceChip(
              label: Text(res.label),
              selected: isSelected,
              selectedColor: AppTheme.primary,
              onSelected: (val) {
                if (val) setState(() => _profile = _profile.copyWith(resolution: res));
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Frame Rate (FPS)
        const Text('Frame Rate', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [24, 30, 60].map((fps) {
            final isSelected = _profile.fps == fps;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('${fps} FPS'),
                selected: isSelected,
                selectedColor: AppTheme.accent,
                onSelected: (val) {
                  if (val) setState(() => _profile = _profile.copyWith(fps: fps));
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Codec selection
        const Text('Video Codec', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: [
            ChoiceChip(
              label: const Text('H.264 (Universal MP4)'),
              selected: _profile.videoCodec == VideoCodec.h264,
              selectedColor: AppTheme.primary,
              onSelected: (_) => setState(() => _profile = _profile.copyWith(videoCodec: VideoCodec.h264)),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('HEVC / H.265 (High Efficiency)'),
              selected: _profile.videoCodec == VideoCodec.hevc,
              selectedColor: AppTheme.primary,
              onSelected: (_) => setState(() => _profile = _profile.copyWith(videoCodec: VideoCodec.hevc)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Bitrate Target
        Text(
          'Video Target Bitrate: ${(_profile.videoBitrateKbps / 1000).toStringAsFixed(1)} Mbps',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Slider(
          value: _profile.videoBitrateKbps.toDouble(),
          min: 4000,
          max: 40000,
          divisions: 9,
          activeColor: AppTheme.primary,
          onChanged: (val) {
            setState(() => _profile = _profile.copyWith(videoBitrateKbps: val.round()));
          },
        ),
      ],
    );
  }
}
