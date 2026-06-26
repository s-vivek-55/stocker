/// Stock item model class to hold product tracking values
class StockItem {
  String name;
  double price;
  int openingStock;
  List<int> returnedStockEntries; // Returned with 2 fields by default
  List<int> addedStockEntries; // Added with 3 fields by default
  List<int> closingStockEntries; // Closing with 2 fields by default

  StockItem({
    required this.name,
    required this.price,
    this.openingStock = 0,
    List<int>? returnedStockEntries,
    List<int>? addedStockEntries,
    List<int>? closingStockEntries,
  }) : returnedStockEntries = returnedStockEntries ?? [0, 0],
       addedStockEntries = addedStockEntries ?? [0, 0, 0],
       closingStockEntries = closingStockEntries ?? [0, 0];

  /// Calculate total returned stock from all entries
  int get returnedStock =>
      returnedStockEntries.fold(0, (sum, val) => sum + val);

  /// Calculate total added stock from all entries
  int get addedStock => addedStockEntries.fold(0, (sum, val) => sum + val);

  /// Calculate total closing stock from all entries
  int get closingStock => closingStockEntries.fold(0, (sum, val) => sum + val);

  /// Calculation: (opening - returned + added - closing) * price
  int get sold => (openingStock - returnedStock + addedStock - closingStock);

  /// Calculate total earnings based on sold quantity and price
  double get totalEarnings => sold > 0 ? sold * price : 0.0;
}
