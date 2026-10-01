import 'package:shared_preferences/shared_preferences.dart';
import 'package:motioncut_pro/core/constants.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  // Projects Index
  List<String> getSavedProjectIds() {
    return _prefs.getStringList(AppConstants.prefsRecentProjectsKey) ?? [];
  }

  Future<bool> saveProjectIds(List<String> ids) async {
    return _prefs.setStringList(AppConstants.prefsRecentProjectsKey, ids);
  }

  // Theme Mode
  bool get isDarkMode => _prefs.getBool(AppConstants.prefsThemeKey) ?? true;
  Future<bool> setDarkMode(bool value) async {
    return _prefs.setBool(AppConstants.prefsThemeKey, value);
  }

  // Proxy Previews
  bool get useProxyPreviews => _prefs.getBool(AppConstants.prefsProxyPreviewKey) ?? true;
  Future<bool> setUseProxyPreviews(bool value) async {
    return _prefs.setBool(AppConstants.prefsProxyPreviewKey, value);
  }

  // Custom storage directory override
  String? get customStorageDir => _prefs.getString(AppConstants.prefsStorageDirKey);
  Future<bool> setCustomStorageDir(String? path) async {
    if (path == null) {
      return _prefs.remove(AppConstants.prefsStorageDirKey);
    }
    return _prefs.setString(AppConstants.prefsStorageDirKey, path);
  }
}
