import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'surat_preview_view.dart';
import 'surat_requirement_sheet.dart';
import '../../models/surat_model.dart';
import '../../services/surat_service.dart';
import '../../viewmodels/auth_viewmodel.dart';

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
  static const Color textGray = Color(0xFF6B7280);

  /// Map: requirementId → URL/teks yang sudah dipenuhi (null = belum)
  final Map<String, String?> _fulfilledMap = {};
  bool _initialized = false;

  /// Inisialisasi auto-requirements dari profil user
  void _initRequirements(SuratModel suratData) {
    if (_initialized) return;
    _initialized = true;
    final user = context.read<AuthViewModel>().currentUser;
    for (final req in suratData.requirements) {
      if (req.type == RequirementType.auto) {
        if (req.autoSourceField == 'ktpUrl') {
          _fulfilledMap[req.id] = user?.ktpUrl;
        } else if (req.autoSourceField == 'kkUrl') {
          _fulfilledMap[req.id] = user?.kkUrl;
        }
      } else {
        _fulfilledMap.putIfAbsent(req.id, () => null);
      }
    }
  }

  bool get _allFulfilled =>
      _fulfilledMap.values.every((v) => v != null && v.isNotEmpty);

  int get _fulfilledCount =>
      _fulfilledMap.values.where((v) => v != null && v.isNotEmpty).length;

  void _openRequirementSheet(SuratRequirement req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SuratRequirementSheet(
        requirement: req,
        currentValue: _fulfilledMap[req.id],
        onFulfilled: (value) {
          setState(() => _fulfilledMap[req.id] = value);
        },
      ),
    );
  }

  void _ajukanPermohonan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SuratPreviewView(title: widget.title)),
    );
  }

  String _generatePenyelipanSk(String title) {
    if (title.toUpperCase().contains("SURAT KETERANGAN USAHA")) return "Surat Keterangan Usaha (SKU)";
    if (title.toUpperCase().contains("TIDAK MAMPU")) return "Surat Keterangan Tidak Mampu (SKTM)";
    if (title.toUpperCase().contains("DOMISILI")) return "Surat Keterangan Domisili";
    return title;
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

        // Inisialisasi requirement state (hanya sekali)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_initialized) setState(() => _initRequirements(suratData));
        });

        final total = suratData.requirements.length;
        final done = _fulfilledCount;

        return Scaffold(
          backgroundColor: bgApp,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ───────────────────────────────────────────
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
                                right: 20, top: 20,
                                child: Transform.rotate(
                                  angle: 12 * 3.14159 / 180,
                                  child: Image(
                                    image: const AssetImage('assets/icons/ic_document_after.png'),
                                    width: 140, height: 140,
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
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: Icon(suratData.icon, color: primaryRed, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Text(
                                        "Pengajuan Surat",
                                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

                // ── KONTEN ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Center(
                        child: Text(
                          _generatePenyelipanSk(suratData.title),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── INFO BANNER: Persetujuan Bertingkat ───────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 18),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                "Persetujuan RT, RW, dan Lurah akan diproses langsung melalui aplikasi ini setelah pengajuan Anda dikirim.",
                                style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 12, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── PERSYARATAN BERKAS (Checklist) ───────────
                      Container(
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Persyaratan Berkas",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                                ),
                                Text(
                                  "$done/$total",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: done == total ? Colors.green.shade600 : primaryRed,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: total > 0 ? done / total : 0,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFF3F4F6),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  done == total ? Colors.green.shade600 : primaryRed,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // List items
                            ...suratData.requirements.map((req) {
                              final isFulfilled = _fulfilledMap[req.id] != null &&
                                  _fulfilledMap[req.id]!.isNotEmpty;
                              final isAuto = req.type == RequirementType.auto;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: isAuto ? null : () => _openRequirementSheet(req),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isFulfilled
                                          ? Colors.green.shade50
                                          : const Color(0xFFFFF5F5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isFulfilled
                                            ? Colors.green.shade200
                                            : const Color(0xFFFFCDD2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Ikon status
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: isFulfilled ? Colors.green.shade100 : const Color(0xFFFFEBEE),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isFulfilled ? Icons.check_rounded : Icons.close_rounded,
                                            color: isFulfilled ? Colors.green.shade700 : Colors.red.shade600,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Teks
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                req.label,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isFulfilled ? Colors.green.shade800 : textDark,
                                                ),
                                              ),
                                              if (isAuto && !isFulfilled) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  req.autoSourceField == 'kkUrl'
                                                      ? 'Upload KK di halaman Profil terlebih dahulu'
                                                      : 'Lengkapi profil Anda terlebih dahulu',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),

                                        // Badge label
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isFulfilled
                                                ? Colors.green.shade100
                                                : isAuto
                                                    ? const Color(0xFFEFF6FF)
                                                    : const Color(0xFFFEF2F2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isFulfilled
                                                ? 'Terpenuhi'
                                                : isAuto
                                                    ? 'Dari Profil'
                                                    : req.type == RequirementType.text
                                                        ? 'Isi Data'
                                                        : 'Upload',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isFulfilled
                                                  ? Colors.green.shade700
                                                  : isAuto
                                                      ? const Color(0xFF1D4ED8)
                                                      : primaryRed,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── PREVIEW TEMPLATE ─────────────────────────
                      const Text(
                        "Preview Format Dokumen",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textGray),
                      ),
                      const SizedBox(height: 12),
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
                            const Icon(Icons.feed_outlined, size: 48, color: Color(0xFFD1D5DB)),
                            const SizedBox(height: 12),
                            Text(
                              "Template_${suratData.title.replaceAll(' ', '_')}.pdf",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── LENGKAPI DATA FORM ────────────────────────
                      const Text(
                        "Lengkapi Data Berikut",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Data profil Anda akan diisi otomatis oleh sistem. Silakan lengkapi data spesifik yang masih kosong.",
                          style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 13, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form fields dinamis
                      ..._buildDynamicFormFields(suratData.fields),

                      const SizedBox(height: 48),

                      // ── TOMBOL LIHAT PREVIEW ──────────────────────
                      if (!_allFulfilled)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Center(
                            child: Text(
                              "Selesaikan ${total - _fulfilledCount} persyaratan yang belum terpenuhi untuk melanjutkan",
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _allFulfilled ? primaryRed : const Color(0xFFD1D5DB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _allFulfilled ? _ajukanPermohonan : null,
                          child: Text(
                            "Lihat Preview",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _allFulfilled ? Colors.white : const Color(0xFF9CA3AF),
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
      },
    );
  }

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
}
