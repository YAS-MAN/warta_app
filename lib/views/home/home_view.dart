import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../report/lapor_view.dart';
import '../darurat/darurat_view.dart';
import '../berita/berita_view.dart';
import '../berita/berita_detail_view.dart';
import '../surat/surat_detail_view.dart';
import '../profil/jadwal_ronda_view.dart';
import '../profil/bantuan_view.dart';
import '../../utils/top_notification.dart';
import '../aktivitas/aktivitas_detail_view.dart';
import '../../models/berita_model.dart';
import '../../models/surat_model.dart';
import '../../services/berita_service.dart';
import '../../services/berita_api_service.dart';
import '../../services/surat_service.dart';
import '../../models/aktivitas_model.dart';
import '../../services/aktivitas_service.dart';
import '../../services/iuran_service.dart';
import '../profil/iuran_view.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomeView extends StatefulWidget {
  final Function(int) onNavigate;
  const HomeView({super.key, required this.onNavigate});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const String _notifPrefKey = 'home_has_notif_enabled';
  static bool _notifFallbackCache = true;
  bool _hasNotification = true;
  
  final IuranService _iuranService = IuranService();

  String _getCurrentBulan() {
    const List<String> months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[DateTime.now().month - 1];
  }

  String _getCurrentTahun() {
    return DateTime.now().year.toString();
  }

  Widget _buildIuranReminder() {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;
        if (user == null || user.kelurahan == null || user.kelurahan!.isEmpty) return const SizedBox.shrink();
        
        // Reminder hanya muncul jika sudah tanggal 25 ke atas
        if (DateTime.now().day < 25) return const SizedBox.shrink();

        return FutureBuilder<bool>(
          future: () async {
            final rtSettings = await _iuranService.getRtSettings(user.kelurahan ?? '', user.rw ?? '', user.rt ?? '');
            if (rtSettings == null || !rtSettings.isActive) return false;
            final tagihan = await _iuranService.cekPembayaranBulanIni(user.uid, _getCurrentBulan(), _getCurrentTahun());
            return tagihan == null || tagihan.status == 2; // Harus bayar jika belum bayar (null) atau ditolak (2)
          }(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
            final harusBayar = snapshot.data ?? false;
            if (!harusBayar) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pengingat Iuran",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Anda belum membayar iuran RT untuk ${_getCurrentBulan()}.",
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const IuranView()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text("Bayar", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Warna sesuai CSS Figma
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgGray = Color(0xFFF9FAFB);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color goldColor = Color(0xFFD4AF37);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Selamat Pagi,";
    } else if (hour < 15) {
      return "Selamat Siang,";
    } else if (hour < 18) {
      return "Selamat Sore,";
    } else {
      return "Selamat Malam,";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getBool(_notifPrefKey);
      final resolved = savedValue ?? _notifFallbackCache;
      _notifFallbackCache = resolved;
      if (!mounted) return;
      setState(() => _hasNotification = resolved);
    } on MissingPluginException {
      // Fallback untuk environment yang plugin web/native belum terdaftar.
      if (!mounted) return;
      setState(() => _hasNotification = _notifFallbackCache);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasNotification = _notifFallbackCache);
    }
  }

  Future<void> _toggleNotificationPreference() async {
    final newValue = !_hasNotification;
    setState(() {
      _hasNotification = newValue;
    });
    _notifFallbackCache = newValue;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notifPrefKey, newValue);
    } on MissingPluginException {
      // Abaikan: nilai tetap tersimpan di fallback cache selama app berjalan.
    } catch (_) {
      // Abaikan error storage agar UX toggle tetap stabil.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGray,

      // ==========================================
      // KONTEN UTAMA (BODY)
      // ==========================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 40,
        ), // Jarak agar tidak tertutup nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HEADER (GRADASI & WATERMARK)
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              // Gunakan ClipRRect agar ikon rumah yang melayang tetap terpotong rapi mengikuti lengkungan merah
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Transform.rotate(
                        angle: 12 * 3.14159 / 180,
                        child: Image(
                          image: const AssetImage(
                            'assets/icons/ic_home_after.png',
                          ),
                          width:
                              180, // Ukuran diperbesar sedikit agar lebih gagah
                          height: 180,
                          color: const Color.fromARGB(255, 58, 1, 1)
                              .withOpacity(
                                0.1,
                              ), // Opacity halus agar tidak menabrak teks
                        ),
                      ),
                    ),

                    // --- Konten Utama ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Teks Sapaan & Ikon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Consumer<AuthViewModel>(
                                    builder: (context, authVM, child) {
                                      final nama =
                                          authVM.currentUser?.nama ??
                                          "Budi Setiawan";
                                      return Text(
                                        nama,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: _toggleNotificationPreference,
                                    borderRadius: BorderRadius.circular(20),
                                    child: _buildTopIcon(
                                      _hasNotification
                                          ? Icons.notifications_active
                                          : Icons.notifications_none,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      _showSearchBottomSheet(context);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: _buildTopIcon(Icons.search),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // --- Card Status Identitas ---
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                24,
                              ), // Disamakan dengan radius umum
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Kotak Fingerprint (Revisi Border)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFDF7E7,
                                    ), // Warna emas pudar
                                    // REVISI: BorderRadius disamakan biar tidak kaku
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.fingerprint,
                                    color: Color(0xFFD4AF37),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "STATUS IDENTITAS",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Terverifikasi (E-KTP)",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Tombol Lihat QR
                                GestureDetector(
                                  onTap: () {
                                    _showQrDialog(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B0000),
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ), // Radius disesuaikan
                                    ),
                                    child: const Text(
                                      "LIHAT QR",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            _buildIuranReminder(),

            // 2. LAYANAN DIGITAL (Menu Grid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Layanan Digital",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _showAllServicesBottomSheet(context);
                        },
                        child: Text(
                          "Lihat Semua",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryRed.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => widget.onNavigate(4), // Profil
                        borderRadius: BorderRadius.circular(16),
                        child: _buildMenuBtn(Icons.badge, "Digital ID"),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LaporView(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: _buildMenuBtn(Icons.campaign, "Pengaduan"),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BeritaView(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: _buildMenuBtn(Icons.article, "Berita"),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DaruratView(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: _buildMenuBtn(
                          Icons.warning_amber_rounded,
                          "Darurat",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. AKTIVITAS TERAKHIR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Aktivitas Terakhir",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      InkWell(
                        onTap: () => widget.onNavigate(3), // Aktivitas
                        child: Text(
                          "Riwayat",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryRed.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FutureBuilder<List<AktivitasModel>>(
                      future: AktivitasService().getRecentAktivitas(
                        context.read<AuthViewModel>().currentUser?.uid ?? '',
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: primaryRed),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Belum ada aktivitas."),
                          );
                        }

                        final items = snapshot.data!;
                        return Column(
                          children: items.asMap().entries.map((entry) {
                            int idx = entry.key;
                            AktivitasModel item = entry.value;

                            return Column(
                              children: [
                                _buildActivityItem(
                                  context,
                                  IconData(
                                    item.iconCodePoint,
                                    fontFamily: item.iconFontFamily,
                                  ),
                                  item.iconColor,
                                  item.iconBgColor,
                                  item.title,
                                  item.subtitle,
                                  item.date,
                                  item.status,
                                  item.statusTextColor,
                                  item.statusBgColor,
                                ),
                                if (idx < items.length - 1)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Divider(
                                      color: bgGray,
                                      thickness: 1.5,
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. BANNER INFORMASI PUBLIK
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FutureBuilder<BeritaModel?>(
                future: BeritaApiService().getLatestHeadline().then((v) async {
                  // If API returns null, fallback to dummy
                  return v ?? await BeritaService().getLatestHeadline();
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: primaryRed),
                      ),
                    );
                  }
                  if (!snapshot.hasData) return const SizedBox();

                  final berita = snapshot.data!;
                  // Determine background: use imageUrl from API or fallback to local asset
                  final ImageProvider bgImage =
                      (berita.imageUrl != null && berita.imageUrl!.isNotEmpty)
                      ? NetworkImage(berita.imageUrl!) as ImageProvider
                      : AssetImage(berita.imagePath);
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BeritaDetailView(berita: berita),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 160),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryRed, // Warna dasar merah
                        borderRadius: BorderRadius.circular(16),
                        // PERUBAHAN: Background efek kota transparan
                        image: DecorationImage(
                          image: bgImage,
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            primaryRed.withOpacity(0.3),
                            BlendMode.dstATop,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            berita.category,
                            style: const TextStyle(
                              color: goldColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            berita.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Ikon Bulat Transparan di Header
  Widget _buildTopIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  // Tombol Menu Layanan Digital (PERUBAHAN: Diperbesar ukurannya)
  Widget _buildMenuBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 64, // Diperbesar dari 56 agar tidak kelihatan renggang
          height: 64, // Diperbesar dari 56
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18), // Melengkung lebih halus
            border: Border.all(color: const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: primaryRed,
            size: 28,
          ), // Ikon juga diperbesar
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: textGray,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Item List Aktivitas
  Widget _buildActivityItem(
    BuildContext context,
    IconData icon,
    Color iconColor,
    Color iconBg,
    String title,
    String subtitle,
    String time,
    String status,
    Color statusColor,
    Color statusBg,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AktivitasDetailView(
              title: title,
              subtitle: subtitle,
              status: status,
              time: time,
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(color: textGray, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Pencarian",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onSubmitted: (value) {
                  _handleGlobalSearch(value);
                },
                decoration: InputDecoration(
                  hintText: "Cari berita atau surat...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF8B0000),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleGlobalSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      TopNotification.show(
        context: context,
        message: "Masukkan kata kunci pencarian dulu.",
      );
      return;
    }

    Navigator.pop(context);
    final suratResults = await SuratService().searchSurat(query);
    if (!mounted) return;

    if (suratResults.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BeritaView(initialSearchQuery: query),
        ),
      );
      return;
    }

    _showSearchResultBottomSheet(query, suratResults);
  }

  void _showSearchResultBottomSheet(
    String query,
    List<SuratModel> suratResults,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hasil untuk "$query"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Surat yang relevan",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...suratResults.take(3).map((surat) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: Text(surat.title),
                    subtitle: Text(surat.category),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (_) => SuratDetailView(title: surat.title),
                        ),
                      );
                    },
                  );
                }),
                const Divider(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.article_outlined),
                  title: const Text("Lanjut cari di Berita"),
                  subtitle: Text('Cari "$query" di berita'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => BeritaView(initialSearchQuery: query),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAllServicesBottomSheet(BuildContext context) {
    final wargaServices = [
      _ServiceMenuItem(
        label: "Digital ID",
        icon: Icons.badge,
        onTap: () => widget.onNavigate(4),
      ),
      _ServiceMenuItem(
        label: "Pengaduan",
        icon: Icons.campaign,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporView()),
        ),
      ),
      _ServiceMenuItem(
        label: "Berita",
        icon: Icons.article,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BeritaView()),
        ),
      ),
      _ServiceMenuItem(
        label: "Surat",
        icon: Icons.mail_outline,
        onTap: () => widget.onNavigate(1),
      ),
      _ServiceMenuItem(
        label: "Darurat",
        icon: Icons.warning_amber_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DaruratView()),
        ),
      ),
      _ServiceMenuItem(
        label: "Iuran",
        icon: Icons.payments_outlined,
        onTap: () {
          widget.onNavigate(4);
          TopNotification.show(
            context: context,
            message: "Buka menu Profil untuk melihat iuran.",
          );
        },
      ),
      _ServiceMenuItem(
        label: "Aktivitas",
        icon: Icons.history,
        onTap: () => widget.onNavigate(3),
      ),
      _ServiceMenuItem(
        label: "Biometrik",
        icon: Icons.fingerprint,
        onTap: () {
          widget.onNavigate(4);
          TopNotification.show(
            context: context,
            message: "Atur biometrik dari menu Profil.",
          );
        },
      ),
      _ServiceMenuItem(
        label: "Jadwal Ronda",
        icon: Icons.event_note_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JadwalRondaView()),
        ),
      ),
      _ServiceMenuItem(
        label: "Bantuan",
        icon: Icons.volunteer_activism_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BantuanView()),
        ),
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Layanan Digital",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wargaServices.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemBuilder: (_, index) {
                        final service = wargaServices[index];
                        return InkWell(
                          onTap: () {
                            Navigator.pop(sheetContext);
                            service.onTap();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: _buildMenuBtn(service.icon, service.label),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQrDialog(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final uid = authVM.currentUser?.uid ?? 'UNKNOWN_USER';

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Digital ID QR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pindai kode QR ini untuk verifikasi identitas fisik.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: uid,
                      version: QrVersions.auto,
                      size: 160.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Tutup",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ServiceMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  _ServiceMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
