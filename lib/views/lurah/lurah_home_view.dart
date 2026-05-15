import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';

class LurahHomeView extends StatefulWidget {
  final Function(int, [int?]) onNavigate;
  const LurahHomeView({super.key, required this.onNavigate});

  @override
  State<LurahHomeView> createState() => _LurahHomeViewState();
}

class _LurahHomeViewState extends State<LurahHomeView> {
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgGray = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF1F2937);
  static const Color goldColor = Color(0xFFD4AF37);
  final ReportService _reportService = ReportService();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Selamat Pagi,";
    if (hour < 15) return "Selamat Siang,";
    if (hour < 18) return "Selamat Sore,";
    return "Selamat Malam,";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 50),
            _buildLaporanSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
            child: Stack(
              children: [
                Positioned(
                  right: -20, top: -20,
                  child: Transform.rotate(
                    angle: 12 * 3.14159 / 180,
                    child: Image(
                      image: const AssetImage('assets/images/warta_logo.png'),
                      width: 180, height: 180,
                      color: const Color.fromARGB(255, 58, 1, 1).withOpacity(0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getGreeting(), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                                Consumer<AuthViewModel>(
                                  builder: (context, authVM, _) {
                                    final user = authVM.currentUser;
                                    final kel = user?.kelurahan ?? "";
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?.nama ?? "Bapak Lurah",
                                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (kel.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            "Kelurahan ${kel.toUpperCase()}",
                                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: goldColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: const Text("PENGURUS LURAH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Quick Actions
        Positioned(
          bottom: -40, left: 24, right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(Icons.description_outlined, const Color(0xFF7C3AED), const Color(0xFF7C3AED).withOpacity(0.1), "Laporan", () => widget.onNavigate(2, 0)),
                _buildQuickAction(Icons.request_page_outlined, Colors.orange, Colors.orange.withOpacity(0.1), "Surat", () => widget.onNavigate(2, 1)),
                _buildQuickAction(Icons.groups_outlined, Colors.blue, Colors.blue.withOpacity(0.1), "Koordinasi", () => widget.onNavigate(1)),
                _buildQuickAction(Icons.person_outline, Colors.teal, Colors.teal.withOpacity(0.1), "Profil", () => widget.onNavigate(3)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return StreamBuilder<List<ReportModel>>(
      stream: _reportService.streamReportsForLurah(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        final message = count > 0
            ? "Terdapat $count laporan kelurahan yang membutuhkan tindak lanjut Anda."
            : "Tidak ada laporan baru tingkat kelurahan saat ini.";
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.mark_email_unread_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 12))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLaporanSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Laporan Terbaru Kelurahan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
              TextButton(
                onPressed: () => widget.onNavigate(2),
                child: const Text("Lihat Semua", style: TextStyle(color: primaryRed, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<ReportModel>>(
            stream: _reportService.streamReportsForLurah(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: primaryRed)));
              }
              final reports = snapshot.data ?? [];
              if (reports.isEmpty) return _buildEmptyState();
              final display = reports.take(3).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: display.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildReportCard(display[index]),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    return InkWell(
      onTap: () => widget.onNavigate(2, 0),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.report_problem_outlined, color: Color(0xFF8B0000), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text("RT ${report.reporterRt}/RW ${report.reporterRw} · ${report.reporterName}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text("Belum ada laporan masuk tingkat kelurahan.", style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, Color iconColor, Color bgColor, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: iconColor, size: 24)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: textDark, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
