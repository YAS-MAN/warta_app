import 'package:flutter/material.dart';
import '../../utils/top_notification.dart';
import 'surat_detail_view.dart';
import 'surat_category_view.dart';

import '../../models/surat_model.dart';
import '../../services/surat_service.dart';

class SuratView extends StatefulWidget {
  final Function(int) onNavigate;

  const SuratView({super.key, required this.onNavigate});

  @override
  State<SuratView> createState() => _SuratViewState();
}

class _SuratViewState extends State<SuratView> {
  // State Filter
  bool _isFilterOpen = false;
  String _selectedFilter = "Semua Kategori";

  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);

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
                          color: Colors.black.withValues(alpha: 0.1),
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
                                ).withValues(alpha: 0.1),
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
                                    InkWell(
                                      onTap: () => widget.onNavigate(0), // Home
                                      child: _buildTopIcon(Icons.arrow_back),
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          widget.onNavigate(3), // Aktivitas
                                      child: _buildTopIcon(Icons.history),
                                    ),
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

                  // Menambahkan Dropdown Filter Animasi di Bawah Header (DIPINDAHKAN KE BAWAH)

                  // Search Bar & Filter Melayang
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              onSubmitted: (value) {
                                TopNotification.show(
                                  context: context,
                                  message: "Mencari surat: $value",
                                );
                              },
                              decoration: InputDecoration(
                                hintText: _selectedFilter == "Semua Kategori"
                                    ? "Cari jenis surat..."
                                    : "Cari surat ${_selectedFilter.toLowerCase()}...",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol Filter Merah (Animasi Rotasi)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isFilterOpen = !_isFilterOpen;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: _isFilterOpen
                                  ? Colors.white
                                  : const Color.fromARGB(255, 117, 0, 0),
                              // Agar nyambung dengan filter saat terbuka
                              borderRadius: _isFilterOpen
                                  ? const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    )
                                  : BorderRadius.circular(12),
                              border: _isFilterOpen
                                  ? Border.all(
                                      color: const Color.fromARGB(
                                        255,
                                        117,
                                        0,
                                        0,
                                      ),
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: AnimatedRotation(
                              turns: _isFilterOpen ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                _isFilterOpen ? Icons.close : Icons.filter_list,
                                color: _isFilterOpen
                                    ? const Color.fromARGB(255, 117, 0, 0)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24), // Spacer for drop shadow
            // ==========================================
            // 2. KATEGORI & FILTER ANIMASI
            // ==========================================
            // --- DROPDOWN FILTER (AnimatedSize Pendorong Konten) ---
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isFilterOpen
                  ? Padding(
                      // Lebar mengikuti lebar Search Bar dan Filter Button (Memenuhi area 24 Kanan - Kiri)
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 16,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pilih Kategori",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFilterChip("Semua Kategori"),
                                _buildFilterChip("Administrasi"),
                                _buildFilterChip("Perizinan"),
                                _buildFilterChip("Keterangan"),
                                _buildFilterChip("Hukum"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(
                      width: double.infinity,
                      height: 0,
                    ), // Hilang saat tertutup
            ),

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
                        child: InkWell(
                          onTap: () =>
                              _navigateToCategory(context, "Administrasi"),
                          child: _buildCategoryCard(
                            Icons.description,
                            const Color(0xFF2563EB),
                            const Color(0xFFEFF6FF),
                            "Administrasi",
                            "KK, KTP, Akta",
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              _navigateToCategory(context, "Perizinan"),
                          child: _buildCategoryCard(
                            Icons.domain,
                            const Color(0xFFEA580C),
                            const Color(0xFFFFF7ED),
                            "Perizinan",
                            "Usaha, Bangunan",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Baris 2
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              _navigateToCategory(context, "Keterangan"),
                          child: _buildCategoryCard(
                            Icons.volunteer_activism,
                            const Color(0xFF9333EA),
                            const Color(0xFFFAF5FF),
                            "Keterangan",
                            "Suket, Domisili",
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _navigateToCategory(context, "Hukum"),
                          child: _buildCategoryCard(
                            Icons.gavel,
                            const Color(0xFF16A34A),
                            const Color(0xFFF0FDF4),
                            "Hukum",
                            "Ahli Waris, Tanah",
                          ),
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
                  _buildPopularItems(),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Fitur Navigasi untuk kategori surat terbaru
  void _navigateToCategory(BuildContext context, String kategori) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SuratCategoryView(categoryName: kategori),
      ),
    );
  }

  // Fungsi dinamis mengambil 3 data pertama acak dari mock data surat
  Widget _buildPopularItems() {
    return FutureBuilder<List<SuratModel>>(
      future: SuratService().getPopularSurat(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Color(0xFF8B0000)),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();

        final popularList = snapshot.data!;
        return Column(
          children: popularList.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _showSuratDialog(context, item.title),
                child: _buildPopularItem(item.icon, item.title, item.category),
              ),
            );
          }).toList(),
        );
      }
    );
  }

  void _showSuratDialog(BuildContext context, String judul) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SuratDetailView(title: judul)),
    );
  }

  // Ikon Bulat Transparan di Header (Back & History)
  Widget _buildTopIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  // Komponen Chip untuk Filter Dropdown
  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _isFilterOpen = false; // Tutup filter saat di tap
        });
        TopNotification.show(
          context: context,
          message: "Filter diterapkan: $label",
          isSuccess: true,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 117, 0, 0)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
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
            color: Colors.black.withValues(alpha: 0.02),
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
            color: Colors.black.withValues(alpha: 0.02),
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
