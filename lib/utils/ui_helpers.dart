import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'theme_helper.dart';

/// Helper class for common UI patterns and reusable widgets
class UIHelpers {
  /// Build a gradient button with customizable properties
  static Widget buildGradientButton({
    required String label,
    required VoidCallback onPressed,
    required List<Color> gradientColors,
    double height = 56,
    double borderRadius = AppConstants.borderRadiusMedium,
    double width = double.infinity,
    bool isLoading = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(colors: gradientColors),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Build a PIN entry box for authentication
  static Widget buildPinBox({
    required TextEditingController controller,
    required int boxNumber,
    required VoidCallback onChanged,
    required String currentTheme,
  }) {
    return Container(
      width: AppConstants.pinBoxSize.toDouble(),
      height: AppConstants.pinBoxSize.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: ThemeHelper.getFabBackgroundColor(currentTheme),
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(AppConstants.paddingMedium),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(_getContextFromController()).nextFocus();
          }
          onChanged();
        },
      ),
    );
  }

  /// Build a standard dialog with title, content, and actions
  static Future<T?> showStandardDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: content),
        actions: actions,
      ),
    );
  }

  /// Build a list of predefined shop buttons for import dialog
  static List<Widget> buildShopButtonList({
    required List<String> shops,
    required VoidCallback Function(String) onShopSelected,
    required Color buttonColor,
  }) {
    return shops
        .map(
          (shop) => Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
                backgroundColor: buttonColor,
              ),
              onPressed: () => onShopSelected(shop)(),
              child: Text(shop, style: const TextStyle(color: Colors.white)),
            ),
          ),
        )
        .toList();
  }

  /// Build a themed container with border
  static Widget buildThemedContainer({
    required Widget child,
    required String theme,
    double padding = AppConstants.paddingLarge,
    double borderRadius = AppConstants.borderRadiusMedium,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: child,
    );
  }

  /// Build a shop card with animations
  static Widget buildShopCard({
    required BuildContext context,
    required String shopName,
    required Color backgroundColor,
    required Color accentColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor.withOpacity(0.25),
                  backgroundColor.withOpacity(0.15),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingXLarge,
              vertical: AppConstants.paddingXXLarge,
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.15),
                  ),
                  child: Icon(icon, size: 40, color: Colors.white),
                ),
                const SizedBox(width: AppConstants.paddingXLarge),
                // Shop Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopName,
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeXXLarge,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      Text(
                        AppConstants.tapToManageInventoryText,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeMedium,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a header with gradient bar
  static Widget buildGradientHeader({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeTitle,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            gradient: LinearGradient(colors: gradientColors),
          ),
        ),
        const SizedBox(height: AppConstants.paddingLarge),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Text(
          'Choose your shop to manage inventory',
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Helper to get context from controller (internal use)
  static BuildContext _getContextFromController() {
    // This is a workaround - in actual use, context should be passed
    throw UnimplementedError('Pass context explicitly to onChanged');
  }
}
