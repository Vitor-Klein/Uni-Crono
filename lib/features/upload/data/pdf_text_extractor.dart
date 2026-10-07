import 'package:flutter/foundation.dart';
import 'package:pdfrx/pdfrx.dart';

/// The text of a PDF, read on the device.
abstract class PdfTextExtractor {
  /// The text of the first pages; "" when the PDF has none (scanned) or
  /// cannot be opened.
  Future<String> extract(Uint8List bytes);
}

/// Reads the text with PDFium, through pdfrx.
class PdfrxTextExtractor implements PdfTextExtractor {
  const PdfrxTextExtractor();

  static const maxPages = 10;

  @override
  Future<String> extract(Uint8List bytes) async {
    PdfDocument? document;
    try {
      await pdfrxFlutterInitialize();
      document = await PdfDocument.openData(bytes);
      final texts = <String>[];
      for (final page in document.pages.take(maxPages)) {
        texts.add((await page.loadText())?.fullText ?? '');
      }
      return texts.join('\n').trim();
    } catch (e) {
      // Only the type: a certificate holds personal data.
      debugPrint('PDF without readable text: ${e.runtimeType}');
      return '';
    } finally {
      await document?.dispose();
    }
  }
}
