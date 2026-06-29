import 'package:flutter_test/flutter_test.dart';
import 'package:stocker/models/stock_item.dart';

void main() {
  group('StockItem Calculations', () {
    test('sold items shows negative value when closing stock is higher than opening stock without any additions', () {
      final item = StockItem(
        name: 'Test Item',
        price: 10.0,
        openingStock: 0,
        closingStockEntries: [5],
      );

      expect(item.sold, -5);
      expect(item.totalEarnings, 0.0);
    });

    test('sold items shows positive value when sold is positive', () {
      final item = StockItem(
        name: 'Test Item',
        price: 10.0,
        openingStock: 10,
        closingStockEntries: [3],
      );

      expect(item.sold, 7);
      expect(item.totalEarnings, 70.0);
    });
  });
}
