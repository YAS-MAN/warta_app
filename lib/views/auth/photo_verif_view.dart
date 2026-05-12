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

  Future<void> _ambilSelfie() async {
    final image = await _mediaService.pickImageXFileFromCamera();
    if (image != null && mounted) {
      setState(() => _selfieImage = image);
    }
  }

  Future<void> _lanjutkan() async {
    if (_selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan ambil foto selfie terlebih dahulu"),
          backgroundColor: Color(0xFF8B0000),
        ),
      );
      return;
    }

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.registerStep2(_selfieImage!);

    if (!mounted) return;

    if (success) {
      // Lanjut ke verifikasi email
      if (!mounted) return;
      final email = authVM.currentUser?.email ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => EmailVerifyView(email: email)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? 'Gagal upload selfie.'),
          backgroundColor: const Color(0xFF8B0000),
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
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 1. HEADER MERAH MELENGKUNG
                SizedBox(
                  height: 180,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 83, 0, 0),
                              Color(0xFF8B0000),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 20,
                                top: 20,
                                child: Transform.rotate(
                                  angle: 12 * 3.14159 / 180,
                                  child: Image(
                                    image: const AssetImage(
                                      'assets/images/warta_logo.png',
                                    ),
                                    width: 140,
                                    height: 140,
                                    color: const Color.fromARGB(255, 58, 1, 1)
                                        .withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  60,
                                  24,
                                  0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () => Navigator.pop(context),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Text(
                                        "Ambil Foto Selfie",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 2. KONTEN TENGAH
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: iconBgLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.person_pin_circle_rounded,
                          size: 40,
                          color: primaryRed.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        "Ambil Foto Selfie",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        "Lengkapi proses ini dengan mengambil foto wajah Anda. Pastikan wajah terlihat jelas tanpa masker/kacamata hitam.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: textGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 3. AREA PREVIEW SELFIE
                      DottedBorder(
                        color: goldColor,
                        strokeWidth: 2,
                        dashPattern: const [8, 4],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(24),
                        child: Container(
                          width: 260,
                          height: 245,
                          decoration: BoxDecoration(
                            color: goldColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: _selfieImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      kIsWeb
                                          ? Image.network(
                                              _selfieImage!.path,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(_selfieImage!.path),
                                              fit: BoxFit.cover,
                                            ),
                                      Positioned(
                                        bottom: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          onTap: _ambilSelfie,
                                          child: Container(),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 45,
                                      color: goldColor,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Ketuk \"Ambil Selfie\" di bawah",
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      if (_selfieImage != null) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _ambilSelfie,
                          child: const Text(
                            "Ketuk foto untuk mengambil ulang",
                            style: TextStyle(
                              color: Color(0xFF8B1E1E),
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 4. TOMBOL-TOMBOL AKSI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (_selfieImage == null)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Colors.yellow,
                                  width: 1,
                                ),
                              ),
                              elevation: 5,
                              shadowColor: primaryRed.withValues(alpha: 0.5),
                            ),
                            onPressed: _ambilSelfie,
                            icon: const Icon(
                              Icons.camera_front,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "MULAI AMBIL SELFIE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 5,
                            ),
                            onPressed: authVM.isLoading ? null : _lanjutkan,
                            icon: authVM.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              authVM.isLoading
                                  ? "MENGUPLOAD..."
                                  : "LANJUTKAN VERIFIKASI",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),


                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
