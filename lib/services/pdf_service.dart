import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import '../models/stock_item.dart';
import '../constants/app_constants.dart';
import 'dart:io';

class PdfService {
  /// Round value: if decimal >= 0.50, round to next integer
  static double roundPrice(double value) {
    final decimal = value - value.toInt();
    if (decimal >= 0.50) {
      return (value.toInt() + 1).toDouble();
    }
    return value.floorToDouble();
  }

  /// Generate and save PDF report with stock data organized by pages
  static Future<String> generateStockReport({
    required String reportName,
    required List<StockItem> page1Items,
    required List<StockItem> page2Items,
    required List<StockItem> page3Items,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData(
        defaultTextStyle: pw.TextStyle(font: pw.Font.times(), fontSize: 10),
      ),
    );

    // Get yesterday's date
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(yesterday);

    // Split items into smaller chunks (15 items per page for optimal readability)
    List<List<StockItem>> splitItems(List<StockItem> items) {
      final chunks = <List<StockItem>>[];
      for (int i = 0; i < items.length; i += AppConstants.itemsPerPdfPage) {
        chunks.add(
          items.sublist(
            i,
            i + AppConstants.itemsPerPdfPage > items.length
                ? items.length
                : i + AppConstants.itemsPerPdfPage,
          ),
        );
      }
      return chunks;
    }

    // Function to create page content without total (for chunks)
    pw.Widget createPageContent(
      List<StockItem> items,
      String pageTitle, {
      bool showTotal = true,
    }) {
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
            '${roundPrice(item.price).toInt()}',
            '${item.openingStock}',
            '${item.returnedStock}',
            '${item.addedStock}',
            '${item.closingStock}',
            '${item.sold}',
            '${roundPrice(item.totalEarnings).toInt()}',
          ],
        ),
      ];

      // Calculate page total
      final pageTotal = items.fold(
        0.0,
        (sum, item) => sum + item.totalEarnings,
      );

      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            pageTitle,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Date: $formattedDate',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 15),
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
          // Only show total for last chunk
          if (showTotal) ...[
            pw.SizedBox(height: 15),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Section Total: ${roundPrice(pageTotal).toInt()}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Calculate all page totals upfront
    final page1Total = page1Items.fold(
      0.0,
      (sum, item) => sum + item.totalEarnings,
    );
    final page2Total = page2Items.fold(
      0.0,
      (sum, item) => sum + item.totalEarnings,
    );
    final page3Total = page3Items.fold(
      0.0,
      (sum, item) => sum + item.totalEarnings,
    );

    // Add Page 1 (split into chunks if too large)
    final page1Chunks = splitItems(page1Items);

    for (int i = 0; i < page1Chunks.length; i++) {
      final chunk = page1Chunks[i];
      final isFirstChunk = i == 0;
      final isLastChunk = i == page1Chunks.length - 1;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (isFirstChunk) ...[
                  pw.Text(
                    'Stock Inventory Report - $reportName',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],
                createPageContent(
                  chunk,
                  'Page 1 (Part ${i + 1})',
                  showTotal: false,
                ),
                if (isLastChunk) ...[
                  pw.SizedBox(height: 15),
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      'Page 1 Total: ${roundPrice(page1Total).toInt()}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    // Add Page 2 (split into chunks if too large)
    if (page2Items.isNotEmpty) {
      final page2Chunks = splitItems(page2Items);

      for (int i = 0; i < page2Chunks.length; i++) {
        final chunk = page2Chunks[i];
        final isLastChunk = i == page2Chunks.length - 1;

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.all(20),
            build: (context) => [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  createPageContent(
                    chunk,
                    'Page 2 (Part ${i + 1})',
                    showTotal: false,
                  ),
                  if (isLastChunk) ...[
                    pw.SizedBox(height: 15),
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'Page 2 Total: ${roundPrice(page2Total).toInt()}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }
    }

    // Add Page 3 (split into chunks if too large)
    if (page3Items.isNotEmpty) {
      final page3Chunks = splitItems(page3Items);

      for (int i = 0; i < page3Chunks.length; i++) {
        final chunk = page3Chunks[i];
        final isLastChunk = i == page3Chunks.length - 1;

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.all(20),
            build: (context) => [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  createPageContent(
                    chunk,
                    'Page 3 (Part ${i + 1})',
                    showTotal: false,
                  ),
                  if (isLastChunk) ...[
                    pw.SizedBox(height: 15),
                    pw.Divider(),
                    pw.SizedBox(height: 10),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'Page 3 Total: ${roundPrice(page3Total).toInt()}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }
    }

    // Add Grand Total Page
    final grandTotal = page1Total + page2Total + page3Total;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Summary - $reportName',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Page-wise Summary',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              // Summary table
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                },
                border: pw.TableBorder.all(),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Page',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Items',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  // Page 1
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Page 1',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${page1Items.length}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${roundPrice(page1Total).toInt()}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  // Page 2
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Page 2',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${page2Items.length}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${roundPrice(page2Total).toInt()}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  // Page 3
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Page 3',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${page3Items.length}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${roundPrice(page3Total).toInt()}',
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 15),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Grand Total: ${roundPrice(grandTotal).toInt()}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
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
      // Sanitize filename - remove invalid characters
      final sanitizedFileName = fileName
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(' ', '_');

      // Use file picker to select download location
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        // Fallback to app documents directory if user cancels
        final dir = await getApplicationDocumentsDirectory();
        selectedDirectory = dir.path;
      }

      // Ensure directory exists
      final directory = Directory(selectedDirectory);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create file with sanitized path
      final filePath =
          '${directory.path}${Platform.pathSeparator}${sanitizedFileName}.pdf';
      final file = File(filePath);

      // Save PDF bytes
      final pdfBytes = await pdf.save();

      // Verify we have content
      if (pdfBytes.isEmpty) {
        throw Exception('PDF generated but contains no data');
      }

      await file.writeAsBytes(pdfBytes);

      // Log success
      print('✅ PDF saved successfully: ${file.path}');
      print('   File size: ${file.lengthSync()} bytes');

      return file.path;
    } catch (e) {
      print('❌ PDF Error: $e');
      throw Exception('Error saving PDF: $e');
    }
  }
}
