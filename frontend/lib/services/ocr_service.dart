import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  /// Processes an XFile image with ML Kit OCR.
  /// XFile is used (rather than File) because it properly handles Android content URIs via saveTo().
  Future<String?> processImage(XFile xfile) async {
    try {
      debugPrint('[OCR] Memproses gambar: ${xfile.path}');

      // Salin ke temp file menggunakan saveTo() yang support content URIs
      final tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String ext = xfile.name
          .split('.')
          .last
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]'), 'jpg');
      final File tempFile = File('${tempDir.path}/ocr_$timestamp.$ext');

      await xfile.saveTo(tempFile.path);
      debugPrint(
        '[OCR] Temp file: ${tempFile.path} (${await tempFile.length()} bytes)',
      );

      final inputImage = InputImage.fromFile(tempFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      final text = recognizedText.text;
      debugPrint('[OCR] Teks terbaca (${text.length} karakter):\n$text');

      return text;
    } catch (e, stack) {
      debugPrint('[OCR] ERROR: $e');
      debugPrint('[OCR] StackTrace: $stack');
      return '__ERROR__: $e';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
