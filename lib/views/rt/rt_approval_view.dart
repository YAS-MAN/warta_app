import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../services/iuran_service.dart';
import '../../models/iuran_model.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RtApprovalView extends StatelessWidget {
  const RtApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFF8B0000);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: primaryRed, // Disesuaikan dengan WARTA (Merah)
          elevation: 0,
          title: const Text(
            "Verifikasi Berkas & Iuran",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Iuran Warga"),
              Tab(text: "Surat Pengantar"),
              Tab(text: "Laporan Warga"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TabIuranWargaApproval(),
            _TabSuratPengantar(),
            _TabLaporanWarga(),
          ],
        ),
      ),
    );
  }
}

class _TabIuranWargaApproval extends StatefulWidget {
  const _TabIuranWargaApproval();

  @override
  State<_TabIuranWargaApproval> createState() => _TabIuranWargaApprovalState();
}

class _TabIuranWargaApprovalState extends State<_TabIuranWargaApproval> {
  final IuranService _iuranService = IuranService();

  String _formatRupiah(int nominal) {
    String str = nominal.toString();
    String result = "";
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = ".$result";
    }
    return "Rp $result";
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl, fit: BoxFit.contain)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Tutup", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthViewModel>(context).currentUser;
    if (user == null) return const Center(child: Text("Data pengguna tidak ditemukan"));

    return StreamBuilder<List<IuranModel>>(
      // Mengambil tagihan dengan status 0 (Pending)
      stream: _iuranService.streamTagihanMasuk(user.kelurahan ?? '', user.rw ?? '', user.rt ?? '', status: 0),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final list = snapshot.data ?? [];
        if (list.isEmpty) return const Center(child: Text("Belum ada tagihan masuk yang perlu diulas."));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final iuran = list[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long, color: Color(0xFF8B0000), size: 20),
                            const SizedBox(width: 8),
                            Text("Iuran ${iuran.bulan} ${iuran.tahun}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text("Menunggu", style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text("Pembayar: ${iuran.namaWarga}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                    Text("Nominal: ${_formatRupiah(iuran.nominal)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    
                    if (iuran.buktiImageUrl.isNotEmpty)
                      InkWell(
                        onTap: () => _showImageDialog(iuran.buktiImageUrl),
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(iuran.buktiImageUrl, width: double.infinity, fit: BoxFit.cover),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(30)),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text("Lihat Bukti", style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              bool s = await _iuranService.updateStatusIuran(
                                idTagihan: iuran.id, 
                                newStatus: 1,
                                uidWarga: iuran.uidWarga,
                                bulan: iuran.bulan,
                                tahun: iuran.tahun,
                                uidRt: user.uid,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s ? "Iuran Lunas!" : "Gagal menyimpan.")));
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                            child: const Text("Setujui", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              bool s = await _iuranService.updateStatusIuran(
                                idTagihan: iuran.id, 
                                newStatus: 2,
                                uidWarga: iuran.uidWarga,
                                bulan: iuran.bulan,
                                tahun: iuran.tahun,
                                uidRt: user.uid,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s ? "Iuran ditolak." : "Gagal menyimpan.")));
                              }
                            },
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: const Text("Tolak"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TabSuratPengantar extends StatelessWidget {
  const _TabSuratPengantar();

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Aksi verifikasi surat segera hadir di iterasi berikutnya."),
        backgroundColor: Color(0xFF8B0000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => _showComingSoon(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.mark_email_unread_outlined, color: Color(0xFF8B0000), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            index == 0 ? "Surat SKU" : "Surat Domisili",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Menunggu",
                          style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("Pemohon: Agus Santoso\nNIK: 3201xxxxxxx", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showComingSoon(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text("Tanda Tangani", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showComingSoon(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Tolak"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabLaporanWarga extends StatefulWidget {
  const _TabLaporanWarga();

  @override
  State<_TabLaporanWarga> createState() => _TabLaporanWargaState();
}

class _TabLaporanWargaState extends State<_TabLaporanWarga> {
  final ReportService _reportService = ReportService();

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Aksi tinjauan laporan segera terhubung di iterasi berikutnya."),
        backgroundColor: Color(0xFF8B0000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;
        final rt = user?.rt ?? '';
        final rw = user?.rw ?? '';
        if (rt.isEmpty || rw.isEmpty) {
          return const Center(
            child: Text("Data RT/RW akun belum lengkap."),
          );
        }

        return StreamBuilder<List<ReportModel>>(
          stream: _reportService.streamReportsForRt(rt: rt, rw: rw),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B0000)),
              );
            }

            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return const Center(
                child: Text("Belum ada laporan warga untuk RT ini."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.report_problem_outlined,
                                    color: Color(0xFF8B0000),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      report.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF8B0000),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatTime(report.createdAt),
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          report.description,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "Pelapor: ${report.reporterName} (RT ${report.reporterRt}/RW ${report.reporterRw})",
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        if (report.imageUrl != null && report.imageUrl!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              report.imageUrl!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await _reportService.resolveReport(report.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Laporan ditandai selesai."),
                                      backgroundColor: Color(0xFF2E7D32),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF2E7D32),
                                  side: const BorderSide(color: Color(0xFF2E7D32)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text("Selesai"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _reportService.forwardReportToRw(report.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Laporan diteruskan ke RW."),
                                      backgroundColor: Color(0xFF8B0000),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B0000),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Forward ke RW",
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime? value) {
    if (value == null) return 'Baru';
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} mnt lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}
