import 'package:uuid/uuid.dart';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/models/track_model.dart';
import 'package:motioncut_pro/models/clip_model.dart';
import 'package:motioncut_pro/models/effect_model.dart';
import 'package:motioncut_pro/core/storage/project_repository.dart';

class ProjectManagerService {
  final ProjectRepository _repository;
  final _uuid = const Uuid();

  ProjectManagerService(this._repository);

  Future<List<ProjectModel>> listProjects() async {
    final projects = await _repository.getAllProjects();
    if (projects.isEmpty) {
      // Seed with a sample starter project if brand new
      final starter = createStarterDemoProject();
      await _repository.saveProject(starter);
      return [starter];
    }
    return projects;
  }

  Future<ProjectModel?> loadProject(String id) async {
    return _repository.getProjectById(id);
  }

  Future<void> saveProject(ProjectModel project) async {
    await _repository.saveProject(project);
  }

  Future<bool> deleteProject(String id) async {
    return _repository.deleteProject(id);
  }

  /// Creates a clean blank project with standard multi-track timeline configuration
  ProjectModel createNewProject({
    String? title,
    AspectRatioType aspectRatio = AspectRatioType.portrait9_16,
  }) {
    final now = DateTime.now();
    final projectId = _uuid.v4();

    return ProjectModel(
      id: projectId,
      title: title ?? 'Project ${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      createdAt: now,
      updatedAt: now,
      aspectRatio: aspectRatio,
      fps: 30,
      tracks: [
        TrackModel(
          id: _uuid.v4(),
          name: 'Text & Titles',
          type: TrackType.text,
          order: 0,
          clips: [],
        ),
        TrackModel(
          id: _uuid.v4(),
          name: 'Overlay / B-Roll',
          type: TrackType.overlayVideo,
          order: 1,
          clips: [],
        ),
        TrackModel(
          id: _uuid.v4(),
          name: 'Main Video',
          type: TrackType.mainVideo,
          order: 2,
          clips: [],
        ),
        TrackModel(
          id: _uuid.v4(),
          name: 'Audio / BGM',
          type: TrackType.audio,
          order: 3,
          clips: [],
        ),
      ],
    );
  }

  /// Creates a ready-to-test starter demo project with populated tracks
  ProjectModel createStarterDemoProject() {
    final now = DateTime.now();
    final projectId = 'demo_project_01';
    final mainTrackId = _uuid.v4();
    final overlayTrackId = _uuid.v4();
    final audioTrackId = _uuid.v4();
    final textTrackId = _uuid.v4();

    return ProjectModel(
      id: projectId,
      title: 'Neon Cyberpunk Reel',
      createdAt: now,
      updatedAt: now,
      aspectRatio: AspectRatioType.portrait9_16,
      fps: 30,
      tracks: [
        TrackModel(
          id: textTrackId,
          name: 'Text & Titles',
          type: TrackType.text,
          order: 0,
          clips: [
            ClipModel(
              id: _uuid.v4(),
              trackId: textTrackId,
              type: ClipType.text,
              name: 'Title: MOTIONCUT',
              sourcePath: '',
              startTimeMs: 500,
              durationMs: 3000,
              sourceOutMs: 3000,
              textContent: 'MOTIONCUT PRO',
              textColorValue: 0xFF05D9E8,
              fontSize: 28.0,
            ),
          ],
        ),
        TrackModel(
          id: overlayTrackId,
          name: 'Overlay / B-Roll',
          type: TrackType.overlayVideo,
          order: 1,
          clips: [
            ClipModel(
              id: _uuid.v4(),
              trackId: overlayTrackId,
              type: ClipType.video,
              name: 'Cyber_Glitch_Overlay.mp4',
              sourcePath: 'assets/samples/cyber_glitch.mp4',
              startTimeMs: 1800,
              durationMs: 3200,
              sourceOutMs: 3200,
              blendMode: BlendModeType.screen,
              opacity: 0.85,
            ),
          ],
        ),
        TrackModel(
          id: mainTrackId,
          name: 'Main Video',
          type: TrackType.mainVideo,
          order: 2,
          clips: [
            ClipModel(
              id: _uuid.v4(),
              trackId: mainTrackId,
              type: ClipType.video,
              name: 'Intro_Shot_A.mp4',
              sourcePath: 'assets/samples/intro_shot.mp4',
              startTimeMs: 0,
              durationMs: 4000,
              sourceOutMs: 4000,
              effects: [
                EffectModel(
                  id: 'color_fx_1',
                  type: EffectType.colorAdjust,
                  name: 'Color Grading',
                  parameters: {'brightness': 0.05, 'contrast': 1.15, 'saturation': 1.25},
                ),
              ],
            ),
            ClipModel(
              id: _uuid.v4(),
              trackId: mainTrackId,
              type: ClipType.video,
              name: 'Action_B.mp4',
              sourcePath: 'assets/samples/action_shot.mp4',
              startTimeMs: 4000,
              durationMs: 4500,
              sourceOutMs: 4500,
              speed: 1.25,
            ),
          ],
        ),
        TrackModel(
          id: audioTrackId,
          name: 'Audio / BGM',
          type: TrackType.audio,
          order: 3,
          clips: [
            ClipModel(
              id: _uuid.v4(),
              trackId: audioTrackId,
              type: ClipType.audio,
              name: 'Synthwave_Beat.wav',
              sourcePath: 'assets/samples/synthwave_beat.wav',
              startTimeMs: 0,
              durationMs: 8500,
              sourceOutMs: 8500,
              volume: 0.85,
            ),
          ],
        ),
      ],
    );
  }
}
