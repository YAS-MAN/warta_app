import 'package:flutter/material.dart';
import 'surat_preview_view.dart';
import '../../models/surat_model.dart';
import '../../services/surat_service.dart';

class SuratDetailView extends StatefulWidget {
  final String title;

  const SuratDetailView({super.key, required this.title});

  @override
  State<SuratDetailView> createState() => _SuratDetailViewState();
}

class _SuratDetailViewState extends State<SuratDetailView> {
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);

  void _ajukanPermohonan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SuratPreviewView(title: widget.title)),
    );
  }

  // Helper untuk membuat singkatan dinamis
  String _generatePenyelipanSk(String title) {
    if (title.toUpperCase().contains("SURAT KETERANGAN USAHA"))
      return "Surat Keterangan Usaha (SKU)";
    if (title.toUpperCase().contains("TIDAK MAMPU"))
      return "Surat Keterangan Tidak Mampu (SKTM)";
    if (title.toUpperCase().contains("DOMISILI"))
      return "Surat Keterangan Domisili";
    return title;
  }

  // Generate Field Dinamis dari Model
  List<Widget> _buildDynamicFormFields(List<SuratFieldModel> modelFields) {
    return modelFields.map((field) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              field.label,
              style: const TextStyle(fontWeight: FontWeight.w600, color: textDark),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: TextField(
                maxLines: field.maxLines,
                decoration: InputDecoration(
                  hintText: field.hint,
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // --- KUMPULAN SYARAT BERDASARKAN JUDUL SURAT ---
  Widget _buildRequirements(List<String> requirements) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Persyaratan Berkas",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...requirements.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(e, style: const TextStyle(color: textDark, fontSize: 14))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SuratModel?>(
      future: SuratService().getSuratByTitle(widget.title),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: bgApp,
            body: Center(child: CircularProgressIndicator(color: primaryRed)),
          );
        }
        
        final suratData = snapshot.data;
        if (suratData == null) {
           return Scaffold(
             backgroundColor: bgApp,
             appBar: AppBar(backgroundColor: primaryRed, title: const Text("Surat Tidak Ditemukan")),
             body: const Center(child: Text("Data surat tidak valid.")),
           );
        }

        return Scaffold(
          backgroundColor: bgApp,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            colors: [
                              Color.fromARGB(255, 83, 0, 0),
                              Color(0xFF8B0000),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 20,
                                top: 20,
                                child: Transform.rotate(
                                  angle: 12 * 3.14159 / 180,
                                  child: Image(
                                    image: const AssetImage(
                                      'assets/icons/ic_document_after.png',
                                    ),
                                    width: 140,
                                    height: 140,
                                    color: const Color.fromARGB(
                                      255,
                                      58,
                                      1,
                                      1,
                                    ).withValues(alpha: 0.1),
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
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        suratData.icon,
                                        color: primaryRed,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Text(
                                        "Pengajuan Surat",
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

                // --- KONTEN FORMULIR ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Surat Bold Tebal
                      Center(
                        child: Text(
                          _generatePenyelipanSk(suratData.title),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Kotak Persyaratan Berkas Dinamis
                      _buildRequirements(suratData.requirements),
                      
                      const SizedBox(height: 32),

                      // Label Kategori Form
                      const Text(
                        "Preview Format Dokumen",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Kotak Kartu Preview Placeholder
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF3F4F6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.feed_outlined,
                              size: 48,
                              color: Color(0xFFD1D5DB),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Template_${suratData.title.replaceAll(' ', '_')}.pdf",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      // Label Lengkapi Data
                      const Text(
                        "Lengkapi Data Berikut",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Notifikasi Biru
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Data profil Anda akan diisi otomatis oleh sistem. Silakan lengkapi data spesifik yang masih kosong.",
                          style: TextStyle(
                            color: Color(0xFF1D4ED8),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                      // Form Text Field Dinamis
                      ..._buildDynamicFormFields(suratData.fields),
                      
                      const SizedBox(height: 48),

                      // Tombol Ajukan Surat
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _ajukanPermohonan,
                          child: const Text(
                            "Lihat Preview",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
