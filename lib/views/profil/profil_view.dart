import 'package:flutter/material.dart';

class ProfilView extends StatelessWidget {
  const ProfilView({super.key});

  // Warna Konsisten WARTA
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF94A3B8);
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color borderColor = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgApp,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 60),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ==========================================
            // 1. BACKGROUND MERAH MELENGKUNG (GRADASI & WATERMARK)
            // ==========================================
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                // Menerapkan Gradasi yang lebih terang dari kartu E-KTP
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 83, 0, 0), 
                    Color(0xFF8B0000), // Merah gelap (sama seperti primaryRed)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              // ClipRRect agar watermark tidak keluar dari lengkungan
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                child: Stack(
                  children: [
                    // --- Watermark Icon ---
                    Positioned(
                      right: 10,
                      top: 20, // Disesuaikan agar posisinya pas di atas
                      child: Transform.rotate(
                        angle: 12 * 3.14159 / 180,
                        child: Image(
                          // TODO: Pastikan pakai ikon yang nyambung dengan Profil
                          image: const AssetImage(
                            'assets/icons/ic_user_after.png',
                          ),
                          width: 180,
                          height: 180,
                          color: const Color.fromARGB(
                            255,
                            58,
                            1,
                            1,
                          ).withOpacity(0.1), // Transparansi halus
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // 2. KONTEN UTAMA
            // ==========================================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: JUDUL & PENGATURAN ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Profil Saya",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- INFO PROFIL (FOTO, NAMA, NIK) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Foto Profil dengan Indikator Online Hijau
                      Stack(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: goldColor, width: 2),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                              // backgroundImage: AssetImage('assets/images/user.jpg'), // Gunakan jika ada gambar
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E), // Hijau online
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryRed, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Teks Profil
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ahmad Syarifuddin",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "NIK: 3174*********0001",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: goldColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: goldColor.withOpacity(0.5),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.verified_user,
                                  color: goldColor,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "TERVERIFIKASI",
                                  style: TextStyle(
                                    color: goldColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- KARTU E-KTP DIGITAL ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B0000), Color(0xFF4A0000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.shield,
                                  color: goldColor,
                                  size: 30,
                                ), // Placeholder Garuda
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "REPUBLIK INDONESIA",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "KARTU TANDA PENDUDUK",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "PROVINSI DKI\nJAKARTA",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "NOMOR INDUK KEPENDUDUKAN",
                          style: TextStyle(color: Colors.white70, fontSize: 9),
                        ),
                        const Text(
                          "3174 0524 0991 0001",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "TEMPAT/TGL LAHIR",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 8,
                                      ),
                                    ),
                                    Text(
                                      "JAKARTA, 24-09-1991",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "JENIS KELAMIN",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 8,
                                      ),
                                    ),
                                    Text(
                                      "LAKI-LAKI",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Kotak QR Code
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.qr_code_2,
                                  color: Colors.black,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- QUICK ACTIONS (Dompet, Riwayat, Poin, Bantuan) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAction(
                        Icons.account_balance_wallet,
                        const Color(0xFF8B0000),
                        const Color(0xFFFEF2F2),
                        "Dompet",
                      ),
                      _buildQuickAction(
                        Icons.receipt_long,
                        const Color(0xFF3B82F6),
                        const Color(0xFFEFF6FF),
                        "Riwayat",
                      ),
                      _buildQuickAction(
                        Icons.star,
                        const Color(0xFFD97706),
                        const Color(0xFFFEF3C7),
                        "Poin",
                      ),
                      _buildQuickAction(
                        Icons.help_outline,
                        const Color(0xFF16A34A),
                        const Color(0xFFDCFCE7),
                        "Bantuan",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- AKUN & KEAMANAN ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AKUN & KEAMANAN",
                        style: TextStyle(
                          color: textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              Icons.person_outline,
                              "Informasi Pribadi",
                            ),
                            const Divider(height: 1, color: borderColor),
                            _buildMenuItem(
                              Icons.lock_outline,
                              "Ubah PIN Keamanan",
                            ),
                            const Divider(height: 1, color: borderColor),
                            _buildMenuItem(
                              Icons.fingerprint,
                              "Biometrik Login",
                              subtitle: "Gunakan Face ID atau Sidik Jari",
                              isSwitch: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- LAINNYA ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "LAINNYA",
                        style: TextStyle(
                          color: textGray,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              Icons.description_outlined,
                              "Syarat & Ketentuan",
                            ),
                            const Divider(height: 1, color: borderColor),
                            _buildMenuItem(
                              Icons.logout,
                              "Keluar dari Aplikasi",
                              isLogout: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- VERSI APLIKASI ---
                const Center(
                  child: Text(
                    "WARTA APP v2.4.0",
                    style: TextStyle(
                      color: textGray,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Tombol Aksi Cepat (Bulat)
  Widget _buildQuickAction(
    IconData icon,
    Color iconColor,
    Color bgColor,
    String label,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: textDark,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Baris Menu List (ListTile Custom)
  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? subtitle,
    bool isSwitch = false,
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLogout
                  ? primaryRed.withOpacity(0.1)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isLogout ? primaryRed : primaryRed,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isLogout ? primaryRed : textDark,
                    fontSize: 14,
                    fontWeight: isLogout ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: textGray, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          if (isSwitch)
            Switch(
              value: true,
              onChanged: (val) {},
              activeColor: Colors.white,
              activeTrackColor: primaryRed,
            )
          else if (!isLogout)
            const Icon(Icons.chevron_right, color: textGray, size: 20),
        ],
      ),
    );
  }
}
