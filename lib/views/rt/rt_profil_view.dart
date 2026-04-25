import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/auth_gate.dart';
import '../main/main_view.dart';
import 'rt_residents_view.dart';
import 'rt_approval_history_view.dart';

class RtProfilView extends StatefulWidget {
  const RtProfilView({super.key});

  @override
  State<RtProfilView> createState() => _RtProfilViewState();
}

class _RtProfilViewState extends State<RtProfilView> {
  bool _useBiometric = false;
  bool _isUploadingSignature = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();

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

  /// Bottom sheet untuk memilih sumber foto profil baru
  Future<void> _showEditPhotoSheet(AuthViewModel authVM) async {
    const Color primaryRed = Color(0xFF8B0000);
    const Color textDark = Color(0xFF1F2937);
    const Color textGray = Color(0xFF6B7280);

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
              'Pilih sumber foto profil Anda',
              style: TextStyle(color: textGray, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoBtn(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    onTap: () => Navigator.pop(ctx, 'camera'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoBtn(
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
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: textGray,
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

  Widget _buildPhotoBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const Color primaryRed = Color(0xFF8B0000);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryRed.withValues(alpha: 0.15)),
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
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFF8B0000),
                    ),
                    hintText: "Kata Sandi",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF8B0000),
                        width: 2,
                      ),
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
                        backgroundColor: const Color(0xFF8B0000),
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
                                backgroundColor: Color(0xFF8B0000),
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

  Future<void> _showSignatureUploadSheet(AuthViewModel authVM) async {
    final user = authVM.currentUser;
    if (user == null) return;

    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Tanda Tangan Digital",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Pilih sumber gambar tanda tangan RT",
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoBtn(
                    icon: Icons.camera_alt_rounded,
                    label: "Kamera",
                    onTap: () => Navigator.pop(ctx, "camera"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPhotoBtn(
                    icon: Icons.photo_library_rounded,
                    label: "Galeri",
                    onTap: () => Navigator.pop(ctx, "gallery"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;
    final picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(
      source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (imageFile == null) return;

    setState(() => _isUploadingSignature = true);
    try {
      final uploadedUrl = await _cloudinaryService.uploadImageXFile(
        imageFile,
        folder: 'rt_signatures',
      );
      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        throw Exception('Upload gambar tanda tangan gagal.');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'rtSignatureUrl': uploadedUrl},
      );
      await authVM.loadCurrentUser(user.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanda tangan digital berhasil diperbarui.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan tanda tangan digital.'),
          backgroundColor: Color(0xFF8B0000),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingSignature = false);
    }
  }

  Widget _buildIdentityCard(AuthViewModel authVM) {
    final user = authVM.currentUser;
    final selfieUrl = user?.selfieUrl ?? '';
    final signatureUrl = user?.rtSignatureUrl ?? '';
    return Padding(
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
              color: Colors.black.withValues(alpha: 0.2),
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
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          "KARTU TANDA PENGURUS",
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
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "RT ${user?.rt ?? '-'} / RW ${user?.rw ?? '-'}",
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              "NAMA KETUA RT",
              style: TextStyle(color: Colors.white70, fontSize: 9),
            ),
            Text(
              user?.nama.toUpperCase() ?? '-',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "NIK: ${user?.nik ?? '-'}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFFEF2F2),
                      backgroundImage: selfieUrl.isNotEmpty
                          ? NetworkImage(selfieUrl)
                          : null,
                      child: selfieUrl.isEmpty
                          ? const Icon(Icons.person, color: Color(0xFF8B0000))
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(
                            0xFFD4AF37,
                          ).withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Text(
                        "KETUA RT",
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 70,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: signatureUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(signatureUrl, fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Text(
                            "TTD",
                            style: TextStyle(
                              color: Color(0xFF8B0000),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    const Color bgApp = Color(0xFFF8F9FA);
    const Color textDark = Color(0xFF1F2937);
    const Color textGray = Color(0xFF6B7280);
    const Color borderColor = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgApp,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 220,
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
                          right: -20,
                          top: -20,
                          child: Transform.rotate(
                            angle: 12 * 3.14159 / 180,
                            child: Image(
                              image: const AssetImage(
                                'assets/images/warta_logo.png',
                              ),
                              width: 180,
                              height: 180,
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
                          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Profil Pengurus",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _showEditPhotoSheet(authVM),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
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
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: _buildIdentityCard(authVM),
                ),
                const SizedBox(height: 8),

                // --- MENU SETTINGS PENGURUS ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sistem Administrasi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Menu List
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              Icons.edit_document,
                              "Tanda Tangan Digital",
                              subtitle:
                                  "Atur tanda tangan untuk persetujuan surat",
                              onTap: () => _showSignatureUploadSheet(authVM),
                            ),
                            const Divider(height: 1, color: borderColor),
                            _buildMenuItem(
                              Icons.people_alt_outlined,
                              "Daftar Penduduk",
                              subtitle: "Manajemen data penduduk lengkap",
                              onTap: () {
                                final activeUser = authVM.currentUser;
                                if (activeUser == null) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RtResidentsView(
                                      kelurahan: activeUser.kelurahan ?? '',
                                      rw: activeUser.rw ?? '',
                                      rt: activeUser.rt ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1, color: borderColor),
                            _buildMenuItem(
                              Icons.history_outlined,
                              "Riwayat Persetujuan",
                              subtitle:
                                  "Arsip berkas dan surat yang pernah ditangani",
                              onTap: () {
                                final activeUser = authVM.currentUser;
                                if (activeUser == null) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RtApprovalHistoryView(
                                      kelurahan: activeUser.kelurahan ?? '',
                                      rw: activeUser.rw ?? '',
                                      rt: activeUser.rt ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1, color: borderColor),
                            _buildMenuItem(
                              Icons.fingerprint,
                              "Autentikasi Biometrik",
                              subtitle:
                                  "Akses login ke panel pengurus secara instan",
                              isSwitch: true,
                              switchValue: _useBiometric,
                              onSwitchChanged: (val) {
                                _promptBiometricToggle(val, authVM);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        "Akses Peran",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ROLE SWITCHER BUTTON
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MainView()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1F2937), Color(0xFF374151)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                color: Colors.white,
                                size: 28,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Beralih ke Panel Warga",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "Gunakan panel reguler untuk keperluan pribadi.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // BOX MENU KELUAR
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildMenuItem(
                          Icons.logout,
                          "Keluar dari Aplikasi",
                          isLogout: true,
                          onTap: () {
                            _showLogoutDialog(context, authVM);
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                      // VERSI APLIKASI
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
                ),
              ],
            ),
          ),
          // Loading overlay saat upload foto
          if (authVM.isLoading || _isUploadingSignature)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
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
                      'Menyimpan perubahan...',
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
  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? subtitle,
    bool isLogout = false,
    bool isSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    const primaryRed = Color(0xFF8B0000);
    const textDark = Color(0xFF1F2937);
    const textGray = Color(0xFF6B7280);

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
                    ? primaryRed.withValues(alpha: 0.1)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryRed, size: 18),
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
                activeThumbColor: primaryRed,
                activeTrackColor: primaryRed.withValues(alpha: 0.4),
              )
            else if (!isLogout)
              const Icon(Icons.chevron_right, color: textGray, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
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
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
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
                        backgroundColor: const Color(0xFF8B0000),
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
                        await authVM.logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AuthGate()),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text(
                        "KELUAR",
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
}
