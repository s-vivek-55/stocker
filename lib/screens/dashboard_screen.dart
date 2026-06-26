import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/stock_item.dart';
import '../widgets/stock_card.dart';
import '../data/saikrupa_sweets_data.dart';
import '../data/saikrupa_snacks_data.dart';
import '../services/pdf_service.dart';
import '../services/data_persistence_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load template data
    _templateItems = List<StockItem>.from(
      widget.shopName == 'Saikrupa Sweets'
          ? saikrupaSweetsItems
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    return _items.sublist(0, 41);
  }

  /// Get items for Page 2 (41-87)
  List<StockItem> get _page2Items {
    return _items.sublist(41, 88);
  }

  /// Get items for Page 3 (88+)
  List<StockItem> get _page3Items {
    return _items.length > 88 ? _items.sublist(88) : [];
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
                  items: _items,
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
                // Save today's data
                await DataPersistenceService.saveDayData(
                  shopName: widget.shopName,
                  items: _items,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Day finished! Data saved successfully.'),
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Reload data for tomorrow
                  await Future.delayed(const Duration(seconds: 2));
                  await _loadData();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopName),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate PDF Report',
            onPressed: _generateReportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Finish Day',
            onPressed: _finishDay,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Page 1'),
            Tab(text: 'Page 2'),
            Tab(text: 'Page 3'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
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

                        final pageTotal = _calculatePageTotal(currentPageItems);

                        return Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Page Earnings:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '₹${pageTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                      color: Colors.green,
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
                        const Text(
                          'Total Earnings:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '₹${_calculateGrandTotal().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: FloatingActionButton(
          onPressed: _addNewItemDialog,
          tooltip: 'Add New Item',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// Build stock list view for a given list of items
  Widget _buildStockListView(List<StockItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => StockCard(
        item: items[index],
        onDelete: () {
          setState(() {
            _items.remove(items[index]);
          });
        },
        onSetState: (callback) {
          setState(callback);
        },
      ),
    );
  }
}
