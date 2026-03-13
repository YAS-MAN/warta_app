import 'package:flutter/material.dart';

class SuratView extends StatelessWidget {
  const SuratView({super.key});

  // Warna sesuai CSS Figma
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);
  static const Color goldColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgApp, // Pastikan variabel bgApp sudah ada
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER MERAH & SEARCH BAR (Tumpang Tindih)
            // ==========================================
            SizedBox(
              height: 230,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    // PADDING DIHAPUS DARI SINI, PINDAH KE DALAM
                    decoration: BoxDecoration(
                      // 1. Terapkan warna gradasi di sini
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
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    // 2. Bungkus Stack dengan ClipRRect
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                      child: Stack(
                        children: [
                          // --- Watermark Icon ---
                          Positioned(
                            right: 20,
                            top: 20,
                            child: Transform.rotate(
                              angle: 12 * 3.14159 / 180,
                              child: Image(
                                image: const AssetImage(
                                  'assets/icons/ic_document_after.png',
                                ),
                                width: 140,
                                height: 140,
                                color: const Color.fromARGB(
                                  255,
                                  58,
                                  1,
                                  1,
                                ).withOpacity(0.1),
                              ),
                            ),
                          ),

                          // --- Konten Teks & Tombol ---
                          // 3. Padding dipindah ke sini
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Baris Ikon Atas (Back & History)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildTopIcon(Icons.arrow_back),
                                    _buildTopIcon(Icons.history),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Teks Judul
                                const Text(
                                  "Layanan Surat",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Ajukan permohonan surat secara online",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search Bar Melayang
                  Positioned(
                    bottom: 5,
                    left: 24,
                    right: 24,
                    child: Row(
                      children: [
                        // Kotak Input Pencarian
                        Expanded(
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Cari jenis surat...",
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol Filter Merah
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 117, 0, 0),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // 2. KATEGORI SURAT (Grid 2x2)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kategori Surat",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Baris 1
                  Row(
                    children: [
                      Expanded(
                        child: _buildCategoryCard(
                          Icons.description,
                          const Color(0xFF2563EB),
                          const Color(0xFFEFF6FF),
                          "Administrasi",
                          "KK, KTP, Akta",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryCard(
                          Icons.domain,
                          const Color(0xFFEA580C),
                          const Color(0xFFFFF7ED),
                          "Perizinan",
                          "Usaha, Bangunan",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Baris 2
                  Row(
                    children: [
                      Expanded(
                        child: _buildCategoryCard(
                          Icons.volunteer_activism,
                          const Color(0xFF9333EA),
                          const Color(0xFFFAF5FF),
                          "Keterangan",
                          "Tidak Mampu, Domisili",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryCard(
                          Icons.gavel,
                          const Color(0xFF16A34A),
                          const Color(0xFFF0FDF4),
                          "Hukum",
                          "Ahli Waris, Tanah",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // 3. PALING SERING DIAKSES (List View)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Paling Sering Diakses",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPopularItem(
                    Icons.home,
                    "Surat Keterangan Domisili",
                    "Administrasi Kependudukan",
                  ),
                  const SizedBox(height: 12),
                  _buildPopularItem(
                    Icons.storefront,
                    "Surat Izin Usaha Mikro",
                    "Perizinan Usaha",
                  ),
                  const SizedBox(height: 12),
                  _buildPopularItem(
                    Icons.family_restroom,
                    "Surat Keterangan Kelahiran",
                    "Pencatatan Sipil",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Ikon Bulat Transparan di Header (Back & History)
  Widget _buildTopIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  // Kotak Kategori (Grid)
  Widget _buildCategoryCard(
    IconData icon,
    Color iconColor,
    Color bgColor,
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: textGray, fontSize: 10)),
        ],
      ),
    );
  }

  // Item List "Paling Sering Diakses"
  Widget _buildPopularItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon Merah Muda
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF991B1B), size: 20),
          ),
          const SizedBox(width: 16),
          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: textGray, fontSize: 11),
                ),
              ],
            ),
          ),
          // Panah Kanan
          const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
        ],
      ),
    );
  }
}
