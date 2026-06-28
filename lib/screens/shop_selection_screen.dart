import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../services/theme_service.dart';
import '../services/user_profile_service.dart';

/// Shop selection screen with animations
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

  // Theme color definitions
  final Map<String, Map<String, dynamic>> _themes = {
    'default': {
      'colors': const [Color(0xFF1a237e), Color(0xFF283593), Color(0xFF3f51b5)],
      'cardColor': Colors.white,
      'textColor': Colors.black,
    },
    'green': {
      'colors': const [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
      'cardColor': Colors.white,
      'textColor': Colors.black,
    },
    'orange': {
      'colors': const [Color(0xFFE65100), Color(0xFFF57C00), Color(0xFFFF9800)],
      'cardColor': Colors.white,
      'textColor': Colors.black,
    },
    'dark': {
      'colors': const [Color(0xFF1a1a1a), Color(0xFF2d2d2d), Color(0xFF424242)],
      'cardColor': const Color(0xFF37474F),
      'textColor': Colors.white,
    },
  };

  @override
  void initState() {
    super.initState();
    _currentTheme = ThemeService.getCurrentTheme();

    // Load username from Hive
    _username = UserProfileService.getUsername() ?? 'User';

    // Generate greeting based on current time
    _greeting = _getGreeting();

    // Title animation controller
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeInOut),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
        );

    // Sweets button controller with pulse animation
    _sweetsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _sweetsScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _sweetsController, curve: Curves.easeInOut),
    );

    // Snacks button controller with pulse animation
    _snacksController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _snacksScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _snacksController, curve: Curves.easeInOut),
    );

    // Start title animation
    _titleController.forward();

    // Stagger the button animations
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _sweetsController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        _snacksController.forward();
      }
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
    final List<Color> themeColors = List<Color>.from(
      _themes[_currentTheme]!['colors'] as List,
    );
    final Color cardColor = _themes[_currentTheme]!['cardColor'] as Color;
    final Color textColor = _themes[_currentTheme]!['textColor'] as Color;

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
              // Animated Title Section
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.06,
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        // Greeting with username
                        Text(
                          'Hi $_username',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Time-based salutation
                        Text(
                          _greeting,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 4,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: _getTitleDecorativeGradient(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Welcome to Stocker subheading
                        Text(
                          'Welcome to Stocker',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose your shop to manage inventory',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Spacer
              SizedBox(height: size.height * 0.04),
              // Shop Buttons with Animations
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Saikrupa Sweets Button
                      ScaleTransition(
                        scale: _sweetsScale,
                        child: _buildShopCard(
                          context: context,
                          shopName: 'Saikrupa Sweets',
                          backgroundColor: _getCardBackgroundColor(0),
                          accentColor: _getCardAccentColor(0),
                          icon: Icons.cake,
                          onTap: () =>
                              _navigateToDashboard(context, 'Saikrupa Sweets'),
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      // Saikrupa Snacks Button
                      ScaleTransition(
                        scale: _snacksScale,
                        child: _buildShopCard(
                          context: context,
                          shopName: 'Saikrupa Snacks',
                          backgroundColor: _getCardBackgroundColor(1),
                          accentColor: _getCardAccentColor(1),
                          icon: Icons.fastfood,
                          onTap: () =>
                              _navigateToDashboard(context, 'Saikrupa Snacks'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.08),
            ],
          ),
        ),
      ),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'edit_name') {
            _showEditNameDialog();
          } else {
            _changeTheme(value);
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
              value: 'edit_name',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20),
                  const SizedBox(width: 12),
                  const Text('Edit Name'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'default',
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentTheme == 'default'
                          ? const Color(0xFF3f51b5)
                          : Colors.grey,
                    ),
                    child: _currentTheme == 'default'
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Text('Default (Blue)'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'green',
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentTheme == 'green'
                          ? const Color(0xFF388E3C)
                          : Colors.grey,
                    ),
                    child: _currentTheme == 'green'
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Text('Green'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'orange',
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentTheme == 'orange'
                          ? const Color(0xFFFF9800)
                          : Colors.grey,
                    ),
                    child: _currentTheme == 'orange'
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Text('Orange'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'dark',
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentTheme == 'dark'
                          ? const Color(0xFF424242)
                          : Colors.grey,
                    ),
                    child: _currentTheme == 'dark'
                        ? const Icon(Icons.check, size: 10, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Text('Dark'),
                ],
              ),
            ),
            const PopupMenuDivider(),
          ];
        },
        child: FloatingActionButton(
          backgroundColor: _getFabBackgroundColor(),
          onPressed: null,
          child: Icon(Icons.palette, color: _getFabIconColor()),
        ),
      ),
    );
  }

  /// Build individual shop card with liquid glass effect
  Widget _buildShopCard({
    required BuildContext context,
    required String shopName,
    required Color backgroundColor,
    required Color accentColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.15),
                  ),
                  child: Icon(icon, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 20),
                // Shop Name and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to manage inventory',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigate to dashboard with page transition animation
  void _navigateToDashboard(BuildContext context, String shopName) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            DashboardScreen(shopName: shopName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
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

  /// Get card background color based on current theme and card index
  Color _getCardBackgroundColor(int cardIndex) {
    switch (_currentTheme) {
      case 'green':
        return cardIndex == 0
            ? const Color(0xFF2E7D32)
            : const Color(0xFF1B5E20);
      case 'orange':
        return cardIndex == 0
            ? const Color(0xFFF57C00)
            : const Color(0xFFE65100);
      case 'dark':
        return cardIndex == 0
            ? const Color(0xFF455A64)
            : const Color(0xFF37474F);
      case 'default':
      default:
        return cardIndex == 0
            ? const Color(0xFF0d47a1)
            : const Color(0xFF1b5e20);
    }
  }

  /// Get card accent color based on current theme and card index
  Color _getCardAccentColor(int cardIndex) {
    switch (_currentTheme) {
      case 'green':
        return const Color(0xFF81C784);
      case 'orange':
        return const Color(0xFFFFB74D);
      case 'dark':
        return const Color(0xFF90CAF9);
      case 'default':
      default:
        return cardIndex == 0
            ? const Color(0xFF42a5f5)
            : const Color(0xFF66bb6a);
    }
  }

  /// Change theme and save selection
  void _changeTheme(String newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
    ThemeService.saveTheme(newTheme);
  }

  /// Get FAB background color based on current theme
  Color _getFabBackgroundColor() {
    switch (_currentTheme) {
      case 'green':
        return const Color(0xFF388E3C);
      case 'orange':
        return const Color(0xFFFF9800);
      case 'dark':
        return const Color(0xFF424242);
      case 'default':
      default:
        return const Color(0xFF3f51b5);
    }
  }

  /// Get FAB icon color based on current theme
  Color _getFabIconColor() {
    switch (_currentTheme) {
      case 'dark':
        return Colors.white;
      case 'green':
      case 'orange':
      case 'default':
      default:
        return Colors.white;
    }
  }

  /// Get title decorative gradient colors based on current theme
  List<Color> _getTitleDecorativeGradient() {
    switch (_currentTheme) {
      case 'green':
        return const [Colors.white, Color(0xFF4CAF50)];
      case 'orange':
        return const [Colors.white, Color(0xFFFF9800)];
      case 'dark':
        return const [Colors.white70, Color(0xFF616161)];
      case 'default':
      default:
        return const [Colors.white, Colors.lightBlue];
    }
  }

  /// Get greeting based on current time
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

  /// Show dialog to edit username
  void _showEditNameDialog() {
    final editController = TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Name',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: editController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
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
                        child: const Text('Cancel'),
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
                                    duration: Duration(seconds: 2),
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
        );
      },
    );
  }
}
