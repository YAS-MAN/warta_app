import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/surat_submission_model.dart';
import '../aktivitas/aktivitas_detail_view.dart';

class RtApprovalHistoryView extends StatelessWidget {
  final String kelurahan;
  final String rw;
  final String rt;

  const RtApprovalHistoryView({
    super.key,
    required this.kelurahan,
    required this.rw,
    required this.rt,
  });

  @override
  Widget build(BuildContext context) {
    final submissionsRef = FirebaseFirestore.instance.collection(
      'surat_submissions',
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildPremiumHeader(context, 'Riwayat Persetujuan'),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: submissionsRef
                  .where('kelurahan', isEqualTo: kelurahan)
                  .where('rw', isEqualTo: rw)
                  .where('rt', isEqualTo: rt)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B0000)),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                final histories =
                    docs
                        .map(SuratSubmissionModel.fromFirestore)
                        .where(
                          (item) =>
                              item.status == 'BERHASIL' ||
                              item.status == 'DITOLAK',
                        )
                        .toList()
                      ..sort((a, b) {
                        final left =
                            a.updatedAt ??
                            a.createdAt ??
                            DateTime.fromMillisecondsSinceEpoch(0);
                        final right =
                            b.updatedAt ??
                            b.createdAt ??
                            DateTime.fromMillisecondsSinceEpoch(0);
                        return right.compareTo(left);
                      });

                if (histories.isEmpty) {
                  return const Center(
                    child: Text('Belum ada riwayat persetujuan surat.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: histories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = histories[index];
                    final isApproved = item.status == 'BERHASIL';
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AktivitasDetailView(
                              title: item.jenisSurat,
                              subtitle: "Pemohon: ${item.nama}",
                              status: item.status,
                              time: _formatTime(
                                item.updatedAt ?? item.createdAt,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isApproved
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isApproved ? Icons.check_circle : Icons.cancel,
                                color: isApproved
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.jenisSurat,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.nama,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  Text(
                                    _formatTime(
                                      item.updatedAt ?? item.createdAt,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
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
                                color: isApproved
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isApproved
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, String title) {
    return Container(
      height: 125,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
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
