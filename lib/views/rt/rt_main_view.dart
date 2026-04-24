import 'package:flutter/material.dart';
import 'rt_home_view.dart';
import 'rt_manajemen_view.dart';
import 'rt_approval_view.dart';
import 'rt_profil_view.dart';
import 'rt_scanner_view.dart';

class RtMainView extends StatefulWidget {
  final int initialIndex;
  const RtMainView({super.key, this.initialIndex = 0});

  @override
  State<RtMainView> createState() => _RtMainViewState();
}

class _RtMainViewState extends State<RtMainView> {
  late int _currentIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Halaman-halaman tab RT
    _pages = [
      RtHomeView(onNavigate: (index) => _setPage(index)),
      const RtManajemenView(),
      const RtApprovalView(),
      const RtProfilView(),
    ];
  }

  void _setPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // Tombol Scan Floating
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RtScannerView()),
          );
        },
        backgroundColor: const Color(0xFFD4AF37), // Emas
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, "Home", 0),
              _buildNavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, "Manajemen", 1),
              const SizedBox(width: 48), // Space untuk FAB
              _buildNavItem(Icons.fact_check_outlined, Icons.fact_check, "Approval", 2),
              _buildNavItem(Icons.person_outline, Icons.person, "Profil", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData iconOutlined, IconData iconFilled, String label, int index) {
    final isSelected = _currentIndex == index;
    final primaryRed = const Color(0xFF8B0000);
    final textGray = const Color(0xFF6B7280);

    return InkWell(
      onTap: () => _setPage(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? iconFilled : iconOutlined,
            color: isSelected ? primaryRed : textGray,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryRed : textGray,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
