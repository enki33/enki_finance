import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _initPrefs();
  }

  late SharedPreferences _prefs;
  static const String _themePreferenceKey = 'theme_mode';

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final themeString = _prefs.getString(_themePreferenceKey);
    if (themeString != null) {
      state = _themeStringToMode(themeString);
    }
  }

  ThemeMode _themeStringToMode(String themeString) {
    switch (themeString) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themePreferenceKey, mode.name);
    state = mode;
  }
}
