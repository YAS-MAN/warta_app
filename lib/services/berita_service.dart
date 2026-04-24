import '../models/berita_model.dart';

class BeritaService {
  Future<List<BeritaModel>> getBeritaList() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Mock network delay

    return [
      BeritaModel(
        id: "1",
        title: "Perkembangan Terbaru Infrastruktur Kota",
        category: "INFORMASI PUBLIK",
        author: "Admin Pemkab · Pemerintah",
        date: "Hari Ini",
        content: "Pemerintah kota telah secara resmi menjadwalkan perumusan kebijakan tata ruang yang baru untuk memastikan pembangunan berkelanjutan di pusat kota. Pengumuman ini dibuat pada rapat kerja daerah minggu lalu.",
        imagePath: "assets/images/city_bg.webp",
      ),
      BeritaModel(
        id: "2",
        title: "Program Vaksinasi Massal Tahap 2 Sedang Berlangsung",
        category: "Kesehatan",
        author: "Dinas Kesehatan",
        date: "Kemarin",
        content: "Dinas kesehatan setempat kembali menggelar vaksinasi massal tahap 2 untuk masyarakat umum di balai desa. Diharapkan warga membawa identitas lengkap.",
        imagePath: "assets/images/city_bg.webp",
      ),
      BeritaModel(
        id: "3",
        title: "Pemadaman Listrik Bergilir di Beberapa Kecamatan",
        category: "Infrastruktur",
        author: "PLN Pusat",
        date: "2 Hari yang lalu",
        content: "Pemeliharaan gardu induk menyebabkan pemadaman bergilir yang diperkirakan berlangsung selama 4 jam pada titik-titik tertentu.",
        imagePath: "assets/images/city_bg.webp",
      ),
      BeritaModel(
        id: "4",
        title: "Festival Kebudayaan Daerah Akhir Pekan Ini",
        category: "Hiburan",
        author: "Dinas Pariwisata",
        date: "3 Hari yang lalu",
        content: "Jangan lewatkan festival tari dan pakaian adat yang akan diselenggarakan akhir pekan ini di alun-alun utama.",
        imagePath: "assets/images/city_bg.webp",
      ),
      BeritaModel(
        id: "5",
        title: "Perbaikan Jalan Protokol, Arus Lalu Lintas Dialihkan",
        category: "Lalu Lintas",
        author: "Dinas Perhubungan",
        date: "4 Hari yang lalu",
        content: "Terdapat pengalihan arus di sepanjang jalan protokol akibat perbaikan aspal yang diperkirakan selesai dalam waktu dua minggu.",
        imagePath: "assets/images/city_bg.webp",
      ),
    ];
  }

  // Khusus untuk di banner Home
  Future<BeritaModel> getLatestHeadline() async {
    final list = await getBeritaList();
    return list.first;
  }
}
