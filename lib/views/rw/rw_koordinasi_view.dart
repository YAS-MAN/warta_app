import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RwKoordinasiView extends StatelessWidget {
  const RwKoordinasiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildPremiumHeader(context, "Koordinasi Pengurus"),
          Expanded(child: _TabDaftarRT()),
        ],
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
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          child: Stack(
            children: [
              Positioned(
                right: -20, top: -10,
                child: Transform.rotate(
                  angle: 12 * 3.14159 / 180,
                  child: Image(image: const AssetImage('assets/images/warta_logo.png'), width: 140, height: 140, color: const Color.fromARGB(255, 58, 1, 1).withValues(alpha: 0.15)),
                ),
              ),
              Center(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabDaftarRT extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;
        if (user == null) return const SizedBox.shrink();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'rt')
              .where('kelurahan', isEqualTo: user.kelurahan)
              .where('rw', isEqualTo: user.rw)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)));
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text("Belum ada ketua RT terdaftar\ndi wilayah RW ini.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              );
            }

            final rtList = docs.map((doc) => UserModel.fromFirestore(doc)).toList()
              ..sort((a, b) => (a.rt ?? '').compareTo(b.rt ?? ''));

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: rtList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rt = rtList[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24, backgroundColor: const Color(0xFFFEF2F2),
                        backgroundImage: (rt.selfieUrl != null && rt.selfieUrl!.isNotEmpty) ? NetworkImage(rt.selfieUrl!) : null,
                        child: (rt.selfieUrl == null || rt.selfieUrl!.isEmpty) ? const Icon(Icons.person, color: Color(0xFF8B0000)) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("RT ${rt.rt ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF8B0000))),
                            Text(rt.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1F2937))),
                            Text(rt.nik, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      _buildActionBtn(Icons.chat_bubble_outline, () {}),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: const Color(0xFF6B7280), size: 20),
      ),
    );
  }
}
