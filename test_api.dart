import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing API...');
  try {
    // Test NewsData (Change API key if expired)
    final String newsDataUrl = 'https://newsdata.io/api/1/news';
    final String newsDataApiKey = '79c1811efcb4484888377f33615f1418';
    
    print('1. Calling NewsData API...');
    final urlNews = Uri.parse('$newsDataUrl?apikey=$newsDataApiKey&country=id');
    final res1 = await http.get(urlNews).timeout(const Duration(seconds: 10));
    print('NewsData Status: ${res1.statusCode}');
    if (res1.statusCode == 200) {
      final data = json.decode(res1.body);
      print('NewsData Response: ${data['status']} - Total: ${data['results']?.length}');
    } else {
      print('NewsData Error: ${res1.body}');
    }

    // Test DetikNews (Localhost Python Scraper)
    print('\n2. Calling Local DetikNews API...');
    final urlDetik = Uri.parse('http://127.0.0.1:5000/api/news/detik?category=berita');
    final res2 = await http.get(urlDetik).timeout(const Duration(seconds: 10));
    print('DetikNews Status: ${res2.statusCode}');
    if (res2.statusCode == 200) {
      final data = json.decode(res2.body);
      print('DetikNews Response: ${data['status']} - Total: ${data['data']?.length}');
    } else {
      print('DetikNews Error: ${res2.body}');
    }

  } catch (e) {
    print('Exception: $e');
  }
}
