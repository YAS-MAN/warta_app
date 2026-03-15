import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
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

  File? _ktpImage;
  bool _isProcessing = false;
  Map<String, String> _parsedData = {};
  String? _ocrRawText;  // raw text from ML Kit, used to show quality hints
  // Tombol aktif hanya kalau NIK dan Nama minimal berhasil terbaca
  bool get _isKtpReady =>
      _ktpImage != null &&
      !_isProcessing &&
      (_parsedData['nik']?.isNotEmpty == true || _parsedData['nama']?.isNotEmpty == true);

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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text("Pilih Sumber Foto KTP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.camera_alt, color: primaryRed, size: 32),
                      ),
                      const SizedBox(height: 8),
                      const Text("Kamera", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 'gallery'),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.photo_library, color: Color(0xFF3B82F6), size: 32),
                      ),
                      const SizedBox(height: 8),
                      const Text("Galeri", style: TextStyle(fontWeight: FontWeight.w600)),
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

    File? image;
    if (source == 'camera') {
      image = await _mediaService.pickImageFromCamera();
    } else {
      image = await _mediaService.pickImageFromGallery();
    }

    if (image == null || !mounted) return;

    setState(() {
      _ktpImage = image;
      _isProcessing = true;
      _parsedData.clear();
    });

    // Jalankan OCR untuk ekstrak teks dari KTP
    final ocrText = await _ocrService.processImage(image);
    
    if (!mounted) return;
    
    // Parse data dari teks OCR
    final Map<String, String> data = _parseKTPData(ocrText ?? '');

    setState(() {
      _isProcessing = false;
      _parsedData = data;
      _ocrRawText = ocrText;  // simpan raw text untuk display & debug
    });
  }

  void _lanjutKeForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormRegistView(prefilledData: _parsedData),
      ),
    );
  }

  /// Menampilkan hasil scan KTP field-by-field dengan tips perbaikan
  Widget _buildOcrResultPanel() {
    // Daftar field penting beserta label UX yang ramah
    final List<Map<String, String>> fields = [
      {'key': 'nik',              'label': 'NIK (16 digit)'},
      {'key': 'nama',             'label': 'Nama'},
      {'key': 'ttl',              'label': 'Tempat / Tgl Lahir'},
      {'key': 'jenis_kelamin',    'label': 'Jenis Kelamin'},
      {'key': 'gol_darah',        'label': 'Golongan Darah'},
      {'key': 'alamat',           'label': 'Alamat'},
      {'key': 'rt',               'label': 'RT/RW'},
      {'key': 'kelurahan',        'label': 'Kel/Desa'},
      {'key': 'kecamatan',        'label': 'Kecamatan'},
      {'key': 'agama',            'label': 'Agama'},
      {'key': 'status_perkawinan','label': 'Status Perkawinan'},
      {'key': 'pekerjaan',        'label': 'Pekerjaan'},
      {'key': 'kewarganegaraan',  'label': 'Kewarganegaraan'},
    ];

    final int total = fields.length;
    final int found = fields.where((f) => _parsedData[f['key']]?.isNotEmpty == true).length;
    final bool ocrFailed = _ocrRawText == null || _ocrRawText!.trim().isEmpty;
    final bool hasCore = _parsedData['nik']?.isNotEmpty == true || _parsedData['nama']?.isNotEmpty == true;

    // Tips kontekstual berdasarkan kondisi
    List<String> tips = [];
    if (ocrFailed) {
      tips.add('📷 OCR tidak berhasil membaca gambar sama sekali.');
      tips.add('Pastikan foto tidak buram atau terlalu gelap.');
      tips.add('Coba ambil foto lebih dekat dan pastikan pencahayaan cukup.');
    } else if (!hasCore) {
      tips.add('⚠️ NIK dan Nama tidak terbaca. Ini field wajib.');
      if (_ocrRawText!.length < 50) {
        tips.add('Gambar kemungkinan terpotong — pastikan seluruh KTP terlihat dalam bingkai.');
      } else {
        tips.add('Gambar mungkin buram — coba ambil ulang dengan kamera yang lebih stabil.');
      }
    } else if (found < total ~/ 2) {
      tips.add('Sebagian field tidak terbaca. Coba perbaiki pencahayaan atau kurangi glare/silau.');
    }

    Color statusColor = hasCore ? Colors.green.shade700 : Colors.red.shade600;
    Color statusBg   = hasCore ? Colors.green.shade50 : Colors.red.shade50;
    IconData statusIcon = hasCore ? Icons.check_circle_rounded : Icons.error_rounded;
    String statusTitle = hasCore
        ? 'Scan Berhasil — $found/$total field terbaca'
        : 'Scan Gagal — Field utama tidak terdeteksi';

    return Container(
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header status
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Grid field checklist
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: fields.map((f) {
              final bool ok = _parsedData[f['key']]?.isNotEmpty == true;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ok ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ok ? Icons.check : Icons.close,
                      size: 12,
                      color: ok ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      f['label']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: ok ? Colors.green.shade900 : Colors.red.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          // Tips jika ada
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              'Saran Perbaikan:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
            ),
            const SizedBox(height: 6),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $tip',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade900, height: 1.4),
              ),
            )),
          ],

          // Nilai mentah OCR untuk debugging (bisa dikomentari saat production)
          if (!hasCore && _ocrRawText != null && _ocrRawText!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              iconColor: Colors.grey,
              title: Text('Lihat teks OCR mentah', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    _ocrRawText!.trim().length > 400 ? '${_ocrRawText!.trim().substring(0, 400)}...' : _ocrRawText!.trim(),
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Parse basic KTP fields from raw OCR text
  Map<String, String> _parseKTPData(String rawText) {
    Map<String, String> data = {};
    
    // Helper function for inline elements that might be skipped
    String getCapsValueAfter(String keywordPtn) {
      final ptn = RegExp(r'' + keywordPtn + r'[\s\:\=\-]*([A-Z0-9\s\.\/\-\,]+?)\n', caseSensitive: false);
      final match = ptn.firstMatch(rawText);
      if (match != null) {
        String val = match.group(1)!.trim();
        if (val.isEmpty || RegExp(r'^[^a-zA-Z0-9]+$').hasMatch(val)) {
             return '';
        }
        return val;
      }
      return '';
    }

    // Provinsi
    final provMatch = RegExp(r'(?:PROVINSI)\s*([A-Z\s]+)', caseSensitive: false).firstMatch(rawText);
    if (provMatch != null) data['provinsi'] = provMatch.group(1)!.split('\n')[0].trim();

    // Kabupaten/Kota
    final kabMatch = RegExp(r'(?:PROVINSI)[^\n]*\n([A-Z\s]+)', caseSensitive: false).firstMatch(rawText);
    if (kabMatch != null) data['kabupaten'] = kabMatch.group(1)!.split('\n')[0].trim();

    // NIK (16 digits)
    final nikMatch = RegExp(r'\b\d{16}\b').firstMatch(rawText);
    if (nikMatch != null) data['nik'] = nikMatch.group(0)!;

    // Nama
    final namaMatch = RegExp(r'(?:Nama|Narna|Name|Nma)[\s\:\=\-]*([A-Z\s\.,]+)', caseSensitive: false).firstMatch(rawText);
    if (namaMatch != null) data['nama'] = namaMatch.group(1)!.split('\n')[0].trim();

    // Tempat/Tgl Lahir
    final ttlMatch = RegExp(r'(?:Tempat|Tgl|Lahir|Tempat/Tgl Lahir|Tempat/Tq1 Lahir)[\s\:\=\-]*([A-Za-z0-9\s]+,?\s*\d{2}-\d{2}-\d{4})', caseSensitive: false).firstMatch(rawText);
    if (ttlMatch != null) data['ttl'] = ttlMatch.group(1)!.split('\n')[0].trim();

    // Jenis Kelamin
    final jkMatch = RegExp(r'((?:LAKI-LAKI|PEREMPUAN|LAKI - LAKI|LAKI))', caseSensitive: false).firstMatch(rawText);
    if (jkMatch != null) {
      String jk = jkMatch.group(1)?.replaceAll(' ', '').toUpperCase() ?? '';
      if(jk == 'LAKI') jk = 'LAKI-LAKI';
      data['jenis_kelamin'] = jk;
    }

    // Gol Darah
    final golMatch = RegExp(r'(?:Gol\.?\s*Darah|Darah)[\s\:\=\-]*([A|B|AB|O|0|\-]+)', caseSensitive: false).firstMatch(rawText);
    if (golMatch != null) {
      String gol = golMatch.group(1)!.replaceAll('-', '').trim();
      if (gol == '0') gol = 'O'; 
      if (gol == '') gol = '-';
      data['gol_darah'] = gol;
    }

    // Alamat
    final alamatMatch = RegExp(r'(?:Alamat)[\s\:\=\-]*([A-Za-z0-9\s\.\/\-]+)', caseSensitive: false).firstMatch(rawText);
    if (alamatMatch != null) {
      data['alamat'] = alamatMatch.group(1)!.split('\n')[0].trim();
    }

    // RT/RW
    final rtrwMatch = RegExp(r'(?:RT|RW|RT/RW|RTI/RW)[\s\:\=\-]*(\d{3})[\s\/\[\]\|\-]*(\d{3})', caseSensitive: false).firstMatch(rawText);
    if (rtrwMatch != null) {
      data['rt'] = rtrwMatch.group(1)!;
      data['rw'] = rtrwMatch.group(2)!;
    }

    // Kel/Desa
    final kelMatch = RegExp(r'(?:Kel/Desa|Kel|Desa|ke1/Desa)[\s\:\=\-]*([A-Z\s]+)', caseSensitive: false).firstMatch(rawText);
    if (kelMatch != null) {
       String kel = kelMatch.group(1)!.split('\n')[0].trim();
       if (kel == 'amin') kel = getCapsValueAfter(r'(?:Kel/Desa|Kel|Desa|ke1/Desa)');
       data['kelurahan'] = kel;
    }

    // Kecamatan
    final kecMatch = RegExp(r'(?:Kecamatan|Kec|kecamatan)[\s\:\=\-]*([A-Z\s]+)', caseSensitive: false).firstMatch(rawText);
    if (kecMatch != null) data['kecamatan'] = kecMatch.group(1)!.split('\n')[0].trim();

    // Agama
    final agamaMatch = RegExp(r'(?:Agama)[\s\:\=\-]*([A-Z\s]+)', caseSensitive: false).firstMatch(rawText);
    if (agamaMatch != null) data['agama'] = agamaMatch.group(1)!.split('\n')[0].trim();

    // Status Perkawinan
    final statusMatch = RegExp(r'(?:Status\s*Perkawinan|Status)[\s\:\=\-]*([A-Z\s]+)', caseSensitive: false).firstMatch(rawText);
    if (statusMatch != null) data['status_perkawinan'] = statusMatch.group(1)!.split('\n')[0].trim();

    // Pekerjaan
    final pekerjaanMatch = RegExp(r'(?:Pekerjaan)[\s\:\=\-]*([A-Z\s\/]+)', caseSensitive: false).firstMatch(rawText);
    if (pekerjaanMatch != null) data['pekerjaan'] = pekerjaanMatch.group(1)!.split('\n')[0].trim();

    // Kewarganegaraan
    final kwMatch = RegExp(r'(?:Kewarganegaraan)[\s\:\=\-]*([A-Z0-9\s]+)', caseSensitive: false).firstMatch(rawText);
    if (kwMatch != null) {
       String kw = kwMatch.group(1)!.split('\n')[0].replaceAll(' ', '').trim();
       if (kw == 'WN1') kw = 'WNI';
       data['kewarganegaraan'] = kw;
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER MERAH MELENGKUNG
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
                                image: const AssetImage('assets/images/warta_logo.png'),
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
                                const Expanded(
                                  child: Text(
                                    "Scan e-KTP",
                                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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

            const SizedBox(height: 32),

            // 2. KONTEN TENGAH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(color: iconBgLight, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.credit_card, size: 40, color: primaryRed),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Foto & Verifikasi e-KTP",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textDark, letterSpacing: -0.6),
                  ),
                  const SizedBox(height: 12),

                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: textGray, height: 1.5),
                      children: [
                        TextSpan(text: "Posisikan e-KTP kamu di dalam bingkai agar data bisa terbaca otomatis oleh sistem "),
                        TextSpan(text: "WARTA", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
                        TextSpan(text: "."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. Area Preview KTP
                  GestureDetector(
                    onTap: _isProcessing ? null : _ambilFotoKTP,
                    child: DottedBorder(
                      color: goldColor,
                      strokeWidth: 2,
                      dashPattern: const [8, 4],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 190,
                        decoration: BoxDecoration(
                          color: goldColor.withValues(alpha: 0.05),
                        ),
                        child: _ktpImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    kIsWeb ? Image.network(_ktpImage!.path, fit: BoxFit.cover) : Image.file(_ktpImage!, fit: BoxFit.cover),
                                    if (_isProcessing)
                                      Container(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        child: const Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(color: Colors.white),
                                            SizedBox(height: 12),
                                            Text("Membaca data KTP...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    if (!_isProcessing)
                                      Container(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.refresh, color: Colors.white, size: 40),
                                      ),
                                  ],
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined, size: 30, color: goldColor),
                                  SizedBox(height: 8),
                                  Text("Area e-KTP", style: TextStyle(color: goldColor, fontSize: 14, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 4),
                                  Text("Ketuk area ini untuk mengambil foto", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3b. PANEL HASIL OCR (muncul setelah foto diambil)
            if (_ktpImage != null && !_isProcessing)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _buildOcrResultPanel(),
              ),

            const SizedBox(height: 24),

            // 4. TOMBOL SELANJUTNYA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isKtpReady ? Colors.green : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: _isKtpReady ? Colors.green.shade700 : Colors.transparent, width: 1),
                    ),
                    elevation: _isKtpReady ? 5 : 0,
                    shadowColor: _isKtpReady ? Colors.green.withValues(alpha: 0.5) : Colors.transparent,
                  ),
                  onPressed: _isKtpReady ? _lanjutKeForm : null,
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                  label: const Text(
                    "SELANJUTNYA",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
