import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';

class EmailVerifyView extends StatefulWidget {
  final String email;
  const EmailVerifyView({super.key, required this.email});

  @override
  State<EmailVerifyView> createState() => _EmailVerifyViewState();
}

class _EmailVerifyViewState extends State<EmailVerifyView> {
  static const Color bgGray = Color(0xFFF9FAFB);
  static const Color primaryRed = Color(0xFF8B1E1E);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);
  static const Color goldColor = Color(0xFFD4AF37);

  bool _isChecking = false;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check setiap 5 detik
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkVerification(silent: true));
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification({bool silent = false}) async {
    if (_isChecking) return;
    if (!silent) setState(() => _isChecking = true);

    final authVM = context.read<AuthViewModel>();
    final verified = await authVM.checkEmailVerified();

    if (!mounted) return;
    if (!silent) setState(() => _isChecking = false);

    if (verified) {
      _autoCheckTimer?.cancel();
      await authVM.finalizeRegistration();
      if (!mounted) return;
      if (!mounted) return;
      
      // Tampilkan notifikasi sukses di ATAS menggunakan MaterialBanner
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: const Text(
            '🎉 Email terverifikasi! Silakan login.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF10B981),
          actions: [
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      // Tunggu sebentar agar user sempat baca banner sebelum pindah
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    } else if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email belum diverifikasi. Silakan cek inbox atau folder spam Anda.'),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;
    final authVM = context.read<AuthViewModel>();
    final success = await authVM.sendVerificationEmail();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email verifikasi telah dikirim ulang.'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // Start cooldown 60 seconds
      setState(() {
        _canResend = false;
        _resendCooldown = 60;
      });
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) { timer.cancel(); return; }
        setState(() => _resendCooldown--);
        if (_resendCooldown <= 0) {
          timer.cancel();
          setState(() => _canResend = true);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.errorMessage ?? 'Gagal mengirim ulang email.'),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      body: Column(
        children: [
          // HEADER
          SizedBox(
            height: 180,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180, width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 20, top: 20,
                          child: Transform.rotate(
                            angle: 12 * 3.14159 / 180,
                            child: Image(image: const AssetImage('assets/images/warta_logo.png'), width: 140, height: 140, color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.1)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text("Verifikasi Email", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
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

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Icon
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: goldColor.withValues(alpha: 0.3), width: 2),
                      ),
                      child: const Icon(Icons.mark_email_read_outlined, size: 44, color: goldColor),
                    ),
                    const SizedBox(height: 28),

                    const Text("Cek Email Anda", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textDark, letterSpacing: -0.5)),
                    const SizedBox(height: 14),

                    Text(
                      "Kami telah mengirimkan link verifikasi ke:",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: textGray, height: 1.5),
                    ),
                    const SizedBox(height: 8),

                    // Email address
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryRed.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email_outlined, color: primaryRed, size: 18),
                          const SizedBox(width: 8),
                          Flexible(child: Text(widget.email, style: const TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Langkah Verifikasi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                          const SizedBox(height: 12),
                          _buildStep("1", "Buka aplikasi email Anda (Gmail, Outlook, dll)"),
                          _buildStep("2", "Cari email dari WARTA / Firebase"),
                          _buildStep("3", "Klik link verifikasi di dalam email"),
                          _buildStep("4", "Kembali ke sini dan tekan tombol di bawah"),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 14, color: Colors.amber.shade700),
                              const SizedBox(width: 6),
                              Expanded(child: Text("Cek juga folder Spam jika email tidak ditemukan.", style: TextStyle(fontSize: 11, color: Colors.amber.shade800, fontStyle: FontStyle.italic))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // VERIFY BUTTON
                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                        onPressed: _isChecking ? null : () => _checkVerification(),
                        icon: _isChecking
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.verified_outlined, color: Colors.white),
                        label: Text(
                          _isChecking ? "MEMERIKSA..." : "SUDAH VERIFIKASI",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // RESEND BUTTON
                    SizedBox(
                      width: double.infinity, height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _canResend ? primaryRed : Colors.grey.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _canResend ? _resendEmail : null,
                        icon: Icon(Icons.refresh, color: _canResend ? primaryRed : Colors.grey, size: 18),
                        label: Text(
                          _canResend ? "KIRIM ULANG EMAIL" : "KIRIM ULANG ($_resendCooldown detik)",
                          style: TextStyle(color: _canResend ? primaryRed : Colors.grey, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(color: primaryRed.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Center(child: Text(number, style: const TextStyle(color: primaryRed, fontSize: 11, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: textGray, height: 1.4))),
        ],
      ),
    );
  }
}
