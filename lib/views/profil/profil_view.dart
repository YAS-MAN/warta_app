import 'package:flutter/material.dart';

import 'profil_detail_view.dart';
import 'iuran_view.dart';
import 'jadwal_ronda_view.dart';
import 'bantuan_view.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/auth_gate.dart';
import 'package:qr_flutter/qr_flutter.dart';

const Color primaryRed = Color(0xFF8B0000);
const Color bgApp = Color(0xFFF8F9FA);
const Color textDark = Color(0xFF0F172A);
const Color textGray = Color(0xFF94A3B8);
const Color goldColor = Color(0xFFD4AF37);
const Color borderColor = Color(0xFFF1F5F9);

class ProfilView extends StatefulWidget {
  final Function(int)? onNavigate;
  const ProfilView({super.key, this.onNavigate});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  bool _useBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBiometricState();
    });
  }

  Future<void> _loadBiometricState() async {
    final authVM = context.read<AuthViewModel>();
    final isEnabled = await authVM.isBiometricEnabled();
    if (mounted) {
      setState(() => _useBiometric = isEnabled);
    }
  }

  void _promptBiometricToggle(bool turnOn, AuthViewModel authVM) {
    if (!turnOn) {
      authVM.disableBiometric();
      setState(() => _useBiometric = false);
      return;
    }

    final TextEditingController passCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Konfirmasi Keamanan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Masukkan kata sandi Anda untuk mengaktifkan pemindai Sidik Jari / FaceID.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: primaryRed),
                    hintText: "Kata Sandi",
                    hintStyle: const TextStyle(color: textGray, fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: primaryRed, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(
                          () => _useBiometric = false,
                        ); // reset UI switch back to off
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "BATAL",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        final password = passCtrl.text;
                        if (password.isEmpty) return;

                        Navigator.pop(ctx);

                        final success = await authVM.enableBiometricWithReauth(
                          password,
                        );
                        if (mounted) {
                          if (success) {
                            setState(() => _useBiometric = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Biometrik berhasil diaktifkan!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            setState(() => _useBiometric = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  authVM.errorMessage ??
                                      "Gagal mengatur biometrik",
                                ),
                                backgroundColor: primaryRed,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "VERIFIKASI",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom sheet untuk memilih sumber foto profil baru
  Future<void> _showEditPhotoSheet(
    BuildContext context,
    AuthViewModel authVM,
  ) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ganti Foto Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih sumber foto baru Anda',
              style: TextStyle(color: textGray, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoSourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    onTap: () => Navigator.pop(ctx, 'camera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoSourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    onTap: () => Navigator.pop(ctx, 'gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: const Color.fromARGB(255, 155, 0, 0),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (choice == null || !mounted) return;

    final bool success = await authVM.updateProfilePhoto(
      fromCamera: choice == 'camera',
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui!'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (authVM.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage!),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildPhotoSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryRed.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryRed, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: primaryRed,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQRCodeBottomSheet(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final uid = authVM.currentUser?.uid ?? 'UNKNOWN_USER';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "QR Code ID Digital",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tunjukkan kode ini untuk keperluan verifikasi",
                style: TextStyle(color: textGray, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: uid,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Tutup",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: bgApp,
        body: Center(child: Text("Data pengguna tidak ditemukan.")),
      );
    }

    return Scaffold(
      backgroundColor: bgApp,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 60),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ==========================================
                // 1. BACKGROUND MERAH MELENGKUNG (GRADASI & WATERMARK)
                // ==========================================
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    // Menerapkan Gradasi yang lebih terang dari kartu E-KTP
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 83, 0, 0),
                        Color(
                          0xFF8B0000,
                        ), // Merah gelap (sama seperti primaryRed)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                  // ClipRRect agar watermark tidak keluar dari lengkungan
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                    child: Stack(
                      children: [
                        // --- Watermark Icon ---
                        Positioned(
                          right: 10,
                          top: 20, // Disesuaikan agar posisinya pas di atas
                          child: Transform.rotate(
                            angle: 12 * 3.14159 / 180,
                            child: Image(
                              // TODO: Pastikan pakai ikon yang nyambung dengan Profil
                              image: const AssetImage(
                                'assets/icons/ic_user_after.png',
                              ),
                              width: 180,
                              height: 180,
                              color: const Color.fromARGB(
                                255,
                                58,
                                1,
                                1,
                              ).withOpacity(0.1), // Transparansi halus
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==========================================
                // 2. KONTEN UTAMA
                // ==========================================
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER: JUDUL & PENGATURAN ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Profil Saya",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfilDetailView(
                                    menuName: "Pengaturan Akun",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- INFO PROFIL (FOTO, NAMA, NIK) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          // Foto Profil dengan Indikator Online Hijau + Tombol Ganti Foto
                          GestureDetector(
                            onTap: () => _showEditPhotoSheet(context, authVM),
                            child: Stack(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: goldColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child:
                                        (user.selfieUrl != null &&
                                            user.selfieUrl!.isNotEmpty)
                                        ? Image.network(
                                            user.selfieUrl!,
                                            fit: BoxFit.cover,
                                            width: 66,
                                            height: 66,
                                            loadingBuilder: (_, child, progress) {
                                              if (progress == null)
                                                return child;
                                              return const CircleAvatar(
                                                backgroundColor: Colors.white,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: primaryRed,
                                                      strokeWidth: 2,
                                                    ),
                                              );
                                            },
                                            errorBuilder: (_, __, ___) =>
                                                const CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          )
                                        : const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                                // Indikator online
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primaryRed,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Teks Profil
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.nama,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: goldColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: goldColor.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.verified_user,
                                      color: goldColor,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      user.role.toUpperCase(),
                                      style: const TextStyle(
                                        color: goldColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- KARTU E-KTP DIGITAL ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B0000), Color(0xFF4A0000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(30),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                        30,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "REPUBLIK INDONESIA",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "KARTU TANDA PENDUDUK",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "RT ${user.rt ?? '-'} / RW ${user.rw ?? '-'}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "NOMOR INDUK KEPENDUDUKAN",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                              ),
                            ),
                            Text(
                              user.nik.replaceAllMapped(
                                RegExp(r".{4}"),
                                (match) => "${match.group(0)} ",
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "TEMPAT/TGL LAHIR",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 8,
                                          ),
                                        ),
                                        Text(
                                          "${(user.tempatLahir ?? '-').toUpperCase()}, ${user.tanggalLahir ?? '-'}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "JENIS KELAMIN",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 8,
                                          ),
                                        ),
                                        Text(
                                          (user.jenisKelamin ?? '-')
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Kotak QR Code
                                InkWell(
                                  onTap: () => _showQRCodeBottomSheet(context),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.qr_code_2,
                                        color: Colors.black,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- QUICK ACTIONS (Iuran, Jadwal Ronda, Bantuan) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const IuranView(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildQuickAction(
                                Icons.payments_outlined,
                                const Color(0xFF8B0000),
                                const Color(0xFFFEF2F2),
                                "Iuran",
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const JadwalRondaView(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildQuickAction(
                                Icons.security_outlined,
                                const Color(0xFF3B82F6),
                                const Color(0xFFEFF6FF),
                                "Jadwal Ronda",
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BantuanView(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildQuickAction(
                                Icons.help_outline,
                                const Color(0xFF16A34A),
                                const Color(0xFFDCFCE7),
                                "Bantuan",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- AKUN & KEAMANAN ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "AKUN & KEAMANAN",
                            style: TextStyle(
                              color: textGray,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem(
                                  Icons.person_outline,
                                  "Informasi Pribadi",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProfilDetailView(
                                          menuName: "Edit Informasi Pribadi",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1, color: borderColor),
                                _buildMenuItem(
                                  Icons.lock_outline,
                                  "Ubah PIN Keamanan",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProfilDetailView(
                                          menuName: "Ubah PIN Keamanan",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1, color: borderColor),
                                _buildMenuItem(
                                  Icons.fingerprint,
                                  "Biometrik Login",
                                  subtitle: "Gunakan Face ID atau Sidik Jari",
                                  isSwitch: true,
                                  switchValue: _useBiometric,
                                  onSwitchChanged: (val) {
                                    _promptBiometricToggle(
                                      val,
                                      context.read<AuthViewModel>(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- LAINNYA ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "LAINNYA",
                            style: TextStyle(
                              color: textGray,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                _buildMenuItem(
                                  Icons.description_outlined,
                                  "Syarat & Ketentuan",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProfilDetailView(
                                          menuName: "Syarat & Ketentuan",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1, color: borderColor),

                                // ROLE SWITCHER (PETUGAS)
                                if (user.role != 'warga') ...[
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const AuthGate(),
                                        ),
                                        (route) => false,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF1F2937),
                                            Color(0xFF374151),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.admin_panel_settings,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Kembali ke Panel Aparatur",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Text(
                                                  "Tutup mode penduduk reguler.",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1, color: borderColor),
                                ],

                                _buildMenuItem(
                                  Icons.logout,
                                  "Keluar dari Aplikasi",
                                  isLogout: true,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      builder: (context) => BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 12,
                                          sigmaY: 12,
                                        ),
                                        child: Dialog(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.6,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.8,
                                                ),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.05),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  "Konfirmasi Logout",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                const Text(
                                                  "Apakah Anda yakin ingin keluar dari sesi aplikasi WARTA Anda saat ini?",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(height: 32),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      style: TextButton.styleFrom(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 12,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        "BATAL",
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            primaryRed,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 24,
                                                              vertical: 12,
                                                            ),
                                                      ),
                                                      onPressed: () async {
                                                        final authVM = context
                                                            .read<
                                                              AuthViewModel
                                                            >();
                                                        await authVM.logout();

                                                        if (context.mounted) {
                                                          Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const AuthGate(),
                                                            ),
                                                            (route) => false,
                                                          );
                                                        }
                                                      },
                                                      child: const Text(
                                                        "KELUAR",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- VERSI APLIKASI ---
                    const Center(
                      child: Text(
                        "WARTA APP v1.0.0",
                        style: TextStyle(
                          color: textGray,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
          // Loading overlay saat upload foto profil
          if (authVM.isLoading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Mengupload foto...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Tombol Aksi Cepat (Bulat)
  Widget _buildQuickAction(
    IconData icon,
    Color iconColor,
    Color bgColor,
    String label,
  ) {
    return Column(
      children: [
        Container(
          width: 60, // Diperbesar dari 50
          height: 60, // Diperbesar dari 50
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18), // Disesuaikan
          ),
          child: Icon(icon, color: iconColor, size: 28), // Diperbesar dari 24
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: textDark,
            fontSize: 12, // Diperbesar dari 11
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Baris Menu List (ListTile Custom)
  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? subtitle,
    bool isSwitch = false,
    bool switchValue = false,
    Function(bool)? onSwitchChanged,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isSwitch ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLogout
                    ? primaryRed.withOpacity(0.1)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isLogout ? primaryRed : primaryRed,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isLogout ? primaryRed : textDark,
                      fontSize: 14,
                      fontWeight: isLogout ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: textGray, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
            if (isSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: Colors.white,
                activeTrackColor: primaryRed,
              )
            else if (!isLogout)
              const Icon(Icons.chevron_right, color: textGray, size: 20),
          ],
        ),
      ),
    );
  }
}
