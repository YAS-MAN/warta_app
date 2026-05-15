import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/top_notification.dart';

class LurahRtResidentsView extends StatefulWidget {
  final String kelurahan;
  final String rw;
  final String rt;
  final String rtName;

  const LurahRtResidentsView({
    super.key,
    required this.kelurahan,
    required this.rw,
    required this.rt,
    required this.rtName,
  });

  @override
  State<LurahRtResidentsView> createState() => _LurahRtResidentsViewState();
}

class _LurahRtResidentsViewState extends State<LurahRtResidentsView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _isUpdating = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateUserRole(UserModel user, String newRole) async {
    if (user.role == newRole) return; // No change needed

    setState(() => _isUpdating = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'role': newRole,
      });
      if (mounted) {
        TopNotification.show(
          context: context,
          message: 'Peran ${user.nama} berhasil diubah menjadi ${newRole.toUpperCase()}.',
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        TopNotification.show(
          context: context,
          message: 'Gagal mengubah peran: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _showRoleAssignmentSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 48, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Atur Peran Warga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              Text("Pilih hak akses / jabatan untuk ${user.nama}", style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(height: 20),

              // Options
              _buildRoleOption(
                context: context,
                user: user,
                roleValue: 'warga',
                title: 'Warga Regular',
                subtitle: 'Akses standar penduduk RT/RW',
                icon: Icons.person_outline_rounded,
                iconColor: Colors.grey.shade700,
              ),
              const SizedBox(height: 10),
              _buildRoleOption(
                context: context,
                user: user,
                roleValue: 'rt',
                title: 'Ketua RT',
                subtitle: 'Memberikan akses verifikasi surat & warga tingkat RT',
                icon: Icons.home_work_rounded,
                iconColor: const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 10),
              _buildRoleOption(
                context: context,
                user: user,
                roleValue: 'rw',
                title: 'Ketua RW',
                subtitle: 'Memberikan akses verifikasi surat tingkat RW',
                icon: Icons.location_city_rounded,
                iconColor: const Color(0xFF6A1B9A),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleOption({
    required BuildContext context,
    required UserModel user,
    required String roleValue,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = user.role.trim().toLowerCase() == roleValue;
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _updateUserRole(user, roleValue);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF8B0000) : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isSelected ? const Color(0xFF8B0000) : const Color(0xFF1F2937))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF8B0000))
            else
              const Icon(Icons.circle_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          Column(
            children: [
              _buildPremiumHeader(context, 'Warga RT ${widget.rt}'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama / NIK...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8B0000)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: usersRef
                      .where('kelurahan', isEqualTo: widget.kelurahan)
                      .where('rw', isEqualTo: widget.rw)
                      .where('rt', isEqualTo: widget.rt)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    
                    final users = docs.map((doc) => UserModel.fromFirestore(doc)).where((user) {
                      final role = user.role.trim().toLowerCase();
                      // Tampilkan warga, rt, dan rw agar Lurah bisa melihat/mengubah semuanya
                      if (role != 'warga' && role != 'rt' && role != 'rw' && role != '') return false;
                      
                      if (_searchQuery.isEmpty) return true;
                      return user.nama.toLowerCase().contains(_searchQuery) || user.nik.toLowerCase().contains(_searchQuery);
                    }).toList()..sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));

                    if (users.isEmpty) {
                      return const Center(child: Text('Tidak ada data warga terdaftar di RT ini.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildUserCard(user);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isUpdating)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B0000)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final role = user.role.trim().toLowerCase();
    Color badgeBg = Colors.grey.shade100;
    Color badgeText = Colors.grey.shade700;
    String badgeLabel = 'Warga';

    if (role == 'rt') {
      badgeBg = const Color(0xFFE8F5E9);
      badgeText = const Color(0xFF2E7D32);
      badgeLabel = 'Ketua RT';
    } else if (role == 'rw') {
      badgeBg = const Color(0xFFF3E5F5);
      badgeText = const Color(0xFF6A1B9A);
      badgeLabel = 'Ketua RW';
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      borderOnForeground: true,
      child: InkWell(
        onTap: () => _showRoleAssignmentSheet(user),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFFEF2F2),
                backgroundImage: (user.selfieUrl != null && user.selfieUrl!.isNotEmpty) ? NetworkImage(user.selfieUrl!) : null,
                child: (user.selfieUrl == null || user.selfieUrl!.isEmpty) ? const Icon(Icons.person, color: Color(0xFF8B0000)) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(user.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                          child: Text(badgeLabel, style: TextStyle(color: badgeText, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('NIK: ${user.nik}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                    Text('Alamat: ${user.alamat ?? "-"}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.edit_note_rounded, color: Color(0xFF8B0000), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, String title) {
    return Container(
      height: 125, width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
          child: Row(
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 2),
                    Text("Ketua RT: ${widget.rtName}", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
