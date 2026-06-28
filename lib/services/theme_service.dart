import 'package:hive/hive.dart';

/// Theme service for persisting and retrieving theme selection
class ThemeService {
  static const String _themeBoxName = 'theme_box';
  static const String _currentThemeKey = 'current_theme';
  static const String _defaultTheme = 'default';

  /// Initialize theme box and store default theme if not set
  static Future<void> initializeTheme() async {
    try {
      if (!Hive.isBoxOpen(_themeBoxName)) {
        await Hive.openBox<String>(_themeBoxName);
      }
      final box = Hive.box<String>(_themeBoxName);
      if (!box.containsKey(_currentThemeKey)) {
        await box.put(_currentThemeKey, _defaultTheme);
      }
    } catch (e) {
      print('Error initializing theme: $e');
    }
  }

  /// Get current selected theme
  static String getCurrentTheme() {
    try {
      if (Hive.isBoxOpen(_themeBoxName)) {
        final box = Hive.box<String>(_themeBoxName);
        return box.get(_currentThemeKey, defaultValue: _defaultTheme) ??
            _defaultTheme;
      }
    } catch (e) {
      print('Error getting theme: $e');
    }
    return _defaultTheme;
  }

  /// Save selected theme to Hive
  static Future<void> saveTheme(String theme) async {
    try {
      if (Hive.isBoxOpen(_themeBoxName)) {
        final box = Hive.box<String>(_themeBoxName);
        await box.put(_currentThemeKey, theme);
      }
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
}
