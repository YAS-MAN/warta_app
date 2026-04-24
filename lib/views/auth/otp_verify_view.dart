import 'package:flutter/material.dart';
import 'login_view.dart';
import '../../utils/top_notification.dart';

class OtpVerifyView extends StatefulWidget {
  const OtpVerifyView({super.key});

  @override
  State<OtpVerifyView> createState() => _OtpVerifyViewState();
}

class _OtpVerifyViewState extends State<OtpVerifyView> {
  @override
  Widget build(BuildContext context) {
    // Definisi Warna dari CSS Figma
    const Color bgGray = Color(0xFFF9FAFB);
    const Color primaryRed = Color(0xFF921515); // Mengikuti hex dari CSS OTP
    const Color textDark = Color(0xFF111827);
    const Color textGray = Color(0xFF6B7280);
    const Color goldColor = Color(0xFFEAB308); // Emas terang untuk border OTP
    const Color goldBg = Color(0xFFFEF08A); // Latar ikon gembok

    return Scaffold(
      backgroundColor: bgGray,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER MERAH MELENGKUNG (Tema Baru Web/App WARTA)
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
                        colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 20,
                            top: 20,
                            child: Transform.rotate(
                              angle: 12 * 3.14159 / 180,
                              child: Image(
                                image: const AssetImage('assets/images/warta_logo.png'),
                                width: 140,
                                height: 140,
                                color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    "Verifikasi OTP",
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Ikon Keamanan / Gembok Emas
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: goldBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline_rounded, size: 40, color: goldColor),
                    ),
                    const SizedBox(height: 32),

                    // Judul
                    const Text(
                      "Verifikasi 2 Langkah",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subjudul
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Masukkan 6 digit kode OTP yang telah kami kirimkan ke email Anda.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: textGray,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 3. KOTAK INPUT OTP (6 Kotak)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 44,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: goldColor, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              textInputAction: index < 5 ? TextInputAction.next : TextInputAction.done,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: "", // Menghilangkan teks "0/1" di bawah
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 4. TEKS KIRIM ULANG KODE
                    GestureDetector(
                      onTap: () {
                        TopNotification.show(
                          context: context,
                          message: "Kode OTP telah dikirim ulang ke email Anda.",
                          isSuccess: true,
                        );
                      },
                      child: const Text(
                        "Kirim ulang kode",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. TOMBOL VERIFIKASI (Di bagian paling bawah)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.yellow, width: 1), // Border kuning sesuai CSS
                    ),
                    elevation: 5,
                    shadowColor: primaryRed.withValues(alpha: 0.4),
                  ),
                  onPressed: () {
                    TopNotification.show(
                      context: context,
                      message: "Registrasi Berhasil! Silakan Login.",
                      isSuccess: true,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    );
                  },
                  child: const Text(
                    "VERIFIKASI",
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
          ],
        ),
      ),
    );
  }
}