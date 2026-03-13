import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // Warna sesuai CSS Figma
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgGray = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color greenSuccess = Color(0xFF16A34A);
  static const Color bgSuccess = Color(0xFFDCFCE7);
  static const Color yellowProcess = Color(0xFFA16207);
  static const Color bgProcess = Color(0xFFFEF9C3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,

      // ==========================================
      // KONTEN UTAMA (BODY)
      // ==========================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 40,
        ), // Jarak agar tidak tertutup nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER (GRADASI & WATERMARK)
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              // Gunakan ClipRRect agar ikon rumah yang melayang tetap terpotong rapi mengikuti lengkungan merah
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Transform.rotate(
                        angle: 12 * 3.14159 / 180,
                        child: Image(
                          image: const AssetImage(
                            'assets/icons/ic_home_after.png',
                          ),
                          width:
                              180, // Ukuran diperbesar sedikit agar lebih gagah
                          height: 180,
                          color: const Color.fromARGB(255, 58, 1, 1)
                              .withOpacity(
                                0.1,
                              ), // Opacity halus agar tidak menabrak teks
                        ),
                      ),
                    ),

                    // --- Konten Utama ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Teks Sapaan & Ikon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Selamat Pagi,",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Text(
                                    "Budi Setiawan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildTopIcon(Icons.notifications_none),
                                  const SizedBox(width: 8),
                                  _buildTopIcon(Icons.search),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // --- Card Status Identitas ---
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                24,
                              ), // Disamakan dengan radius umum
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Kotak Fingerprint (Revisi Border)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFDF7E7,
                                    ), // Warna emas pudar
                                    // REVISI: BorderRadius disamakan biar tidak kaku
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.fingerprint,
                                    color: Color(0xFFD4AF37),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "STATUS IDENTITAS",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Terverifikasi (E-KTP)",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Tombol Lihat QR
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B0000),
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ), // Radius disesuaikan
                                  ),
                                  child: const Text(
                                    "LIHAT QR",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 2. LAYANAN DIGITAL (Menu Grid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Layanan Digital",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        "Lihat Semua",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryRed.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMenuBtn(Icons.badge, "Digital ID"),
                      _buildMenuBtn(Icons.campaign, "Pengaduan"),
                      _buildMenuBtn(Icons.article, "Berita"),
                      _buildMenuBtn(Icons.priority_high, "Darurat"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. AKTIVITAS TERAKHIR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Aktivitas Terakhir",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        "Riwayat",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryRed.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildActivityItem(
                          Icons.check_circle,
                          greenSuccess,
                          bgSuccess,
                          "Verifikasi E-KTP",
                          "2 Jam yang lalu",
                          "BERHASIL",
                          greenSuccess,
                          bgSuccess,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: bgGray, thickness: 1.5),
                        ),
                        _buildActivityItem(
                          Icons.description,
                          Colors.blue,
                          Colors.blue.withOpacity(0.1),
                          "Permohonan Surat",
                          "Kemarin, 14:20",
                          "PROSES",
                          yellowProcess,
                          bgProcess,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. BANNER INFORMASI PUBLIK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryRed, // Warna dasar merah
                  borderRadius: BorderRadius.circular(16),
                  // PERUBAHAN: Background efek kota transparan
                  image: DecorationImage(
                    image: const AssetImage('assets/images/city_bg.webp'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      primaryRed.withOpacity(0.3),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "INFORMASI PUBLIK",
                      style: TextStyle(
                        color: goldColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Vaksinasi Massal\nKecamatan Merdeka",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Ikon Bulat Transparan di Header
  Widget _buildTopIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  // Tombol Menu Layanan Digital (PERUBAHAN: Diperbesar ukurannya)
  Widget _buildMenuBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 64, // Diperbesar dari 56 agar tidak kelihatan renggang
          height: 64, // Diperbesar dari 56
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18), // Melengkung lebih halus
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: primaryRed,
            size: 28,
          ), // Ikon juga diperbesar
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: textGray,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Item List Aktivitas
  Widget _buildActivityItem(
    IconData icon,
    Color iconColor,
    Color iconBg,
    String title,
    String time,
    String status,
    Color statusColor,
    Color statusBg,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: textGray, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
