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
  int _approvalSubIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _setPage(int index, [int? subIndex]) {
    setState(() {
      _currentIndex = index;
      if (index == 2 && subIndex != null) {
        _approvalSubIndex = subIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      RtHomeView(onNavigate: (index, [subIndex]) => _setPage(index, subIndex)),
      const RtManajemenView(),
      RtApprovalView(
        key: ValueKey(_approvalSubIndex),
        initialIndex: _approvalSubIndex,
      ),
      const RtProfilView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 65,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryRed.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
