import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/user_profile_service.dart';
import '../services/theme_service.dart';
import '../services/import_service.dart';
import '../services/data_persistence_service.dart';
import '../constants/app_constants.dart';
import '../utils/theme_helper.dart';

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pin1 = TextEditingController();
  final TextEditingController _pin2 = TextEditingController();
  final TextEditingController _pin3 = TextEditingController();
  final TextEditingController _pin4 = TextEditingController();

  File? _selectedFile;
  bool _isLoading = false;
  int _importedItemsCount = 0;
  String _selectedShopForImport = '';
  late String _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = ThemeService.getCurrentTheme();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pin1.dispose();
    _pin2.dispose();
    _pin3.dispose();
    _pin4.dispose();
    super.dispose();
  }

  Future<void> _showShopSelectionDialog() async {
    final TextEditingController shopNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Select Shop for Import'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose which shop to import data for:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              // Predefined shops
              ..._getPredefinedShops().map(
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
                'Or enter custom shop name:',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: shopNameController,
                decoration: InputDecoration(
                  hintText: 'Custom shop name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
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
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: shopNameController.text.isNotEmpty
                        ? () {
                            Navigator.pop(context);
                            _importFile(shopNameController.text);
                          }
                        : null,
                    child: const Text('Import'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getPredefinedShops() {
    return AppConstants.predefinedShops;
  }

  Future<void> _importFile(String shopName) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        dialogTitle: 'Select CSV or Excel file for $shopName',
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);

        try {
          final items = await ImportService.importFromFile(
            result.files.single.path!,
          );

          // Save imported items for the selected shop
          await DataPersistenceService.saveDayData(
            shopName: shopName,
            items: items,
          );

          setState(() {
            _selectedFile = File(result.files.single.path!);
            _importedItemsCount = items.length;
            _selectedShopForImport = shopName;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Imported ${items.length} items to $shopName'),
                backgroundColor: Colors.green,
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Color> _getGradient() {
    return ThemeHelper.getGradient(_currentTheme);
  }

  List<Color> _getButtonGradient() {
    return ThemeHelper.getButtonGradient(_currentTheme);
  }

  Future<void> _proceed() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      await UserProfileService.saveUserProfile(
        username: _nameController.text,
        pin: pin,
      );
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/shop-selection');
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
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradient(),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'Welcome!',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's get started",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 60),

                // Name Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // PIN Label
                Text(
                  'Enter 4-Digit PIN',
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
                    _buildBox(_pin1, 1),
                    const SizedBox(width: 12),
                    _buildBox(_pin2, 2),
                    const SizedBox(width: 12),
                    _buildBox(_pin3, 3),
                    const SizedBox(width: 12),
                    _buildBox(_pin4, 4),
                  ],
                ),
                const SizedBox(height: 48),

                // Import Data Button
                if (_importedItemsCount == 0)
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _showShopSelectionDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file,
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Import CSV/Excel',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.green.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Imported $_importedItemsCount items to $_selectedShopForImport',
                            style: TextStyle(
                              color: Colors.green.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _importedItemsCount = 0;
                              _selectedShopForImport = '';
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: Colors.green.withOpacity(0.7),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Button
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
                      onTap: _isLoading ? null : _proceed,
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
                                'Proceed',
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
                const SizedBox(height: 24),

                // Skip
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () => Navigator.of(
                          context,
                        ).pushReplacementNamed('/shop-selection'),
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(TextEditingController controller, int num) {
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
