import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../models/stock_item.dart';

class ImportService {
  /// Import stock items from CSV file
  /// CSV must have columns: name, price, openingStock
  static Future<List<StockItem>> importFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      final csv = await file.readAsString();

      List<List<dynamic>> rows = const CsvToListConverter().convert(csv);

      if (rows.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // First row should be headers
      List<String> headers = rows[0]
          .map((h) => h.toString().toLowerCase())
          .toList();

      int nameIndex = headers.indexOf('name');
      int priceIndex = headers.indexOf('price');
      int openingStockIndex = headers.indexOf('openingstock');

      if (nameIndex == -1 || priceIndex == -1 || openingStockIndex == -1) {
        throw Exception('CSV must contain columns: name, price, openingStock');
      }

      List<StockItem> items = [];

      for (int i = 1; i < rows.length; i++) {
        List<dynamic> row = rows[i];

        if (row.isEmpty || row.every((cell) => cell.toString().isEmpty)) {
          continue; // Skip empty rows
        }

        try {
          String name = row[nameIndex].toString().trim();
          double price = double.parse(row[priceIndex].toString());
          int openingStock = int.parse(row[openingStockIndex].toString());

          if (name.isNotEmpty) {
            items.add(
              StockItem(name: name, price: price, openingStock: openingStock),
            );
          }
        } catch (e) {
          // Skip rows with invalid data
          continue;
        }
      }

      if (items.isEmpty) {
        throw Exception('No valid items found in CSV');
      }

      return items;
    } catch (e) {
      rethrow;
    }
  }

  /// Import stock items from Excel file
  /// Excel must have columns: name, price, openingStock
  static Future<List<StockItem>> importFromExcel(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        throw Exception('Excel file is empty');
      }

      final sheet = excel.tables.values.first;
      if (sheet.rows.isEmpty) {
        throw Exception('Excel sheet is empty');
      }

      // Find header row and column indices
      List<String> headers = sheet.rows[0]
          .map((cell) => (cell?.value ?? '').toString().toLowerCase())
          .toList();

      int nameIndex = headers.indexOf('name');
      int priceIndex = headers.indexOf('price');
      int openingStockIndex = headers.indexOf('openingstock');

      if (nameIndex == -1 || priceIndex == -1 || openingStockIndex == -1) {
        throw Exception(
          'Excel must contain columns: name, price, openingStock',
        );
      }

      List<StockItem> items = [];

      for (int i = 1; i < sheet.rows.length; i++) {
        var row = sheet.rows[i];

        if (row.isEmpty ||
            row.every((cell) => (cell?.value ?? '').toString().isEmpty)) {
          continue; // Skip empty rows
        }

        try {
          String name = (row[nameIndex]?.value ?? '').toString().trim();
          double price = double.parse(
            (row[priceIndex]?.value ?? '0').toString(),
          );
          int openingStock = int.parse(
            (row[openingStockIndex]?.value ?? '0').toString(),
          );

          if (name.isNotEmpty) {
            items.add(
              StockItem(name: name, price: price, openingStock: openingStock),
            );
          }
        } catch (e) {
          // Skip rows with invalid data
          continue;
        }
      }

      if (items.isEmpty) {
        throw Exception('No valid items found in Excel');
      }

      return items;
    } catch (e) {
      rethrow;
    }
  }

  /// Determine file type and import accordingly
  static Future<List<StockItem>> importFromFile(String filePath) async {
    if (filePath.toLowerCase().endsWith('.csv')) {
      return await importFromCsv(filePath);
    } else if (filePath.toLowerCase().endsWith('.xlsx') ||
        filePath.toLowerCase().endsWith('.xls')) {
      return await importFromExcel(filePath);
    } else {
      throw Exception('Unsupported file format. Use CSV or Excel files.');
    }
  }
}
