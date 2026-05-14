import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';
import '../../utils/top_notification.dart';

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
      
      // Tampilkan notifikasi sukses menggunakan TopNotification
      TopNotification.show(
        context: context,
        message: '🎉 Email terverifikasi! Silakan login.',
        isSuccess: true,
      );

      // Tunggu sebentar agar user sempat baca notifikasi sebelum pindah
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    } else if (!silent) {
      TopNotification.show(
        context: context,
        message: 'Email belum diverifikasi. Silakan cek inbox atau folder spam Anda.',
        isError: true,
      );
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;
    final authVM = context.read<AuthViewModel>();
    final success = await authVM.sendVerificationEmail();
    if (!mounted) return;

    if (success) {
      TopNotification.show(
        context: context,
        message: 'Email verifikasi telah dikirim ulang.',
        isSuccess: true,
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
      TopNotification.show(
        context: context,
        message: authVM.errorMessage ?? 'Gagal mengirim ulang email.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      body: Column(
        children: [
          // HEADER - Reduced height
          Container(
            height: 140, // Reduced from 180
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
                  right: -20, top: -20,
                  child: Transform.rotate(
                    angle: 12 * 3.14159 / 180,
                    child: Image(image: const AssetImage('assets/images/warta_logo.png'), width: 120, height: 120, color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.1)),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 60, 24, 0),
                  child: Text("Verifikasi Email", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute content
                children: [
                  Column(
                    children: [
                      const Text("Cek Email Anda", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      const Text(
                        "Kami telah mengirimkan link verifikasi ke:",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: textGray, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),

                      // Adjusted Email Icon / Placeholder (Balanced)
                      Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F1), // Light pink
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryRed.withValues(alpha: 0.1), width: 1.5),
                        ),
                        child: const Icon(Icons.mail_outline_rounded, size: 36, color: primaryRed),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.email,
                        style: const TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),

                  // Instructions Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Langkah Verifikasi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                        const SizedBox(height: 16),
                        _buildStep("1", "Buka aplikasi email Anda (Gmail, Outlook, dll)"),
                        _buildStep("2", "Cari email dari WARTA / Firebase"),
                        _buildStep("3", "Klik link verifikasi di dalam email"),
                        _buildStep("4", "Kembali ke sini dan tekan tombol di bawah"),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            Expanded(child: Text("Cek juga folder Spam jika email tidak ditemukan.", style: TextStyle(fontSize: 11, color: Colors.amber.shade800, fontStyle: FontStyle.italic))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // BUTTONS
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: _isChecking ? null : () => _checkVerification(),
                          icon: _isChecking
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.check_circle_outline, color: Colors.white),
                          label: Text(
                            _isChecking ? "MEMERIKSA..." : "SUDAH VERIFIKASI",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity, height: 52,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _canResend ? primaryRed : Colors.grey.shade300, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _canResend ? _resendEmail : null,
                          icon: Icon(Icons.refresh_rounded, color: _canResend ? primaryRed : Colors.grey, size: 20),
                          label: Text(
                            _canResend ? "KIRIM ULANG EMAIL" : "KIRIM ULANG ($_resendCooldown d)",
                            style: TextStyle(color: _canResend ? primaryRed : Colors.grey, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
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
