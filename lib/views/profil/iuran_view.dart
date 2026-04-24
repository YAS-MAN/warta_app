import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../models/iuran_model.dart';
import '../../services/iuran_service.dart';
import '../../services/cloudinary_service.dart';
import '../../utils/top_notification.dart';
import '../../viewmodels/auth_viewmodel.dart';

class IuranView extends StatefulWidget {
  const IuranView({super.key});

  @override
  State<IuranView> createState() => _IuranViewState();
}

class _IuranViewState extends State<IuranView> {
  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);

  final IuranService _iuranService = IuranService();
  final CloudinaryService _cloudinary = CloudinaryService();

  bool _isUploading = false;

  String _formatRupiah(int nominal) {
    String str = nominal.toString();
    String result = "";
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) {
        result = ".$result";
      }
    }
    return "Rp $result";
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getCurrentBulan() {
    const List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[DateTime.now().month - 1];
  }

  String _getCurrentTahun() {
    return DateTime.now().year.toString();
  }

  Future<void> _bayarIuran(UserModel user, IuranRtModel settings) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      TopNotification.show(
        context: context,
        message: "Mengunggah bukti pembayaran...",
      );

      String? imageUrl = await _cloudinary.uploadImageXFile(
        pickedFile,
        folder: 'warta_iuran',
      );

      if (imageUrl != null) {
        // Simpan ke riwayat (Status 0 = Pending)
        IuranModel iuranBaru = IuranModel(
          id: '', // Diabaikan oleh firestore
          uidWarga: user.uid,
          namaWarga: user.nama,
          rt: user.rt ?? '',
          rw: user.rw ?? '',
          kelurahan: user.kelurahan ?? '',
          bulan: _getCurrentBulan(),
          tahun: _getCurrentTahun(),
          nominal: settings.nominalWajib,
          status: 0,
          buktiImageUrl: imageUrl,
          createdAt: DateTime.now(),
        );

        bool success = await _iuranService.bayarIuran(iuranBaru);
        if (success && mounted) {
          TopNotification.show(
            context: context,
            message: "Bukti terkirim! Menunggu konfirmasi RT.",
            isSuccess: true,
          );
        } else if (mounted) {
          TopNotification.show(
            context: context,
            message: "Gagal menyimpan riwayat.",
            isError: true,
          );
        }
      } else {
        if (mounted)
          TopNotification.show(
            context: context,
            message: "Gagal mengunggah gambar.",
            isError: true,
          );
      }
      setState(() => _isUploading = false);
    }
  }

  void _showBayarDialog(UserModel user, IuranRtModel settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pembayaran Iuran",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (settings.qrImageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    settings.qrImageUrl,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                )
              else
                Container(
                  height: 150,
                  alignment: Alignment.center,
                  color: Colors.grey[200],
                  child: const Text("Gambar QRIS belum diunggah RT"),
                ),
              const SizedBox(height: 16),
              Text(
                "Atau Transfer ke: ${settings.bankName}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "No Rekening: ${settings.accountNumber}",
                style: const TextStyle(
                  fontSize: 16,
                  color: primaryRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text(
                    "Unggah Bukti Transfer",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _bayarIuran(user, settings);
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.currentUser;

    if (user == null)
      return const Scaffold(
        body: Center(child: Text("Data warga tidak ditemukan")),
      );

    final kel = user.kelurahan ?? '';
    final rw = user.rw ?? '';
    final rt = user.rt ?? '';

    return Scaffold(
      backgroundColor: bgApp,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 60),
            child: Column(
              children: [
                // HEADER MERAH MELENGKUNG
                SizedBox(
                  height: 180,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 83, 0, 0),
                              Color(0xFF8B0000),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 20,
                                top: 20,
                                child: Transform.rotate(
                                  angle: 12 * 3.14159 / 180,
                                  child: Image.asset(
                                    'assets/icons/ic_document_after.png',
                                    width: 140,
                                    height: 140,
                                    color: Colors.black.withValues(alpha: 0.1),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  60,
                                  24,
                                  0,
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () => Navigator.pop(context),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Text(
                                      "Iuran Warga",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
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
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. CEK SETTING RT DULU
                      StreamBuilder<IuranRtModel?>(
                        stream: _iuranService.streamRtSettings(kel, rw, rt),
                        builder: (context, snapshotSetting) {
                          if (snapshotSetting.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final settings = snapshotSetting.data;

                          if (settings == null || !settings.isActive) {
                            return _buildBannerTidakAdaIuran();
                          }

                          // 2. CEK RIWAYAT PEMBAYARAN WARGA BULAN INI
                          return FutureBuilder<IuranModel?>(
                            future: _iuranService.cekPembayaranBulanIni(
                              user.uid,
                              _getCurrentBulan(),
                              _getCurrentTahun(),
                            ),
                            builder: (context, snapshotIuran) {
                              if (snapshotIuran.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final tagihanBulanIni = snapshotIuran.data;

                              return _buildCardTagihan(
                                settings,
                                tagihanBulanIni,
                                user,
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        "Riwayat Pembayaran",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textGray,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. DAFTAR RIWAYAT SEMUA
                      FutureBuilder<List<IuranModel>>(
                        future: _iuranService.getRiwayatIuranWarga(user.uid),
                        builder: (context, snapshotList) {
                          if (snapshotList.connectionState ==
                              ConnectionState.waiting)
                            return const CircularProgressIndicator();
                          final history = snapshotList.data ?? [];

                          if (history.isEmpty)
                            return const Center(
                              child: Text(
                                "Belum ada riwayat pembayaran",
                                style: TextStyle(color: textGray),
                              ),
                            );

                          return Column(
                            children: history
                                .map((iuran) => _buildRiwayatCard(iuran))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Mengirim Bukti...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  Widget _buildBannerTidakAdaIuran() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
          SizedBox(height: 12),
          Text(
            "Iuran Bulan Ini Belum Diaktifkan",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "Tidak ada tagihan yang perlu dibayar.",
            style: TextStyle(color: textGray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTagihan(
    IuranRtModel settings,
    IuranModel? tagihan,
    UserModel user,
  ) {
    bool isPending = tagihan != null && tagihan.status == 0;
    bool isLunas = tagihan != null && tagihan.status == 1;
    bool isDitolak = tagihan != null && tagihan.status == 2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Iuran Lingkungan Bulanan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLunas
                      ? Colors.green.withValues(alpha: 0.1)
                      : (isPending
                            ? Colors.orange.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isLunas
                      ? "LUNAS"
                      : (isPending
                            ? "PENDING"
                            : (isDitolak ? "DITOLAK" : "BELUM BAYAR")),
                  style: TextStyle(
                    color: isLunas
                        ? Colors.green
                        : (isPending ? Colors.orange : primaryRed),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Periode: ${_getCurrentBulan()} ${_getCurrentTahun()}",
            style: const TextStyle(color: textGray, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            _formatRupiah(settings.nominalWajib),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryRed,
            ),
          ),
          const SizedBox(height: 16),

          if (isLunas)
            const SizedBox(
              width: double.infinity,
              child: Text(
                "Terima kasih, pembayaran bulan ini sudah lunas.",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else if (isPending)
            const SizedBox(
              width: double.infinity,
              child: Text(
                "Bukti sedang ditinjau oleh Pengurus RT.",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showBayarDialog(user, settings),
                child: Text(
                  isDitolak ? "Bayar Ulang" : "Bayar Sekarang",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          if (isDitolak)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "Bukti sebelumnya ditolak. Silakan unggah bukti yang benar.",
                style: TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(IuranModel iuran) {
    bool isLunas = iuran.status == 1;
    bool isPending = iuran.status == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLunas
                      ? const Color(0xFFF0FDF4)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isLunas ? Icons.check_circle : Icons.hourglass_top,
                  color: isLunas ? const Color(0xFF10B981) : Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Iuran ${iuran.bulan} ${iuran.tahun}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(iuran.createdAt),
                    style: const TextStyle(color: textGray, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatRupiah(iuran.nominal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  fontSize: 14,
                ),
              ),
              if (isPending)
                const Text(
                  "Pending",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
