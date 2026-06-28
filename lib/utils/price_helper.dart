/// Helper class for price-related operations
class PriceHelper {
  /// Round price to 2 decimal places
  /// Used consistently across all price displays
  static double roundPrice(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  /// Format price as currency string
  static String formatPrice(double price) {
    return '₹${roundPrice(price).toStringAsFixed(2)}';
  }

  /// Parse string to double price safely
  static double parsePrice(String value) {
    try {
      return roundPrice(double.parse(value));
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if price is valid (non-negative)
  static bool isValidPrice(double price) {
    return price >= 0;
  }
}
