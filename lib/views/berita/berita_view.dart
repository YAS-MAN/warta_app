import 'package:flutter/material.dart';
import '../../utils/top_notification.dart';
import '../../models/berita_model.dart';
import '../../services/berita_service.dart';
import '../../services/berita_api_service.dart';
import 'berita_detail_view.dart';

class BeritaView extends StatefulWidget {
  final String? initialSearchQuery;

  const BeritaView({super.key, this.initialSearchQuery});

  @override
  State<BeritaView> createState() => _BeritaViewState();
}

class _BeritaViewState extends State<BeritaView> {
  final TextEditingController _searchController = TextEditingController();
  final BeritaApiService _apiService = BeritaApiService();
  final BeritaService _fallbackService = BeritaService();

  late Future<List<BeritaModel>> _futureBerita;
  bool _isSearching = false;
  String _dataSource = 'live'; // 'live' | 'dummy'

  @override
  void initState() {
    super.initState();
    final initialQuery = widget.initialSearchQuery?.trim() ?? '';
    if (initialQuery.isNotEmpty) {
      _searchController.text = initialQuery;
      _isSearching = true;
      _futureBerita = _searchBerita(initialQuery);
    } else {
      _futureBerita = _loadBerita();
    }
  }

  Future<List<BeritaModel>> _loadBerita({String? query}) async {
    // Try real API first
    final apiResult = await _apiService.getBeritaList(query: query ?? '');
    if (apiResult.isNotEmpty) {
      if (mounted) setState(() => _dataSource = 'live');
      return apiResult;
    }
    // Fallback to dummy service
    if (mounted) setState(() => _dataSource = 'dummy');
    return _fallbackService.getBeritaList();
  }

  Future<List<BeritaModel>> _searchBerita(String query) async {
    if (query.trim().isEmpty) return _loadBerita();
    final apiResult = await _apiService.searchBerita(query);
    return apiResult;
  }

  void _onSearch(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _futureBerita = _loadBerita();
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _futureBerita = _searchBerita(value);
    });

    TopNotification.show(
      context: context,
      message: 'Mencari: "$value"...',
    );
  }

  Widget _buildImage(BeritaModel article, {double height = 200, BoxFit fit = BoxFit.cover}) {
    if (article.imageUrl != null && article.imageUrl!.isNotEmpty) {
      return Image.network(
        article.imageUrl!,
        width: double.infinity,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackImage(height),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _buildFallbackImage(height),
      );
    }
    return _buildFallbackImage(height);
  }

  Widget _buildFallbackImage(double height) {
    return Image.asset(
      'assets/images/city_bg.webp',
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1F2937);
    const Color bgApp = Colors.white;

    return Scaffold(
      backgroundColor: bgApp,
      body: SafeArea(
        child: Column(
          children: [
            // TOP HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.arrow_back, color: textDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari berita...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearch('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (_) => setState(() {}), // rebuild to show/hide clear btn
                        onSubmitted: _onSearch,
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SOURCE BADGE
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (_dataSource == 'live'
                              ? const Color(0xFF8B0000)
                              : Colors.orange)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _dataSource == 'live' ? Icons.wifi : Icons.wifi_off,
                          color: _dataSource == 'live' ? const Color(0xFF8B0000) : Colors.orange,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _dataSource == 'live' ? 'Live Berita Indonesia' : 'Mode Offline (Demo)',
                          style: TextStyle(
                            color: _dataSource == 'live' ? const Color(0xFF8B0000) : Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_isSearching)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('Hapus Filter', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),

            // KONTEN BERITA
            Expanded(
              child: FutureBuilder<List<BeritaModel>>(
                future: _futureBerita,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF8B0000)),
                          SizedBox(height: 16),
                          Text('Mengambil berita terkini...', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    if (_isSearching) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 52, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada berita untuk kata kunci "${_searchController.text.trim()}".',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearch('');
                                },
                                child: const Text('Hapus filter'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Tidak dapat memuat berita.', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => setState(() { _futureBerita = _loadBerita(); }),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
                          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    );
                  }

                  final heroArticle = snapshot.data!.first;
                  final relatedArticles = snapshot.data!.skip(1).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Informasi Publik & Berita',
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person, size: 16, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              heroArticle.author,
                              style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // GAMBAR UTAMA
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BeritaDetailView(berita: heroArticle),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: _buildImage(heroArticle),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // KATEGORI BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B0000).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            heroArticle.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B0000),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          heroArticle.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          heroArticle.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF1F2937).withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Divider(color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),

                        const Text(
                          'Berita Terkait',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),

                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: relatedArticles.length,
                          itemBuilder: (context, index) {
                            final article = relatedArticles[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BeritaDetailView(berita: article),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 100,
                                        height: 70,
                                        child: _buildImage(article, height: 70),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1F2937),
                                              height: 1.3,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  article.category,
                                                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                article.date.length > 16 ? article.date.substring(0, 16) : article.date,
                                                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
