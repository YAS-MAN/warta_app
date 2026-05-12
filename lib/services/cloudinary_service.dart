import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Service untuk upload gambar ke Cloudinary (free tier).
/// Menggunakan unsigned upload preset — tidak butuh API Secret di client.
class CloudinaryService {
  static const String _cloudName = 'dm8ub8uew';
  static const String _uploadPreset = 'warta_db';

  static const String _baseUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Upload gambar ke Cloudinary.
  /// [folder]: 'ktp_photos' atau 'selfies'
  /// Returns URL string jika sukses, null jika gagal.
  Future<String?> uploadImage(File imageFile, {String folder = 'warta'}) async {
    try {
      debugPrint('[Cloudinary] Mengupload ke folder: $folder');

      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'upload_image.jpg',
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody) as Map<String, dynamic>;
        final url = jsonData['secure_url'] as String?;
        debugPrint('[Cloudinary] Upload sukses: $url');
        return url;
      } else {
        debugPrint('[Cloudinary] Upload gagal [${response.statusCode}]: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('[Cloudinary] ERROR: $e');
      return null;
    }
  }

  /// Upload gambar ke Cloudinary menggunakan XFile (Mendukung Flutter Web).
  Future<String?> uploadImageXFile(XFile xFile, {String folder = 'warta'}) async {
    try {
      debugPrint('[Cloudinary] Mengupload ke folder: $folder via XFile');

      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      final bytes = await xFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: xFile.name.isNotEmpty ? xFile.name : 'upload_image.jpg',
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody) as Map<String, dynamic>;
        final url = jsonData['secure_url'] as String?;
        debugPrint('[Cloudinary] Upload sukses: $url');
        return url;
      } else {
        debugPrint('[Cloudinary] Upload gagal [${response.statusCode}]: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('[Cloudinary] ERROR XFile: $e');
      return null;
    }
  }

  /// Upload file bytes (dari file_picker) ke Cloudinary.
  /// Mendukung PDF dan format dokumen lainnya via auto/upload.
  Future<String?> uploadFileBytes(
    Uint8List bytes,
    String filename, {
    String folder = 'surat_docs',
  }) async {
    try {
      debugPrint('[Cloudinary] Mengupload file: $filename ke folder: $folder');

      // Gunakan auto/upload agar Cloudinary otomatis deteksi tipe file
      const autoUploadUrl =
          'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload';

      final request = http.MultipartRequest('POST', Uri.parse(autoUploadUrl));
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody) as Map<String, dynamic>;
        final url = jsonData['secure_url'] as String?;
        debugPrint('[Cloudinary] Upload file sukses: $url');
        return url;
      } else {
        debugPrint(
            '[Cloudinary] Upload file gagal [${response.statusCode}]: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('[Cloudinary] ERROR file upload: $e');
      return null;
    }
  }
}
