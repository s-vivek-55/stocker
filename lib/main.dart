import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/initialization_screen.dart';
import 'screens/login_screen.dart';
import 'screens/shop_selection_screen.dart';
import 'services/data_persistence_service.dart';
import 'services/theme_service.dart';
import 'services/user_profile_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Hive.initFlutter();
    print('✓ Hive initialized');
    await DataPersistenceService.initializeHive();
    print('✓ DataPersistenceService initialized');
    await ThemeService.initializeTheme();
    print('✓ ThemeService initialized');
    await UserProfileService.initializeUserProfile();
    print('✓ UserProfileService initialized');
  } catch (e) {
    print('✗ Error during initialization: $e');
  }
  runApp(const StockerApp());
}

class StockerApp extends StatelessWidget {
  const StockerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stocker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/initialization': (context) => const InitializationScreen(),
        '/login': (context) => const LoginScreen(),
        '/shop-selection': (context) => const ShopSelectionScreen(),
      },
    );
  }
}
