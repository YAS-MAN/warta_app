import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  // --- File-returning methods (for display with Image.file) ---

  Future<File?> pickImageFromCamera() async {
    final xfile = await pickImageXFileFromCamera();
    if (xfile == null) return null;
    return getDisplayFile(xfile);
  }

  Future<File?> pickImageFromGallery() async {
    final xfile = await pickImageXFileFromGallery();
    if (xfile == null) return null;
    return getDisplayFile(xfile);
  }

  // --- XFile-returning methods (exposes raw XFile for OCR, which handles content URIs) ---

  Future<XFile?> pickImageXFileFromCamera() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
    } catch (e) {
      debugPrint('[MediaService] Camera error: $e');
      return null;
    }
  }

  Future<XFile?> pickImageXFileFromGallery() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
    } catch (e) {
      debugPrint('[MediaService] Gallery error: $e');
      return null;
    }
  }

  /// Converts XFile to a real temp File path. For display with Image.file().
  Future<File> getDisplayFile(XFile xfile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String ext = xfile.name.split('.').last;
      final File dest = File('${tempDir.path}/img_$timestamp.$ext');
      await xfile.saveTo(dest.path);
      debugPrint('[MediaService] Saved to temp: ${dest.path}');
      return dest;
    } catch (e) {
      debugPrint('[MediaService] _toTempFile failed ($e), fallback to original path');
      return File(xfile.path);
    }
  }
}
