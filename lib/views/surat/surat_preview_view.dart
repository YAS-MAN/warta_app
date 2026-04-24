import 'package:flutter/material.dart';
import '../../utils/top_notification.dart';
import '../../models/surat_model.dart';
import '../../services/surat_service.dart';

class SuratPreviewView extends StatefulWidget {
  final String title;

  const SuratPreviewView({super.key, required this.title});

  @override
  State<SuratPreviewView> createState() => _SuratPreviewViewState();
}

class _SuratPreviewViewState extends State<SuratPreviewView> {
  static const Color bgApp = Color(
    0xFFE5E7EB,
  ); // Abu-abu gelap khas background mockup document

  void _kirimPengajuan() {
    TopNotification.show(
      context: context,
      message: "Permohonan ${widget.title} berhasil diajukan!",
      isSuccess: true,
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // Pop kembali hingga ke MainView agar seperti sukses selesai
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    });
  }

  // Helper untuk membuat teks surat dinamis berdasarkan jenis surat
  String _generateBody(String? template) {
    String intro = "Yang bertanda tangan di bawah ini, Kepala Kelurahan Maju, Kecamatan Waru, Kota Surabaya, dengan ini menerangkan bahwa:\n\n";
    String userData = "Nama: Yasman Yazid\nNIK: 35780123456789\nAlamat: Jl. Raya Maju No. 123, RT 05 RW 02\n\n";
    String explanation = template ?? "Menerangkan bahwa individu di atas adalah benar warga Kelurahan Maju dan bermaksud mengurus keperluan administrasi sesuai ketentuan. Demikian surat ini dibuat agar dapat dipergunakan sebagaimana mestinya.";

    return intro + userData + explanation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgApp,
      body: FutureBuilder<SuratModel?>(
        future: SuratService().getSuratByTitle(widget.title),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          final surat = snapshot.data;
          
          return Stack(
            children: [
              SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Spasi tombol
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
                                    image: const AssetImage('assets/icons/ic_document_after.png'),
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
                                    Expanded(
                                      child: const Text(
                                        "Preview Dokumen",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
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

                // Konten Kertas Putih
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // KOP SURAT
                        const Text(
                          "PEMERINTAH KOTA SURABAYA\nKECAMATAN WARU - KELURAHAN MAJU",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(height: 2, color: Colors.black87),
                        const SizedBox(height: 24),

                        // JUDUL SURAT
                        Text(
                          widget.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Nomor: 123/RT.05/RW.02/2026",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                        const SizedBox(height: 32),

                        // ISI SURAT (DINAMIS TRANSLASI FORM KE TEKS DOC)
                        Text(
                          _generateBody(surat?.templateKonten),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),

                        const SizedBox(height: 48),

                        // STEMPEL DAN TANDA TANGAN
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Surabaya, 16 Februari 2026",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Ikon Digital Signature (Fake Stamp)
                              const Icon(
                                Icons
                                    .qr_code_2, // Alternatif stamp / signature mockup
                                size: 50,
                                color: Color(0xFF22C55E),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Telah Disetujui\n(Digital Signature)",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Unduh / Kirim Fixed Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E), // Hijau Sukses
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _kirimPengajuan,
                  child: const Text(
                    "Ajukan Surat", // Bisa juga Kirim Pengajuan, sesuai desain
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }),
    );
  }
}
