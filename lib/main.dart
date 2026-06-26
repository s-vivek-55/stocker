import 'package:flutter/material.dart';
import 'screens/shop_selection_screen.dart';

void main() {
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
      home: const ShopSelectionScreen(),
    );
  }
}
