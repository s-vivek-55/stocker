import 'package:flutter/material.dart';

/// Central constants file for the entire app
class AppConstants {
  // ==================== App Strings ====================
  static const String appName = 'Stocker';
  static const String appSubtitle = 'Inventory Management System';

  // Shop Names
  static const String shopSweetsName = 'Saikrupa Sweets';
  static const String shopSnacksName = 'Saikrupa Snacks';
  static const String shopGeneralName = 'General Store';
  static const String shopImportedName = 'Imported';

  static const List<String> predefinedShops = [
    shopSweetsName,
    shopSnacksName,
    shopGeneralName,
  ];

  // UI Text
  static const String welcomeText = 'Welcome!';
  static const String letsGetStartedText = "Let's get started";
  static const String welcomeToStockerText = 'Welcome to Stocker';
  static const String chooseShopText = 'Choose your shop to manage inventory';
  static const String enterNameText = 'Enter your name';
  static const String enter4DigitPinText = 'Enter 4-Digit PIN';
  static const String selectShopForImportText = 'Select Shop for Import';
  static const String chooseShopForImportText =
      'Choose which shop to import data for:';
  static const String orEnterCustomShopText = 'Or enter custom shop name:';
  static const String customShopNameHintText = 'Custom shop name';
  static const String tapToManageInventoryText = 'Tap to manage inventory';
  static const String proceedText = 'Proceed';
  static const String skipText = 'Skip';
  static const String editNameText = 'Edit Name';
  static const String importCsvExcelText = 'Import CSV/Excel';
  static const String editText = 'Edit';
  static const String cancelText = 'Cancel';
  static const String importText = 'Import';
  static const String addItemText = 'Add Item';
  static const String generateReportText = 'Generate Report';
  static const String finishDayText = 'Finish Day';
  static const String resetAllDataText = 'Reset All Data';
  static const String addNewItemText = 'Add New Item';
  static const String generateReportDialogText = 'Generate Report';
  static const String selectDateRangeText = 'Select Date Range';
  static const String startDateText = 'Start Date';
  static const String endDateText = 'End Date';
  static const String generateText = 'Generate';
  static const String finishDayConfirmText = 'Finish Day';
  static const String finishDayDescriptionText =
      'This will move today\'s closing stock to tomorrow\'s opening stock.';
  static const String resetDataWarningText =
      'Are you sure? This will delete all data for this shop.';
  static const String resetDataConfirmText = 'Reset';

  // ==================== Colors - Default Theme ====================
  static const Color colorDefaultPrimary = Color(0xFF1a237e);
  static const Color colorDefaultSecondary = Color(0xFF283593);
  static const Color colorDefaultTertiary = Color(0xFF3f51b5);

  // ==================== Colors - Green Theme ====================
  static const Color colorGreenPrimary = Color(0xFF1B5E20);
  static const Color colorGreenSecondary = Color(0xFF2E7D32);
  static const Color colorGreenTertiary = Color(0xFF388E3C);
  static const Color colorGreenAccent = Color(0xFF81C784);

  // ==================== Colors - Orange Theme ====================
  static const Color colorOrangePrimary = Color(0xFFE65100);
  static const Color colorOrangeSecondary = Color(0xFFF57C00);
  static const Color colorOrangeTertiary = Color(0xFFFF9800);
  static const Color colorOrangeAccent = Color(0xFFFFB74D);

  // ==================== Colors - Dark Theme ====================
  static const Color colorDarkPrimary = Color(0xFF1a1a1a);
  static const Color colorDarkSecondary = Color(0xFF2d2d2d);
  static const Color colorDarkTertiary = Color(0xFF424242);
  static const Color colorDarkBg = Color(0xFF37474F);
  static const Color colorDarkCard = Color(0xFF455A64);
  static const Color colorDarkAccent = Color(0xFF90CAF9);

  // ==================== Common Colors ====================
  static const Color colorWhite = Colors.white;
  static const Color colorBlack = Colors.black;
  static const Color colorGrey = Colors.grey;
  static const Color colorGreen = Colors.green;
  static const Color colorRed = Colors.red;
  static const Color colorOrange = Colors.orange;

  // ==================== Stock Field Colors ====================
  static const Color fieldColorOpening = Color.fromARGB(
    255,
    0,
    0,
    0,
  ); // Bold Italic
  static const Color fieldColorRemoved = Color.fromARGB(
    255,
    255,
    152,
    0,
  ); // Orange
  static const Color fieldColorAdded = Color.fromARGB(
    255,
    76,
    175,
    80,
  ); // Green
  static const Color fieldColorClosing = Color.fromARGB(
    255,
    244,
    67,
    54,
  ); // Red Bold
  static const double fieldOpacityDarkMode = 0.75;

  // ==================== Durations & Timings ====================
  static const Duration durationTitleAnimation = Duration(milliseconds: 800);
  static const Duration durationButtonPulse = Duration(milliseconds: 1200);
  static const Duration durationButtonStagger1 = Duration(milliseconds: 600);
  static const Duration durationButtonStagger2 = Duration(milliseconds: 900);
  static const Duration durationPageTransition = Duration(milliseconds: 600);
  static const Duration durationDialogAnimation = Duration(milliseconds: 300);
  static const Duration durationSplashAnimation = Duration(seconds: 3);
  static const Duration durationSnackbar = Duration(seconds: 2);
  static const Duration durationSnackbarLong = Duration(seconds: 3);

  // ==================== Pagination ====================
  static const int itemsPerDashboardPage1 = 41;
  static const int itemsPerDashboardPage2 = 47;
  static const int itemsPerPdfPage = 15;
  static const int maxItemsPerPage = 88;

  // ==================== PIN & Input ====================
  static const int pinLength = 4;
  static const int pinBoxSize = 60;

  // ==================== Border Radius ====================
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;

  // ==================== Padding & Spacing ====================
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 20.0;
  static const double paddingXXLarge = 24.0;

  // ==================== Font Sizes ====================
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeTitle = 36.0;

  // ==================== Hive Storage Keys ====================
  static const String hiveThemeBoxName = 'theme_box';
  static const String hiveThemeCurrentKey = 'current_theme';
  static const String hiveThemeDefault = 'default';

  static const String hiveProfileBoxName = 'user_profile_box';
  static const String hiveProfileUsernameKey = 'username';
  static const String hiveProfilePinKey = 'pin';

  static const String hiveDataBoxName = 'stocker_box';
  static const String hiveDataDateKeyPrefix = 'date_';

  // ==================== Date & Time ====================
  static const String dateFormatDefault = 'yyyy-MM-dd';
  static const String dateFormatDisplay = 'dd MMM yyyy';

  // ==================== Animation Curves ====================
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveEaseOutCubic = Curves.easeOutCubic;
  static const Curve curveLinear = Curves.linear;
}
