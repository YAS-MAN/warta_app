import 'package:flutter/material.dart';
import '../../utils/top_notification.dart';
import '../../services/bantuan_service.dart';
import '../../models/faq_model.dart';

class BantuanView extends StatelessWidget {
  const BantuanView({super.key});

  static const Color primaryRed = Color(0xFF8B0000);
  static const Color bgApp = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgApp,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          children: [
            // ==========================================
            // 1. HEADER MERAH MELENGKUNG (GRADASI & WATERMARK)
            // ==========================================
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
                                    "Pusat Bantuan",
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
            ),
            
            // --- KONTEN DETAIL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primaryRed,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.support_agent, color: Colors.white, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          "Butuh Bantuan Langsung?",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Pengurus RW siap membantu Anda 24/7",
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            TopNotification.show(
                              context: context,
                              message: "Membuka WhatsApp Bantuan RW...",
                              isSuccess: true,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.chat),
                          label: const Text("Hubungi via WhatsApp"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Pertanyaan Umum (FAQ)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textGray,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<FaqModel>>(
                    future: BantuanService().getFaqs(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: primaryRed));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("Belum ada FAQ saat ini.", style: TextStyle(color: textGray));
                      }
                      return Column(
                        children: snapshot.data!.map((faq) => _buildFaqItem(context, faq.question, faq.answer)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Hilangkan garis bawaan ExpansionTile
        child: Builder( // Gunakan Builder untuk context yang baru (meskipun disini kita pakai root context untuk Theme sementara)
          builder: (context) {
            return ExpansionTile(
              title: Text(
                question,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textDark),
              ),
              iconColor: textGray,
              collapsedIconColor: textGray,
              childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              children: [
                Text(
                  answer,
                  style: const TextStyle(fontSize: 12, color: textGray, height: 1.5),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
