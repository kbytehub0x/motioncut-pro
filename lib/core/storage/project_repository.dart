import 'dart:io';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/core/utils/file_utils.dart';
import 'package:motioncut_pro/core/storage/local_storage.dart';

class ProjectRepository {
  final LocalStorage _localStorage;

  ProjectRepository(this._localStorage);

  Future<File> _getProjectFile(String projectId) async {
    final dir = await FileUtils.getAppProjectDirectory();
    return File('${dir.path}/$projectId.json');
  }

  Future<List<ProjectModel>> getAllProjects() async {
    final dir = await FileUtils.getAppProjectDirectory();
    if (!await dir.exists()) return [];

    final List<ProjectModel> projects = [];
    final files = dir.listSync();

    for (final entity in files) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final content = await entity.readAsString();
          final project = ProjectModel.fromJson(content);
          projects.add(project);
        } catch (e) {
          // ignore corrupted or invalid files
        }
      }
    }

    // Sort by last modified descending
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  Future<ProjectModel?> getProjectById(String id) async {
    try {
      final file = await _getProjectFile(id);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return ProjectModel.fromJson(content);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProject(ProjectModel project) async {
    final file = await _getProjectFile(project.id);
    await file.writeAsString(project.toJson(), flush: true);

    // Update index
    final ids = _localStorage.getSavedProjectIds();
    if (!ids.contains(project.id)) {
      ids.insert(0, project.id);
      await _localStorage.saveProjectIds(ids);
    }
  }

  Future<bool> deleteProject(String id) async {
    try {
      final file = await _getProjectFile(id);
      if (await file.exists()) {
        await file.delete();
      }
      final ids = _localStorage.getSavedProjectIds();
      ids.remove(id);
      await _localStorage.saveProjectIds(ids);
      return true;
    } catch (_) {
      return false;
    }
  }
}
