import 'package:hive/hive.dart';
import '../models/stock_item.dart';

/// Service for persisting and loading stock data with daily tracking using Hive
class DataPersistenceService {
  static const String _boxName = 'stocker_box';
  static const String _dateKeyPrefix = 'date_';

  /// Initialize Hive
  static Future<void> initializeHive() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(StockItemAdapter());
    }
    await Hive.openBox(_boxName);
  }

  /// Save today's data to Hive
  static Future<void> saveDayData({
    required String shopName,
    required List<StockItem> items,
  }) async {
    final box = Hive.box(_boxName);
    final today = DateTime.now();
    final dateKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final dataKey = '${_dateKeyPrefix}${shopName}_$dateKey';

    // Save the items list
    await box.put(dataKey, items);

    // Update last recorded date
    await box.put('last_date_$shopName', dateKey);
  }

  /// Load today's data or create fresh data from yesterday's closing
  static Future<List<StockItem>> loadOrCreateDayData({
    required String shopName,
    required List<StockItem> templateItems,
  }) async {
    final box = Hive.box(_boxName);
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    final todayDataKey = '${_dateKeyPrefix}${shopName}_$todayKey';
    final yesterdayDataKey = '${_dateKeyPrefix}${shopName}_$yesterdayKey';

    // Check if data already exists for today
    final todayData = box.get(todayDataKey);
    if (todayData != null) {
      return List<StockItem>.from(todayData);
    }

    // Load yesterday's data to use closing stocks as opening stocks
    final yesterdayData = box.get(yesterdayDataKey);
    if (yesterdayData != null) {
      final yesterdayItems = List<StockItem>.from(yesterdayData);

      // Create new items with yesterday's closing stock as today's opening stock
      final todayItems = <StockItem>[];
      for (var i = 0; i < templateItems.length; i++) {
        final templateItem = templateItems[i];
        final yesterdayItem = i < yesterdayItems.length
            ? yesterdayItems[i]
            : null;
        final openingStock =
            yesterdayItem?.closingStock ?? templateItem.openingStock;

        todayItems.add(
          StockItem(
            name: templateItem.name,
            price: templateItem.price,
            openingStock: openingStock,
            returnedStockEntries: [0],
            addedStockEntries: [0, 0],
            closingStockEntries: [0], // Reset closing to 0 for new day
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
    final box = Hive.box(_boxName);
    return box.get('last_date_$shopName');
  }

  /// Finish the day, save data, and prepare for tomorrow
  /// Creates tomorrow's items with today's closing stock as opening stock
  static Future<List<StockItem>> finishDayAndLoadNext({
    required String shopName,
    required List<StockItem> items,
    required List<StockItem> templateItems,
  }) async {
    final box = Hive.box(_boxName);
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayDataKey = '${_dateKeyPrefix}${shopName}_$todayKey';

    // Save today's data
    await box.put(todayDataKey, items);
    await box.put('last_date_$shopName', todayKey);

    // Create tomorrow's items using today's closing stock as opening stock
    final tomorrowItems = <StockItem>[];
    for (var i = 0; i < templateItems.length; i++) {
      final templateItem = templateItems[i];
      final todayItem = i < items.length ? items[i] : null;

      // Use today's closing stock as tomorrow's opening stock
      final openingStock = todayItem?.closingStock ?? templateItem.openingStock;

      tomorrowItems.add(
        StockItem(
          name: templateItem.name,
          price: templateItem.price,
          openingStock: openingStock,
          returnedStockEntries: [0],
          addedStockEntries: [0, 0],
          closingStockEntries: [0], // Reset closing to 0 for new day
        ),
      );
    }

    return tomorrowItems;
  }
}
