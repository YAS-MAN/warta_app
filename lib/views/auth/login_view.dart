import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgGray = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFD1D5DB);
  static const Color goldColor = Color(0xFFB8860B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRememberMe();
    });
  }

  Future<void> _loadRememberMe() async {
    final authVM = context.read<AuthViewModel>();
    final data = await authVM.getRememberMe();
    if (mounted) {
      setState(() {
        _rememberMe = data['isEnabled'] == true;
        if (_rememberMe) {
          _emailCtrl.text = data['email'] ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String loginId = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (loginId.isEmpty || password.isEmpty) {
      _showSnackbar('Email/Nama dan password tidak boleh kosong.');
      return;
    }

    if (!loginId.contains('@')) {
      loginId = loginId.toUpperCase();
    }

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.login(loginId, password);

    if (!mounted) return;
    if (success) {
      await authVM.saveRememberMe(loginId, _rememberMe);
    } else {
      _showSnackbar(authVM.errorMessage ?? 'Login gagal.');
    }
  }

  Future<void> _loginBiometric() async {
    final authVM = context.read<AuthViewModel>();
    final success = await authVM.loginBiometric();

    if (!mounted) return;
    if (!success) {
      _showSnackbar(authVM.errorMessage ?? 'Gagal masuk via biometrik.');
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showForgotPasswordSheet() {
    final TextEditingController resetEmailCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Lupa Kata Sandi?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Masukkan alamat email Anda yang terdaftar. Kami akan mengirimkan tautan untuk mengatur ulang kata sandi.",
                  style: TextStyle(color: textGray, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: resetEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: primaryRed),
                    hintText: "Alamat Email Anda",
                    hintStyle: const TextStyle(color: textGray, fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: primaryRed, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Consumer<AuthViewModel>(
                    builder: (context, authVM, _) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: authVM.isLoading
                            ? null
                            : () async {
                                final email = resetEmailCtrl.text.trim();
                                if (email.isEmpty) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(content: Text("Isi email terlebih dahulu")));
                                  return;
                                }

                                final success = await authVM.resetPassword(email);
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  if (success) {
                                    _showSnackbar("Email reset password berhasil dikirim.");
                                  } else {
                                    _showSnackbar(authVM.errorMessage ?? "Gagal reset.");
                                  }
                                }
                              },
                        child: authVM.isLoading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Kirim Tautan Reset",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Layer 1: Lengkungan Emas
            Container(
              height: 325,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: goldColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(400, 80),
                ),
              ),
            ),
            // Layer 2: Lengkungan Merah
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8B0000), Color(0xFF660000)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(400, 80),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Image(
                    image: AssetImage('assets/images/warta_logo.png'),
                    width: 120,
                    height: 120,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "WARTA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),

            // Kotak Form Login
            Padding(
              padding: const EdgeInsets.only(top: 250, left: 24, right: 24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Consumer<AuthViewModel>(
                  builder: (context, authVM, _) {
                    return Column(
                      children: [
                        const Text(
                          "Selamat Datang Kembali",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Input Email/Username
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: primaryRed,
                            ),
                            hintText: "Email / Nama Pengguna",
                            hintStyle: const TextStyle(color: textGray, fontSize: 16),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: primaryRed, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Input Password
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: primaryRed),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: textGray,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            hintText: "Password",
                            hintStyle: const TextStyle(color: textGray, fontSize: 16),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: primaryRed, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Opsi Remember Me & Lupa Sandi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (val) {
                                      setState(() => _rememberMe = val ?? false);
                                    },
                                    activeColor: primaryRed,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text("Ingat Saya", style: TextStyle(fontSize: 12, color: textDark)),
                              ],
                            ),
                            TextButton(
                              onPressed: _showForgotPasswordSheet,
                              child: const Text(
                                "Lupa Sandi?",
                                style: TextStyle(color: primaryRed, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Tombol MASUK & Fingerprint
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 5,
                                    shadowColor: primaryRed.withValues(alpha: 0.5),
                                  ),
                                  onPressed: authVM.isLoading ? null : _login,
                                  child: authVM.isLoading
                                      ? const SizedBox(
                                          width: 22, height: 22,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : const Text(
                                          "MASUK",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Fingerprint Button
                            SizedBox(
                              height: 56,
                              width: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: const Color(0xFFFEF2F2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: primaryRed, width: 1.5),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: authVM.isLoading ? null : _loginBiometric,
                                child: const Icon(Icons.fingerprint, color: primaryRed, size: 28),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          "Warga baru? Silakan daftar.",
                          style: TextStyle(color: textGray, fontSize: 14),
                        ),
                        const SizedBox(height: 16),

                        // Tombol SCAN KTP (Emas Outline)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: goldColor,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: authVM.isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterView(),
                                      ),
                                    );
                                  },
                            child: const Text(
                              "SCAN KTP UNTUK DAFTAR",
                              style: TextStyle(
                                color: goldColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                letterSpacing: 0.35,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
