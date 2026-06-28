import 'package:hive_flutter/hive_flutter.dart';

/// Service to manage user profile (username and PIN) in Hive
class UserProfileService {
  static const String _profileBoxName = 'user_profile_box';
  static const String _usernameKey = 'username';
  static const String _pinKey = 'pin';

  /// Initialize the user profile box in Hive
  static Future<void> initializeUserProfile() async {
    try {
      if (!Hive.isBoxOpen(_profileBoxName)) {
        await Hive.openBox<String>(_profileBoxName);
      }
    } catch (e) {
      print('Error initializing user profile box: $e');
    }
  }

  /// Check if user has been set up (username exists)
  static bool isUserSetup() {
    try {
      final box = Hive.box<String>(_profileBoxName);
      return box.containsKey(_usernameKey);
    } catch (e) {
      print('Error checking if user setup: $e');
      return false;
    }
  }

  /// Get stored username
  static String? getUsername() {
    try {
      final box = Hive.box<String>(_profileBoxName);
      return box.get(_usernameKey);
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

  /// Save username and PIN
  static Future<void> saveUserProfile({
    required String username,
    required String pin,
  }) async {
    try {
      final box = Hive.box<String>(_profileBoxName);
      await box.put(_usernameKey, username);
      await box.put(_pinKey, pin);
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  /// Update username only
  static Future<void> updateUsername(String newUsername) async {
    try {
      final box = Hive.box<String>(_profileBoxName);
      await box.put(_usernameKey, newUsername);
    } catch (e) {
      print('Error updating username: $e');
      rethrow;
    }
  }

  /// Verify PIN
  static bool verifyPin(String enteredPin) {
    try {
      final box = Hive.box<String>(_profileBoxName);
      final storedPin = box.get(_pinKey);
      return storedPin == enteredPin;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  /// Clear user profile (for logout/reset)
  static Future<void> clearUserProfile() async {
    try {
      final box = Hive.box<String>(_profileBoxName);
      await box.clear();
    } catch (e) {
      print('Error clearing user profile: $e');
    }
  }

  /// Clear ALL Hive data (for fresh start)
  static Future<void> clearAllData() async {
    try {
      // Clear user profile box
      if (Hive.isBoxOpen(_profileBoxName)) {
        await Hive.box<String>(_profileBoxName).clear();
      }

      // Clear theme box
      if (Hive.isBoxOpen('theme_box')) {
        await Hive.box<String>('theme_box').clear();
      }

      // Clear stocker box (stock data)
      if (Hive.isBoxOpen('stocker_box')) {
        await Hive.box('stocker_box').clear();
      }

      print('All Hive data cleared successfully');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }
}
