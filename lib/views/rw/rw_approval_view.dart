import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/report_model.dart';
import '../../models/surat_submission_model.dart';
import '../../services/report_service.dart';
import '../../services/surat_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../utils/top_notification.dart';

class RwApprovalView extends StatelessWidget {
  final int initialIndex;
  const RwApprovalView({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialIndex,
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: Stack(
                children: [
                  Positioned(
                    right: -20, top: -10,
                    child: Transform.rotate(
                      angle: 12 * 3.14159 / 180,
                      child: Image(
                        image: const AssetImage('assets/images/warta_logo.png'),
                        width: 160, height: 160,
                        color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: const Text(
            "Verifikasi & Laporan",
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
              Tab(text: "Laporan Masuk"),
              Tab(text: "Surat Keterangan"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TabLaporanMasuk(),
            _TabSuratKeterangan(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TAB 1: LAPORAN MASUK DARI RT
// ═══════════════════════════════════════════════════════════════════
class _TabLaporanMasuk extends StatelessWidget {
  const _TabLaporanMasuk();

  @override
  Widget build(BuildContext context) {
    final reportService = ReportService();
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final rw = authVM.currentUser?.rw ?? '';
        if (rw.isEmpty) return const Center(child: Text("Data RW belum tersedia."));

        return StreamBuilder<List<ReportModel>>(
          stream: reportService.streamReportsForRw(rw: rw),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)));
            }
            final reports = snapshot.data ?? [];
            if (reports.isEmpty) {
              return _buildEmpty("Belum ada laporan yang\nditeruskan dari RT.");
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportCard(report: report, reportService: reportService);
              },
            );
          },
        );
      },
    );
  }

  static Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 56, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 14)),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final ReportService reportService;
  const _ReportCard({required this.report, required this.reportService});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.report_problem_outlined, color: Color(0xFF8B0000), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B0000), fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(report.description, style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))),
          const SizedBox(height: 10),
          Text("Pelapor: ${report.reporterName} (RT ${report.reporterRt}/RW ${report.reporterRw})", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (report.imageUrl != null && report.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(report.imageUrl!, height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await reportService.resolveReport(report.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan diselesaikan di tingkat RW."), backgroundColor: Color(0xFF2E7D32)));
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2E7D32), side: const BorderSide(color: Color(0xFF2E7D32)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text("Selesai"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await reportService.forwardReportToLurah(report.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan diteruskan ke Lurah."), backgroundColor: Color(0xFF8B0000)));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                  child: const Text("Forward ke Lurah", style: TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TAB 2: SURAT KETERANGAN (PROSES RW)
// ═══════════════════════════════════════════════════════════════════
class _TabSuratKeterangan extends StatefulWidget {
  const _TabSuratKeterangan();

  @override
  State<_TabSuratKeterangan> createState() => _TabSuratKeteranganState();
}

class _TabSuratKeteranganState extends State<_TabSuratKeterangan> {
  final SuratService _suratService = SuratService();

  Future<void> _showRejectDialog(BuildContext context, SuratSubmissionModel submission, String actedByUid) async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.report_problem_outlined, color: Color(0xFFEF4444), size: 24),
              SizedBox(width: 8),
              Text("Tolak Pengajuan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Surat: ${submission.jenisSurat}", style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
              Text("Pemohon: ${submission.nama}", style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
              const SizedBox(height: 16),
              const Text("Alasan Penolakan *", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tuliskan alasan penolakan...",
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                  filled: true, fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Color(0xFF6B7280)))),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  TopNotification.show(context: ctx, message: "Alasan penolakan wajib diisi.", isError: true);
                  return;
                }
                Navigator.pop(ctx, reason);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Tolak", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await _suratService.updateSubmissionStatus(submissionId: submission.id, newStatus: 'DITOLAK', actedByUid: actedByUid, rejectionReason: result);
      if (!context.mounted) return;
      TopNotification.show(context: context, message: "Pengajuan surat berhasil ditolak.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;
        final kelurahan = user?.kelurahan ?? '';
        final rw = user?.rw ?? '';
        if (kelurahan.isEmpty || rw.isEmpty) {
          return const Center(child: Text("Data wilayah RW belum lengkap."));
        }

        return StreamBuilder<List<SuratSubmissionModel>>(
          stream: _suratService.streamSubmissionsForRw(kelurahan: kelurahan, rw: rw),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)));
            }
            final submissions = snapshot.data ?? [];
            if (submissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mark_email_read_outlined, size: 56, color: Colors.grey.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text("Belum ada surat keterangan\nyang perlu ditinjau.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 14)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final sub = submissions[index];
                final dateStr = sub.createdAt != null ? DateFormat('dd MMM yyyy').format(sub.createdAt!) : '-';
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.description_outlined, color: Color(0xFF8B0000), size: 20),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.4,
                                  child: Text(sub.jenisSurat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(6)),
                              child: const Text("Menunggu", style: TextStyle(color: Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text("Pemohon: ${sub.nama}", style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                        const SizedBox(height: 4),
                        Text("NIK: ${sub.nik}  ·  $dateStr", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _suratService.updateSubmissionStatus(submissionId: sub.id, newStatus: 'PROSES LURAH', actedByUid: user!.uid);
                                  if (!context.mounted) return;
                                  TopNotification.show(context: context, message: "Surat disetujui dan diteruskan ke Lurah.", isSuccess: true);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                                child: const Text("Tanda Tangani", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showRejectDialog(context, sub, user!.uid),
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
      },
    );
  }
}
