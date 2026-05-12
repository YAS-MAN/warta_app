import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/surat_service.dart';
import '../../models/surat_submission_model.dart';
import '../surat/surat_detail_view.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/top_notification.dart';

class AktivitasDetailView extends StatefulWidget {
  final String title;
  final String subtitle;
  final String status;
  final String time;
  final String? referenceId;
  final String? activityType;

  const AktivitasDetailView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.time,
    this.referenceId,
    this.activityType,
  });

  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);

  @override
  State<AktivitasDetailView> createState() => _AktivitasDetailViewState();
}

class _AktivitasDetailViewState extends State<AktivitasDetailView> {
  SuratSubmissionModel? _submission;
  String _fallbackContent = "";
  bool _loadingSubmission = true;
  Uint8List? _rtSignatureBytes;

  @override
  void initState() {
    super.initState();
    _fetchSubmission();
  }

  Future<void> _fetchSubmission() async {
    if (widget.referenceId != null && widget.referenceId!.isNotEmpty && widget.activityType == 'surat') {
      final sub = await SuratService().getSubmissionById(widget.referenceId!);
      
      // Ambil TTD RT jika sudah diproses
      if (sub != null && sub.actedByUid != null && sub.actedByUid!.isNotEmpty) {
        try {
          final rtDoc = await FirebaseFirestore.instance.collection('users').doc(sub.actedByUid).get();
          if (rtDoc.exists) {
            final sigUrl = rtDoc.data()?['rtSignatureUrl'] as String?;
            if (sigUrl != null && sigUrl.isNotEmpty) {
              final response = await http.get(Uri.parse(sigUrl));
              if (response.statusCode == 200) {
                _rtSignatureBytes = response.bodyBytes;
              }
            }
          }
        } catch (e) {
          debugPrint("Gagal mengambil TTD RT: $e");
        }
      }

      String fallback = "";
      if (sub?.customBody == null || sub!.customBody!.isEmpty) {
        final surat = await SuratService().getSuratByTitle(widget.title);
        fallback = surat?.templateKonten ?? "Menerangkan bahwa surat pengantar ini dibuat sebagai kelengkapan administrasi warga kelurahan setempat.";
      }
      if (mounted) {
        setState(() {
          _submission = sub;
          _fallbackContent = fallback;
          _loadingSubmission = false;
        });
      }
    } else {
      String fallback = "";
      if (widget.activityType == 'surat' || widget.title.toLowerCase().contains('surat') || widget.title.toLowerCase().contains('keterangan')) {
        final surat = await SuratService().getSuratByTitle(widget.title);
        fallback = surat?.templateKonten ?? "Menerangkan bahwa surat pengantar ini dibuat sebagai kelengkapan administrasi warga kelurahan setempat.";
      }
      if (mounted) {
        setState(() {
          _fallbackContent = fallback;
          _loadingSubmission = false;
        });
      }
    }
  }

