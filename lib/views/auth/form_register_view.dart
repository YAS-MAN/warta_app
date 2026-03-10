import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class FormRegistView extends StatelessWidget {
  const FormRegistView({super.key});

  // Definisi Warna dari Desain Figma
  static const Color primaryRed = Color(0xFF800000);
  static const Color bgGray = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1E293B);
  static const Color labelGray = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFD1D5DB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER MERAH & TOMBOL BACK (Menggunakan Stack agar bisa tumpang tindih)
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // Background Merah Melengkung
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(400, 80),
                    ),
                  ),
                ),
                // AppBar Custom
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 24, right: 24),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () {
                            // TODO: Navigasi kembali
                          },
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          "Lengkapi Data Diri",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // Balancer agar teks di tengah
                    ],
                  ),
                ),
                
                // 2. KOTAK PLACEHOLDER FOTO KTP (Tumpang tindih dengan background merah)
                Padding(
                  padding: const EdgeInsets.only(top: 110, left: 24, right: 24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: DottedBorder(
                      color: borderColor,
                      strokeWidth: 2,
                      dashPattern: const [6, 4],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryRed.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: primaryRed, size: 30),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "[FOTO_KTP_USER]",
                              style: TextStyle(fontWeight: FontWeight.bold, color: textDark),
                            ),
                            const Text(
                              "KETUK UNTUK UNGGAH FOTO KTP",
                              style: TextStyle(fontSize: 10, color: labelGray),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 3. FORMULIR PENGISIAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION: IDENTITAS UTAMA ---
                  _buildSectionHeader(Icons.fingerprint, "IDENTITAS UTAMA"),
                  _buildTextField("NIK", "3275012345678901"),
                  const SizedBox(height: 16),
                  _buildTextField("NAMA LENGKAP", "BUDI SETIAWAN"),
                  // Hint kecil di bawah nama
                  const Padding(
                    padding: EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      "ⓘ Nama ini akan digunakan sebagai USERNAME Login",
                      style: TextStyle(color: primaryRed, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("TEMPAT LAHIR", "JAKARTA")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("TGL LAHIR", "17-08-1945")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown("JENIS KELAMIN", "LAKI-LAKI")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("GOL. DARAH", "O")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("AGAMA", "ISLAM"),
                  const SizedBox(height: 16),
                  _buildDropdown("STATUS PERKAWINAN", "KAWIN"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("KEWARGANEGARAAN", "WNI")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("PEKERJAAN", "WIRAUSAHA")),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- SECTION: ALAMAT DOMISILI ---
                  _buildSectionHeader(Icons.location_on_outlined, "ALAMAT DOMISILI"),
                  _buildTextField("ALAMAT", "JL. MAWAR MERAH NO. 123, RT 001/002", maxLines: 3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("RT", "001")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("RW", "002")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("KELURAHAN", "KALIMALANG")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("KECAMATAN", "BEKASI SELATAN")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("KABUPATEN/KOTA", "KOTA BEKASI"),

                  const SizedBox(height: 32),

                  // --- SECTION: DATA AKUN ---
                  _buildSectionHeader(Icons.account_circle_outlined, "DATA AKUN"),
                  _buildTextField("EMAIL", "budi.setiawan@email.com"),
                  const SizedBox(height: 16),
                  _buildTextField("BUAT PASSWORD", "password123", isPassword: true),

                  const SizedBox(height: 40),

                  // --- TOMBOL SIMPAN ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        // TODO: Proses simpan data ke Firebase
                      },
                      icon: const Icon(Icons.verified_user_outlined, color: Colors.white),
                      label: const Text(
                        "SIMPAN & LANJUT",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "Pastikan semua data sudah sesuai dengan KTP asli Anda sebelum\nmenekan tombol simpan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: labelGray, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FUNGSI BANTUAN (REUSABLE WIDGETS)
  // ==========================================

  // Pembuat Judul Section (Misal: IDENTITAS UTAMA)
  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryRed, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: primaryRed, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: borderColor, height: 1),
        ],
      ),
    );
  }

  // Pembuat Form Input Teks (TextFormField)
  Widget _buildTextField(String label, String initialValue, {int maxLines = 1, bool isPassword = false}) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      obscureText: isPassword,
      style: const TextStyle(color: textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: labelGray, fontSize: 12, fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        suffixIcon: isPassword ? const Icon(Icons.visibility_outlined, color: labelGray) : null,
      ),
    );
  }

  // Pembuat Form Dropdown
  Widget _buildDropdown(String label, String initialValue) {
    return DropdownButtonFormField<String>(
      value: initialValue,
      icon: const Icon(Icons.keyboard_arrow_down, color: labelGray),
      style: const TextStyle(color: textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: labelGray, fontSize: 12, fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
      ),
      items: [
        DropdownMenuItem(value: initialValue, child: Text(initialValue)),
        // Tambahkan item lain di sini nanti
      ],
      onChanged: (value) {},
    );
  }
}