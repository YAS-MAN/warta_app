import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'photo_verif_view.dart';

class FormRegistView extends StatefulWidget {
  final Map<String, String> prefilledData;
  final File? ktpImageFile; // foto KTP dari halaman scan
  const FormRegistView({
    super.key,
    this.prefilledData = const {},
    this.ktpImageFile,
  });

  @override
  State<FormRegistView> createState() => _FormRegistViewState();
}

class _FormRegistViewState extends State<FormRegistView> {
  // Definisi Warna dari Desain Figma
  static const Color primaryRed = Color(0xFF800000);
  static const Color bgGray = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1E293B);
  static const Color labelGray = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFD1D5DB);

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Text Controllers
  late final TextEditingController _nikCtrl;
  late final TextEditingController _namaCtrl;
  late final TextEditingController _tempatLahirCtrl;
  late final TextEditingController _tglLahirCtrl;
  late final TextEditingController _golDarahCtrl;
  late final TextEditingController _agamaCtrl;
  late final TextEditingController _kewarganegaraanCtrl;
  late final TextEditingController _pekerjaanCtrl;
  late final TextEditingController _alamatCtrl;
  late final TextEditingController _rtCtrl;
  late final TextEditingController _rwCtrl;
  late final TextEditingController _kelCtrl;
  late final TextEditingController _kecCtrl;
  late final TextEditingController _kabCtrl;
  // Akun
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _confirmPasswordCtrl;

  String _jenisKelamin = '-';
  String _statusPerkawinan = '-';

  bool get _hasOcrData => widget.prefilledData.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final d = widget.prefilledData;
    _nikCtrl = TextEditingController(text: d['nik'] ?? '');
    _namaCtrl = TextEditingController(text: d['nama'] ?? '');
    _tempatLahirCtrl = TextEditingController(text: d['tempat_lahir'] ?? '');
    _tglLahirCtrl = TextEditingController(text: d['tanggal_lahir'] ?? '');
    _golDarahCtrl = TextEditingController(text: d['gol_darah'] ?? '');
    _agamaCtrl = TextEditingController(text: d['agama'] ?? '');
    _kewarganegaraanCtrl = TextEditingController(
      text: d['kewarganegaraan'] ?? '',
    );
    _pekerjaanCtrl = TextEditingController(text: d['pekerjaan'] ?? '');
    _alamatCtrl = TextEditingController(text: d['alamat'] ?? '');
    _rtCtrl = TextEditingController(text: d['rt'] ?? '');
    _rwCtrl = TextEditingController(text: d['rw'] ?? '');
    _kelCtrl = TextEditingController(text: d['kelurahan'] ?? '');
    _kecCtrl = TextEditingController(text: d['kecamatan'] ?? '');
    _kabCtrl = TextEditingController(text: d['kabupaten'] ?? '');
    _emailCtrl = TextEditingController();
    _passwordCtrl = TextEditingController();
    _confirmPasswordCtrl = TextEditingController();

    // Dropdown values — validate against allowed options
    const allowedJK = ['LAKI-LAKI', 'PEREMPUAN'];
    final jkRaw = (d['jenis_kelamin'] ?? '').toUpperCase();
    _jenisKelamin = allowedJK.contains(jkRaw) ? jkRaw : '-';

    const allowedSP = ['BELUM KAWIN', 'KAWIN', 'CERAI HIDUP', 'CERAI MATI'];
    final spRaw = (d['status_perkawinan'] ?? '').toUpperCase().trim();
    _statusPerkawinan = allowedSP.contains(spRaw) ? spRaw : '-';
  }

  @override
  void dispose() {
    _nikCtrl.dispose();
    _namaCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _tglLahirCtrl.dispose();
    _golDarahCtrl.dispose();
    _agamaCtrl.dispose();
    _kewarganegaraanCtrl.dispose();
    _pekerjaanCtrl.dispose();
    _alamatCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _kelCtrl.dispose();
    _kecCtrl.dispose();
    _kabCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  /// Opens DatePicker and sets the tanggal lahir field
  Future<void> _pickTanggalLahir() async {
    // Parse existing value if any
    DateTime initial = DateTime(2000);
    final parts = _tglLahirCtrl.text.split('-');
    if (parts.length == 3) {
      try {
        initial = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // locale removed — add flutter_localizations to main.dart untuk Bahasa Indonesia
    );
    if (picked != null) {
      final dd = picked.day.toString().padLeft(2, '0');
      final mm = picked.month.toString().padLeft(2, '0');
      final yy = picked.year.toString();
      setState(() => _tglLahirCtrl.text = '$dd-$mm-$yy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER MERAH & TOMBOL BACK (Menggunakan Stack agar bisa tumpang tindih)
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // Background Merah Melengkung (Sesuai Desain Baru)
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
                                      'assets/images/warta_logo.png',
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
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  60,
                                  24,
                                  0,
                                ),
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
                                    const Expanded(
                                      child: Text(
                                        "Lengkapi Data Diri",
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

                // 2. KOTAK PLACEHOLDER FOTO KTP (Tumpang tindih dengan background merah)
                Padding(
                  padding: const EdgeInsets.only(top: 110, left: 24, right: 24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: DottedBorder(
                      color: borderColor,
                      strokeWidth: 2,
                      dashPattern: const [6, 4],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // Tampilkan foto KTP asli jika tersedia, placeholder jika tidak
                        child: widget.ktpImageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  widget.ktpImageFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryRed.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.credit_card,
                                      color: primaryRed,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Foto KTP",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textDark,
                                    ),
                                  ),
                                  const Text(
                                    "Scan KTP terlebih dahulu",
                                    style: TextStyle(fontSize: 10, color: labelGray),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 3. FORMULIR PENGISIAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Banner OCR Autofill ---
                  if (_hasOcrData) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Data berhasil terbaca dari KTP. Harap periksa kembali sebelum melanjutkan.",
                              style: TextStyle(
                                color: Color(0xFF166534),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // --- SECTION: IDENTITAS UTAMA ---
                  _buildSectionHeader(Icons.fingerprint, "IDENTITAS UTAMA"),
                  _buildTextField("NIK", "", controller: _nikCtrl),
                  const SizedBox(height: 16),
                  _buildTextField("NAMA LENGKAP", "", controller: _namaCtrl, isUpperCase: true),
                  // Hint kecil di bawah nama
                  const Padding(
                    padding: EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      "ⓘ Nama ini akan digunakan sebagai USERNAME Login",
                      style: TextStyle(
                        color: primaryRed,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TEMPAT LAHIR + TANGGAL LAHIR (terpisah)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          "TEMPAT LAHIR",
                          "",
                          controller: _tempatLahirCtrl,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: _pickTanggalLahir,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              "TGL LAHIR (hh-bb-tttt)",
                              "",
                              controller: _tglLahirCtrl,
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: labelGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          "JENIS KELAMIN",
                          _jenisKelamin,
                          ['-', 'LAKI-LAKI', 'PEREMPUAN'],
                          (v) => setState(() => _jenisKelamin = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          "GOL. DARAH",
                          "",
                          controller: _golDarahCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("AGAMA", "", controller: _agamaCtrl),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    "STATUS PERKAWINAN",
                    _statusPerkawinan,
                    ['-', 'BELUM KAWIN', 'KAWIN', 'CERAI HIDUP', 'CERAI MATI'],
                    (v) => setState(() => _statusPerkawinan = v!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "KEWARGANEGARAAN",
                          "",
                          controller: _kewarganegaraanCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          "PEKERJAAN",
                          "",
                          controller: _pekerjaanCtrl,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- SECTION: ALAMAT DOMISILI ---
                  _buildSectionHeader(
                    Icons.location_on_outlined,
                    "ALAMAT DOMISILI",
                  ),
                  _buildTextField(
                    "ALAMAT",
                    "",
                    maxLines: 3,
                    controller: _alamatCtrl,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField("RT", "", controller: _rtCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField("RW", "", controller: _rwCtrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "KELURAHAN",
                          "",
                          controller: _kelCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          "KECAMATAN",
                          "",
                          controller: _kecCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("KABUPATEN/KOTA", "", controller: _kabCtrl),

                  const SizedBox(height: 32),

                  // --- SECTION: DATA AKUN ---
                  _buildSectionHeader(
                    Icons.account_circle_outlined,
                    "DATA AKUN",
                  ),
                  _buildTextField("EMAIL", "", controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "BUAT PASSWORD",
                    "",
                    controller: _passwordCtrl,
                    isPassword: true,
                    isObscure: _obscurePassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "KONFIRMASI PASSWORD",
                    "",
                    controller: _confirmPasswordCtrl,
                    isPassword: true,
                    isObscure: _obscureConfirmPassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),

                  const SizedBox(height: 40),

                  // --- TOMBOL SIMPAN ---
                  Consumer<AuthViewModel>(
                    builder: (context, authVM, _) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryRed,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              onPressed: authVM.isLoading
                                  ? null
                                  : () => _simpanDanLanjut(authVM),
                              icon: authVM.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.verified_user_outlined,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                authVM.isLoading
                                    ? "MEMPROSES..."
                                    : "SIMPAN & LANJUT",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      "Pastikan semua data sudah sesuai dengan KTP asli Anda sebelum\nmenekan tombol simpan.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: labelGray, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LOGIKA REGISTRASI
  // ==========================================

  Future<void> _simpanDanLanjut(AuthViewModel authVM) async {
    // Validasi field wajib
    if (_nikCtrl.text.trim().isEmpty || _namaCtrl.text.trim().isEmpty) {
      _showSnackbar('NIK dan Nama tidak boleh kosong.');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty) {
      _showSnackbar('Email tidak boleh kosong.');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      _showSnackbar('Password minimal 6 karakter.');
      return;
    }
    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _showSnackbar('Password dan konfirmasi password tidak cocok.');
      return;
    }

    // Kumpulkan data KTP dari controllers
    final ktpData = {
      'nik': _nikCtrl.text.trim(),
      'nama': _namaCtrl.text.trim().toUpperCase(),
      'tempat_lahir': _tempatLahirCtrl.text.trim(),
      'tanggal_lahir': _tglLahirCtrl.text.trim(),
      'jenis_kelamin': _jenisKelamin,
      'gol_darah': _golDarahCtrl.text.trim(),
      'agama': _agamaCtrl.text.trim(),
      'status_perkawinan': _statusPerkawinan,
      'pekerjaan': _pekerjaanCtrl.text.trim(),
      'kewarganegaraan': _kewarganegaraanCtrl.text.trim(),
      'alamat': _alamatCtrl.text.trim(),
      'rt': _rtCtrl.text.trim(),
      'rw': _rwCtrl.text.trim(),
      'kelurahan': _kelCtrl.text.trim(),
      'kecamatan': _kecCtrl.text.trim(),
      'kabupaten': _kabCtrl.text.trim(),
    };

    final success = await authVM.registerStep1(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      ktpData: ktpData,
      ktpImageFile: widget.ktpImageFile,
    );

    if (!mounted) return;
    if (success) {
      // Lanjut ke upload selfie
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoVerifView(pendingUid: authVM.pendingUid),
        ),
      );
    } else {
      _showSnackbar(authVM.errorMessage ?? 'Registrasi gagal. Coba lagi.');
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF8B0000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ==========================================
  // FUNGSI BANTUAN (REUSABLE WIDGETS)
  // ==========================================

  // Pembuat Judul Section (Misal: IDENTITAS UTAMA)
  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryRed, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: primaryRed,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: borderColor, height: 1),
        ],
      ),
    );
  }

  // Pembuat Form Input Teks (TextFormField)
  Widget _buildTextField(
    String label,
    String initialValue, {
    int maxLines = 1,
    bool isPassword = false,
    bool? isObscure,
    VoidCallback? onToggleObscure,
    TextEditingController? controller,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool isUpperCase = false,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      maxLines: maxLines,
      obscureText: isObscure ?? false,
      keyboardType: keyboardType,
      textCapitalization: isUpperCase ? TextCapitalization.characters : TextCapitalization.none,
      style: const TextStyle(color: textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: labelGray,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (isObscure ?? true)
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: labelGray,
                ),
                onPressed: onToggleObscure,
              )
            : suffixIcon,
      ),
    );
  }

  // Pembuat Form Dropdown – dengan items dan callback yang proper
  Widget _buildDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: options.contains(value) ? value : options.first,
      icon: const Icon(Icons.keyboard_arrow_down, color: labelGray),
      style: const TextStyle(color: textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: labelGray,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
      ),
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
