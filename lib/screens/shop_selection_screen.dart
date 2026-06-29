import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../screens/dashboard_screen.dart';
import '../services/theme_service.dart';
import '../services/user_profile_service.dart';
import '../services/import_service.dart';
import '../services/data_persistence_service.dart';
import '../constants/app_constants.dart';
import '../utils/theme_helper.dart';
import '../utils/ui_helpers.dart';

class ShopSelectionScreen extends StatefulWidget {
  const ShopSelectionScreen({super.key});

  @override
  State<ShopSelectionScreen> createState() => _ShopSelectionScreenState();
}

class _ShopSelectionScreenState extends State<ShopSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _sweetsController;
  late AnimationController _snacksController;
  late AnimationController _titleController;
  late Animation<double> _sweetsScale;
  late Animation<double> _snacksScale;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late String _currentTheme;
  late String _username;
  late String _greeting;

  @override
  void initState() {
    super.initState();
    _currentTheme = ThemeService.getCurrentTheme();
    _username = UserProfileService.getUsername() ?? 'User';
    _greeting = _getGreeting();

    // Title animation controller
    _titleController = AnimationController(
      duration: AppConstants.durationTitleAnimation,
      vsync: this,
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: AppConstants.curveEaseInOut,
      ),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _titleController,
            curve: AppConstants.curveEaseOutCubic,
          ),
        );

    // Dairy button controller with pulse animation
    _sweetsController = AnimationController(
      duration: AppConstants.durationButtonPulse,
      vsync: this,
    )..repeat(reverse: true);

    _sweetsScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _sweetsController,
        curve: AppConstants.curveEaseInOut,
      ),
    );

    // Snacks button controller with pulse animation
    _snacksController = AnimationController(
      duration: AppConstants.durationButtonPulse,
      vsync: this,
    )..repeat(reverse: true);

    _snacksScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _snacksController,
        curve: AppConstants.curveEaseInOut,
      ),
    );

    _titleController.forward();

    Future.delayed(AppConstants.durationButtonStagger1, () {
      if (mounted) _sweetsController.forward();
    });

    Future.delayed(AppConstants.durationButtonStagger2, () {
      if (mounted) _snacksController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sweetsController.dispose();
    _snacksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeColors = ThemeHelper.getGradient(_currentTheme);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Action Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.exit_to_app, color: Colors.white70),
                      tooltip: 'Exit App',
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          tooltip: 'Edit Name',
                          onPressed: _showEditNameDialog,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.upload_file, color: Colors.white70),
                          tooltip: 'Import CSV/Excel',
                          onPressed: _showShopSelectionDialog,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Title Section (Centered)
                          FadeTransition(
                            opacity: _titleFade,
                            child: SlideTransition(
                              position: _titleSlide,
                              child: Column(
                                children: [
                                  Text(
                                    "Hi, "+_username,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _greeting,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 4,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: LinearGradient(
                                        colors: ThemeHelper.getTitleDecorativeGradient(
                                          _currentTheme,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppConstants.welcomeToStockerText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppConstants.chooseShopText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Shop Cards
                          ScaleTransition(
                            scale: _sweetsScale,
                            child: UIHelpers.buildShopCard(
                              context: context,
                              shopName: AppConstants.shopSweetsName,
                              backgroundColor: ThemeHelper.getCardBackgroundColor(
                                _currentTheme,
                                0,
                              ),
                              accentColor: ThemeHelper.getCardAccentColor(
                                _currentTheme,
                                0,
                              ),
                              icon: Icons.cake,
                              onTap: () => _navigateToDashboard(
                                context,
                                AppConstants.shopSweetsName,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ScaleTransition(
                            scale: _snacksScale,
                            child: UIHelpers.buildShopCard(
                              context: context,
                              shopName: AppConstants.shopSnacksName,
                              backgroundColor: ThemeHelper.getCardBackgroundColor(
                                _currentTheme,
                                1,
                              ),
                              accentColor: ThemeHelper.getCardAccentColor(
                                _currentTheme,
                                1,
                              ),
                              icon: Icons.fastfood,
                              onTap: () => _navigateToDashboard(
                                context,
                                AppConstants.shopSnacksName,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Bottom Change Theme Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton.icon(
                  onPressed: _showThemeSelectionDialog,
                  icon: const Icon(Icons.palette, color: Colors.white70, size: 20),
                  label: const Text(
                    'Change Theme',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, String shopName) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: AppConstants.durationPageTransition,
        pageBuilder: (context, animation, secondaryAnimation) =>
            DashboardScreen(shopName: shopName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: AppConstants.curveEaseInOut));
          var offsetAnimation = animation.drive(tween);
          var fadeAnimation = animation.drive(
            Tween<double>(begin: 0.0, end: 1.0),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
      ),
    );
  }

  Future<void> _showShopSelectionDialog() async {
    final shopNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(AppConstants.selectShopForImportText),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppConstants.chooseShopForImportText,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...AppConstants.predefinedShops.map(
                (shop) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: ThemeHelper.getFabBackgroundColor(
                        _currentTheme,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _importFile(shop);
                    },
                    child: Text(
                      shop,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                AppConstants.orEnterCustomShopText,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: shopNameController,
                decoration: InputDecoration(
                  hintText: AppConstants.customShopNameHintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusSmall,
                    ),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(AppConstants.cancelText),
                  ),
                  ElevatedButton(
                    onPressed: shopNameController.text.isNotEmpty
                        ? () {
                            Navigator.pop(context);
                            _importFile(shopNameController.text);
                          }
                        : null,
                    child: const Text(AppConstants.importText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importFile(String shopName) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        dialogTitle: 'Select CSV or Excel file for $shopName',
      );

      if (result != null && result.files.single.path != null) {
        try {
          final items = await ImportService.importFromFile(
            result.files.single.path!,
          );
          await DataPersistenceService.saveDayData(
            shopName: shopName,
            items: items,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Imported ${items.length} items to $shopName'),
                backgroundColor: Colors.green,
                duration: AppConstants.durationSnackbarLong,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Import error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File picker error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _changeTheme(String newTheme) {
    setState(() => _currentTheme = newTheme);
    ThemeService.saveTheme(newTheme);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning!';
    } else if (hour < 17) {
      return 'Good afternoon!';
    } else {
      return 'Good evening!';
    }
  }

  void _showEditNameDialog() {
    final editController = TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppConstants.editNameText,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: editController,
                  decoration: const InputDecoration(
                    hintText: AppConstants.enterNameText,
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(AppConstants.cancelText),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (editController.text.isNotEmpty) {
                          try {
                            await UserProfileService.updateUsername(
                              editController.text,
                            );
                            setState(() => _username = editController.text);
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Name updated successfully'),
                                  duration: AppConstants.durationSnackbar,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a name'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('Select Theme'),
        children: [
          _buildThemeDialogOption(
            'default',
            'Default (Blue)',
            AppConstants.colorDefaultTertiary,
          ),
          _buildThemeDialogOption(
            'green',
            'Green',
            AppConstants.colorGreenTertiary,
          ),
          _buildThemeDialogOption(
            'orange',
            'Orange',
            AppConstants.colorOrangeTertiary,
          ),
          _buildThemeDialogOption(
            'dark',
            'Dark',
            AppConstants.colorDarkTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeDialogOption(
    String themeValue,
    String themeName,
    Color color,
  ) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.of(context).pop();
        _changeTheme(themeValue);
      },
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: _currentTheme == themeValue
                ? const Icon(Icons.check, size: 10, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(themeName),
        ],
      ),
    );
  }
}
