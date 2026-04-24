import 'package:flutter/material.dart';
import '../surat/surat_detail_view.dart'; // Navigation for re-apply

class AktivitasDetailView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final String time;

  const AktivitasDetailView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.time,
  });

  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    bool isLaporan = title.toLowerCase().contains('pengaduan') || title.toLowerCase().contains('laporan');

    Color statusColor;
    Color statusBg;

    if (status == "BERHASIL" || status == "SELESAI" || status == "LAPORAN DISELESAIKAN") {
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0xFFF0FDF4);
    } else if (status == "PROSES" || status == "LAPORAN DITERIMA") {
      statusColor = const Color(0xFF3B82F6);
      statusBg = const Color(0xFFEFF6FF);
    } else {
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEF2F2);
    }

    return Scaffold(
      backgroundColor: bgApp,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER MERAH MELENGKUNG (GRADASI & WATERMARK)
            // ==========================================
            SizedBox(
              height: 180,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 20,
                            top: 20,
                            child: Transform.rotate(
                              angle: 12 * 3.14159 / 180,
                              child: Image(
                                image: const AssetImage('assets/icons/ic_restore_after.png'),
                                width: 140,
                                height: 140,
                                color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    "Detail Aktivitas",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // --- KONTEN DETAIL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: textGray,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFF1F5F9)),
              const SizedBox(height: 24),
              _buildDetailRow("Waktu", time),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Status", style: TextStyle(color: textGray, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              // ==========================================
              // KONDISIONAL BERDASARKAN STATUS
              // ==========================================
              if (status == "BERHASIL" || status == "SELESAI" || status == "LAPORAN DISELESAIKAN") ...[
                const SizedBox(height: 32),
                const Text("Tanggapan / Hasil", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textGray)),
                const SizedBox(height: 12),
                if (isLaporan)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.check_circle_outline, size: 40, color: Color(0xFF10B981)),
                        SizedBox(height: 12),
                        Text("Laporan Telah Diselesaikan", style: TextStyle(color: textDark, fontWeight: FontWeight.w600)),
                        SizedBox(height: 4),
                        Text("Terima kasih atas partisipasi Anda", style: TextStyle(color: textGray, fontSize: 12)),
                      ],
                    ),
                  )
                else ...[
                  // Preview Dokumen Berhasil
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.description, size: 40, color: Color(0xFF10B981)),
                        const SizedBox(height: 12),
                        Text("Dokumen_${title.replaceAll(' ', '_')}.pdf", style: const TextStyle(color: textDark, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text("Ditandatangani Digital", style: TextStyle(color: textGray, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tombol Download
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mendownload dokumen..."), backgroundColor: Color(0xFF10B981)));
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text("Download Surat (PDF)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]
              ] else if (status == "DITOLAK" || status == "LAPORAN TIDAK SESUAI") ...[
                const SizedBox(height: 32),
                // Kotak Alasan Penolakan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 8),
                          Text(isLaporan ? "Keterangan" : "Alasan Penolakan", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Mock text alasan
                      Text(
                        isLaporan 
                          ? "Laporan tidak sesuai kriteria atau informasi yang diberikan kurang detail. Silakan hubungi RT/RW setempat." 
                          : "Dokumen persyaratan KTP terlihat buram dan foto usaha tidak sesuai kriteria. Mohon lengkapi perbaikan.", 
                        style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13, height: 1.5)
                      ),
                    ],
                  ),
                ),
                if (!isLaporan) ...[
                  const SizedBox(height: 24),
                  // Tombol Ajukan Ulang
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed, // Merah Primary
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SuratDetailView(title: title)));
                      },
                      child: const Text("Ajukan Ulang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ]
              ] else ...[
                 // PROSES
                 const SizedBox(height: 32),
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                   child: Row(
                     children: [
                       const Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
                       const SizedBox(width: 12),
                       Expanded(child: Text(
                         isLaporan ? "Laporan Anda telah diterima dan sedang dalam tahap verifikasi oleh admin." : "Pengajuan Anda sedang divalidasi oleh petugas kelurahan. Mohon menunggu.", 
                         style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 13)
                       )),
                     ],
                   ),
                 ),
              ],
            ],
          ),
        ),
      ),
    ],
  ),
),
);
}

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: textGray, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: textDark, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
