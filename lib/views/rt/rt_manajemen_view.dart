import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/ronda_service.dart';
import '../../services/iuran_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/user_model.dart';
import '../../models/ronda_model.dart';
import '../../models/iuran_model.dart';
import '../../utils/top_notification.dart';

class RtManajemenView extends StatelessWidget {
  const RtManajemenView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFF8B0000);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: primaryRed, // Disesuaikan dengan WARTA (Merah)
          elevation: 0,
          title: const Text(
            "Manajemen Pengurus",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Iuran Warga"),
              Tab(text: "Jadwal Ronda"),
            ],
          ),
        ),
        body: const TabBarView(children: [_TabIuranWarga(), _TabJadwalRonda()]),
      ),
    );
  }
}

class _TabIuranWarga extends StatefulWidget {
  const _TabIuranWarga();

  @override
  State<_TabIuranWarga> createState() => _TabIuranWargaState();
}

class _TabIuranWargaState extends State<_TabIuranWarga> {
  final IuranService _iuranService = IuranService();
  final CloudinaryService _cloudinary = CloudinaryService();
  
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accNumController = TextEditingController();
  
  bool _isSaving = false;
  XFile? _newQrFile;

  @override
  void dispose() {
    _nominalController.dispose();
    _bankNameController.dispose();
    _accNumController.dispose();
    super.dispose();
  }