  Future<void> _downloadPdf() async {
    final body = (_submission?.customBody != null && _submission!.customBody!.isNotEmpty)
        ? _submission!.customBody!
        : (_fallbackContent.isNotEmpty ? _fallbackContent : "Menerangkan bahwa surat pengantar ini dibuat sebagai kelengkapan administrasi warga kelurahan setempat.");


    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                widget.title.toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 24),
              pw.Text(
                body,
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Demikian surat keterangan ini dibuat untuk dipergunakan sebagaimana mestinya.',
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
              pw.Spacer(),
              // Kotak Info Legalitas & Status Dokumen di atas barisan TTD
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                margin: const pw.EdgeInsets.only(bottom: 16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Dokumen elektronik ini diterbitkan & disahkan oleh Sistem WARTA.',
                      style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                    ),
                    pw.Row(
                      children: [
                        pw.Text('Status Verifikasi: ', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.Text(
                          _submission?.status ?? widget.status,
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: (_submission?.status ?? widget.status) == 'BERHASIL'
                                ? PdfColors.green800
                                : PdfColors.blue800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Barisan 3 Otoritas Tanda Tangan: RT (Kiri), RW (Tengah), Lurah (Kanan)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // 1. Tanda Tangan RT (Kiri)
                  pw.Container(
                    width: 140,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Mengetahui,', style: pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Ketua RT ${_submission?.rt ?? "004"}',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 12),
                        // Penanda TTD Elektronik
                        if (_rtSignatureBytes != null)
                          pw.Container(
                            height: 40,
                            width: 80,
                            child: pw.Image(pw.MemoryImage(_rtSignatureBytes!)),
                          )
                        else
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.blue50,
                              border: pw.Border.all(color: PdfColors.blue300, width: 0.5),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            ),
                            child: pw.Text(
                              '[ e-TTD RT ]',
                              style: pw.TextStyle(
                                color: PdfColors.blue800,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        pw.SizedBox(height: 12),
                        pw.Container(height: 0.5, width: 120, color: PdfColors.black),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '(${(_submission?.status == "PROSES RW" || _submission?.status == "PROSES LURAH" || _submission?.status == "BERHASIL") ? "Ketua RT Terverifikasi" : "......................................."})',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // 2. Tanda Tangan RW (Tengah)
                  pw.Container(
                    width: 140,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Mengetahui,', style: pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Ketua RW ${_submission?.rw ?? "003"}',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 12),
                        // Penanda TTD Elektronik
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            border: pw.Border.all(color: PdfColors.blue300, width: 0.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            '[ e-TTD RW ]',
                            style: pw.TextStyle(
                              color: PdfColors.blue800,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Container(height: 0.5, width: 120, color: PdfColors.black),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '(${(_submission?.status == "PROSES LURAH" || _submission?.status == "BERHASIL") ? "Ketua RW Terverifikasi" : "......................................."})',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // 3. Tanda Tangan Lurah (Kanan)
                  pw.Container(
                    width: 150,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          '${_submission?.kelurahan != null && _submission!.kelurahan.isNotEmpty ? _submission!.kelurahan : "Gandaria Utara"}, ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
                          style: pw.TextStyle(fontSize: 9),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Kepala Kelurahan',
                          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 12),
                        // Penanda TTD Elektronik Lurah
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.red50,
                            border: pw.Border.all(color: PdfColors.red300, width: 0.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            '[ e-TTD LURAH ]',
                            style: pw.TextStyle(
                              color: PdfColors.red800,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Container(height: 0.5, width: 130, color: PdfColors.black),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '(${_submission?.status == "BERHASIL" ? "Pejabat Kelurahan Resmi" : "......................................."})',
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Surat_${widget.title.replaceAll(' ', '_')}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLaporan = widget.title.toLowerCase().contains('pengaduan') || widget.title.toLowerCase().contains('laporan');
    final isSurat = widget.activityType == 'surat';

    Color statusColor;
    Color statusBg;

    if (widget.status == "BERHASIL" || widget.status == "SELESAI" || widget.status == "LAPORAN DISELESAIKAN") {
      statusColor = const Color(0xFF10B981);
      statusBg = const Color(0xFFF0FDF4);
    } else if (widget.status == "PROSES" || widget.status == "PROSES RW" || widget.status == "PROSES LURAH" || widget.status == "LAPORAN DITERIMA") {
      statusColor = const Color(0xFF3B82F6);
      statusBg = const Color(0xFFEFF6FF);
    } else {
      statusColor = const Color(0xFFEF4444);
      statusBg = const Color(0xFFFEF2F2);
    }

    return Scaffold(
      backgroundColor: AktivitasDetailView.bgApp,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // HEADER
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
                          color: Colors.black.withOpacity(0.1),
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
                                color: const Color.fromARGB(255, 58, 1, 1).withOpacity(0.1),
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
                                      color: Colors.white.withOpacity(0.2),
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
            
            // KONTEN DETAIL
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
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AktivitasDetailView.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AktivitasDetailView.textGray,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 24),
                    _buildDetailRow("Waktu", widget.time),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Status", style: TextStyle(color: AktivitasDetailView.textGray, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // BERHASIL / SELESAI
                    if (widget.status == "BERHASIL" || widget.status == "SELESAI" || widget.status == "LAPORAN DISELESAIKAN") ...[
                      const SizedBox(height: 32),
                      const Text("Tanggapan / Hasil", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AktivitasDetailView.textGray)),
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
                              Text("Laporan Telah Diselesaikan", style: TextStyle(color: AktivitasDetailView.textDark, fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text("Terima kasih atas partisipasi Anda", style: TextStyle(color: AktivitasDetailView.textGray, fontSize: 12)),
                            ],
                          ),
                        )
                      else ...[
                        // Preview Konten Surat
                        if (_loadingSubmission)
                          const Center(child: CircularProgressIndicator(color: AktivitasDetailView.primaryRed))
                        else if ((_submission?.customBody != null && _submission!.customBody!.isNotEmpty) || _fallbackContent.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.description, size: 20, color: Color(0xFF10B981)),
                                    const SizedBox(width: 8),
                                    Text("Dokumen_${widget.title.replaceAll(' ', '_')}.pdf", style: const TextStyle(color: AktivitasDetailView.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text("Ditandatangani Digital", style: TextStyle(color: AktivitasDetailView.textGray, fontSize: 11)),
                                const Divider(height: 24),
                                Text(
                                  (_submission?.customBody != null && _submission!.customBody!.isNotEmpty) ? _submission!.customBody! : _fallbackContent,
                                  style: const TextStyle(fontSize: 11, color: AktivitasDetailView.textDark, height: 1.6),
                                  maxLines: 15,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                          )
                        else
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
                                Text("Dokumen_${widget.title.replaceAll(' ', '_')}.pdf", style: const TextStyle(color: AktivitasDetailView.textDark, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                const Text("Ditandatangani Digital", style: TextStyle(color: AktivitasDetailView.textGray, fontSize: 12)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Tombol Download PDF
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _downloadPdf,
                            icon: const Icon(Icons.download, color: Colors.white),
                            label: const Text("Download Surat (PDF)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ]
                    ] else if (widget.status == "DITOLAK" || widget.status == "LAPORAN TIDAK SESUAI") ...[
                      const SizedBox(height: 32),
                      // Alasan Penolakan — dari Firestore, bukan hardcoded
                      _buildRejectionBox(isLaporan),
                      if (!isLaporan && isSurat) ...[
                        const SizedBox(height: 24),
                        // Tombol Ajukan Ulang
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AktivitasDetailView.primaryRed,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              if (_submission != null) {
                                // Ajukan ulang menggunakan resubmitSurat
                                _resubmit();
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => SuratDetailView(title: widget.title)));
                              }
                            },
                            child: const Text("Ajukan Ulang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ]
                    ] else ...[
                       // PROSES / PROSES RW / PROSES LURAH
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
                               isLaporan 
                                 ? "Laporan Anda telah diterima dan sedang dalam tahap verifikasi oleh admin." 
                                 : widget.status == "PROSES RW" 
                                   ? "Pengajuan telah disetujui RT dan sedang diverifikasi oleh Ketua RW." 
                                   : widget.status == "PROSES LURAH"
                                     ? "Pengajuan telah disetujui RW dan menunggu pengesahan resmi dari Kelurahan/Lurah."
                                     : "Pengajuan Anda sedang divalidasi oleh Ketua RT setempat. Mohon menunggu.", 
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

  Widget _buildRejectionBox(bool isLaporan) {
    // Ambil alasan dari submission Firestore jika tersedia
    String rejectionText;
    if (_loadingSubmission) {
      return const Center(child: CircularProgressIndicator(color: AktivitasDetailView.primaryRed));
    }

    if (_submission?.rejectionReason != null && _submission!.rejectionReason!.isNotEmpty) {
      rejectionText = _submission!.rejectionReason!;
    } else if (isLaporan) {
      rejectionText = "Laporan tidak sesuai kriteria atau informasi yang diberikan kurang detail. Silakan hubungi RT/RW setempat.";
    } else {
      rejectionText = "Pengajuan ditolak oleh petugas. Silakan hubungi RT/RW untuk informasi lebih lanjut.";
    }

    return Container(
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
          Text(
            rejectionText,
            style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Future<void> _resubmit() async {
    if (_submission == null) return;
    try {
      await SuratService().resubmitSurat(
        submissionId: _submission!.id,
        userId: _submission!.userId,
        customBody: _submission!.customBody,
      );
      if (!mounted) return;
      TopNotification.show(
        context: context,
        message: "Pengajuan ulang berhasil dikirim!",
        isSuccess: true,
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      TopNotification.show(
        context: context,
        message: "Gagal mengajukan ulang: $e",
        isError: true,
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AktivitasDetailView.textGray, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: AktivitasDetailView.textDark, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
