import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart'; // Paket untuk border putus-putus

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna dari CSS Figma
    const Color bgGray = Color(0xFFF9FAFB);
    const Color primaryRed = Color(0xFF8B1E1E); // Sedikit lebih terang dari halaman login
    const Color textDark = Color(0xFF0F172A);
    const Color textGray = Color(0xFF64748B);
    const Color goldColor = Color(0xFFD4AF37);
    const Color iconBgLight = Color(0xFFFEE2E2); // Pink/Merah sangat muda

    return Scaffold(
      backgroundColor: bgGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER MERAH MELENGKUNG (Sama dengan Login, tapi lebih pendek)
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryRed,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(400, 80),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Ganti dengan Image.asset() kalau logo sudah siap
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Image(image: AssetImage('assets/images/warta_logo.png'), width: 80,height: 80,),
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
                  // Ikon Kamera Bulat Pink
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: iconBgLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.camera_alt_rounded, size: 40, color: primaryRed.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 24),

                  // Judul
                  const Text(
                    "Foto & Verifikasi e-KTP",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subjudul/Instruksi
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: textGray, height: 1.5),
                      children: [
                        TextSpan(text: "Yuk mulai! Posisikan e-KTP kamu di dalam bingkai agar data bisa terbaca otomatis oleh sistem "),
                        TextSpan(text: "WARTA", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
                        TextSpan(text: "."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. AREA SCAN E-KTP (Dotted Border)
                  DottedBorder(
                    color: goldColor,
                    strokeWidth: 2,
                    dashPattern: const [8, 4], // Panjang garis 8, spasi 4
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 190,
                      decoration: BoxDecoration(
                        color: goldColor.withOpacity(0.05), // Background emas transparan
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 30, color: goldColor),
                          SizedBox(height: 8),
                          Text(
                            "Area e-KTP",
                            style: TextStyle(
                              color: goldColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 4. TOMBOL AMBIL FOTO (Menempel di bawah)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.yellow, width: 1), // Border kuning halus seperti di CSS
                    ),
                    elevation: 5,
                    shadowColor: primaryRed.withOpacity(0.5),
                  ),
                  onPressed: () {
                    // TODO: Panggil fungsi Kamera/ML Kit dari AuthViewModel
                  },
                  icon: const Icon(Icons.camera, color: Colors.white),
                  label: const Text(
                    "AMBIL FOTO",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}