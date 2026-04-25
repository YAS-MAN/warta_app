import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report_model.dart';
import '../../models/surat_submission_model.dart';
import '../../services/report_service.dart';
import '../../services/iuran_service.dart';
import '../../services/surat_service.dart';
import '../../models/iuran_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../aktivitas/aktivitas_detail_view.dart';

class RtApprovalView extends StatelessWidget {
  const RtApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 83, 0, 0),
                  Color(0xFF8B0000),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -10,
                    child: Transform.rotate(
                      angle: 12 * 3.14159 / 180,
                      child: Image(
                        image: const AssetImage('assets/images/warta_logo.png'),
                        width: 160,
                        height: 160,
                        color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: const Text(
            "Verifikasi Berkas & Iuran",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: false,
            dividerColor: Colors.transparent,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.receipt_long, color: Color(0xFF9333EA), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Iuran ${iuran.bulan} ${iuran.tahun}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
                                const SizedBox(height: 4),
                                Text(iuran.namaWarga, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                          child: const Text("PROSES", style: TextStyle(color: Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                    const SizedBox(height: 16),
                    Text("Nominal: ${_formatRupiah(iuran.nominal)}", style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13, fontWeight: FontWeight.w500)),
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

class _TabSuratPengantar extends StatefulWidget {
  const _TabSuratPengantar();

  @override
  State<_TabSuratPengantar> createState() => _TabSuratPengantarState();
}

class _TabSuratPengantarState extends State<_TabSuratPengantar> {
  final SuratService _suratService = SuratService();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;
        final kelurahan = user?.kelurahan ?? '';
        final rw = user?.rw ?? '';
        final rt = user?.rt ?? '';
        if (kelurahan.isEmpty || rw.isEmpty || rt.isEmpty) {
          return const Center(child: Text("Data wilayah RT belum lengkap."));
        }

        return StreamBuilder<List<SuratSubmissionModel>>(
          stream: _suratService.streamSubmissionsForRt(
            kelurahan: kelurahan,
            rw: rw,
            rt: rt,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B0000)),
              );
            }

            final submissions = snapshot.data ?? [];
            if (submissions.isEmpty) {
              return const Center(
                child: Text("Belum ada pengajuan surat untuk ditinjau."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final submission = submissions[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AktivitasDetailView(
                            title: submission.jenisSurat,
                            subtitle: "Pemohon: ${submission.nama}",
                            status: submission.status,
                            time: _formatTime(submission.createdAt),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2FE),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.description,
                                        color: Color(0xFF0EA5E9),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            submission.jenisSurat,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF1F2937),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            submission.nama,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  "PROSES",
                                  style: TextStyle(
                                    color: Color(0xFFD97706),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          const SizedBox(height: 16),
                          Text(
                            "NIK: ${submission.nik}",
                            style: const TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await _suratService.updateSubmissionStatus(
                                      submissionId: submission.id,
                                      newStatus: 'BERHASIL',
                                      actedByUid: user?.uid ?? '',
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Pengajuan surat berhasil disetujui.",
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B0000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Tanda Tangani",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await _suratService.updateSubmissionStatus(
                                      submissionId: submission.id,
                                      newStatus: 'DITOLAK',
                                      actedByUid: user?.uid ?? '',
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Pengajuan surat berhasil ditolak.",
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
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

class _TabLaporanWarga extends StatefulWidget {
  const _TabLaporanWarga();

  @override
  State<_TabLaporanWarga> createState() => _TabLaporanWargaState();
}

class _TabLaporanWargaState extends State<_TabLaporanWarga> {
  final ReportService _reportService = ReportService();

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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AktivitasDetailView(
                            title: report.title,
                            subtitle: report.description,
                            status: "PROSES",
                            time: _formatTime(report.createdAt),
                          ),
                        ),
                      );
                    },
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.report_problem, color: Color(0xFFEF4444), size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          report.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(report.reporterName, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                              child: const Text("TINJAUAN", style: TextStyle(color: Color(0xFFDC2626), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Dikirim: ${_formatTime(report.createdAt)}",
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                            Text(
                              "RT ${report.reporterRt}/RW ${report.reporterRw}",
                              style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          report.description,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
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
