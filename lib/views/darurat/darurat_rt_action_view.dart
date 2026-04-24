import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/darurat_model.dart';
import '../../services/darurat_service.dart';
import '../../utils/top_notification.dart';

class DaruratActionModal {
  static void show(BuildContext context, EmergencySignalModel emergency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB), // Background abu-abu muda ala WARTA
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar (Garis kecil di tengah atas)
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PERINGATAN DARURAT",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.red,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Segera hubungi warga terkait!",
                            style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Warga Info Card
              const Text(
                "Info Pengirim Sinyal:", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937), fontSize: 14)
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emergency.namaWarga, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "GPS: ${emergency.latitude.toStringAsFixed(5)}, ${emergency.longitude.toStringAsFixed(5)}", 
                            style: const TextStyle(color: Colors.grey, fontSize: 13)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Aksi Baris 1: Maps
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.map_outlined, color: Color(0xFF1F2937)),
                  label: const Text("Lacak di Google Maps", style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${emergency.latitude},${emergency.longitude}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Aksi Baris 2: Forward WA
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("Teruskan Info ke WA Grup", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WA Green
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final text = "🚨 *DARURAT!* 🚨\nWarga bernama *${emergency.namaWarga}* memancarkan sinyal bahaya (TRACE).\n\nMohon warga di sekitar lokasi segera merapat untuk memberikan pertolongan!\nCek Lokasi GPS Terakhir: https://www.google.com/maps/search/?api=1&query=${emergency.latitude},${emergency.longitude}";
                    final Uri waUrl = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(text)}");
                    if (await canLaunchUrl(waUrl)) {
                      await launchUrl(waUrl);
                    } else {
                      if (ctx.mounted) {
                        TopNotification.show(context: ctx, message: "Tidak dapat membuka aplikasi WhatsApp", isError: true);
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFE5E7EB)),
              const SizedBox(height: 12),

              // Tombol Tandai Selesai
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.verified_user),
                  label: const Text("Tandai Darurat Telah Diatasi", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000), // Merah gelap WARTA
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await DaruratService().resolveEmergency(emergency.id);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      TopNotification.show(context: ctx, message: "Peringatan darurat berhasil ditutup.", isSuccess: true);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
