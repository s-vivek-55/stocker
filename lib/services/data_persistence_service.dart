import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stock_item.dart';

/// Service for persisting and loading stock data with daily tracking
class DataPersistenceService {
  static const String _keyPrefix = 'stocker_data_';
  static const String _dateKey = 'current_date';

  /// Save today's data to device storage
  static Future<void> saveDayData({
    required String shopName,
    required List<StockItem> items,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Save the data
    final itemsJson = items.map((item) => _itemToJson(item)).toList();
    await prefs.setString(
      '$_keyPrefix${shopName}_$dateKey',
      jsonEncode(itemsJson),
    );

    // Update last recorded date
    await prefs.setString('${_keyPrefix}last_date_$shopName', dateKey);
  }

  /// Load today's data or create fresh data for tomorrow
  static Future<List<StockItem>> loadOrCreateDayData({
    required String shopName,
    required List<StockItem> templateItems,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    // Check if data already exists for today
    final todayDataJson = prefs.getString('$_keyPrefix${shopName}_$todayKey');
    if (todayDataJson != null) {
      return _parseItemsFromJson(jsonDecode(todayDataJson));
    }

    // Load yesterday's data to use closing stocks as opening stocks
    final yesterdayDataJson = prefs.getString('$_keyPrefix${shopName}_$yesterdayKey');
    if (yesterdayDataJson != null) {
      final yesterdayItems = _parseItemsFromJson(jsonDecode(yesterdayDataJson));

      // Create new items with yesterday's closing stock as today's opening stock
      final todayItems = <StockItem>[];
      for (var i = 0; i < templateItems.length; i++) {
        final templateItem = templateItems[i];
        final yesterdayItem = i < yesterdayItems.length ? yesterdayItems[i] : null;
        final openingStock = yesterdayItem?.closingStock ?? templateItem.openingStock;

        todayItems.add(
          StockItem(
            name: templateItem.name,
            price: templateItem.price,
            openingStock: openingStock,
          ),
        );
      }

      return todayItems;
    }

    // If no previous data, return fresh template items
    return templateItems.map((item) {
      return StockItem(
        name: item.name,
        price: item.price,
        openingStock: item.openingStock,
      );
    }).toList();
  }

  /// Get the date of the last saved data
  static Future<String?> getLastSavedDate(String shopName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_keyPrefix}last_date_$shopName');
  }

  /// Convert StockItem to JSON-serializable map
  static Map<String, dynamic> _itemToJson(StockItem item) {
    return {
      'name': item.name,
      'price': item.price,
      'openingStock': item.openingStock,
      'returnedStockEntries': item.returnedStockEntries,
      'addedStockEntries': item.addedStockEntries,
      'closingStockEntries': item.closingStockEntries,
    };
  }

  /// Parse StockItems from JSON
  static List<StockItem> _parseItemsFromJson(List<dynamic> json) {
    return json.map((itemJson) {
      return StockItem(
        name: itemJson['name'],
        price: itemJson['price'].toDouble(),
        openingStock: itemJson['openingStock'],
      )
        ..returnedStockEntries = List<int>.from(itemJson['returnedStockEntries'] ?? [0])
        ..addedStockEntries = List<int>.from(itemJson['addedStockEntries'] ?? [0, 0, 0])
        ..closingStockEntries = List<int>.from(itemJson['closingStockEntries'] ?? [0]);
    }).toList();
  }
}
