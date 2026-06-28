import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Helper class for all theme-related operations
class ThemeHelper {
  /// Get gradient colors for current theme
  static List<Color> getGradient(String theme) {
    switch (theme) {
      case 'green':
        return const [
          AppConstants.colorGreenPrimary,
          AppConstants.colorGreenSecondary,
          AppConstants.colorGreenTertiary,
        ];
      case 'orange':
        return const [
          AppConstants.colorOrangePrimary,
          AppConstants.colorOrangeSecondary,
          AppConstants.colorOrangeTertiary,
        ];
      case 'dark':
        return const [
          AppConstants.colorDarkPrimary,
          AppConstants.colorDarkSecondary,
          AppConstants.colorDarkTertiary,
        ];
      case 'default':
      default:
        return const [
          AppConstants.colorDefaultPrimary,
          AppConstants.colorDefaultSecondary,
          AppConstants.colorDefaultTertiary,
        ];
    }
  }

  /// Get button gradient colors for current theme
  static List<Color> getButtonGradient(String theme) {
    switch (theme) {
      case 'green':
        return const [
          AppConstants.colorGreenSecondary,
          AppConstants.colorGreenPrimary,
        ];
      case 'orange':
        return const [
          AppConstants.colorOrangeSecondary,
          AppConstants.colorOrangePrimary,
        ];
      case 'dark':
        return const [AppConstants.colorDarkTertiary, Color(0xFF212121)];
      case 'default':
      default:
        return const [Color(0xFF42a5f5), Color(0xFF1e88e5)];
    }
  }

  /// Get title decorative gradient for current theme
  static List<Color> getTitleDecorativeGradient(String theme) {
    switch (theme) {
      case 'green':
        return const [Colors.white, Color(0xFF4CAF50)];
      case 'orange':
        return const [Colors.white, AppConstants.colorOrangeTertiary];
      case 'dark':
        return const [Colors.white70, Color(0xFF616161)];
      case 'default':
      default:
        return const [Colors.white, Colors.lightBlue];
    }
  }

  /// Get FAB background color for current theme
  static Color getFabBackgroundColor(String theme) {
    switch (theme) {
      case 'green':
        return AppConstants.colorGreenTertiary;
      case 'orange':
        return AppConstants.colorOrangeTertiary;
      case 'dark':
        return AppConstants.colorDarkTertiary;
      case 'default':
      default:
        return AppConstants.colorDefaultTertiary;
    }
  }

  /// Get card background color for current theme and index
  static Color getCardBackgroundColor(String theme, int cardIndex) {
    switch (theme) {
      case 'green':
        return cardIndex == 0
            ? AppConstants.colorGreenSecondary
            : AppConstants.colorGreenPrimary;
      case 'orange':
        return cardIndex == 0
            ? AppConstants.colorOrangeSecondary
            : AppConstants.colorOrangePrimary;
      case 'dark':
        return cardIndex == 0
            ? AppConstants.colorDarkCard
            : AppConstants.colorDarkBg;
      case 'default':
      default:
        return cardIndex == 0
            ? const Color(0xFF0d47a1)
            : const Color(0xFF1b5e20);
    }
  }

  /// Get card accent color for current theme
  static Color getCardAccentColor(String theme, [int cardIndex = 0]) {
    switch (theme) {
      case 'green':
        return AppConstants.colorGreenAccent;
      case 'orange':
        return AppConstants.colorOrangeAccent;
      case 'dark':
        return AppConstants.colorDarkAccent;
      case 'default':
      default:
        return cardIndex == 0
            ? const Color(0xFF42a5f5)
            : const Color(0xFF66bb6a);
    }
  }

  /// Get text color for current theme
  static Color getTextColor(String theme) {
    return theme == 'dark' ? Colors.white : Colors.black;
  }

  /// Get label text color based on theme (for field labels)
  static Color getLabelColor(String theme, String fieldType) {
    if (theme == 'dark') {
      return Colors.white.withOpacity(AppConstants.fieldOpacityDarkMode);
    }

    switch (fieldType) {
      case 'opening':
        return AppConstants.fieldColorOpening;
      case 'removed':
        return AppConstants.fieldColorRemoved;
      case 'added':
        return AppConstants.fieldColorAdded;
      case 'closing':
        return AppConstants.fieldColorClosing;
      default:
        return Colors.black;
    }
  }

  /// Get field value color based on field type and theme
  static Color getFieldValueColor(String theme, String fieldType) {
    if (theme == 'dark') {
      return Colors.white.withOpacity(AppConstants.fieldOpacityDarkMode);
    }

    switch (fieldType) {
      case 'opening':
        return AppConstants.fieldColorOpening;
      case 'removed':
        return AppConstants.fieldColorRemoved;
      case 'added':
        return AppConstants.fieldColorAdded;
      case 'closing':
        return AppConstants.fieldColorClosing;
      default:
        return Colors.black;
    }
  }

  /// Get background color for theme
  static Color getBackgroundColor(String theme) {
    switch (theme) {
      case 'dark':
        return AppConstants.colorDarkBg;
      default:
        return Colors.white;
    }
  }

  /// Get theme map with all color information
  static Map<String, Map<String, dynamic>> getThemeMap() {
    return {
      'default': {
        'colors': getGradient('default'),
        'cardColor': Colors.white,
        'textColor': Colors.black,
      },
      'green': {
        'colors': getGradient('green'),
        'cardColor': Colors.white,
        'textColor': Colors.black,
      },
      'orange': {
        'colors': getGradient('orange'),
        'cardColor': Colors.white,
        'textColor': Colors.black,
      },
      'dark': {
        'colors': getGradient('dark'),
        'cardColor': const Color(0xFF37474F),
        'textColor': Colors.white,
      },
    };
  }
}
