import 'package:flutter/material.dart';

class AktivitasView extends StatelessWidget {
  const AktivitasView({super.key});

  // Warna Konsisten WARTA
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color primaryRedDark = Color(
    0xFFB10000,
  ); // Merah untuk tombol aktif
  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);
  static const Color textLightGray = Color(0xFF94A3B8);
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color borderColor = Color(0xFFF1F5F9);

  // Warna Status
  static const Color colorSuccess = Color(0xFF10B981);
  static const Color bgSuccess = Color(0xFFF0FDF4);
  static const Color colorProcess = Color(0xFF3B82F6);
  static const Color bgProcess = Color(0xFFEFF6FF);
  static const Color colorReject = Color(0xFFEF4444);
  static const Color bgReject = Color(0xFFFEF2F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgApp,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER LENGKUNG (GRADASI & WATERMARK)
            // ==========================================
            SizedBox(
              height: 230, // Tinggi area header
              child: Stack(
                clipBehavior:
                    Clip.none, // Penting agar tab bisa melayang keluar sedikit
                children: [
                  // 1. BACKGROUND MERAH (Paling Bawah)
                  Container(
                    height: 200,
                    width: double.infinity,
                    // PADDING DIHAPUS DARI SINI
                    decoration: BoxDecoration(
                      // --- TERAPKAN GRADASI DI SINI ---
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
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    // 1. Tambahkan ClipRRect agar watermark mengikuti lengkungan
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                      child: Stack(
                        children: [
                          // --- Watermark Icon ---
                          Positioned(
                            right: 5, // Sesuaikan geseran kanan-kirinya
                            top: 30, // Sesuaikan geseran atas-bawahnya
                            child: Transform.rotate(
                              angle: 12 * 3.14159 / 180,
                              child: Image(
                                image: const AssetImage(
                                  'assets/icons/ic_restore_after.png',
                                ), // Pastikan nama asetnya benar
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

                          // --- Konten Teks ---
                          // 2. Padding dipindah ke sini, khusus untuk Teks
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Aktivitas Saya",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Pantau status pengajuan dan laporan Anda",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
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

                  // Filter Tabs (Semua, Menunggu, Selesai) - Menimpa Header
                  Positioned(
                    bottom: 5, // Mengatur seberapa jauh dia melayang dari bawah
                    left: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTabButton("Semua", isActive: true),
                        _buildTabButton("Menunggu", isActive: false),
                        _buildTabButton("Selesai", isActive: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // ==========================================
            // 2. KELOMPOK: HARI INI
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "HARI INI",
                    style: TextStyle(
                      color: textLightGray,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Item 1: Verifikasi E-KTP (Berhasil)
                  _buildActivityCard(
                    icon: Icons.check_circle,
                    iconColor: colorSuccess,
                    iconBg: bgSuccess,
                    title: "Verifikasi E-KTP",
                    subtitle: "Identitas Kependudukan Digital",
                    status: "BERHASIL",
                    statusColor: colorSuccess,
                    statusBg: bgSuccess,
                    time: "14:30 WIB",
                    actionText: "LIHAT DETAIL",
                  ),
                  const SizedBox(height: 16),

                  // Item 2: Permohonan SKCK (Proses) dengan indikator tahapan
                  _buildActivityCard(
                    icon: Icons.description,
                    iconColor: colorProcess,
                    iconBg: bgProcess,
                    title: "Permohonan SKCK",
                    subtitle: "Layanan Kepolisian",
                    status: "PROSES",
                    statusColor: colorProcess,
                    statusBg: bgProcess,
                    time: "09:15 WIB",
                    actionText: "LIHAT DETAIL",
                    customContent: _buildProgressIndicator(), // Indikator 1-2-3
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // 3. KELOMPOK: KEMARIN
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "KEMARIN",
                    style: TextStyle(
                      color: textLightGray,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Item 3: Pengajuan KK Baru (Ditolak)
                  _buildActivityCard(
                    icon: Icons.cancel,
                    iconColor: colorReject,
                    iconBg: bgReject,
                    title: "Pengajuan KK Baru",
                    subtitle: "Dokumen Tidak Lengkap",
                    status: "DITOLAK",
                    statusColor: colorReject,
                    statusBg: bgReject,
                    time: "16:45 WIB",
                    actionText: "AJUKAN ULANG",
                    actionColor: goldColor,
                  ),
                  const SizedBox(height: 16),

                  // Item 4: Laporan Jalan Rusak (Selesai/Berhasil)
                  _buildActivityCard(
                    icon: Icons
                        .campaign, // Menggunakan ikon pengeras suara seperti di desain
                    iconColor: const Color(0xFFF97316), // Oranye
                    iconBg: const Color(0xFFFFF7ED),
                    title: "Laporan Jalan Rusak",
                    subtitle: "Pengaduan Masyarakat",
                    status: "SELESAI",
                    statusColor: colorSuccess,
                    statusBg: bgSuccess,
                    time: "10:20 WIB",
                    actionText: "LIHAT TANGGAPAN",
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

  // Tombol Filter Tab di Header
  Widget _buildTabButton(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      decoration: BoxDecoration(
        // Jika aktif, gunakan gradasi yang sama dengan header
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFF8B0000), Color.fromARGB(255, 83, 0, 0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null, // Jika tidak aktif, tidak pakai gradasi
        color: isActive ? null : Colors.white, // Jika tidak aktif, pakai putih
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Komponen Kartu Aktivitas Keseluruhan
  Widget _buildActivityCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String time,
    required String actionText,
    Color? actionColor, // Opsional, default merah marun
    Widget? customContent, // Untuk indikator 1-2-3 pada proses SKCK
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              // Teks Judul & Subjudul
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: textGray, fontSize: 12),
                    ),
                    if (customContent != null) ...[
                      const SizedBox(height: 12),
                      customContent,
                    ],
                  ],
                ),
              ),
              // Label Status (Kanan Atas)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: bgApp, thickness: 1.5),
          const SizedBox(height: 8),
          // Baris Waktu & Aksi (Kanan Bawah)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: textLightGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                actionText,
                style: TextStyle(
                  color: actionColor ?? primaryRed,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Khusus untuk Tahapan SKCK (Bulatan 1, 2, 3)
  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepCircle("1", isDone: true),
        const SizedBox(width: 4),
        _buildStepCircle("2", isCurrent: true),
        const SizedBox(width: 4),
        _buildStepCircle("3"),
        const SizedBox(width: 8),
        const Text(
          "Tahap Verifikasi Berkas",
          style: TextStyle(
            color: textLightGray,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Lingkaran kecil untuk tahap proses
  Widget _buildStepCircle(
    String step, {
    bool isDone = false,
    bool isCurrent = false,
  }) {
    Color bgColor = const Color(0xFFF1F5F9); // Abu-abu (Default)
    Color textColor = textLightGray;

    if (isDone) {
      bgColor = const Color(0xFFDBEAFE); // Biru muda
      textColor = const Color(0xFF60A5FA);
    } else if (isCurrent) {
      bgColor = const Color(0xFF3B82F6); // Biru tua
      textColor = Colors.white;
    }

    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Text(
        step,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
