import 'package:flutter/material.dart';
import '../main/main_view.dart';
import '../auth/register_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi Warna dari CSS Figma kamu
    const Color bgGray = Color(0xFFF8F9FA);
    const Color textDark = Color(0xFF1F2937);
    const Color textGray = Color(0xFF6B7280);
    const Color borderColor = Color(0xFFD1D5DB);
    const Color goldColor = Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: bgGray,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Layer 1: Lengkungan Emas (Sedikit lebih tinggi dari yang merah)
            Container(
              height: 325,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: goldColor, // Warna emas
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(400, 80),
                ),
              ),
            ),
            // Layer 2: Lengkungan Merah
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8B0000), Color(0xFF660000)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(400, 80),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Image(
                    image: AssetImage('assets/images/warta_logo.png'),
                    width: 80,
                    height: 80,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "WARTA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ), // Jarak tambahan karena ditimpa kotak putih
                ],
              ),
            ),

            // 2. KOTAK FORM LOGIN (Overlapping / Menimpa Background Merah)
            Padding(
              padding: const EdgeInsets.only(top: 250, left: 24, right: 24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24), // Sesuai CSS Figma
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Selamat Datang Kembali",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Input Email
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFF8B0000),
                        ),
                        hintText: "Email/Username",
                        hintStyle: const TextStyle(
                          color: textGray,
                          fontSize: 16,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF8B0000),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Password
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color(0xFF8B0000),
                        ),
                        suffixIcon: const Icon(
                          Icons.visibility,
                          color: textGray,
                        ),
                        hintText: "Password",
                        hintStyle: const TextStyle(
                          color: textGray,
                          fontSize: 16,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF8B0000),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol MASUK (Merah)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          shadowColor: const Color(0xFF8B0000).withOpacity(0.5),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainView(),
                            ),
                          );
                        },
                        child: const Text(
                          "MASUK",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Warga baru? Silakan daftar.",
                      style: TextStyle(color: textGray, fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // Tombol SCAN KTP (Emas Outline)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: goldColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          // Pindah ke halaman utama (ganti MainNavigationPage dengan nama class Navbar kamu)
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterView(),
                            ),
                          );
                        },
                        child: const Text(
                          "SCAN KTP UNTUK DAFTAR",
                          style: TextStyle(
                            color: goldColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40), // Spasi bawah biar bisa di-scroll
          ],
        ),
      ),
    );
  }
}
