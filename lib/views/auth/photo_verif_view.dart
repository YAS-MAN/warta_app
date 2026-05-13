import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/media_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'email_verify_view.dart';

class PhotoVerifView extends StatefulWidget {
  /// uid dari proses registerStep1. Null jika view dibuka tanpa konteks registrasi.
  final String? pendingUid;

  const PhotoVerifView({super.key, this.pendingUid});

  @override
  State<PhotoVerifView> createState() => _PhotoVerifViewState();
}

class _PhotoVerifViewState extends State<PhotoVerifView> {
  static const Color bgGray = Color(0xFFF9FAFB);
  static const Color primaryRed = Color(0xFF8B1E1E);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color iconBgLight = Color(0xFFFEE2E2);

  final MediaService _mediaService = MediaService();
  XFile? _selfieImage;

  Future<void> _showPickOptions() async {
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text("Ambil Foto Selfie", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Kamera",
                  color: primaryRed,
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: "Galeri",
                  color: Colors.blue,
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = source == 'camera'
        ? await _mediaService.pickImageXFileFromCamera()
        : await _mediaService.pickImageXFileFromGallery();

    if (image != null && mounted) {
      setState(() => _selfieImage = image);
    }
  }

  Widget _buildPickerOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Future<void> _lanjutkan() async {
    if (_selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan ambil foto selfie terlebih dahulu"),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.registerStep2(_selfieImage!);

    if (!mounted) return;

    if (success) {
      final email = authVM.currentUser?.email ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EmailVerifyView(email: email)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? 'Gagal upload selfie.'),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        return Scaffold(
          backgroundColor: bgGray,
          body: Column(
            children: [
              // 1. HEADER - Reduced height
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20, top: -20,
                      child: Transform.rotate(
                        angle: 12 * 3.14159 / 180,
                        child: Image(image: const AssetImage('assets/images/warta_logo.png'), width: 120, height: 120, color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.1)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 60, 24, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text("Ambil Foto Selfie", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. KONTEN
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: iconBgLight, borderRadius: BorderRadius.circular(16)),
                            child: Icon(Icons.face_retouching_natural_rounded, size: 32, color: primaryRed.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 16),
                          const Text("Ambil Foto Selfie", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.5)),
                          const SizedBox(height: 8),
                          const Text(
                            "Pastikan wajah terlihat jelas tanpa masker atau kacamata hitam untuk proses verifikasi.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: textGray, height: 1.4),
                          ),
                          const SizedBox(height: 24),

                          // 3. AREA PREVIEW SELFIE
                          GestureDetector(
                            onTap: _showPickOptions,
                            child: DottedBorder(
                              color: goldColor.withValues(alpha: 0.5),
                              strokeWidth: 2,
                              dashPattern: const [8, 4],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(24),
                              child: Container(
                                width: 240, height: 240,
                                decoration: BoxDecoration(color: goldColor.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(24)),
                                child: _selfieImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            kIsWeb ? Image.network(_selfieImage!.path, fit: BoxFit.cover) : Image.file(File(_selfieImage!.path), fit: BoxFit.cover),
                                            Positioned(
                                              bottom: 12, right: 12,
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                                                child: const Icon(Icons.check, color: Colors.white, size: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.add_a_photo_outlined, size: 40, color: goldColor),
                                          const SizedBox(height: 12),
                                          Text("Ketuk untuk ambil selfie", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 4. TOMBOL AKSI
                      Column(
                        children: [
                          if (_selfieImage == null)
                            SizedBox(
                              width: double.infinity, height: 56,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryRed,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: _showPickOptions,
                                icon: const Icon(Icons.camera_front_rounded, color: Colors.white),
                                label: const Text("MULAI AMBIL SELFIE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity, height: 56,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: authVM.isLoading ? null : _lanjutkan,
                                icon: authVM.isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.check_circle_rounded, color: Colors.white),
                                label: Text(authVM.isLoading ? "MENGUPLOAD..." : "LANJUTKAN VERIFIKASI", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
