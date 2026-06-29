import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../widgets/stock_card.dart';
import '../data/saikrupa_dairy_data.dart';
import '../data/saikrupa_snacks_data.dart';
import '../services/pdf_service.dart';
import '../services/data_persistence_service.dart';
import '../services/theme_service.dart';
import '../constants/app_constants.dart';
import '../utils/theme_helper.dart';

/// Main dashboard screen with tab-based pagination
class DashboardScreen extends StatefulWidget {
  final String shopName;

  const DashboardScreen({super.key, required this.shopName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<StockItem> _items;
  late List<StockItem> _templateItems;
  bool _isLoading = true;
  String _currentTheme = 'default';
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load saved theme from Hive
    _currentTheme = ThemeService.getCurrentTheme();

    // Load template data
    _templateItems = List<StockItem>.from(
      widget.shopName == 'Saikrupa Dairy'
          ? saikrupaDairyItems
          : saikrupaSnacksItems,
    );

    // Load persisted data
    _loadData();

    _tabController.addListener(() {
      setState(() {});
    });
  }

  /// Load today's data or create fresh data from yesterday's closing
  Future<void> _loadData() async {
    final items = await DataPersistenceService.loadOrCreateDayData(
      shopName: widget.shopName,
      templateItems: _templateItems,
    );

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  /// Auto-save today's data to Hive
  void _autoSaveData() {
    DataPersistenceService.saveDayData(
      shopName: widget.shopName,
      items: _items,
    ).then((_) {
      print('✓ Auto-saved today\'s data');
    }).catchError((e) {
      print('✗ Error auto-saving data: $e');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Round price: if decimal >= 0.50, round to next integer
  double _roundPrice(double value) {
    final decimal = value - value.toInt();
    if (decimal >= 0.50) {
      return (value.toInt() + 1).toDouble();
    }
    return value.floorToDouble();
  }

  /// Calculate grand total from all items
  double _calculateGrandTotal() {
    return _items.fold(0.0, (sum, item) => sum + item.totalEarnings);
  }

  /// Calculate page total from a list of items
  double _calculatePageTotal(List<StockItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalEarnings);
  }

  /// Get items for Page 1 (0-40)
  List<StockItem> get _page1Items {
    return _items.sublist(0, AppConstants.itemsPerDashboardPage1);
  }

  /// Get items for Page 2 (41-87)
  List<StockItem> get _page2Items {
    return _items.sublist(
      AppConstants.itemsPerDashboardPage1,
      AppConstants.itemsPerDashboardPage1 + AppConstants.itemsPerDashboardPage2,
    );
  }

  /// Get items for Page 3 (88+)
  List<StockItem> get _page3Items {
    final startIndex =
        AppConstants.itemsPerDashboardPage1 +
        AppConstants.itemsPerDashboardPage2;
    return _items.length > startIndex ? _items.sublist(startIndex) : [];
  }

  /// Show dialog to add new item
  void _addNewItemDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Add New Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final String name = nameController.text;
              final double price = double.tryParse(priceController.text) ?? 0;

              if (name.isNotEmpty && price > 0) {
                setState(() {
                  _items.add(
                    StockItem(name: name, price: price, openingStock: 0),
                  );
                });
                _autoSaveData();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to generate PDF report
  void _generateReportDialog() {
    final TextEditingController reportNameController = TextEditingController();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr =
        '${yesterday.day}/${yesterday.month}/${yesterday.year}';

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Generate Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reportNameController,
              decoration: const InputDecoration(
                labelText: 'Report Name',
                hintText: 'e.g., Daily Stock Report',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Date: Yesterday ($yesterdayStr)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reportName = reportNameController.text;
              if (reportName.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a report name')),
                  );
                }
                return;
              }

              final dialogContext = context;
              if (mounted) {
                Navigator.of(dialogContext).pop();
              }

              try {
                final filePath = await PdfService.generateStockReport(
                  reportName: reportName,
                  page1Items: _page1Items,
                  page2Items: _page2Items,
                  page3Items: _page3Items,
                );

                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Report saved: $filePath'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Error generating report: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Generate PDF'),
          ),
        ],
      ),
    );
  }

