import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// PENTING: Pastikan jalur import ini sesuai dengan letak folder kamu
import 'views/auth/login_view.dart';

void main() {
  runApp(const WartaApp());
}

class WartaApp extends StatelessWidget {
  const WartaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WARTA',
      // Menghilangkan pita "DEBUG" yang ganggu di pojok kanan atas
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B0000)),
        useMaterial3: true,
        // Gunakan copyWith untuk mengatur jenis teks spesifik
        textTheme: GoogleFonts.interTextTheme().copyWith(
          // Mengatur teks utama/judul menjadi tebal (w600)
          bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
          // Mengatur teks biasa menjadi sedikit lebih tebal (w500)
          bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
      ),

      // INI KUNCINYA: Jadikan LoginView sebagai halaman pertama yang terbuka
      home: const LoginView(),
    );
  }
}
