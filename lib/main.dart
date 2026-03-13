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
        // Set warna dasar aplikasi ke Merah Marun WARTA
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B0000)),
        useMaterial3: true,
        // fontFamily: 'Inter', // Buka komen ini kalau font Inter sudah kamu tambahkan ke pubspec.yaml
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),

      // INI KUNCINYA: Jadikan LoginView sebagai halaman pertama yang terbuka
      home: const LoginView(),
    );
  }
}
