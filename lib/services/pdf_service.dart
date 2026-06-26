import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import '../models/stock_item.dart';
import 'dart:io';

class PdfService {
  /// Generate and save PDF report with stock data
  static Future<String> generateStockReport({
    required String reportName,
    required List<StockItem> items,
  }) async {
    final pdf = pw.Document();

    // Get yesterday's date
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(yesterday);

    // Create table data
    final tableData = [
      // Header row
      [
        'Name',
        'Price',
        'Opening',
        'Returned',
        'Added',
        'Closing',
        'Sold',
        'Earnings',
      ],
      // Data rows
      ...items.map(
        (item) => [
          item.name,
          '₹${item.price}',
          '${item.openingStock}',
          '${item.returnedStock}',
          '${item.addedStock}',
          '${item.closingStock}',
          '${item.sold < 0 ? 0 : item.sold}',
          '₹${item.totalEarnings.toStringAsFixed(2)}',
        ],
      ),
    ];

    // Calculate grand total
    final grandTotal = items.fold(0.0, (sum, item) => sum + item.totalEarnings);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          // Header
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Stock Inventory Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Report Name: $reportName',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Date: $formattedDate',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
            ],
          ),

          // Table
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(1.5),
              6: const pw.FlexColumnWidth(1.5),
              7: const pw.FlexColumnWidth(2),
            },
            border: pw.TableBorder.all(),
            children: tableData.asMap().entries.map((entry) {
              final isHeader = entry.key == 0;
              final row = entry.value;

              return pw.TableRow(
                decoration: isHeader
                    ? pw.BoxDecoration(color: PdfColors.grey300)
                    : null,
                children: row
                    .map(
                      (cell) => pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          cell.toString(),
                          style: pw.TextStyle(
                            fontWeight: isHeader ? pw.FontWeight.bold : null,
                            fontSize: 9,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
              );
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          // Summary
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Total Items: ${items.length}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Grand Total Earnings: ₹${grandTotal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Save PDF with date in filename
    final dateForFilename = DateFormat('yyyy-MM-dd').format(yesterday);
    final filename = '${reportName}_$dateForFilename';
    return await _savePdf(pdf, filename);
  }

  /// Save PDF to device storage with file picker
  static Future<String> _savePdf(pw.Document pdf, String fileName) async {
    try {
      // Use file picker to select download location
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // Fallback to app documents directory if user cancels
        final dir = await getApplicationDocumentsDirectory();
        selectedDirectory = dir.path;
      }

      final file = File('$selectedDirectory/$fileName.pdf');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      throw Exception('Error saving PDF: $e');
    }
  }
}
