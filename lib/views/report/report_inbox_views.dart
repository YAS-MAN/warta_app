import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RwReportInboxView extends StatefulWidget {
  const RwReportInboxView({super.key});

  @override
  State<RwReportInboxView> createState() => _RwReportInboxViewState();
}

class _RwReportInboxViewState extends State<RwReportInboxView> {
  final ReportService _reportService = ReportService();
  static const Color primary = Color(0xFF6A1B9A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Laporan Masuk RW",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          final rw = authVM.currentUser?.rw ?? '';
          if (rw.isEmpty) {
            return const Center(child: Text("Data RW akun belum tersedia."));
          }

          return StreamBuilder<List<ReportModel>>(
            stream: _reportService.streamReportsForRw(rw: rw),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: primary));
              }
              final reports = snapshot.data ?? [];
              if (reports.isEmpty) {
                return const Center(child: Text("Belum ada laporan untuk RW ini."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, index) => _ReportCard(
                  report: reports[index],
                  primaryColor: primary,
                  rightButtonText: "Forward ke Lurah",
                  onRightButtonTap: () async {
                    await _reportService.forwardReportToLurah(reports[index].id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Laporan diteruskan ke Lurah."),
                        backgroundColor: primary,
                      ),
                    );
                  },
                  onResolveTap: () async {
                    await _reportService.resolveReport(reports[index].id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Laporan diselesaikan di tingkat RW."),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LurahReportInboxView extends StatefulWidget {
  const LurahReportInboxView({super.key});

  @override
  State<LurahReportInboxView> createState() => _LurahReportInboxViewState();
}

class _LurahReportInboxViewState extends State<LurahReportInboxView> {
  final ReportService _reportService = ReportService();
  static const Color primary = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Laporan Tingkat Kelurahan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: _reportService.streamReportsForLurah(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primary));
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text("Belum ada eskalasi laporan ke lurah."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) => _ReportCard(
              report: reports[index],
              primaryColor: primary,
              rightButtonText: "Tindak Lanjut",
              onRightButtonTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Rincian tindak lanjut lurah dapat dikembangkan berikutnya."),
                    backgroundColor: primary,
                  ),
                );
              },
              onResolveTap: () async {
                await _reportService.resolveReport(reports[index].id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Laporan diselesaikan di tingkat kelurahan."),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportModel report;
  final Color primaryColor;
  final String rightButtonText;
  final VoidCallback onRightButtonTap;
  final VoidCallback onResolveTap;

  const _ReportCard({
    required this.report,
    required this.primaryColor,
    required this.rightButtonText,
    required this.onRightButtonTap,
    required this.onResolveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.report_problem_outlined, color: primaryColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  report.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.description,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 10),
          Text(
            "Pelapor: ${report.reporterName} (RT ${report.reporterRt}/RW ${report.reporterRw})",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (report.imageUrl != null && report.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onResolveTap,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Selesai"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRightButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    rightButtonText,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

