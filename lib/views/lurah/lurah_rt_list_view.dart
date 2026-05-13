import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'lurah_rt_residents_view.dart';

class LurahRtListView extends StatefulWidget {
  final String kelurahan;
  final String rw;
  final String rwName;

  const LurahRtListView({
    super.key,
    required this.kelurahan,
    required this.rw,
    required this.rwName,
  });

  @override
  State<LurahRtListView> createState() => _LurahRtListViewState();
}

class _LurahRtListViewState extends State<LurahRtListView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildPremiumHeader(context, 'Daftar RT di RW ${widget.rw}'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nomor RT...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8B0000)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(child: _buildRtList()),
        ],
      ),
    );
  }

  Widget _buildRtList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'rt')
          .where('rw', isEqualTo: widget.rw)
          .where('kelurahan', isEqualTo: widget.kelurahan)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF8B0000)));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Belum ada data RT terdaftar di wilayah RW ini.'));
        }

        final rtUsers = docs.map((doc) => UserModel.fromFirestore(doc)).where((user) {
          if (_searchQuery.isEmpty) return true;
          return (user.rt ?? '').toLowerCase().contains(_searchQuery);
        }).toList()..sort((a, b) => (a.rt ?? '').compareTo(b.rt ?? ''));

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rtUsers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final rtUser = rtUsers[index];
            return _buildRtItem(rtUser);
          },
        );
      },
    );
  }

  Widget _buildRtItem(UserModel rtUser) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LurahRtResidentsView(
              kelurahan: widget.kelurahan,
              rw: widget.rw,
              rt: rtUser.rt ?? '',
              rtName: rtUser.nama,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.home_work_rounded, color: Color(0xFF8B0000)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("RT ${rtUser.rt ?? '-'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937))),
                  const SizedBox(height: 4),
                  Text("Ketua: ${rtUser.nama}", style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
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
                    Text("Ketua RW: ${widget.rwName}", style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500)),
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
