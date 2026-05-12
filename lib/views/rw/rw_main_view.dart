import 'package:flutter/material.dart';
import 'rw_home_view.dart';
import 'rw_koordinasi_view.dart';
import 'rw_approval_view.dart';
import 'rw_profil_view.dart';

class RwMainView extends StatefulWidget {
  final int initialIndex;
  const RwMainView({super.key, this.initialIndex = 0});

  @override
  State<RwMainView> createState() => _RwMainViewState();
}

class _RwMainViewState extends State<RwMainView> {
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
      RwHomeView(onNavigate: (index, [subIndex]) => _setPage(index, subIndex)),
      const RwKoordinasiView(),
      RwApprovalView(
        key: ValueKey(_approvalSubIndex),
        initialIndex: _approvalSubIndex,
      ),
      const RwProfilView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, "Home", 0),
              _buildNavItem(Icons.groups_outlined, Icons.groups, "Koordinasi", 1),
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
    const primaryRed = Color(0xFF8B0000);
    const textGray = Color(0xFF6B7280);

    return InkWell(
      onTap: () => _setPage(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 70,
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
