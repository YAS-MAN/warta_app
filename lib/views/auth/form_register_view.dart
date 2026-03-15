import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'photo_verif_view.dart';

class FormRegistView extends StatefulWidget {
  final Map<String, String> prefilledData;
  const FormRegistView({super.key, this.prefilledData = const {}});

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
  late final TextEditingController _ttlCtrl;
  late final TextEditingController _alamatCtrl;

  bool get _hasOcrData => widget.prefilledData.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Pre-fill dari hasil OCR jika ada
    _nikCtrl = TextEditingController(text: widget.prefilledData['nik'] ?? '');
    _namaCtrl = TextEditingController(text: widget.prefilledData['nama'] ?? '');
    _ttlCtrl = TextEditingController(text: widget.prefilledData['ttl'] ?? '');
    _alamatCtrl = TextEditingController(text: widget.prefilledData['alamat'] ?? '');
  }

  @override
  void dispose() {
    _nikCtrl.dispose();
    _namaCtrl.dispose();
    _ttlCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryRed.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: primaryRed,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "[FOTO_KTP_USER]",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const Text(
                              "KETUK UNTUK UNGGAH FOTO KTP",
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
                  if (_hasOcrData) ...
                    [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Data berhasil terbaca dari KTP. Harap periksa kembali sebelum melanjutkan.",
                                style: TextStyle(color: Color(0xFF166534), fontSize: 12, height: 1.4),
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
                  _buildTextField("NAMA LENGKAP", "", controller: _namaCtrl),
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField("TEMPAT / TGL LAHIR", widget.prefilledData['ttl'] ?? "", controller: _ttlCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField("TGL LAHIR", ""),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown("JENIS KELAMIN", widget.prefilledData['jenis_kelamin']?.isNotEmpty == true ? widget.prefilledData['jenis_kelamin']! : "-"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("GOL. DARAH", widget.prefilledData['gol_darah'] ?? "")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("AGAMA", widget.prefilledData['agama'] ?? ""),
                  const SizedBox(height: 16),
                  _buildDropdown("STATUS PERKAWINAN", widget.prefilledData['status_perkawinan']?.isNotEmpty == true ? widget.prefilledData['status_perkawinan']! : "-"),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField("KEWARGANEGARAAN", widget.prefilledData['kewarganegaraan'] ?? ""),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField("PEKERJAAN", widget.prefilledData['pekerjaan'] ?? ""),
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
                      Expanded(child: _buildTextField("RT", widget.prefilledData['rt'] ?? "")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("RW", widget.prefilledData['rw'] ?? "")),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField("KELURAHAN", widget.prefilledData['kelurahan'] ?? ""),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField("KECAMATAN", widget.prefilledData['kecamatan'] ?? ""),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("KABUPATEN/KOTA", widget.prefilledData['kabupaten'] ?? ""),

                  const SizedBox(height: 32),

                  // --- SECTION: DATA AKUN ---
                  _buildSectionHeader(
                    Icons.account_circle_outlined,
                    "DATA AKUN",
                  ),
                  _buildTextField("EMAIL", ""),
                  const SizedBox(height: 16),
                  _buildTextField(
                    "BUAT PASSWORD",
                    "",
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PhotoVerifView(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "SIMPAN & LANJUT",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
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
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      maxLines: maxLines,
      obscureText: isObscure ?? false,
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
            : null,
      ),
    );
  }

  // Pembuat Form Dropdown
  Widget _buildDropdown(String label, String initialValue) {
    return DropdownButtonFormField<String>(
      value: initialValue,
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
      items: [
        DropdownMenuItem(value: initialValue, child: Text(initialValue)),
        // Tambahkan item lain di sini nanti
      ],
      onChanged: (value) {},
    );
  }
}
