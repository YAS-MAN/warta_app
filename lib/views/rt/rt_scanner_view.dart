import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/auth_service.dart';
import '../../utils/top_notification.dart';

class RtScannerView extends StatefulWidget {
  const RtScannerView({super.key});

  @override
  State<RtScannerView> createState() => _RtScannerViewState();
}

class _RtScannerViewState extends State<RtScannerView> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return; // Prevent multiple scans at once

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        setState(() {
          _isScanning = false;
        });

        // Tampilkan loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );

        try {
          // Cari user di database
          final user = await AuthService().getUserByUid(rawValue);

          if (!mounted) return;
          Navigator.pop(context); // Tutup loading

          if (user != null) {
            // Tampilkan hasil bottom sheet
            _showResultBottomSheet(
              context: context,
              nama: user.nama,
              nik: user.nik,
              alamat:
                  "RT ${user.rt ?? '-'} / RW ${user.rw ?? '-'}, ${user.kelurahan ?? '-'}",
            );
          } else {
            // User tidak ditemukan (Bukan QR aplikasi WARTA)
            TopNotification.show(
              context: context,
              message: "QR Code tidak valid atau Warga tidak terdaftar.",
              isError: true,
            );

            // Lanjutkan scanning setelah 2 detik
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _isScanning = true;
                });
              }
            });
          }
        } catch (e) {
          if (!mounted) return;
          Navigator.pop(context);
          TopNotification.show(
            context: context,
            message: "Terjadi kesalahan koneksi",
            isError: true,
          );
          setState(() {
            _isScanning = true;
          });
        }
      }
    }
  }

  void _showResultBottomSheet({
    required BuildContext context,
    required String nama,
    required String nik,
    required String alamat,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sukses Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Verifikasi Berhasil",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),

              // Data Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Nama Lengkap", nama),
                    const Divider(height: 24),
                    _buildInfoRow("NIK Kependudukan", nik),
                    const Divider(height: 24),
                    _buildInfoRow("Alamat / Domisili", alamat),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // Tutup bottom sheet
                    // Lanjutkan scan
                    if (mounted) {
                      setState(() {
                        _isScanning = true;
                      });
                    }
                  },
                  child: const Text(
                    "Pindai Lagi",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Scan Digital ID",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _scannerController, onDetect: _onDetect),
          // Frame Overlay (Kotak Scan)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent, width: 3),
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
              ),
            ),
          ),
          const Positioned(
            bottom: 60,
            child: Text(
              "Arahkan QR Code Warga ke dalam area kotak",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
