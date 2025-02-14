import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF6200EE),
      primaryContainer: Color(0xFF3700B3),
      secondary: Color(0xFF6200EE),
      background: Color(0xFF121212),
      surface: Color(0xFF121212),
      error: Color(0xFFCF6679),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF121212),
      selectedItemColor: Color(0xFF6200EE),
      unselectedItemColor: Colors.white.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardTheme(
      color: Color(0xFF1E1E1E),
      elevation: 4,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6200EE),
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Color(0xFF6200EE);
        }
        return Colors.grey;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Color(0xFF6200EE).withOpacity(0.5);
        }
        return Colors.grey.withOpacity(0.5);
      }),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Colors.white.withOpacity(0.87)),
      bodyLarge: TextStyle(color: Colors.white.withOpacity(0.87)),
      bodyMedium: TextStyle(color: Colors.white.withOpacity(0.87)),
      bodySmall: TextStyle(color: Colors.white.withOpacity(0.6)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1E1E1E),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF6200EE)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.12),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Color(0xFF1E1E1E),
      elevation: 8,
    ),
  );
}