  void _pickQrImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _newQrFile = pickedFile);
    }
  }

  void _showEditSettingDialog(IuranRtModel? currentSettings, String kel, String rw, String rt) {
    _nominalController.text = currentSettings?.nominalWajib.toString() ?? '50000';
    _bankNameController.text = currentSettings?.bankName ?? '';
    _accNumController.text = currentSettings?.accountNumber ?? '';
    _newQrFile = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pengaturan Iuran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nominalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Nominal Wajib Bulanan (Rp)", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bankNameController,
                    decoration: const InputDecoration(labelText: "Nama Bank (Contoh: BCA / DANA)", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _accNumController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Nomor Rekening", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  
                  // QR Upload
                  const Text("QRIS Transfer:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setModalState(() => _newQrFile = pickedFile);
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _newQrFile != null
                          ? (kIsWeb ? Image.network(_newQrFile!.path, fit: BoxFit.contain) : Image.file(File(_newQrFile!.path), fit: BoxFit.contain))
                          : (currentSettings != null && currentSettings.qrImageUrl.isNotEmpty
                              ? Image.network(currentSettings.qrImageUrl, fit: BoxFit.contain)
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: Colors.grey),
                                    Text("Ketuk untuk Unggah QRIS", style: TextStyle(color: Colors.grey)),
                                  ],
                                )),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
                      onPressed: _isSaving ? null : () async {
                        setModalState(() => _isSaving = true);
                        setState(() => _isSaving = true);

                        String qrUrl = currentSettings?.qrImageUrl ?? '';
                        if (_newQrFile != null) {
                          String? uploaded = await _cloudinary.uploadImageXFile(_newQrFile!, folder: 'warta_qr');
                          if (uploaded != null) qrUrl = uploaded;
                        }

                        final newModel = IuranRtModel(
                          id: '', // abaikan
                          kelurahan: kel,
                          rw: rw,
                          rt: rt,
                          nominalWajib: int.tryParse(_nominalController.text) ?? 0,
                          isActive: currentSettings?.isActive ?? false,
                          qrImageUrl: qrUrl,
                          bankName: _bankNameController.text,
                          accountNumber: _accNumController.text,
                        );

                        bool success = await _iuranService.saveRtSettings(newModel);
                        if (mounted) {
                          Navigator.pop(ctx);
                          TopNotification.show(context: context, message: success ? "Berhasil disimpan" : "Gagal menyimpan", isSuccess: success, isError: !success);
                          setState(() => _isSaving = false);
                        }
                      },
                      child: _isSaving 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Simpan Pengaturan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthViewModel>(context).currentUser;
    if (user == null) return const Center(child: Text("Data pengguna tidak ditemukan"));

    return Stack(
      children: [
        StreamBuilder<IuranRtModel?>(
          stream: _iuranService.streamRtSettings(user.kelurahan ?? '', user.rw ?? '', user.rt ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            
            final settings = snapshot.data;
            bool isActive = settings?.isActive ?? false;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // KARTU PENGATURAN
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Status Iuran Bulan Ini", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Switch(
                            value: isActive,
                            activeColor: Colors.green,
                            onChanged: (val) async {
                              final updated = IuranRtModel(
                                id: '', kelurahan: user.kelurahan ?? '', rw: user.rw ?? '', rt: user.rt ?? '',
                                nominalWajib: settings?.nominalWajib ?? 50000,
                                isActive: val,
                                qrImageUrl: settings?.qrImageUrl ?? '',
                                bankName: settings?.bankName ?? '',
                                accountNumber: settings?.accountNumber ?? '',
                              );
                              await _iuranService.saveRtSettings(updated);
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, color: Color(0xFF8B0000)),
                          const SizedBox(width: 8),
                          Expanded(child: Text("Nominal: Rp ${settings?.nominalWajib ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.account_balance, color: Color(0xFF8B0000)),
                          const SizedBox(width: 8),
                          Expanded(child: Text("Rek: ${settings?.bankName ?? '-'} (${settings?.accountNumber ?? '-'})")),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.settings),
                          label: const Text("Edit Nominal & Rekening/QR"),
                          onPressed: () => _showEditSettingDialog(settings, user.kelurahan ?? '', user.rw ?? '', user.rt ?? ''),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const Text("Tinjau Pembayaran Warga", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF8B0000)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text("Untuk menyetujui atau menolak bukti transfer warga, silakan buka menu Approval di navigasi bawah.", style: TextStyle(fontSize: 12, color: Color(0xFF8B0000))),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
        
        if (_isSaving)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
      ],
    );
  }
}

class _TabJadwalRonda extends StatefulWidget {
  const _TabJadwalRonda();

  @override
  State<_TabJadwalRonda> createState() => _TabJadwalRondaState();
}

class _TabJadwalRondaState extends State<_TabJadwalRonda> {
  final RondaService _rondaService = RondaService();
  final TextEditingController _lokasiController = TextEditingController(
    text: "Pos Ronda Utama",
  );
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final List<String?> _slotAssignments = List<String?>.filled(4, null);
  bool? _enabledOverride;
  bool _enabledCached = false;
  List<UserModel> _residentsCached = const [];
  List<RondaScheduleModel> _schedulesCached = const [];
  bool _isLoading = true;
  bool _loadedOnce = false;
  String? _lastLoadedAreaKey;
  String? _loadError;

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Aksi detail $title belum tersedia di iterasi ini."),
        backgroundColor: const Color(0xFF8B0000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadData({required String rt, required String rw}) async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _rondaService.getRondaEnabled(rt: rt, rw: rw),
        _rondaService.getResidentsByArea(rt: rt, rw: rw),
        _rondaService.getSchedulesByArea(rt: rt, rw: rw),
      ]);

      if (!mounted) return;
      setState(() {
        _enabledCached = (results[0] as bool?) ?? false;
        _residentsCached = (results[1] as List<UserModel>?) ?? <UserModel>[];
        _schedulesCached =
            (results[2] as List<RondaScheduleModel>?) ?? <RondaScheduleModel>[];
        _loadedOnce = true;
        _loadError = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadedOnce = true;
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _ensureLoaded(String rt, String rw) {
    final areaKey = '$rt|$rw';
    if (_lastLoadedAreaKey == areaKey && _loadedOnce) return;
    _lastLoadedAreaKey = areaKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_loadedOnce && _lastLoadedAreaKey == areaKey) return;
      _loadData(rt: rt, rw: rw);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;
        final rt = user?.rt ?? '';
        final rw = user?.rw ?? '';
        if (rt.isEmpty || rw.isEmpty) {
          return const Center(
            child: Text("Data RT/RW ketua RT belum tersedia."),
          );
        }

        _ensureLoaded(rt, rw);

        final enabled = _enabledOverride ?? _enabledCached;

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_loadError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFF97316).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      "Gagal memuat data ronda: $_loadError",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9A3412),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                SwitchListTile(
                  value: enabled,
                  onChanged: (v) async {
                    final prev = enabled;
                    setState(() {
                      _enabledOverride = v;
                      _enabledCached = v; // jaga UI tetap stabil
                    });
                    try {
                      await _rondaService.setRondaEnabled(
                        rt: rt,
                        rw: rw,
                        enabled: v,
                        updatedByUid: user?.uid ?? '',
                      );
                      if (!mounted) return;
                      setState(() => _enabledOverride = null);
                      await _loadData(rt: rt, rw: rw);
                    } catch (e) {
                      if (!mounted) return;
                      setState(() {
                        _enabledOverride = prev;
                        _enabledCached = prev;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Gagal mengubah status ronda: $e"),
                          backgroundColor: const Color(0xFF8B0000),
                        ),
                      );
                    }
                  },
                  title: const Text(
                    "Aktifkan Jadwal Ronda",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    enabled
                        ? "Ronda aktif. Warga RT yang sama dapat melihat jadwal."
                        : "Ronda dinonaktifkan untuk wilayah ini.",
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(height: 8),
                  _buildComposerCard(_residentsCached, rt, rw, user?.uid ?? ''),
                  const SizedBox(height: 16),
                  const Text(
                    "Jadwal Tersimpan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_schedulesCached.isEmpty)
                    const Text("Belum ada jadwal ronda tersimpan.")
                  else
                    ..._schedulesCached.map(_buildSavedScheduleCard),
                ],
              ],
            ),
            if (_isLoading)
              const Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: Color(0xFF8B0000),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildComposerCard(
    List<UserModel> residents,
    String rt,
    String rw,
    String uid,
  ) {
    final wargaOnly = residents.where((u) => u.role == 'warga').toList();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Atur Jadwal (Drag & Drop)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              "Daftar warga terdeteksi: ${wargaOnly.length} orang (RT $rt / RW $rw)",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: _selectedDate,
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lokasiController,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: "Lokasi ronda",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (wargaOnly.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Text(
                  "Belum ada data warga untuk RT/RW ini.\n"
                  "Pastikan di koleksi 'users' ada dokumen dengan role='warga' dan rt/rw sesuai.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: wargaOnly.map((warga) {
                  return Draggable<String>(
                    data: warga.nama,
                    feedback: _dragChip(warga.nama),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: _dragChip(warga.nama),
                    ),
                    child: _dragChip(warga.nama),
                  );
                }).toList(),
              ),
            const SizedBox(height: 14),
            Column(
              children: List.generate(4, (index) {
                final current = _slotAssignments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DragTarget<String>(
                    onAcceptWithDetails: (details) {
                      setState(() => _slotAssignments[index] = details.data);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: candidateData.isNotEmpty
                              ? const Color(0xFFFEF2F2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF8B0000,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_pin_circle_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                current ??
                                    "Drop warga ke slot regu #${index + 1}",
                              ),
                            ),
                            if (current != null)
                              IconButton(
                                onPressed: () => setState(
                                  () => _slotAssignments[index] = null,
                                ),
                                icon: const Icon(Icons.close, size: 18),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final anggota = _slotAssignments
                      .whereType<String>()
                      .toSet()
                      .toList();
                  if (anggota.isEmpty) {
                    _showComingSoon(
                      context,
                      "Minimal isi 1 anggota untuk jadwal ronda.",
                    );
                    return;
                  }
                  await _rondaService.upsertSchedule(
                    rt: rt,
                    rw: rw,
                    tanggal: _selectedDate,
                    lokasi: _lokasiController.text.trim().isEmpty
                        ? "Pos Ronda Utama"
                        : _lokasiController.text.trim(),
                    anggota: anggota,
                    createdByUid: uid,
                  );
                  if (!mounted) return;
                  setState(() {
                    for (var i = 0; i < _slotAssignments.length; i++) {
                      _slotAssignments[i] = null;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Jadwal ronda berhasil disimpan."),
                      backgroundColor: Color(0xFF8B0000),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                ),
                child: const Text(
                  "Simpan Jadwal",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dragChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF8B0000).withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8B0000),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSavedScheduleCard(RondaScheduleModel item) {
    final dateLabel =
        "${item.tanggal.day}/${item.tanggal.month}/${item.tanggal.year}";
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B0000),
                  ),
                ),
                const Icon(Icons.shield_outlined, color: Color(0xFF8B0000)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Lokasi: ${item.lokasi}",
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              "Anggota: ${item.anggota.join(', ')}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    super.dispose();
  }
}
