import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/core/constants.dart';
import 'package:motioncut_pro/core/di/di_setup.dart';
import 'package:motioncut_pro/models/project_model.dart';
import 'package:motioncut_pro/views/editor_screen.dart';
import 'package:motioncut_pro/views/settings_screen.dart';
import 'package:motioncut_pro/widgets/project/project_card.dart';
import 'package:motioncut_pro/widgets/project/project_actions.dart';
import 'package:motioncut_pro/widgets/common/confirm_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<ProjectModel> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    final manager = ref.read(projectManagerServiceProvider);
    final list = await manager.listProjects();
    setState(() {
      _projects = list;
      _isLoading = false;
    });
  }

  Future<void> _handleNewProject() async {
    final result = await ProjectActions.showNewProjectDialog(context);
    if (result == null) return;

    final manager = ref.read(projectManagerServiceProvider);
    final newProject = manager.createNewProject(
      title: result['title'] as String,
      aspectRatio: result['aspectRatio'] as AspectRatioType,
      fps: result['fps'] as int? ?? 30,
    );
    await manager.saveProject(newProject);
    await _loadProjects();

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditorScreen(project: newProject)),
    ).then((_) => _loadProjects());
  }

  Future<void> _handleDeleteProject(ProjectModel project) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Project?',
      message: 'Are you sure you want to delete "${project.title}"? This cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Colors.redAccent,
    );

    if (confirmed) {
      final manager = ref.read(projectManagerServiceProvider);
      await manager.deleteProject(project.id);
      _loadProjects();
    }
  }

  Future<void> _handleDuplicateProject(ProjectModel project) async {
    final manager = ref.read(projectManagerServiceProvider);
    final duplicated = project.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${project.title} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await manager.saveProject(duplicated);
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.movie_filter, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _loadProjects,
              color: AppTheme.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Hero "Create Project" CTA Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2B0A1A), Color(0xFF131524)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pro Mobile Video Editor',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Zero Watermark. 100% Offline FFmpeg Engine.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            'New Project',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: _handleNewProject,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Projects (${_projects.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                        onPressed: _loadProjects,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_projects.isEmpty)
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Center(
                        child: Text(
                          'No projects yet. Tap "+ New Project" to begin!',
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _projects.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.88,
                      ),
                      itemBuilder: (context, index) {
                        final proj = _projects[index];
                        return ProjectCard(
                          project: proj,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditorScreen(project: proj),
                              ),
                            ).then((_) => _loadProjects());
                          },
                          onDelete: () => _handleDeleteProject(proj),
                          onDuplicate: () => _handleDuplicateProject(proj),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
