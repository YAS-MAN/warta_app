import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/top_notification.dart';
import 'aktivitas_detail_view.dart';
import '../../models/aktivitas_model.dart';
import '../../services/aktivitas_service.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AktivitasView extends StatefulWidget {
  const AktivitasView({super.key});

  @override
  State<AktivitasView> createState() => _AktivitasViewState();
}

class _AktivitasViewState extends State<AktivitasView> {
  int _activeTabIndex = 0; // 0: Semua, 1: Menunggu, 2: Selesai

  // Tema Warna Konsisten WARTA
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);
  static const Color textLightGray = Color(0xFF94A3B8);
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color borderColor = Color(0xFFF1F5F9);

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
                        _buildTabButton("Semua", 0),
                        _buildTabButton("Menunggu", 1),
                        _buildTabButton("Selesai", 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const SizedBox(height: 24),
            // ==========================================
            // DAFTAR AKTIVITAS DINAMIS DARI SERVICE
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer<AuthViewModel>(
                builder: (context, authVM, _) {
                  final uid = authVM.currentUser?.uid ?? '';
                  return StreamBuilder<List<AktivitasModel>>(
                stream: AktivitasService().streamUserActivities(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: primaryRed),
                      )
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada aktivitas."));
                  }

                  // Filter logic based on active tab
                  List<AktivitasModel> allItems = snapshot.data!;
                  List<AktivitasModel> filteredItems = allItems.where((item) {
                    if (_activeTabIndex == 0) return true; // Semua
                    if (_activeTabIndex == 1) return item.status == "PROSES"; // Menunggu
                    if (_activeTabIndex == 2) return item.status == "BERHASIL" || item.status == "SELESAI"; // Selesai
                    return false;
                  }).toList();

                  // Sort or group logic could be applied here. For now, we list them directly.
                  if (filteredItems.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("Tidak ada aktivitas di kategori ini.", style: TextStyle(color: textGray)),
                      )
                    );
                  }

                  return Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: filteredItems.map((item) {
                       // Menentukan custom handler untuk "INGATKAN ADMIN" jika PROSES
                       String actionText = item.status == "PROSES" ? "INGATKAN ADMIN" : "LIHAT DETAIL";
                       VoidCallback? actionCallback;
                       
                       if (item.status == "PROSES") {
                         actionCallback = () {
                            TopNotification.show(
                              context: context,
                              message: "Pengingat berhasil dikirim ke Admin",
                              isSuccess: true,
                            );
                         };
                       } else if (item.status == "DITOLAK") {
                         actionText = "AJUKAN ULANG";
                         actionCallback = () => _showDetailDialog(context, item.title, item.subtitle, item.status, item.date);
                       }

                       // Custom indikator khusus untuk "Permohonan SKCK" bisa ditambahkan jika nama title sesuai
                       Widget? customContent;
                       if (item.title == "Permohonan SKCK" && item.status == "PROSES") {
                         customContent = _buildProgressIndicator();
                       }

                       return Padding(
                         padding: const EdgeInsets.only(bottom: 16),
                         child: _buildActivityCard(
                           icon: IconData(item.iconCodePoint, fontFamily: item.iconFontFamily),
                           iconColor: item.iconColor,
                           iconBg: item.iconBgColor,
                           title: item.title,
                           subtitle: item.subtitle,
                           status: item.status,
                           statusColor: item.statusTextColor,
                           statusBg: item.statusBgColor,
                           time: item.date,
                           actionText: actionText,
                           actionColor: item.status == "DITOLAK" ? goldColor : primaryRed,
                           customContent: customContent,
                           onTap: () => _showDetailDialog(context, item.title, item.subtitle, item.status, item.date),
                           onActionTap: actionCallback,
                         ),
                       );
                     }).toList(),
                  );
                }
              );},
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Tombol Filter Tab di Header dengan Animasi Transisi & Hover
  Widget _buildTabButton(String label, int index) {
    bool isActive = _activeTabIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.red.withValues(alpha: 0.9) : Colors.white,
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF8B0000), Color.fromARGB(255, 83, 0, 0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? primaryRed.withOpacity(0.4)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isActive ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          child: Text(label),
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
    VoidCallback? onTap,
    VoidCallback? onActionTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                InkWell(
                  onTap: onActionTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      actionText,
                      style: TextStyle(
                        color: actionColor ?? primaryRed,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  void _showDetailDialog(
    BuildContext context,
    String title,
    String subtitle,
    String status,
    String time,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AktivitasDetailView(
          title: title,
          subtitle: subtitle,
          status: status,
          time: time,
        ),
      ),
    );
  }
}
