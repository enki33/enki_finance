import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _themePreferenceKey = 'theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themePreferenceKey);
      if (themeString != null) {
        state = _themeStringToMode(themeString);
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  ThemeMode _themeStringToMode(String themeString) {
    switch (themeString.toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _themePreferenceKey, mode.toString().split('.').last);
      state = mode;
      debugPrint('Theme mode set to: ${mode.toString()}');
    } catch (e) {
      debugPrint('Error setting theme mode: $e');
    }
  }
}