  /// Finish the day - save data and prepare for tomorrow
  void _finishDay() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Finish Day'),
        content: const Text(
          'Save today\'s data and start fresh for tomorrow?\n\nTomorrow\'s opening stock will be set to today\'s closing stock.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Finish day, save data, and load tomorrow's data
                final tomorrowItems =
                    await DataPersistenceService.finishDayAndLoadNext(
                      shopName: widget.shopName,
                      items: _items,
                      templateItems: _templateItems,
                    );

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Day finished! Data saved successfully.'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Update UI with tomorrow's data
                  setState(() {
                    _items = tomorrowItems;
                    _isLoading = false;
                  });
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving data: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = ThemeHelper.getGradient(_currentTheme);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: themeColors,
            ),
          ),
        ),
        title: Text(
          widget.shopName,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(color: Colors.white),
          unselectedLabelStyle: const TextStyle(color: Colors.white70),
          tabs: const [
            Tab(text: 'Page 1'),
            Tab(text: 'Page 2'),
            Tab(text: 'Page 3'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeColors,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  if (_isMenuOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _toggleMenu,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  Column(
                    children: [
                      // Page-Specific Total Summary Card
                      Builder(
                        builder: (context) {
                          List<StockItem> currentPageItems;
                          switch (_tabController.index) {
                            case 0:
                              currentPageItems = _page1Items;
                              break;
                            case 1:
                              currentPageItems = _page2Items;
                              break;
                            case 2:
                              currentPageItems = _page3Items;
                              break;
                            default:
                              currentPageItems = _page1Items;
                          }

                          final pageTotal = _calculatePageTotal(
                            currentPageItems,
                          );

                          return Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getPageEarningsColor(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Page Earnings:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getPageEarningsTextColor(),
                                  ),
                                ),
                                Text(
                                  '₹${pageTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _getPageEarningsTextColor(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Tabbed Pages
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildStockListView(_page1Items),
                            _buildStockListView(_page2Items),
                            _buildStockListView(_page3Items),
                          ],
                        ),
                      ),
                      // Bottom padding for floating widget
                      const SizedBox(height: 100),
                    ],
                  ),

                  // Grand Total Floating Widget at Bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getTotalEarningsColor(),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Earnings:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getTotalEarningsTextColor(),
                            ),
                          ),
                          Text(
                            '${_roundPrice(_calculateGrandTotal()).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getTotalEarningsTextColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isMenuOpen) ...[
              _buildSpeedDialItem(
                label: 'Back to Shops',
                icon: Icons.store,
                onPressed: () {
                  _toggleMenu();
                  Navigator.of(context).pushReplacementNamed('/shop-selection');
                },
              ),
              const SizedBox(height: 10),
              _buildSpeedDialItem(
                label: 'Generate PDF',
                icon: Icons.picture_as_pdf,
                onPressed: () {
                  _toggleMenu();
                  _generateReportDialog();
                },
              ),
              const SizedBox(height: 10),
              _buildSpeedDialItem(
                label: 'Finish Day',
                icon: Icons.done_all,
                onPressed: () {
                  _toggleMenu();
                  _finishDay();
                },
              ),
              const SizedBox(height: 10),
              _buildSpeedDialItem(
                label: 'Add New Item',
                icon: Icons.add_box,
                onPressed: () {
                  _toggleMenu();
                  _addNewItemDialog();
                },
              ),
              const SizedBox(height: 15),
            ],
            FloatingActionButton(
              onPressed: _toggleMenu,
              tooltip: 'Menu',
              child: AnimatedRotation(
                turns: _isMenuOpen ? 0.125 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build stock list view for a given list of items
  Widget _buildStockListView(List<StockItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => StockCard(
        key: ValueKey(
          '${items[index].name}_${items[index].price}_${items[index].openingStock}',
        ),
        item: items[index],
        onDelete: () {
          setState(() {
            _items.remove(items[index]);
          });
          _autoSaveData();
        },
        onSetState: (callback) {
          setState(callback);
          _autoSaveData();
        },
        currentTheme: _currentTheme,
      ),
    );
  }

  /// Toggle speed dial menu open/close
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  /// Build speed dial sub-button with label
  Widget _buildSpeedDialItem({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          onPressed: onPressed,
          heroTag: label,
          child: Icon(icon),
        ),
      ],
    );
  }

  /// Get page earnings card color based on selected theme
  Color _getPageEarningsColor() {
    switch (_currentTheme) {
      case 'green':
        return const Color(0xFFFFD54F); // Bright yellow for green theme
      case 'orange':
        return const Color(0xFFFFC107); // Amber/yellow for orange theme
      case 'dark':
        return const Color(0xFF37474F); // Blue-gray for dark mode
      case 'default':
      default:
        return Colors.blue;
    }
  }

  /// Get page earnings text color based on selected theme
  Color _getPageEarningsTextColor() {
    switch (_currentTheme) {
      case 'green':
      case 'orange':
        return Colors.black87; // Dark text for yellow backgrounds
      case 'dark':
      case 'default':
      default:
        return Colors.white;
    }
  }

  /// Get total earnings card color based on selected theme
  Color _getTotalEarningsColor() {
    switch (_currentTheme) {
      case 'green':
        return Colors.green[700]!;
      case 'orange':
        return Colors.deepOrange[700]!;
      case 'dark':
        return const Color(0xFF37474F); // Blue-gray for dark mode
      case 'default':
      default:
        return Colors.green;
    }
  }

  /// Get total earnings text color based on selected theme
  Color _getTotalEarningsTextColor() {
    switch (_currentTheme) {
      case 'dark':
        return Colors.white70;
      case 'default':
      case 'green':
      case 'orange':
      default:
        return Colors.white;
    }
  }
}
