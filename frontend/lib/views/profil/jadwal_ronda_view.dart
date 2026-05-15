import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/ronda_model.dart';
import '../../services/ronda_service.dart';

class JadwalRondaView extends StatelessWidget {
  const JadwalRondaView({super.key});

  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final rt = user?.rt ?? '';
    final rw = user?.rw ?? '';
    final rondaService = RondaService();

    return Scaffold(
      backgroundColor: bgApp,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FutureBuilder(
              future: Future.wait([
                rondaService.getRondaEnabled(rt: rt, rw: rw),
                rondaService.getSchedulesByArea(rt: rt, rw: rw),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryRed),
                  );
                }

                final enabled = (snapshot.data?[0] as bool?) ?? false;
                if (!enabled) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFF475569)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Jadwal ronda belum diaktifkan untuk wilayah ini.",
                                  style: TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          "RT $rt / RW $rw",
                          style: const TextStyle(
                            color: textGray,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Jika wilayah Anda tidak menerapkan ronda, ini normal. "
                          "Jika seharusnya ada jadwal, Ketua RT dapat mengaktifkannya dari menu Manajemen.",
                          style: TextStyle(color: textGray, fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  );
                }

                final jadwalList = (snapshot.data?[1] as List<RondaScheduleModel>?) ?? <RondaScheduleModel>[];
                if (jadwalList.isEmpty) {
                  return const Center(child: Text("Belum ada jadwal ronda untuk RT Anda."));
                }

                final nextJadwal = jadwalList.first;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF97316).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: Color(0xFFF97316),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Jadwal ronda terdekat: ${_formatDate(nextJadwal.tanggal)} di ${nextJadwal.lokasi}.",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9A3412),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Jadwal RT $rt / RW $rw",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textGray,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...jadwalList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final jadwal = entry.value;
                        final hari = _weekdayName(jadwal.tanggal.weekday);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () => _showDetailRonda(context, hari, _formatDate(jadwal.tanggal), jadwal),
                            borderRadius: BorderRadius.circular(16),
                            child: _buildJadwalCard(
                              "$hari, ${_formatDate(jadwal.tanggal)}",
                              "${jadwal.lokasi} • ${jadwal.anggota.join(', ')}",
                              index == 0,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailRonda(BuildContext context, String hari, String tanggal, RondaScheduleModel jadwal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(Icons.security, color: primaryRed, size: 48),
            const SizedBox(height: 16),
            Text("$hari, $tanggal", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Lokasi Kumpul:", style: TextStyle(fontWeight: FontWeight.bold, color: textGray)),
            Text(jadwal.lokasi, style: const TextStyle(fontSize: 16, color: textDark)),
            const SizedBox(height: 16),
            const Text("Petugas Ronda:", style: TextStyle(fontWeight: FontWeight.bold, color: textGray)),
            const SizedBox(height: 8),
            ...jadwal.anggota.map((nama) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: primaryRed),
                  const SizedBox(width: 8),
                  Text(nama, style: const TextStyle(fontSize: 14)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Transform.rotate(
                      angle: 12 * 3.14159 / 180,
                      child: Image(
                        image: const AssetImage('assets/icons/ic_document_after.png'),
                        width: 140,
                        height: 140,
                        color: const Color.fromARGB(255, 58, 1, 1).withOpacity(0.1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            "Jadwal Ronda",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayName(int weekday) {
    const names = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return names[(weekday - 1).clamp(0, 6)];
  }

  Widget _buildJadwalCard(String hari, String jam, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCurrent ? primaryRed : const Color(0xFFF1F5F9), width: isCurrent ? 1.5 : 1),
        boxShadow: isCurrent ? [
          BoxShadow(
            color: primaryRed.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent ? primaryRed : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_today, color: isCurrent ? Colors.white : textGray, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hari,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? primaryRed : textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: textGray),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        jam,
                        style: const TextStyle(color: textGray, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
