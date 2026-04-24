import 'package:flutter/material.dart';
import '../models/surat_model.dart';

class SuratService {
  // Data Master Surat
  static final List<SuratModel> _allSurat = _generateDummySurat();

  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ["Administrasi", "Perizinan", "Keterangan", "Hukum"];
  }

  Future<List<SuratModel>> getSuratByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _allSurat.where((s) => s.category == category).toList();
  }

  Future<SuratModel?> getSuratByTitle(String title) async {
     await Future.delayed(const Duration(milliseconds: 200));
     try {
       return _allSurat.firstWhere((s) => s.title.toLowerCase() == title.toLowerCase());
     } catch (e) {
       return null;
     }
  }

  Future<List<SuratModel>> getPopularSurat() async {
     await Future.delayed(const Duration(milliseconds: 300));
     // Mengambil 3 sampel dasar
     List<SuratModel> popular = [];
     var admin = _allSurat.where((s) => s.category == "Administrasi").toList();
     var izin = _allSurat.where((s) => s.category == "Perizinan").toList();
     var ket = _allSurat.where((s) => s.category == "Keterangan").toList();

     if (admin.isNotEmpty) popular.add(admin[0]);
     if (izin.isNotEmpty) popular.add(izin[0]);
     if (ket.isNotEmpty) popular.add(ket[0]);

     return popular;
  }

  Future<List<SuratModel>> searchSurat(String query) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) return [];

    return _allSurat.where((surat) {
      return surat.title.toLowerCase().contains(keyword) ||
          surat.description.toLowerCase().contains(keyword) ||
          surat.category.toLowerCase().contains(keyword);
    }).toList();
  }

  static List<SuratModel> _generateDummySurat() {
    final List<Map<String, dynamic>> rawData = [
      // Administrasi
      {"cat": "Administrasi", "title": "Kartu Keluarga (KK)", "desc": "Pembuatan atau Perubahan KK", "icon": Icons.family_restroom},
      {"cat": "Administrasi", "title": "Kartu Tanda Penduduk (KTP)", "desc": "Perekaman atau Penggantian KTP Baru", "icon": Icons.badge},
      {"cat": "Administrasi", "title": "Akta Kelahiran", "desc": "Penerbitan Surat Keterangan Lahir", "icon": Icons.child_care},
      {"cat": "Administrasi", "title": "Akta Kematian", "desc": "Pelaporan Meninggal Dunia", "icon": Icons.nights_stay},
      {"cat": "Administrasi", "title": "Surat Pindah", "desc": "Mengurus Perpindahan Domisili", "icon": Icons.transfer_within_a_station},
      // Perizinan
      {"cat": "Perizinan", "title": "Surat Izin Tempat Usaha (SITU)", "desc": "Pendaftaran Lokasi Usaha", "icon": Icons.storefront},
      {"cat": "Perizinan", "title": "Izin Mendirikan Bangunan (IMB)", "desc": "Persetujuan Pendirian Bangunan", "icon": Icons.domain},
      {"cat": "Perizinan", "title": "Izin Reklame", "desc": "Pemasangan Papan Reklame/Spanduk", "icon": Icons.campaign},
      {"cat": "Perizinan", "title": "Izin Keramaian", "desc": "Pemberitahuan Acara Skala Besar", "icon": Icons.festival},
      // Keterangan
      {"cat": "Keterangan", "title": "Surat Keterangan Domisili", "desc": "Bukti Tempat Tinggal Sementara", "icon": Icons.location_on},
      {"cat": "Keterangan", "title": "Keterangan Tidak Mampu (SKTM)", "desc": "Pengajuan Keringanan Biaya", "icon": Icons.volunteer_activism},
      {"cat": "Keterangan", "title": "Surat Keterangan Usaha (SKU)", "desc": "Pernyataan Memiliki Usaha", "icon": Icons.storefront},
      {"cat": "Keterangan", "title": "Pengantar SKCK", "desc": "Syarat Pembuatan Catatan Kepolisian", "icon": Icons.local_police},
      // Hukum
      {"cat": "Hukum", "title": "Keterangan Ahli Waris", "desc": "Pernyataan Silsilah Keluarga", "icon": Icons.account_balance},
      {"cat": "Hukum", "title": "Keterangan Belum Menikah", "desc": "Status Perkawinan Lajang", "icon": Icons.favorite_border},
      {"cat": "Hukum", "title": "Keterangan Janda/Duda", "desc": "Pernyataan Status Cerai Mati/Hidup", "icon": Icons.favorite_border},
      {"cat": "Hukum", "title": "Surat Kuasa Tanah", "desc": "Pelimpahan Wewenang Properti", "icon": Icons.landscape},
    ];

    List<SuratModel> result = [];
    int idCounter = 1;

    for (var data in rawData) {
      String t = (data["title"] as String).toLowerCase();
      
      // -- Requirements --
      List<String> reqs = ["Fotokopi KTP / E-KTP", "Fotokopi Kartu Keluarga (KK)"];
      if (t.contains("usaha") || t.contains("bangunan") || t.contains("reklame")) {
        reqs.add("Foto Tempat Usaha / Objek Lengkap");
        reqs.add("Surat Pengantar RT/RW");
      } else if (t.contains("pindah") || t.contains("domisili")) {
        reqs.add("Surat Pengantar RT/RW");
        reqs.add("Bukti Kepemilikan Lahan / Sewa");
      } else if (t.contains("tidak mampu") || t.contains("sktm")) {
        reqs.add("Surat Pengantar RT/RW");
        reqs.add("Surat Pernyataan Bermaterai");
      } else {
        reqs.add("Surat Pengantar RT/RW");
      }

      // -- Fields --
      List<SuratFieldModel> fields = [];
      if (t.contains("usaha") || t.contains("sku") || t.contains("situ")) {
        fields.add(SuratFieldModel(label: "Nama Usaha", hint: "Misal: Warung Sembako Berkah"));
        fields.add(SuratFieldModel(label: "Jenis Usaha", hint: "Misal: Kuliner / Dagang"));
        fields.add(SuratFieldModel(label: "Alamat Usaha", hint: "Masukkan alamat lengkap usaha", maxLines: 3));
      } else if (t.contains("pindah")) {
        fields.add(SuratFieldModel(label: "Alamat Tujuan", hint: "Masukkan alamat domisili baru", maxLines: 3));
        fields.add(SuratFieldModel(label: "Alasan Pindah", hint: "Misal: Mengikuti Keluarga / Pekerjaan"));
      } else if (t.contains("tidak mampu") || t.contains("sktm")) {
        fields.add(SuratFieldModel(label: "Keperluan / Tujuan", hint: "Misal: Pendaftaran Sekolah Anak"));
        fields.add(SuratFieldModel(label: "Penghasilan Per Bulan", hint: "Misal: Rp 1.500.000"));
      } else {
        fields.add(SuratFieldModel(label: "Keperluan", hint: "Jelaskan keperluan pengajuan surat ini", maxLines: 2));
      }

      // -- Template Konten --
      String templateKonten = "";
      if (t.contains("usaha") || t.contains("sku") || t.contains("situ")) {
        templateKonten = "Menerangkan bahwa individu di atas memiliki usaha yang berdomisili di Kelurahan Maju. Surat keterangan ini menyatakan legalitas dasar usaha tersebut untuk keperluan administrasi perbankan atau izin lanjutan.";
      } else if (t.contains("kk") || t.contains("ktp") || t.contains("akta")) {
        templateKonten = "Menerangkan bahwa individu di atas sedang dalam proses pengurusan dokumen kependudukan sipil tingkat Kelurahan. Surat pengantar ini wajib dibawa ke Dinas Kependudukan dan Pencatatan Sipil.";
      } else if (t.contains("pindah")) {
        templateKonten = "Menerangkan bahwa individu di atas telah mengajukan permohonan pindah domisili dari Kelurahan Maju ke alamat tujuan. Semua catatan kewajiban di kelurahan asal telah diselesaikan.";
      } else if (t.contains("tidak mampu") || t.contains("sktm")) {
        templateKonten = "Menerangkan bahwa individu tersebut di atas benar-benar warga Kelurahan Maju yang berstatus janda/duda/berpenghasilan rendah, sehingga layak untuk mendapatkan program bantuan kesejahteraan atau keringanan biaya pendidikan.";
      } else if (t.contains("skck")) {
        templateKonten = "Menerangkan bahwa warga tersebut di atas berkelakuan baik, tidak bermasalah dalam lingkungan sosial, dan surat pengantar ini digunakan untuk keperluan kepolisian (SKCK).";
      } else if (data["cat"] == "Hukum") {
        templateKonten = "Menerangkan status hukum dan/atau sipil individu di atas telah sesuai dengan catatan register Kelurahan Maju berdasar bukti-bukti sah yang dilampirkan.";
      } else {
        templateKonten = "Menerangkan bahwa individu di atas adalah benar warga Kelurahan Maju dan bermaksud mengurus keperluan administrasi sesuai ketentuan. Demikian surat ini dibuat agar dapat dipergunakan sebagaimana mestinya.";
      }

      var iconData = data["icon"] as IconData;

      result.add(SuratModel(
        id: "SRT-${idCounter.toString().padLeft(3, '0')}",
        category: data["cat"],
        title: data["title"],
        description: data["desc"],
        iconCodePoint: iconData.codePoint,
        iconFontFamily: iconData.fontFamily,
        requirements: reqs,
        fields: fields,
        templateKonten: templateKonten,
      ));
      idCounter++;
    }

    return result;
  }
}
