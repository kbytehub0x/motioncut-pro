import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motioncut_pro/core/theme.dart';
import 'package:motioncut_pro/core/di/di_setup.dart';
import 'package:motioncut_pro/core/utils/file_utils.dart';
import 'package:motioncut_pro/widgets/common/confirm_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _useProxy = true;
  String _cacheSizeStr = 'Calculating...';
  String _storagePath = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = ref.read(localStorageProvider);
    final cacheService = ref.read(mediaCacheServiceProvider);
    final bytes = await cacheService.getCacheSizeInBytes();
    final projDir = await FileUtils.getAppProjectDirectory();

    setState(() {
      _useProxy = storage.useProxyPreviews;
      _cacheSizeStr = FileUtils.formatFileSize(bytes);
      _storagePath = projDir.path;
    });
  }

  Future<void> _clearCache() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Clear Cache?',
      message: 'This removes cached proxy frames and waveforms to free up device storage.',
      confirmText: 'Clear Cache',
    );

    if (confirmed) {
      final cacheService = ref.read(mediaCacheServiceProvider);
      await cacheService.clearAllCache();
      await _loadSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.read(localStorageProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Editor Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Performance & Rendering',
              style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          SwitchListTile(
            title: const Text('Generate Proxy Previews'),
            subtitle: const Text('Improves timeline scrub responsiveness on mobile', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: _useProxy,
            activeColor: AppTheme.primary,
            onChanged: (val) async {
              await storage.setUseProxyPreviews(val);
              setState(() => _useProxy = val);
            },
          ),
          const Divider(),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Storage & Cache',
              style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          ListTile(
            title: const Text('Storage Location'),
            subtitle: Text(_storagePath, style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'monospace')),
            leading: const Icon(Icons.folder_outlined, color: Colors.white70),
          ),
          ListTile(
            title: const Text('Temporary Cache Size'),
            subtitle: Text(_cacheSizeStr, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            leading: const Icon(Icons.cleaning_services_outlined, color: Colors.white70),
            trailing: OutlinedButton(
              onPressed: _clearCache,
              child: const Text('Clear'),
            ),
          ),
          const Divider(),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Engine Specifications',
              style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const ListTile(
            title: Text('Offline FFmpeg Engine'),
            subtitle: Text('Full native build with libx264, libx265, aac, amix, and libsoxr', style: TextStyle(color: Colors.white54, fontSize: 12)),
            leading: Icon(Icons.memory, color: Colors.white70),
          ),
          const ListTile(
            title: Text('Watermark Policy'),
            subtitle: Text('100% Free & Open Source. Zero brand watermarks.', style: TextStyle(color: AppTheme.success, fontSize: 12)),
            leading: Icon(Icons.verified, color: AppTheme.success),
          ),
        ],
      ),
    );
  }
}
