import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/berita_model.dart';

class BeritaDetailView extends StatelessWidget {
  final BeritaModel berita;

  const BeritaDetailView({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1F2937);
    const Color bgApp = Colors.white;

    final ImageProvider bgImage = (berita.imageUrl != null && berita.imageUrl!.isNotEmpty)
        ? NetworkImage(berita.imageUrl!) as ImageProvider
        : AssetImage(berita.imagePath);

    return Scaffold(
      backgroundColor: bgApp,
      body: CustomScrollView(
        slivers: [
          // HEADER IMAGE WITH BACK BUTTON
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF8B0000),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image(
                image: bgImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/city_bg.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // CONTENT
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: bgApp,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CATEGORY BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B0000).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      berita.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B0000),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TITLE
                  Text(
                    berita.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // AUTHOR & DATE
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.person, size: 16, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            berita.author,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            berita.date,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // BODY CONTENT
                  Text(
                    berita.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: textDark.withValues(alpha: 0.85),
                      height: 1.8,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 32),
                  
                  if (berita.sourceUrl != null && berita.sourceUrl!.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final Uri url = Uri.parse(berita.sourceUrl!);
                          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tidak dapat membuka tautan')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.open_in_browser, size: 20),
                        label: const Text('Baca Artikel Asli', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
