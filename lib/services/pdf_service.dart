import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {

  // extracts all text from a PDF file
  static Future<String> extractText(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < document.pages.count; i++) {
      final pageText = extractor.extractText(
        startPageIndex: i,
        endPageIndex: i,
      );
      buffer.writeln(pageText);
    }

    document.dispose();
    return buffer.toString().trim();
  }

  // gets total page count
  static Future<int> getPageCount(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final count = document.pages.count;
    document.dispose();
    return count;
  }

  // formats bytes into readable size e.g. "1.2 MB"
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}