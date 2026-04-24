class BeritaModel {
  final String id;
  final String title;
  final String category;
  final String author;
  final String date;
  final String content;
  final String imagePath; // local asset path
  final String? imageUrl;  // remote URL from API
  final String? sourceUrl; // external link to original article

  BeritaModel({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.date,
    required this.content,
    required this.imagePath,
    this.imageUrl,
    this.sourceUrl,
  });

  /// Maps from DetikNews scraper JSON shape
  factory BeritaModel.fromDetik(Map<String, dynamic> json, String id) {
    return BeritaModel(
      id: id,
      title: json['judul'] ?? '',
      category: 'DetikNews',
      author: 'Detik.com',
      date: json['waktu'] ?? '',
      content: json['body'] ?? json['judul'] ?? '',
      imagePath: 'assets/images/city_bg.webp',
      imageUrl: json['gambar'],
      sourceUrl: json['link'],
    );
  }

  /// Maps from RSS2JSON shape
  factory BeritaModel.fromRSS2JSON(Map<String, dynamic> json, String id) {
    // Extract image from enclosure if available, otherwise from thumbnail
    String? imageUrl;
    if (json['enclosure'] != null && json['enclosure']['link'] != null) {
      imageUrl = json['enclosure']['link'];
    } else if (json['thumbnail'] != null && json['thumbnail'].toString().isNotEmpty) {
      imageUrl = json['thumbnail'];
    }

    // Gunakan content polos jika tersedia, jika tidak fall back ke description 
    String rawContent = json['content'] ?? json['description'] ?? json['title'] ?? '';
    String contentClean = rawContent.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    final String link = json['link'] ?? '';
    if (link.isNotEmpty) {
      contentClean += '\n\nBaca artikel selengkapnya di:\n$link';
    }

    return BeritaModel(
      id: id,
      title: json['title'] ?? '',
      category: 'Nasional',
      author: 'CNN Indonesia',
      date: json['pubDate'] ?? '',
      content: contentClean,
      imagePath: 'assets/images/city_bg.webp',
      imageUrl: imageUrl,
      sourceUrl: link.isNotEmpty ? link : null,
    );
  }
}
