import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/berita_model.dart';

/// Layanan berita yang terintegrasi dengan RSS2JSON (Public CORS-enabled API)
/// Mengambil RSS feed dari portal berita Nasional (Contoh: CNN Indonesia)
class BeritaApiService {
  // ============================================================
  // RSS TO JSON API
  // Menggunakan layanan pihak ketiga agar tidak terkena blokir CORS di Web
  // ============================================================
  static const String _rssUrl = 'https://www.cnnindonesia.com/nasional/rss';
  static const String _baseUrl = 'https://api.rss2json.com/v1/api.json';

  // ============================================================
  // Mengambil berita dari API
  // ============================================================
  Future<List<BeritaModel>> fetchBeritaRSS() async {
    try {
      final uri = Uri.parse('$_baseUrl?rss_url=$_rssUrl');
      debugPrint('[BeritaAPI] Requesting: $uri');
      
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      debugPrint('[BeritaAPI] HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok' && data['items'] != null) {
          final List results = data['items'] ?? [];
          final mapped = results
              .asMap()
              .entries
              .map((e) => BeritaModel.fromRSS2JSON(e.value, '${e.key + 1}'))
              .where((b) => b.title.isNotEmpty)
              .toList();
          debugPrint('[BeritaAPI] SUCCESS: ${mapped.length} items');
          return mapped;
        }
      } else {
        debugPrint(
          '[BeritaAPI] HTTP ${response.statusCode}: ${response.body.substring(0, 100)}',
        );
      }
    } on TimeoutException catch (_) {
      debugPrint('[BeritaAPI] Request timed out');
    } catch (e) {
      debugPrint('[BeritaAPI] Exception: $e');
    }
    return [];
  }

  // ============================================================
  // Mengambil berita dengan endpoint terkini (Default / Fallback)
  // ============================================================
  Future<List<BeritaModel>> getBeritaList({
    String query = '', 
  }) async {
    // 1. Ambil dari RSS Nasional
    final newsData = await fetchBeritaRSS();
    
    // Jika ada query (seperti search), filter secara lokal di sisi client
    if (query.isNotEmpty && newsData.isNotEmpty) {
      final q = query.toLowerCase();
      return newsData.where((element) => 
        element.title.toLowerCase().contains(q) || 
        element.content.toLowerCase().contains(q)
      ).toList();
    }
    
    return newsData;
  }

  /// Specificly untuk homepage headline
  Future<BeritaModel?> getLatestHeadline() async {
    final list = await getBeritaList();
    return list.isNotEmpty ? list.first : null;
  }

  // ============================================================
  // Pencarian berita (lokal filtering)
  // ============================================================
  Future<List<BeritaModel>> searchBerita(String query) async {
    if (query.isEmpty) return [];
    
    final newsData = await fetchBeritaRSS();
    final q = query.toLowerCase();
    
    final filtered = newsData.where((element) => 
      element.title.toLowerCase().contains(q) || 
      element.content.toLowerCase().contains(q)
    ).toList();
    
    return filtered;
  }
}
