import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/login_view.dart';
import '../main/main_view.dart';
import '../dashboard/dashboard_super_admin_view.dart';
import '../dashboard/dashboard_lurah_view.dart';
import '../rt/rt_main_view.dart';
import '../dashboard/dashboard_rw_view.dart';

/// AuthGate: mendengarkan Firebase Auth state changes.
/// Secara otomatis mengarahkan user ke tampilan yang benar berdasarkan role.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Masih loading — tampilkan splash/loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        // Belum login → ke LoginView
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginView();
        }

        // Sudah login → load user data dari Firestore lalu route berdasarkan role
        return _RoleRouter(uid: snapshot.data!.uid);
      },
    );
  }
}

/// Widget yang memuat data user dari Firestore dan route ke dashboard yang sesuai
class _RoleRouter extends StatefulWidget {
  final String uid;
  const _RoleRouter({required this.uid});

  @override
  State<_RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<_RoleRouter> {
  @override
  void initState() {
    super.initState();
    // Load user data setelah frame pertama render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().loadCurrentUser(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;

        // Belum ada data user → loading
        if (user == null) {
          return const _SplashScreen();
        }

        // Route berdasarkan role
        switch (user.role) {
          case 'super_admin':
            return const DashboardSuperAdminView();
          case 'lurah':
            return const DashboardLurahView();
          case 'rt':
            return const RtMainView();
          case 'rw':
            return const DashboardRwView();
          default: // 'warga'
            return const MainView();
        }
      },
    );
  }
}

/// Splash screen sementara saat menunggu auth state / load data
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF8B0000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/warta_logo.png'),
              width: 100,
              height: 100,
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(height: 16),
            Text(
              'WARTA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
