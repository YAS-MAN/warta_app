import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class RtResidentsView extends StatefulWidget {
  final String kelurahan;
  final String rw;
  final String rt;

  const RtResidentsView({
    super.key,
    required this.kelurahan,
    required this.rw,
    required this.rt,
  });

  @override
  State<RtResidentsView> createState() => _RtResidentsViewState();
}

class _RtResidentsViewState extends State<RtResidentsView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildPremiumHeader(context, 'Daftar Penduduk'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) =>
                  setState(() => _searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nama / NIK warga...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: usersRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B0000)),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                final targetRt = widget.rt.trim().toLowerCase();
                final targetRw = widget.rw.trim().toLowerCase();

                final users =
                    docs.map((doc) => UserModel.fromFirestore(doc)).where((
                      user,
                    ) {
                      final userRt = (user.rt ?? '').trim().toLowerCase();
                      final userRw = (user.rw ?? '').trim().toLowerCase();
                      final role = user.role.trim().toLowerCase();

                      // Samakan perilaku dengan jadwal ronda: basis area RT/RW.
                      final isSameArea =
                          userRt == targetRt && userRw == targetRw;
                      final isWarga = role == 'warga' || role.isEmpty;
                      if (!isSameArea || !isWarga) return false;

                      if (_searchQuery.isEmpty) return true;
                      return user.nama.toLowerCase().contains(_searchQuery) ||
                          user.nik.toLowerCase().contains(_searchQuery);
                    }).toList()..sort(
                      (a, b) =>
                          a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
                    );

                if (users.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data penduduk di wilayah ini.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFFEF2F2),
                            backgroundImage:
                                (user.selfieUrl != null &&
                                    user.selfieUrl!.isNotEmpty)
                                ? NetworkImage(user.selfieUrl!)
                                : null,
                            child:
                                (user.selfieUrl == null ||
                                    user.selfieUrl!.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    color: Color(0xFF8B0000),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NIK: ${user.nik}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Alamat: ${user.alamat ?? "-"}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hapus warga',
                            onPressed: () => _confirmDeleteResident(
                              context: context,
                              usersRef: usersRef,
                              user: user,
                            ),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, String title) {
    return Container(
      height: 125,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteResident({
    required BuildContext context,
    required CollectionReference<Map<String, dynamic>> usersRef,
    required UserModel user,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data Warga'),
        content: Text(
          'Yakin hapus data ${user.nama}? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await usersRef.doc(user.uid).delete();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data ${user.nama} berhasil dihapus.'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus data warga.'),
          backgroundColor: Color(0xFF8B0000),
        ),
      );
    }
  }
}
