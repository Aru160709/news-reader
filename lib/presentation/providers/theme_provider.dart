import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_reader/core/constants/api_constants.dart';

/// Theme Provider
/// Provider untuk manage Dark/Light mode
class ThemeProvider with ChangeNotifier {
  final SharedPreferences prefs;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider({required this.prefs}) {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Return berdasarkan system setting
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Load theme mode dari storage
  void _loadThemeMode() {
    final savedTheme = prefs.getString(StorageKeys.themeMode);

    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    }
  }

  /// Toggle theme mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    await _saveThemeMode();
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveThemeMode();
    notifyListeners();
  }

  /// Save theme mode ke storage
  Future<void> _saveThemeMode() async {
    String themeString;

    switch (_themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }

    await prefs.setString(StorageKeys.themeMode, themeString);
  }
}
