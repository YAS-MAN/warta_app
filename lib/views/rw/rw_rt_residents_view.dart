import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class RwRtResidentsView extends StatefulWidget {
  final String kelurahan;
  final String rw;
  final String rt;
  final String rtName;

  const RwRtResidentsView({
    super.key,
    required this.kelurahan,
    required this.rw,
    required this.rt,
    required this.rtName,
  });

  @override
  State<RwRtResidentsView> createState() => _RwRtResidentsViewState();
}

class _RwRtResidentsViewState extends State<RwRtResidentsView> {
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
          _buildPremiumHeader(context, 'Warga RT ${widget.rt}'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nama / NIK...',
                prefixIcon: const Icon(Icons.search),
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
                  // Show only 'warga' or empty role (usually warga)
                  if (role != 'warga' && role != '') return false;
                  
                  if (_searchQuery.isEmpty) return true;
                  return user.nama.toLowerCase().contains(_searchQuery) || user.nik.toLowerCase().contains(_searchQuery);
                }).toList()..sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));

                if (users.isEmpty) {
                  return const Center(child: Text('Tidak ada data warga di RT ini.'));
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
    );
  }

  Widget _buildUserCard(UserModel user) {
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
            backgroundImage: (user.selfieUrl != null && user.selfieUrl!.isNotEmpty) ? NetworkImage(user.selfieUrl!) : null,
            child: (user.selfieUrl == null || user.selfieUrl!.isEmpty) ? const Icon(Icons.person, color: Color(0xFF8B0000)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937))),
                const SizedBox(height: 4),
                Text('NIK: ${user.nik}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                Text('Alamat: ${user.alamat ?? "-"}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
              ],
            ),
          ),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
          child: Row(
            children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    Text("Ketua: ${widget.rtName}", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
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
