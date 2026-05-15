import 'package:flutter/material.dart';
import 'lurah_home_view.dart';
import 'lurah_koordinasi_view.dart';
import 'lurah_approval_view.dart';
import 'lurah_profil_view.dart';
import '../rt/rt_scanner_view.dart';

class LurahMainView extends StatefulWidget {
  final int initialIndex;
  const LurahMainView({super.key, this.initialIndex = 0});

  @override
  State<LurahMainView> createState() => _LurahMainViewState();
}

class _LurahMainViewState extends State<LurahMainView> {
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
      LurahHomeView(onNavigate: (index, [subIndex]) => _setPage(index, subIndex)),
      const LurahKoordinasiView(),
      LurahApprovalView(
        key: ValueKey(_approvalSubIndex),
        initialIndex: _approvalSubIndex,
      ),
      const LurahProfilView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
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
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.groups, "Koordinasi", 1),
              const SizedBox(width: 48), // Space untuk FAB
              _buildNavItem(Icons.fact_check, "Approval", 2),
              _buildNavItem(Icons.person, "Profil", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    const primaryRed = Color(0xFF8B0000);
    const textGray = Color(0xFF6B7280);

    return InkWell(
      onTap: () => _setPage(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryRed.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
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
