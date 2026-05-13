import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/media_service.dart';
import '../../services/ocr_service.dart';
import 'form_register_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Warna konsisten WARTA
  static const Color bgGray = Color(0xFFF9FAFB);
  static const Color primaryRed = Color(0xFF8B1E1E);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);
  static const Color goldColor = Color(0xFFD4AF37);
  static const Color iconBgLight = Color(0xFFFEE2E2);

  final MediaService _mediaService = MediaService();
  final OcrService _ocrService = OcrService();

  XFile? _ktpImage;
  bool _isProcessing = false;
  Map<String, String> _parsedData = {};

  // Tombol aktif hanya kalau NIK dan Nama minimal berhasil terbaca
  bool get _isKtpReady =>
      _ktpImage != null &&
      !_isProcessing &&
      (_parsedData['nik']?.isNotEmpty == true ||
          _parsedData['nama']?.isNotEmpty == true);

  Future<void> _ambilFotoKTP() async {
    // Pilih dari kamera atau galeri
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Pilih Sumber Foto KTP",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, 'camera'),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: primaryRed,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Kamera",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 'gallery'),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Color(0xFF3B82F6),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Galeri",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    XFile? xfile;
    if (source == 'camera') {
      xfile = await _mediaService.pickImageXFileFromCamera();
    } else {
      xfile = await _mediaService.pickImageXFileFromGallery();
    }

    if (xfile == null || !mounted) return;

    setState(() {
      _ktpImage = xfile;
      _isProcessing = true;
      _parsedData.clear();
    });

    // Jalankan OCR dari XFile (menghindari _Namespace error di Android)
    final ocrText = await _ocrService.processImage(xfile);

    if (!mounted) return;

    // Cek apakah OCR melempar error
    final bool isOcrError = ocrText != null && ocrText.startsWith('__ERROR__:');

    // Parse data dari teks OCR (skip jika error)
    final Map<String, String> data = (isOcrError || ocrText == null)
        ? {}
        : _parseKTPData(ocrText);

    setState(() {
      _isProcessing = false;
      _parsedData = data;
    });
  }

  void _lanjutKeForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormRegistView(
          prefilledData: _parsedData,
          ktpImageFile: _ktpImage, // pass foto KTP ke form
        ),
      ),
    );
  }



  /// Parse KTP fields from raw OCR text using a multi-pass strategy:
  /// 1. Positional Parser: Anchored on NIK, reads values at fixed offsets.
  /// 2. Label Fallback: Regular regex-based scanning if positional fails.
  /// 3. Inline Patterns: For fields like Status/Kewarganegaraan often merged.
  Map<String, String> _parseKTPData(String rawText) {
    final Map<String, String> data = {};
    final List<String> lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // ---------- helpers ----------
    String clean(String s) => s.trim().replaceAll(RegExp(r'\s{2,}'), ' ');

    bool isAnyLabel(String s) => RegExp(
      r'^(?:NIK|Nama|Tempat|Tgl|Jenis|Gol\.?|Darah|Alamat|RTIRW|RT\s*[/I]?RW|RT\b|RW\b|Kel|Kec|Agama|Status|Berlaku|Pekerjaan|Kewarg|PROVINSI)',
      caseSensitive: false,
    ).hasMatch(s.trim());

    bool isStrictLabel(String s) => RegExp(
      r'^(?:NIK\b|Nama\b|Tempat\b|Tgl\b|Jenis\b|Gol\b|Darah\b|Alamat\b|RTIRW|RT\b|RW\b|Agama\b|Status\b|Berlaku\b|Pekerjaan\b|Kewarg|PROVINSI\b|Kecamatan\b|Kel\.?/)',
      caseSensitive: false,
    ).hasMatch(s.trim());

    String findValue(
      RegExp labelPat, {
      bool nextLine = false,
      int maxAhead = 8,
    }) {
      for (int i = 0; i < lines.length; i++) {
        final match = labelPat.firstMatch(lines[i]);
        if (match != null) {
          String val = clean(
            lines[i]
                .substring(match.end)
                .replaceAll(RegExp(r'^[\s:=\-E]+'), ''),
          );
          if (val.isEmpty && nextLine) {
            for (int j = i + 1; j <= i + maxAhead && j < lines.length; j++) {
              final c = clean(lines[j].replaceAll(RegExp(r'^[\s:=\-]+'), ''));
              if (c.isEmpty || isAnyLabel(c)) continue;
              val = c;
              break;
            }
          }
          return val;
        }
      }
      return '';
    }

    void acceptIf(String key, String val, {int minLen = 2}) {
      final v = clean(val);
      if (v.length >= minLen && !isStrictLabel(v)) data[key] = v.toUpperCase();
    }

    // ================================================================
    // PASS 1 — NIK (16-digit anchor) + POSITIONAL PARSER
    // ================================================================
    int nikLineIdx = -1;
    for (int i = 0; i < lines.length; i++) {
      final stripped = lines[i].replaceAll(RegExp(r'\D'), '');
      if (stripped.length >= 15 && stripped.length <= 16) {
        nikLineIdx = i;
        data['nik'] = stripped;
        break;
      }
    }

    if (nikLineIdx >= 0) {
      int ptr = nikLineIdx + 1;

      // -- Nama (+1) --
      if (ptr < lines.length) {
        final n = clean(lines[ptr]).toUpperCase();
        if (n.length >= 3 &&
            !RegExp(r'\d').hasMatch(n) &&
            !isAnyLabel(n) &&
            !n.contains('LAHIR') &&
            !RegExp(
              r'^(JAKARTA|BANDUNG|SURABAYA|MEDAN|PROVINSI)',
              caseSensitive: false,
            ).hasMatch(n)) {
          data['nama'] = n;
        }
        ptr++;
      }

      // -- TTL (+2) --
      if (ptr < lines.length) {
        final ttlLine = clean(lines[ptr]);
        final dm = RegExp(r'(\d{2}[-/]\d{2}[-/]\d{4})').firstMatch(ttlLine);
        if (dm != null) {
          data['tanggal_lahir'] = dm.group(1)!.replaceAll('/', '-');
          final tempat = ttlLine
              .substring(0, dm.start)
              .replaceAll(RegExp(r'[\s,]+$'), '')
              .trim();
          if (tempat.length >= 2) data['tempat_lahir'] = tempat.toUpperCase();
        } else if (ttlLine.length >= 2 &&
            !RegExp(r'\d').hasMatch(ttlLine) &&
            !isAnyLabel(ttlLine)) {
          data['tempat_lahir'] = ttlLine.toUpperCase();
          for (int j = ptr + 1; j <= ptr + 3 && j < lines.length; j++) {
            final dm2 = RegExp(
              r'(\d{2}[-/]\d{2}[-/]\d{4})',
            ).firstMatch(lines[j]);
            if (dm2 != null) {
              data['tanggal_lahir'] = dm2.group(1)!.replaceAll('/', '-');
              break;
            }
          }
        }
        ptr++;
      }

      // -- Jenis Kelamin (+3) --
      if (ptr < lines.length) {
        final jkUp = clean(lines[ptr]).toUpperCase();
        if (jkUp.contains('LAKI')) {
          data['jenis_kelamin'] = 'LAKI-LAKI';
          ptr++;
        } else if (jkUp.contains('PEREMPUAN') || jkUp.contains('WANITA')) {
          data['jenis_kelamin'] = 'PEREMPUAN';
          ptr++;
        }
      }

      // -- Alamat (+4) --
      if (ptr < lines.length) {
        final al = clean(lines[ptr]).toUpperCase();
        if (al.length >= 4 &&
            !RegExp(r'^\d{3}[/\\]\d{3}').hasMatch(al) &&
            !isAnyLabel(al)) {
          data['alamat'] = al;
          ptr++;
        }
      }

      // -- RT / RW (+5) --
      if (ptr < lines.length) {
        final rtrwLine = clean(lines[ptr]);
        final rm = RegExp(r'(\d{3})\s*[/\\|I]\s*(\d{3})').firstMatch(rtrwLine);
        if (rm != null) {
          data['rt'] = rm.group(1)!;
          data['rw'] = rm.group(2)!;
          ptr++;
        }
      }

      // -- Kelurahan (+6) --
      if (ptr < lines.length) {
        final kel = clean(lines[ptr]).toUpperCase();
        if (kel.length > 2 &&
            !RegExp(r'^\d').hasMatch(kel) &&
            !isAnyLabel(kel) &&
            !RegExp(r'^Kec', caseSensitive: false).hasMatch(kel)) {
          data['kelurahan'] = kel;
          ptr++;
        }
      }

      // -- Kecamatan (+7) --
      if (ptr < lines.length) {
        final kec = clean(lines[ptr]).toUpperCase();
        if (kec.length > 2 &&
            !RegExp(r'^\d').hasMatch(kec) &&
            !isAnyLabel(kec)) {
          data['kecamatan'] = kec;
          ptr++;
        }
      }

      // -- Agama (+8) --
      if (ptr < lines.length) {
        final ag = clean(lines[ptr]).replaceAll(RegExp(r'^1'), 'I');
        if (RegExp(
          r'^(ISLAM|KRISTEN|KATHOLIK|HINDU|BUDHA|KONGHUCU)',
          caseSensitive: false,
        ).hasMatch(ag)) {
          data['agama'] = ag.toUpperCase();
        }
      }
    }

    // ================================================================
    // PASS 2 — Fallout/Individual Field Fallbacks
    // ================================================================
    if (!data.containsKey('nik') || (data['nik']?.length ?? 0) < 15) {
      final nikFallback = RegExp(r'\b(\d{15,16})\b').firstMatch(rawText);
      if (nikFallback != null) data['nik'] = nikFallback.group(1)!;
    }

    if (!data.containsKey('nama')) {
      final n = findValue(
        RegExp(r'^(?:Nama|Narna|Nam\s*a|Nma|Name)', caseSensitive: false),
        nextLine: true,
      );
      if (n.length >= 3 &&
          !RegExp(r'[\d]').hasMatch(n) &&
          !n.toUpperCase().contains('LAHIR') &&
          !n.toUpperCase().contains('TEMPAT') &&
          !n.toUpperCase().contains('TANGGAL') &&
          !n.toUpperCase().contains('PROVINSI') &&
          !n.toUpperCase().contains('KECAMATAN') &&
          !n.toUpperCase().contains('KELURAHAN') &&
          !n.toUpperCase().contains('RT/RW') &&
          !n.toUpperCase().contains('AGAMA') &&
          !n.toUpperCase().contains('STATUS PERKAWINAN') &&
          !n.toUpperCase().contains('KEWARGANEGARAAN') &&
          !n.toUpperCase().contains('ALAMAT') &&
          !n.toUpperCase().contains('GOL. DARAH')) {
        data['nama'] = n.toUpperCase();
      }
    }

    if (!data.containsKey('jenis_kelamin')) {
      final rawUp = rawText.toUpperCase();
      if (rawUp.contains('LAKI') && !rawUp.contains('PEREMPUAN')) {
        data['jenis_kelamin'] = 'LAKI-LAKI';
      } else if (rawUp.contains('PEREMPUAN') || rawUp.contains('WANITA')) {
        data['jenis_kelamin'] = 'PEREMPUAN';
      }
    }

    if (!data.containsKey('gol_darah')) {
      final golRaw = findValue(
        RegExp(r'(?:Gol\.?\s*Darah|Gol\.\s*Dr)', caseSensitive: false),
        nextLine: true,
      );
      if (golRaw.isNotEmpty) {
        final g = golRaw.replaceAll(RegExp(r'[\s:]'), '').toUpperCase();
        data['gol_darah'] = RegExp(r'^(AB|A|B|O)$').hasMatch(g) ? g : '-';
      } else {
        data['gol_darah'] = '-';
      }
    }

    if (!data.containsKey('rt')) {
      final rmFallback = RegExp(
        r'(\d{3})\s*[/\\|I]\s*(\d{3})',
      ).firstMatch(rawText);
      if (rmFallback != null) {
        data['rt'] = rmFallback.group(1)!;
        data['rw'] = rmFallback.group(2)!;
      }
    }

    if (!data.containsKey('agama')) {
      final religionMatch = RegExp(
        r'\b(ISLAM|KRISTEN|KATHOLIK|HINDU|BUDHA|KONGHUCU)\b',
        caseSensitive: false,
      ).firstMatch(rawText.replaceAll('1SLAM', 'ISLAM'));
      if (religionMatch != null) {
        data['agama'] = religionMatch.group(1)!.toUpperCase();
      }
    }

    // Status Perkawinan
    final spRaw = findValue(
      RegExp(r'^Status\s*Perkawinan\b', caseSensitive: false),
      nextLine: true,
    );
    final spSearch = spRaw.isNotEmpty ? spRaw : rawText;
    if (RegExp(r'BELUM\s*KAWIN', caseSensitive: false).hasMatch(spSearch)) {
      data['status_perkawinan'] = 'BELUM KAWIN';
    } else if (RegExp(r'\bKAWIN\b', caseSensitive: false).hasMatch(spSearch)) {
      data['status_perkawinan'] = 'KAWIN';
    } else if (RegExp(r'CERAI', caseSensitive: false).hasMatch(spSearch)) {
      data['status_perkawinan'] = spSearch.toUpperCase().contains('MATI')
          ? 'CERAI MATI'
          : 'CERAI HIDUP';
    }

    // Pekerjaan
    String pkRaw = findValue(
      RegExp(r'^Pekerjaan\b', caseSensitive: false),
      nextLine: true,
      maxAhead: 8,
    );
    if (pkRaw.length > 2 && !isStrictLabel(pkRaw)) {
      pkRaw = pkRaw.replaceAllMapped(
        RegExp(r'([A-Z])[iIhH]([A-Z])'),
        (m) => '${m.group(1)}/${m.group(2)}',
      );
      acceptIf('pekerjaan', pkRaw, minLen: 3);
    }

    // Kewarganegaraan
    final kwMatch = RegExp(
      r'\b(WN[I1]|WNA)\b',
      caseSensitive: false,
    ).firstMatch(rawText);
    if (kwMatch != null) {
      data['kewarganegaraan'] = kwMatch
          .group(1)!
          .toUpperCase()
          .replaceAll('1', 'I');
    }

    // Provinsi & Kabupaten
    final provMatch = RegExp(
      r'PROVINSI\s+([A-Z\s]+)',
      caseSensitive: false,
    ).firstMatch(rawText);
    if (provMatch != null) {
      acceptIf('provinsi', provMatch.group(1)!.split('\n')[0].trim());
    }

    for (int i = 0; i < lines.length; i++) {
      if (RegExp(r'PROVINSI', caseSensitive: false).hasMatch(lines[i]) &&
          i + 1 < lines.length) {
        final next = clean(lines[i + 1]);
        if (next.isNotEmpty && !isAnyLabel(next)) {
          data['kabupaten'] = next.toUpperCase();
          break;
        }
      }
    }

    return data;
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      body: Column(
        children: [
          // 1. HEADER - Sacrificed height to avoid scrolling
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10, top: -10,
                  child: Transform.rotate(
                    angle: 12 * 3.14159 / 180,
                    child: Image(image: const AssetImage('assets/images/warta_logo.png'), width: 100, height: 100, color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.1)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 50, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text("Scan e-KTP", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. KONTEN
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: iconBgLight, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.credit_card_rounded, size: 32, color: primaryRed),
                      ),
                      const SizedBox(height: 16),
                      const Text("Foto & Verifikasi e-KTP", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(fontSize: 13, color: textGray, height: 1.4),
                          children: [
                            TextSpan(text: "Posisikan e-KTP kamu di dalam bingkai agar data bisa terbaca otomatis oleh sistem "),
                            TextSpan(text: "WARTA", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
                            TextSpan(text: "."),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Area Preview KTP
                      GestureDetector(
                        onTap: _isProcessing ? null : _ambilFotoKTP,
                        child: DottedBorder(
                          color: goldColor.withValues(alpha: 0.5),
                          strokeWidth: 2,
                          dashPattern: const [8, 4],
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 180, // Optimized height
                            decoration: BoxDecoration(color: goldColor.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16)),
                            child: _ktpImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        kIsWeb ? Image.network(_ktpImage!.path, fit: BoxFit.cover) : Image.file(File(_ktpImage!.path), fit: BoxFit.cover),
                                        if (_isProcessing)
                                          Container(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            child: const Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                                SizedBox(height: 16),
                                                Text("Membaca data KTP...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        if (!_isProcessing)
                                          Container(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            alignment: Alignment.center,
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                                              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 32),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_a_photo_outlined, size: 40, color: goldColor),
                                      const SizedBox(height: 12),
                                      const Text("Area e-KTP", style: TextStyle(color: goldColor, fontSize: 15, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      const Text("Ketuk area ini untuk mengambil foto", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 3b. STATUS & TOMBOL
                  Column(
                    children: [
                      if (_ktpImage != null && !_isProcessing) ...[
                        _isKtpReady
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade200)),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text("Data KTP terbaca! Silakan lanjut.", style: TextStyle(color: Colors.green.shade800, fontSize: 13, fontWeight: FontWeight.w600))),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.orange.shade200)),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text("KTP kurang jelas? Coba ambil ulang.", style: TextStyle(color: Colors.orange.shade800, fontSize: 13, fontWeight: FontWeight.w600))),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 20),
                      ],
                      
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isKtpReady ? const Color(0xFF10B981) : primaryRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: (_ktpImage == null || _isProcessing) ? null : _lanjutKeForm,
                          icon: Icon(_isKtpReady ? Icons.arrow_forward_rounded : Icons.camera_alt_rounded, color: Colors.white),
                          label: Text(
                            _ktpImage == null ? "AMBIL FOTO KTP" : (_isKtpReady ? "SELANJUTNYA" : "TETAP LANJUTKAN"),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity, height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF64748B), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FormRegistView(prefilledData: {}, ktpImageFile: null),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_note, color: Color(0xFF64748B), size: 20),
                          label: const Text("INPUT DATA MANUAL", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
