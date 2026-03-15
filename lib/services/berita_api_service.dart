import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/berita_model.dart';

/// Layanan berita yang terintegrasi dengan dua sumber:
/// 1. NewsData.io — API berita Indonesia (sumber utama, memerlukan internet)
/// 2. DetikNews Scraper — Python Flask lokal di localhost:5000 (fallback jika flask sedang berjalan)
/// 3. BeritaService — Dummy data (terakhir, jika semua gagal)
class BeritaApiService {
  // ============================================================
  // NEWS DATA API (Primary - Real Indonesian News)
  // ============================================================
  static const String _newsDataApiKey = '79c1811efcb4484888377f33615f1418';

  // ============================================================
  // DETIK NEWS SCRAPER (Local Flask — Secondary)
  // Harus menjalankan `python main.py` di folder detiknews_api lebih dulu
  // ============================================================
  static const String _detikBaseUrl = 'http://127.0.0.1:5000';

  // ============================================================
  // Mengambil berita dari NewsData.io
  // Dokumentasi: https://newsdata.io/docs
  // ============================================================
  Future<List<BeritaModel>> fetchFromNewsData({
    String country = 'id',
    String language = 'id',
    int size = 10,
    String? query,
  }) async {
    try {
      final queryParams = {
        'apikey': _newsDataApiKey,
        'country': country,
        'language': language,
        'size': '$size',
        if (query != null) 'q': query,
      };

      final uri = Uri.https('newsdata.io', '/api/1/news', queryParams);
      debugPrint('[NewsData] Requesting: $uri');
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      debugPrint('[NewsData] HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List results = data['results'] ?? [];
          final mapped = results
              .asMap()
              .entries
              .map((e) => BeritaModel.fromNewsData(e.value, '${e.key + 1}'))
              .where((b) => b.title.isNotEmpty)
              .toList();
          debugPrint('[NewsData] SUCCESS: ${mapped.length} items');
          return mapped;
        } else {
          // API returned error JSON (e.g. rate limit message)
          debugPrint(
            '[NewsData] API error body: ${response.body.substring(0, 200)}',
          );
        }
      } else if (response.statusCode == 401) {
        debugPrint('[NewsData] Unauthorized — API key invalid or expired');
      } else if (response.statusCode == 429) {
        debugPrint('[NewsData] Rate limit exceeded (429)');
      } else {
        debugPrint(
          '[NewsData] HTTP ${response.statusCode}: ${response.body.substring(0, 200)}',
        );
      }
    } on TimeoutException catch (_) {
      debugPrint('[NewsData] Request timed out');
    } catch (e) {
      debugPrint('[NewsData] Exception: $e');
    }
    return [];
  }

  // ============================================================
  // Mengambil berita dari DetikNews Scraper (Lokal Flask)
  // Endpoint: GET /search?q=<query>&detail=true&limit=<number>
  // ============================================================
  Future<List<BeritaModel>> fetchFromDetikNews({
    String query = 'berita indonesia',
    int limit = 10,
    bool detail = true,
  }) async {
    try {
      final uri = Uri.parse(
        '$_detikBaseUrl/search?q=${Uri.encodeComponent(query)}&detail=$detail&limit=$limit',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 200) {
          debugPrint('DETIK API SUCCESS: ${data['data'].length} items');
          final List results = data['data'] ?? [];
          return results
              .asMap()
              .entries
              .map((e) => BeritaModel.fromDetik(e.value, '${e.key + 1}'))
              .where((b) => b.title.isNotEmpty)
              .toList();
        } else {
          debugPrint('DETIK API FAILED (Status != 200): ${response.body}');
        }
      } else {
        debugPrint(
          'DETIK API FAILED (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('DETIK API EXCEPTION: $e');
      // Flask tidak berjalan atau tidak bisa dihubungi
    }
    return [];
  }

  // ============================================================
  // Mengambil berita dengan strategi waterfall:
  // 1. Coba NewsData.io
  // 2. Jika gagal, coba DetikNews Flask lokal
  // 3. Jika keduanya gagal, kembalikan list kosong
  // ============================================================
  Future<List<BeritaModel>> getBeritaList({
    String query = 'pemerintah daerah',
  }) async {
    // 1. Coba NewsData.io
    final newsData = await fetchFromNewsData(query: query);
    if (newsData.isNotEmpty) return newsData;

    // 2. Coba DetikNews lokal
    final detik = await fetchFromDetikNews(query: query);
    if (detik.isNotEmpty) return detik;

    // 3. Gagal semua — kembalikan list kosong
    return [];
  }

  /// Specificly untuk homepage headline
  Future<BeritaModel?> getLatestHeadline() async {
    final list = await getBeritaList();
    return list.isNotEmpty ? list.first : null;
  }

  // ============================================================
  // Pencarian berita berdasarkan query user
  // ============================================================
  Future<List<BeritaModel>> searchBerita(String query) async {
    if (query.isEmpty) return [];

    // Coba NewsData.io dengan query
    final newsData = await fetchFromNewsData(query: query, size: 10);
    if (newsData.isNotEmpty) return newsData;

    // Coba DetikNews lokal dengan query
    return fetchFromDetikNews(query: query, limit: 10);
  }
}
