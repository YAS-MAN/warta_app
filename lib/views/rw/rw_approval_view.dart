import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report_model.dart';
import '../../models/surat_submission_model.dart';
import '../../models/surat_model.dart';
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
          shadowColor: Colors.black.withOpacity(0.5),
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
                        color: const Color.fromARGB(255, 58, 1, 1).withOpacity(0.15),
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
              Tab(text: "Laporan"),
              Tab(text: "Surat"),
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
          Icon(Icons.mark_email_read_outlined, size: 56, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 14)),
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
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
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
                    if (context.mounted) {
                      TopNotification.show(
                        context: context,
                        message: "Laporan diselesaikan di tingkat RW.",
                        isSuccess: true,
                      );
                    }
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
                    if (context.mounted) {
                      TopNotification.show(
                        context: context,
                        message: "Laporan diteruskan ke Lurah.",
                        isSuccess: true,
                      );
                    }
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

  /// Tampilkan preview konten surat dalam bottom sheet
  void _showSuratPreview(
    BuildContext context,
    SuratSubmissionModel submission,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Preview Surat RW",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFBAE6FD),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _previewRow(
                                  "Jenis Surat",
                                  submission.jenisSurat,
                                ),
                                const SizedBox(height: 8),
                                _previewRow("Nama Pemohon", submission.nama),
                                const SizedBox(height: 8),
                                _previewRow("NIK", submission.nik),
                                const SizedBox(height: 8),
                                _previewRow(
                                  "RT/RW",
                                  "${submission.rt}/${submission.rw}",
                                ),
                                const SizedBox(height: 8),
                                _previewRow("Kelurahan", submission.kelurahan),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Isi Surat",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child:
                                (submission.customBody != null &&
                                        submission.customBody!.isNotEmpty)
                                    ? Text(
                                        submission.customBody!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.7,
                                          color: Color(0xFF374151),
                                        ),
                                      )
                                    : FutureBuilder<SuratModel?>(
                                        future: _suratService.getSuratByTitle(
                                          submission.jenisSurat,
                                        ),
                                        builder: (context, snapshot) {
                                          final fallbackText =
                                              snapshot.data?.templateKonten ??
                                              "Menerangkan bahwa surat pengantar ini dibuat sebagai kelengkapan administrasi warga kelurahan setempat.";
                                          return Text(
                                            fallbackText,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              height: 1.7,
                                              color: Color(0xFF374151),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Tanda Tangan Digital Terverifikasi",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          _buildSignatureRow(
                            "Tanda Tangan Ketua RT",
                            submission.rtUid ?? submission.actedByUid,
                            'rtSignatureUrl',
                          ),
                          if (submission.status == 'PROSES LURAH' ||
                              submission.status == 'BERHASIL')
                            _buildSignatureRow(
                              "Tanda Tangan Ketua RW",
                              submission.rwUid,
                              'rwSignatureUrl',
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSignatureRow(String title, String? uid, String fieldName) {
    if (uid == null || uid.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        if (userData == null) return const SizedBox.shrink();
        final sigUrl = userData[fieldName] as String?;
        if (sigUrl == null || sigUrl.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 80,
                width: 140,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  sigUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error_outline, color: Colors.red, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _previewRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Text(
          ": ",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

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
                    Icon(Icons.mark_email_read_outlined, size: 56, color: Colors.grey.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text("Belum ada surat keterangan\nyang perlu ditinjau.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 14)),
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
                  child: InkWell(
                    onTap: () => _showSuratPreview(context, sub),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
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
                        // Hint untuk preview
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 14,
                                color: Color(0xFF0EA5E9),
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Ketuk untuk preview surat",
                                style: TextStyle(
                                  color: Color(0xFF0EA5E9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
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
