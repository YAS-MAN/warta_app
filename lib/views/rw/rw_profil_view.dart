import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/cloudinary_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/auth_gate.dart';
import '../main/main_view.dart';
import 'rw_residents_view.dart';
import 'rw_approval_history_view.dart';

class RwProfilView extends StatefulWidget {
  const RwProfilView({super.key});

  @override
  State<RwProfilView> createState() => _RwProfilViewState();
}

class _RwProfilViewState extends State<RwProfilView> {
  bool _useBiometric = false;
  bool _isUploadingSignature = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBiometricState());
  }

  Future<void> _loadBiometricState() async {
    final authVM = context.read<AuthViewModel>();
    final isEnabled = await authVM.isBiometricEnabled();
    if (mounted) setState(() => _useBiometric = isEnabled);
  }

  Future<void> _showEditPhotoSheet(AuthViewModel authVM) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('Ganti Foto Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 8),
            const Text('Pilih sumber foto profil Anda', style: TextStyle(color: textGray, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildPhotoBtn(icon: Icons.camera_alt_rounded, label: 'Kamera', onTap: () => Navigator.pop(ctx, 'camera'))),
                const SizedBox(width: 16),
                Expanded(child: _buildPhotoBtn(icon: Icons.photo_library_rounded, label: 'Galeri', onTap: () => Navigator.pop(ctx, 'gallery'))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Batal', style: TextStyle(color: textGray, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    final bool success = await authVM.updateProfilePhoto(fromCamera: choice == 'camera');
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: Color(0xFF16A34A), behavior: SnackBarBehavior.floating));
    } else if (authVM.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authVM.errorMessage!), backgroundColor: primaryRed, behavior: SnackBarBehavior.floating));
    }
  }

  Widget _buildPhotoBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryRed.withValues(alpha: 0.15))),
        child: Column(
          children: [
            Icon(icon, color: primaryRed, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: primaryRed, fontWeight: FontWeight.w600, fontSize: 13)),
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
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Dialog(
          backgroundColor: Colors.transparent, elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: Text("Konfirmasi Keamanan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87))),
                const SizedBox(height: 12),
                const Text("Masukkan kata sandi Anda untuk mengaktifkan pemindai Sidik Jari / FaceID.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 16),
                TextField(
                  controller: passCtrl, obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: primaryRed), hintText: "Kata Sandi",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryRed, width: 2)),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () { Navigator.pop(ctx); setState(() => _useBiometric = false); },
                      child: const Text("BATAL", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      onPressed: () async {
                        final password = passCtrl.text;
                        if (password.isEmpty) return;
                        Navigator.pop(ctx);
                        final success = await authVM.enableBiometricWithReauth(password);
                        if (mounted) {
                          if (success) {
                            setState(() => _useBiometric = true);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Biometrik berhasil diaktifkan!"), backgroundColor: Colors.green));
                          } else {
                            setState(() => _useBiometric = false);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authVM.errorMessage ?? "Gagal mengatur biometrik"), backgroundColor: primaryRed));
                          }
                        }
                      },
                      child: const Text("VERIFIKASI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 1.5)),
          title: const Text("Keluar", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Apakah kamu yakin ingin keluar dari akun ini?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              onPressed: () async {
                Navigator.pop(ctx);
                await authVM.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthGate()), (route) => false);
                }
              },
              child: const Text("Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
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
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 16),
            const Text("Tanda Tangan Digital", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textDark)),
            const SizedBox(height: 6),
            const Text("Pilih sumber gambar tanda tangan RW", style: TextStyle(fontSize: 12, color: textGray)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildPhotoBtn(icon: Icons.camera_alt_rounded, label: "Kamera", onTap: () => Navigator.pop(ctx, "camera"))),
                const SizedBox(width: 12),
                Expanded(child: _buildPhotoBtn(icon: Icons.photo_library_rounded, label: "Galeri", onTap: () => Navigator.pop(ctx, "gallery"))),
              ],
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;
    final picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery, imageQuality: 85);
    if (imageFile == null) return;

    setState(() => _isUploadingSignature = true);
    try {
      final uploadedUrl = await _cloudinaryService.uploadImageXFile(imageFile, folder: 'rw_signatures');
      if (uploadedUrl == null || uploadedUrl.isEmpty) throw Exception('Upload gagal.');

      // For RW, we use 'rwSignatureUrl' field (need to make sure model supports it or just use a generic field)
      // Actually RT uses 'rtSignatureUrl'. Let's use 'rwSignatureUrl' for consistency.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'rwSignatureUrl': uploadedUrl});
      await authVM.loadCurrentUser(user.uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanda tangan digital berhasil diperbarui.'), backgroundColor: Color(0xFF16A34A)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan tanda tangan digital.'), backgroundColor: primaryRed));
    } finally {
      if (mounted) setState(() => _isUploadingSignature = false);
    }
  }

  Widget _buildIdentityCard(AuthViewModel authVM) {
    final user = authVM.currentUser;
    final selfieUrl = user?.selfieUrl ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primaryRed, Color(0xFF4A0000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 10))],
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
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                      ),
                      child: ClipOval(
                        child: Column(
                          children: [
                            Expanded(child: Container(color: const Color(0xFFED1C24))), // Red
                            Expanded(child: Container(color: Colors.white)), // White
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("REPUBLIK INDONESIA", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text("KARTU TANDA PENGURUS", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text("RW ${user?.rw ?? '-'}", style: const TextStyle(color: Colors.white, fontSize: 9)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text("NAMA KETUA RW", style: TextStyle(color: Colors.white70, fontSize: 9)),
            Text(user?.nama.toUpperCase() ?? '-', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 12),
            Text("NIK: ${user?.nik ?? '-'}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 24, backgroundColor: const Color(0xFFFEF2F2),
                  backgroundImage: selfieUrl.isNotEmpty ? NetworkImage(selfieUrl) : null,
                  child: selfieUrl.isEmpty ? const Icon(Icons.person, color: primaryRed) : null,
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("JABATAN", style: TextStyle(color: Colors.white70, fontSize: 8)),
                    Text("KETUA RW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? subtitle, VoidCallback? onTap, bool isLogout = false, bool isSwitch = false, bool switchValue = false, ValueChanged<bool>? onSwitchChanged}) {
    return InkWell(
      onTap: isSwitch ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: isLogout ? const Color(0xFFFEF2F2) : primaryRed.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: isLogout ? Colors.red : primaryRed, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isLogout ? Colors.red : textDark)),
                  if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 11, color: textGray))],
                ],
              ),
            ),
            if (isSwitch)
              Switch(value: switchValue, onChanged: onSwitchChanged, activeThumbColor: primaryRed)
            else if (!isLogout)
              const Icon(Icons.chevron_right, color: textGray, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: bgApp,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header (same as RT)
                Container(
                  height: 180, width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color.fromARGB(255, 83, 0, 0), primaryRed], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                    child: Stack(
                      children: [
                        Positioned(right: -20, top: -20, child: Transform.rotate(angle: 12 * 3.14159 / 180, child: Image(image: const AssetImage('assets/images/warta_logo.png'), width: 180, height: 180, color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.1)))),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Profil Pengurus", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              IconButton(onPressed: () => _showEditPhotoSheet(authVM), icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Transform.translate(offset: const Offset(0, -40), child: _buildIdentityCard(authVM)),

                const SizedBox(height: 8),

                // Signature Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tanda Tangan Digital RW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity, height: 120,
                          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor, style: BorderStyle.solid)),
                          child: _isUploadingSignature 
                            ? const Center(child: CircularProgressIndicator(color: primaryRed))
                            : (user?.rwSignatureUrl != null && user!.rwSignatureUrl!.isNotEmpty)
                              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(user.rwSignatureUrl!, fit: BoxFit.contain))
                              : Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.drive_file_rename_outline, color: Colors.grey.withValues(alpha: 0.5), size: 32), const SizedBox(height: 8), const Text("Belum ada tanda tangan", style: TextStyle(color: Colors.grey, fontSize: 11))])),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _showSignatureUploadSheet(authVM), icon: const Icon(Icons.upload, size: 16, color: Colors.white), label: const Text("Upload Tanda Tangan", style: TextStyle(color: Colors.white, fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sistem Administrasi
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Sistem Administrasi", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
                        child: Column(
                          children: [
                            _buildMenuItem(Icons.people_alt_outlined, "Daftar Penduduk RW", subtitle: "Seluruh warga dalam wilayah RW", onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => RwResidentsView(kelurahan: user?.kelurahan ?? '', rw: user?.rw ?? '')));
                            }),
                            const Divider(height: 1, color: borderColor),
                            _buildMenuItem(Icons.history_outlined, "Riwayat Persetujuan", subtitle: "Arsip laporan & surat yang ditandani", onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => RwApprovalHistoryView(kelurahan: user?.kelurahan ?? '', rw: user?.rw ?? '')));
                            }),
                            const Divider(height: 1, color: borderColor),
                            _buildMenuItem(Icons.fingerprint, "Autentikasi Biometrik", subtitle: "Login instan dengan sidik jari / FaceID", isSwitch: true, switchValue: _useBiometric, onSwitchChanged: (val) => _promptBiometricToggle(val, authVM)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text("Akses Peran", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MainView())),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF374151)]), borderRadius: BorderRadius.circular(16)),
                          child: const Row(
                            children: [
                              Icon(Icons.swap_horiz, color: Colors.white, size: 28),
                              SizedBox(width: 16),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Beralih ke Panel Warga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text("Gunakan panel reguler untuk keperluan pribadi.", style: TextStyle(color: Colors.grey, fontSize: 10))])),
                              Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)), child: _buildMenuItem(Icons.logout, "Keluar dari Aplikasi", isLogout: true, onTap: () => _showLogoutDialog(context, authVM))),
                      const SizedBox(height: 32),
                      const Center(child: Text("WARTA APP v1.0.0", style: TextStyle(color: textGray, fontSize: 10, letterSpacing: 1))),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (authVM.isLoading) Container(color: Colors.black.withValues(alpha: 0.35), child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }
}
