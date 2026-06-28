import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/user_profile_service.dart';
import '../utils/theme_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late String _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = ThemeService.getCurrentTheme();

    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward().then((_) {
      if (mounted) {
        // Ensure services are initialized
        Future.wait([
              UserProfileService.initializeUserProfile(),
              ThemeService.initializeTheme(),
            ])
            .then((_) {
              if (mounted) {
                // Check if user has already been set up
                if (UserProfileService.isUserSetup()) {
                  Navigator.of(context).pushReplacementNamed('/login');
                } else {
                  Navigator.of(context).pushReplacementNamed('/initialization');
                }
              }
            })
            .catchError((e) {
              print('Error during initialization: $e');
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/initialization');
              }
            });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use default blue gradient for splash screen
    final themeColors = ThemeHelper.getGradient('default');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeColors,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/logo/app_logo.png', width: 150, height: 150),
              const SizedBox(height: 40),
              // Progress Bar
              SizedBox(
                width: 200,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            minHeight: 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
