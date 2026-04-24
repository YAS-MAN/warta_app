import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../report/report_inbox_views.dart';

class DashboardSuperAdminView extends StatelessWidget {
  const DashboardSuperAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return _AdminDashboardBase(
      role: 'super_admin',
      roleLabel: 'Super Admin',
      icon: Icons.admin_panel_settings_rounded,
      color: const Color(0xFF8B0000),
      accentColor: const Color(0xFFD4AF37),
      menuItems: const [
        _MenuItem(
          icon: Icons.people_alt_rounded,
          label: 'Manajemen Warga',
          subtitle: 'Kelola data penduduk & role',
        ),
        _MenuItem(
          icon: Icons.verified_user_rounded,
          label: 'Verifikasi Akun',
          subtitle: 'Setujui/tolak registrasi warga',
        ),
        _MenuItem(
          icon: Icons.newspaper_rounded,
          label: 'Kelola Berita',
          subtitle: 'Tambah, edit, hapus berita',
        ),
        _MenuItem(
          icon: Icons.bar_chart_rounded,
          label: 'Laporan & Statistik',
          subtitle: 'Data laporan warga',
        ),
        _MenuItem(
          icon: Icons.settings_rounded,
          label: 'Pengaturan Sistem',
          subtitle: 'Konfigurasi aplikasi',
        ),
      ],
    );
  }
}

class DashboardLurahView extends StatelessWidget {
  const DashboardLurahView({super.key});

  @override
  Widget build(BuildContext context) {
    return _AdminDashboardBase(
      role: 'lurah',
      roleLabel: 'Lurah',
      icon: Icons.account_balance_rounded,
      color: const Color(0xFF1565C0),
      accentColor: const Color(0xFF42A5F5),
      menuItems: [
        _MenuItem(
          icon: Icons.people_rounded,
          label: 'Data Warga',
          subtitle: 'Lihat data seluruh warga',
        ),
        _MenuItem(
          icon: Icons.description_rounded,
          label: 'Kelola Surat',
          subtitle: 'Persetujuan surat kelurahan',
        ),
        _MenuItem(
          icon: Icons.campaign_rounded,
          label: 'Pengumuman',
          subtitle: 'Buat pengumuman warga',
        ),
        _MenuItem(
          icon: Icons.bar_chart_rounded,
          label: 'Laporan',
          subtitle: 'Laporan wilayah',
          onTap: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LurahReportInboxView()),
            );
          },
        ),
      ],
    );
  }
}

class DashboardRtView extends StatelessWidget {
  const DashboardRtView({super.key});

  @override
  Widget build(BuildContext context) {
    return _AdminDashboardBase(
      role: 'rt',
      roleLabel: 'Ketua RT',
      icon: Icons.home_work_rounded,
      color: const Color(0xFF2E7D32),
      accentColor: const Color(0xFF66BB6A),
      menuItems: const [
        _MenuItem(
          icon: Icons.people_rounded,
          label: 'Warga RT',
          subtitle: 'Data warga dalam RT',
        ),
        _MenuItem(
          icon: Icons.description_rounded,
          label: 'Surat Pengantar',
          subtitle: 'Proses surat pengantar',
        ),
        _MenuItem(
          icon: Icons.report_problem_rounded,
          label: 'Laporan Warga',
          subtitle: 'Keluhan & laporan dari warga',
        ),
        _MenuItem(
          icon: Icons.event_rounded,
          label: 'Kegiatan RT',
          subtitle: 'Jadwal kegiatan lingkungan',
        ),
      ],
    );
  }
}

class DashboardRwView extends StatelessWidget {
  const DashboardRwView({super.key});

  @override
  Widget build(BuildContext context) {
    return _AdminDashboardBase(
      role: 'rw',
      roleLabel: 'Ketua RW',
      icon: Icons.location_city_rounded,
      color: const Color(0xFF6A1B9A),
      accentColor: const Color(0xFFAB47BC),
      menuItems: [
        _MenuItem(
          icon: Icons.people_rounded,
          label: 'Data RW',
          subtitle: 'Seluruh warga dalam RW',
        ),
        _MenuItem(
          icon: Icons.description_rounded,
          label: 'Surat Keterangan',
          subtitle: 'Proses surat keterangan RW',
        ),
        _MenuItem(
          icon: Icons.report_rounded,
          label: 'Laporan Masuk',
          subtitle: 'Laporan dari seluruh RT',
          onTap: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RwReportInboxView()),
            );
          },
        ),
        _MenuItem(
          icon: Icons.group_work_rounded,
          label: 'Koordinasi RT',
          subtitle: 'Koordinasi dengan ketua RT',
        ),
      ],
    );
  }
}

// ================================================================
// BASE WIDGET — digunakan oleh semua dashboard
// ================================================================

class _AdminDashboardBase extends StatelessWidget {
  final String role;
  final String roleLabel;
  final IconData icon;
  final Color color;
  final Color accentColor;
  final List<_MenuItem> menuItems;

  const _AdminDashboardBase({
    required this.role,
    required this.roleLabel,
    required this.icon,
    required this.color,
    required this.accentColor,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.9), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circle
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Halo, ${user?.nama.split(' ').first ?? roleLabel}!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      roleLabel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (user != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Keluar',
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                onPressed: () => _confirmLogout(context, authVM),
              ),
            ],
          ),

          // ── Menu Grid ──
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coming soon banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.construction_rounded, color: accentColor, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dashboard $roleLabel',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 14,
                                ),
                              ),
                              const Text(
                                'Fitur lengkap sedang dikembangkan',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    'Menu Utama',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Grid menu
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                    children: menuItems
                        .map((item) => _MenuCard(item: item, color: color, accentColor: accentColor))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await authVM.logout();
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final void Function(BuildContext context)? onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuItem item;
  final Color color;
  final Color accentColor;

  const _MenuCard({required this.item, required this.color, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: color.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (item.onTap != null) {
            item.onTap!(context);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.label} — Segera hadir!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
