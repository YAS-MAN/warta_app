import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/surat_model.dart';
import '../../services/cloudinary_service.dart';

/// Bottom sheet untuk memenuhi satu persyaratan surat:
/// - type == upload → pilih foto (kamera/galeri) → upload Cloudinary
/// - type == text   → isi teks
class SuratRequirementSheet extends StatefulWidget {
  final SuratRequirement requirement;
  final String? currentValue; // URL atau teks yang sudah ada
  final void Function(String value) onFulfilled;

  const SuratRequirementSheet({
    super.key,
    required this.requirement,
    required this.onFulfilled,
    this.currentValue,
  });

  @override
  State<SuratRequirementSheet> createState() => _SuratRequirementSheetState();
}

class _SuratRequirementSheetState extends State<SuratRequirementSheet> {
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);

  bool _isUploading = false;
  String? _uploadedUrl;
  String? _errorMsg;
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentValue != null) {
      if (widget.requirement.type == RequirementType.text) {
        _textCtrl.text = widget.currentValue!;
      } else {
        _uploadedUrl = widget.currentValue;
      }
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(bool fromCamera) async {
    setState(() {
      _isUploading = true;
      _errorMsg = null;
    });
    try {
      final picker = ImagePicker();
      final XFile? file = fromCamera
          ? await picker.pickImage(source: ImageSource.camera, imageQuality: 80)
          : await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

      if (file == null) {
        setState(() => _isUploading = false);
        return;
      }

      final cloudinary = CloudinaryService();
      final url = await cloudinary.uploadImageXFile(file, folder: 'surat_docs');

      if (url == null) throw Exception('Upload gagal. Coba lagi.');

      setState(() {
        _uploadedUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
        _isUploading = false;
      });
    }
  }

  void _save() {
    if (widget.requirement.type == RequirementType.text) {
      final text = _textCtrl.text.trim();
      if (text.isEmpty) {
        setState(() => _errorMsg = 'Kolom ini tidak boleh kosong.');
        return;
      }
      widget.onFulfilled(text);
    } else {
      if (_uploadedUrl == null) {
        setState(() => _errorMsg = 'Silakan upload dokumen terlebih dahulu.');
        return;
      }
      widget.onFulfilled(_uploadedUrl!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isText = widget.requirement.type == RequirementType.text;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Label
          Text(
            widget.requirement.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.requirement.description,
            style: const TextStyle(color: textGray, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Body: upload or text
          if (isText) ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: TextField(
                controller: _textCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: widget.requirement.hint ?? 'Isi di sini...',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ] else ...[
            // Preview foto jika sudah ada
            if (_uploadedUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _uploadedUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '✓ Dokumen berhasil diupload',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Tombol upload
            if (_isUploading)
              const Center(child: CircularProgressIndicator(color: primaryRed))
            else
              Row(
                children: [
                  Expanded(
                    child: _buildUploadBtn(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      onTap: () => _pickAndUpload(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUploadBtn(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      onTap: () => _pickAndUpload(false),
                    ),
                  ),
                ],
              ),
          ],

          // Error
          if (_errorMsg != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMsg!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],

          const SizedBox(height: 24),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isUploading ? null : _save,
              child: const Text(
                'Simpan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8B0000).withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF8B0000), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B0000),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
