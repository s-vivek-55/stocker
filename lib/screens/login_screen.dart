import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';
import '../services/theme_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pin1 = TextEditingController();
  final TextEditingController _pin2 = TextEditingController();
  final TextEditingController _pin3 = TextEditingController();
  final TextEditingController _pin4 = TextEditingController();

  bool _isLoading = false;
  String? _username;
  late String _currentTheme;

  @override
  void initState() {
    super.initState();
    _username = UserProfileService.getUsername();
    _currentTheme = ThemeService.getCurrentTheme();
  }

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    _pin3.dispose();
    _pin4.dispose();
    super.dispose();
  }

  List<Color> _getGradient() {
    switch (_currentTheme) {
      case 'green':
        return [
          const Color(0xFF1B5E20),
          const Color(0xFF2E7D32),
          const Color(0xFF388E3C),
        ];
      case 'orange':
        return [
          const Color(0xFFE65100),
          const Color(0xFFF57C00),
          const Color(0xFFFF9800),
        ];
      case 'dark':
        return [
          const Color(0xFF1a1a1a),
          const Color(0xFF2d2d2d),
          const Color(0xFF424242),
        ];
      default:
        return [
          const Color(0xFF1a237e),
          const Color(0xFF283593),
          const Color(0xFF3f51b5),
        ];
    }
  }

  List<Color> _getButtonGradient() {
    switch (_currentTheme) {
      case 'green':
        return [const Color(0xFF2E7D32), const Color(0xFF1B5E20)];
      case 'orange':
        return [const Color(0xFFF57C00), const Color(0xFFE65100)];
      case 'dark':
        return [const Color(0xFF424242), const Color(0xFF212121)];
      default:
        return [const Color(0xFF42a5f5), const Color(0xFF1e88e5)];
    }
  }

  Future<void> _verify() async {
    String pin = _pin1.text + _pin2.text + _pin3.text + _pin4.text;

    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 4-digit PIN'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (UserProfileService.verifyPin(pin)) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/shop-selection');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect PIN'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          _pin1.clear();
          _pin2.clear();
          _pin3.clear();
          _pin4.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradient(),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Welcome back!',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _username ?? 'User',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 60),

                  // PIN Label
                  Text(
                    'Enter PIN',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PIN Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPin(_pin1, 1),
                      const SizedBox(width: 12),
                      _buildPin(_pin2, 2),
                      const SizedBox(width: 12),
                      _buildPin(_pin3, 3),
                      const SizedBox(width: 12),
                      _buildPin(_pin4, 4),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // Unlock Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: _getButtonGradient()),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _verify,
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Unlock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Reset Data Button
                  GestureDetector(
                    onTap: _isLoading ? null : _showResetDataDialog,
                    child: Text(
                      'Reset All Data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Reset All Data',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text(
            'This will clear all stored data including:\n• Username and PIN\n• Theme settings\n• All stock information\n\nYou will need to set up again after this.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await UserProfileService.clearAllData();
                  if (mounted) {
                    Navigator.of(context).pop();
                    // Add delay to allow Hive to properly reinitialize
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (mounted) {
                      // Reinitialize the services before navigating
                      await UserProfileService.initializeUserProfile();
                      await ThemeService.initializeTheme();
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/splash');
                      }
                    }
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
              },
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPin(TextEditingController controller, int num) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          obscureText: true,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(0),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && num < 4) FocusScope.of(context).nextFocus();
          },
        ),
      ),
    );
  }
}
