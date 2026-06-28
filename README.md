# Stocker - Stock Inventory Management App

A Flutter-based inventory management application for tracking daily stock levels across multiple shops/stores with real-time data persistence, PDF export, and multi-theme support.

## 📱 Features Implemented

### Authentication & User Management
- **PIN-based Authentication System**
  - First-time user setup with username and 4-digit PIN
  - Secure PIN verification for existing users
  - Individual PIN digit input boxes with auto-focus
  - Reset all data functionality with confirmation dialog

- **Username Management**
  - Edit username via FAB menu on main screen
  - Personalized greeting with time-based salutation (Morning/Afternoon/Evening)
  - User profile persistence via Hive database

### Theme System
- **4 Color Themes**
  - Blue (Default)
  - Green
  - Orange
  - Dark Mode
  
- **Theme-Aware Styling**
  - Dynamic color application across all screens
  - Gradient backgrounds adapt to selected theme
  - Text colors adjust for readability in dark mode
  - Theme preference saved to Hive database

### Stock Management
- **Multi-Shop Support**
  - Separate inventory tracking for each shop
  - Tab-based navigation between shop inventories
  - Quick shop selection screen

- **Daily Stock Tracking**
  - Opening stock (bold italic, theme-aware coloring)
  - Removed items/returns (orange colored)
  - Added items (green colored)
  - Closing stock (red bold colored)
  - Automatic day transition with data rollover

- **Input Improvements**
  - Multi-digit value capture fixed (ValueKey optimization)
  - All fields accept user input without truncation
  - Auto-select text on field tap
  - Real-time value updating

- **Stock Item Display**
  - Item name with theme-aware coloring
  - Rate/price entry field
  - Visual summary with Sold and Earnings calculations
  - Delete functionality per item
  - Scrollable field layout for mobile devices

### Data Management
- **Hive Database Integration**
  - User profile box (username, PIN)
  - Theme preference box
  - Stock data boxes (organized by date and shop)
  - Persistent local storage

- **Daily Data Lifecycle**
  - Load today's data or create new from previous day's closing
  - Closing stock from previous day becomes opening stock for new day
  - Automatic entry list initialization
  - Day finish triggers data save and next day load

- **Data Reset**
  - User-initiated reset all data from login screen
  - Clears all Hive boxes safely
  - Automatic re-initialization of services
  - Smooth navigation back to setup screen

### PDF Generation
- **Professional PDF Export**
  - Daily inventory report generation
  - Multiple page support for large inventories
  - Times Roman font with Unicode support
  - Proper page pagination
  - Summary statistics included

### UI/UX Enhancements
- **Initialization Screen**
  - Full-screen gradient background
  - Name input with person icon
  - 4-digit PIN entry boxes
  - Theme-consistent styling
  - "Skip for now" option

- **Login Screen**
  - Personalized "Welcome back, {name}" message
  - 4-digit PIN unlock interface
  - Auto-focus between PIN boxes
  - Reset data option
  - Theme-aware gradient background

- **Dashboard Screen**
  - Shop-specific inventory tabs
  - Real-time stock calculations
  - Day finish button with snackbar feedback
  - Animated title and shop buttons
  - Pulse animation on shop cards

- **Overflow Prevention**
  - Custom dialog with SingleChildScrollView for name editing
  - Proper keyboard handling with resizeToAvoidBottomInset: false
  - Full-screen gradients maintained during keyboard interaction
  - Dynamic text field sizes

### Bug Fixes & Optimizations
- ✅ TextFormField to TextEditingController migration for editable fields
- ✅ Multi-digit input truncation issue resolved (ValueKey fix)
- ✅ Opening stock transfer from previous day's closing
- ✅ Closing stock reset to 0 on new day
- ✅ Dark theme text visibility with 75% opacity
- ✅ Edit name dialog overflow prevention
- ✅ Initialization screen background full coverage
- ✅ Black screen after data reset
- ✅ Package namespace updated to com.svc.stocker

## 🛠️ Technical Stack

- **Flutter SDK:** ^3.12.2
- **Dart:** Latest stable
- **Target:** Android 12+ (API 31+)

### Dependencies
- **hive** ^2.2.3 - Local data persistence
- **hive_flutter** ^1.1.0 - Flutter integration
- **pdf** ^3.10.7 - PDF generation
- **printing** ^5.11.0 - PDF output & preview
- **file_picker** ^10.3.10 - File selection
- **intl** ^0.19.0 - Internationalization & date formatting
- **path_provider** ^2.1.1 - File system access

## 📊 Database Architecture (Hive)

**Boxes:**
- `user_profile_box` - username (String), pin (String)
- `theme_box` - current_theme (String: 'default'|'green'|'orange'|'dark')
- `stocker_box` - keys: "date_{shopName}_{YYYY-MM-DD}" → List<StockItem>

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.12.2 or higher
- Android SDK with API level 31+
- Dart latest stable version

### Installation
```bash
# Clone repository
git clone <repo-url>
cd stocker

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run --release
```

### Building APK
```bash
flutter build apk --release
```

APK Location: `build/app/outputs/flutter-apk/app-release.apk`

## 📝 Usage

1. **First Time Setup**
   - Enter your name
   - Set a 4-digit PIN
   - Select your shop
   - Start tracking inventory

2. **Daily Workflow**
   - Enter opening stock (auto-populated from yesterday's closing)
   - Log returned items (removed)
   - Log added items (new stock)
   - Enter closing stock
   - Review summary (Sold, Earnings)
   - Finish day to save and move to next day

3. **Theme Switching**
   - Tap FAB menu on dashboard
   - Select desired theme
   - Changes apply immediately across app

4. **Data Export**
   - Generate PDF reports for daily inventory
   - Share or save locally

## 🎨 App Screens

1. **Splash Screen** - Animated intro with automatic navigation
2. **Initialization Screen** - First-time user setup
3. **Login Screen** - PIN-based authentication
4. **Shop Selection Screen** - Choose shop with personalized greeting
5. **Dashboard Screen** - Main inventory management interface
6. **PDF Preview** - Report generation and export

## 🔒 Security

- PIN stored locally via Hive
- No server-side storage
- User-controlled data reset
- Local file system access only

## 📄 License

This project is provided as-is for inventory management purposes.

## 🐛 Known Issues

- file_picker plugin requires Kotlin Gradle Plugin migration (Future warning)
- Some compiled libraries available for newer versions (See `flutter pub outdated`)

## 📞 Support

For issues or feature requests, please refer to the project repository issues section.
