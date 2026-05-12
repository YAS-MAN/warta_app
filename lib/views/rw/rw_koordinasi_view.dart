import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user_model.dart';

class RwKoordinasiView extends StatelessWidget {
  const RwKoordinasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.5),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              child: Stack(
                children: [
                  Positioned(
                    right: -20, top: -10,
                    child: Transform.rotate(
                      angle: 12 * 3.14159 / 180,
                      child: Image(image: const AssetImage('assets/images/warta_logo.png'), width: 160, height: 160, color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: const Text("Koordinasi Pengurus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Daftar Ketua RT"),
              Tab(text: "Manajemen Wilayah"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TabDaftarRt(),
            _TabManajemenWilayah(),
          ],
        ),
      ),
    );
  }
}

class _TabDaftarRt extends StatelessWidget {
  const _TabDaftarRt();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;
        final rw = user?.rw ?? '';
        final kelurahan = user?.kelurahan ?? '';
        if (rw.isEmpty || kelurahan.isEmpty) return const Center(child: Text("Data wilayah RW belum lengkap."));

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'rt')
              .where('rw', isEqualTo: rw)
              .where('kelurahan', isEqualTo: kelurahan)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)));
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) return _buildEmptyState("Belum ada data Ketua RT\ndi bawah RW ini.");

            final rtUsers = docs.map((d) => UserModel.fromFirestore(d)).toList();
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rtUsers.length,
              itemBuilder: (context, index) {
                final rt = rtUsers[index];
                return _buildRtCard(rt);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRtCard(UserModel rt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withValues(alpha: 0.1)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24, backgroundColor: const Color(0xFFFEF2F2),
            backgroundImage: (rt.selfieUrl != null && rt.selfieUrl!.isNotEmpty) ? NetworkImage(rt.selfieUrl!) : null,
            child: (rt.selfieUrl == null || rt.selfieUrl!.isEmpty) ? const Icon(Icons.person, color: Color(0xFF8B0000)) : null,
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(rt.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937))), const SizedBox(height: 4), Text("RT ${rt.rt ?? '-'} · NIK: ${rt.nik}", style: const TextStyle(fontSize: 12, color: Colors.grey))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)), child: const Text("Aktif", style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.groups_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.3)), const SizedBox(height: 16), Text(msg, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 14))]));
  }
}

class _TabManajemenWilayah extends StatelessWidget {
  const _TabManajemenWilayah();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.analytics_outlined, size: 64, color: Color(0xFF8B0000)),
            ),
            const SizedBox(height: 24),
            const Text(
              "Manajemen Wilayah RW",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 12),
            const Text(
              "Fitur ini dirancang untuk memantau rekapitulasi data Iuran dan Jadwal Ronda dari seluruh RT di bawah naungan RW ini secara real-time.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Tahap Pengembangan",
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
