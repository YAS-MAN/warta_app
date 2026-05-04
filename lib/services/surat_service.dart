import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/surat_submission_model.dart';
import '../models/surat_model.dart';
import '../models/user_model.dart';
import 'aktivitas_service.dart';

class SuratService {
  static final List<SuratModel> _allSurat = _generateDummySurat();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AktivitasService _aktivitasService = AktivitasService();

  CollectionReference<Map<String, dynamic>> get _suratSubmissions =>
      _firestore.collection('surat_submissions');

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
      return _allSurat.firstWhere(
          (s) => s.title.toLowerCase() == title.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  Future<List<SuratModel>> getPopularSurat() async {
    await Future.delayed(const Duration(milliseconds: 300));
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

  Future<void> submitSurat({
    required UserModel user,
    required String jenisSurat,
  }) async {
    final trimmedJenisSurat = jenisSurat.trim();
    final submissionDoc = await _suratSubmissions.add({
      'userId': user.uid,
      'nama': user.nama,
      'nik': user.nik,
      'jenisSurat': trimmedJenisSurat,
      'status': 'PROSES',
      'rt': user.rt ?? '',
      'rw': user.rw ?? '',
      'kelurahan': user.kelurahan ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _aktivitasService.addActivity(
      userId: user.uid,
      title: trimmedJenisSurat,
      subtitle: 'Pengajuan surat berhasil dikirim dan menunggu verifikasi RT.',
      status: 'PROSES',
      activityType: 'surat',
      referenceId: submissionDoc.id,
    );
  }

  Stream<List<SuratSubmissionModel>> streamSubmissionsForRt({
    required String kelurahan,
    required String rw,
    required String rt,
  }) {
    if (kelurahan.isEmpty || rw.isEmpty || rt.isEmpty) {
      return Stream.value([]);
    }
    return _suratSubmissions
        .where('kelurahan', isEqualTo: kelurahan)
        .where('rw', isEqualTo: rw)
        .where('rt', isEqualTo: rt)
        .where('status', isEqualTo: 'PROSES')
        .snapshots()
        .map((snapshot) {
      final list =
          snapshot.docs.map(SuratSubmissionModel.fromFirestore).toList();
      list.sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });
      return list;
    });
  }

  Future<void> updateSubmissionStatus({
    required String submissionId,
    required String newStatus,
    required String actedByUid,
  }) async {
    final normalizedStatus = newStatus.toUpperCase();
    final doc = await _suratSubmissions.doc(submissionId).get();
    final data = doc.data();
    if (data == null) return;

    await _suratSubmissions.doc(submissionId).update({
      'status': normalizedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'actedByUid': actedByUid,
    });

    final userId = (data['userId'] ?? '').toString();
    final jenisSurat = (data['jenisSurat'] ?? 'Pengajuan surat').toString();
    if (userId.isNotEmpty) {
      await _aktivitasService.addActivity(
        userId: userId,
        title: jenisSurat,
        subtitle: normalizedStatus == 'BERHASIL'
            ? 'Pengajuan surat telah disetujui RT.'
            : 'Pengajuan surat ditolak RT.',
        status: normalizedStatus,
        activityType: 'surat',
        referenceId: submissionId,
      );
    }
  }

  // ─── MASTER DATA SURAT ───────────────────────────────────────────────────────

  static const _reqKtp = SuratRequirement(
    id: 'ktp_scan',
    label: 'Scan KTP / E-KTP',
    description: 'Foto KTP yang terdaftar saat registrasi',
    type: RequirementType.auto,
    autoSourceField: 'ktpUrl',
  );

  static const _reqKk = SuratRequirement(
    id: 'kk_scan',
    label: 'Scan Kartu Keluarga (KK)',
    description: 'Foto KK dari profil Anda',
    type: RequirementType.auto,
    autoSourceField: 'kkUrl',
  );

  static const _reqFormF102 = SuratRequirement(
    id: 'form_f102',
    label: 'Formulir F1-02 (Peristiwa Kependudukan)',
    description: 'Download & isi formulir dari Disdukcapil, lalu upload foto/scan',
    type: RequirementType.upload,
  );

  static const _reqFormF103 = SuratRequirement(
    id: 'form_f103',
    label: 'Formulir F1-03 (Perpindahan Penduduk)',
    description: 'Download & isi formulir perpindahan dari Disdukcapil',
    type: RequirementType.upload,
  );

  static const _reqFormF201 = SuratRequirement(
    id: 'form_f201',
    label: 'Formulir F2-01 (Pelaporan Pencatatan Sipil)',
    description: 'Download & isi formulir F2.01 dari Disdukcapil, lalu upload',
    type: RequirementType.upload,
  );

  static List<SuratModel> _generateDummySurat() {
    int id = 1;
    SuratModel mk(String cat, String title, String desc, IconData icon,
        List<SuratRequirement> reqs, List<SuratFieldModel> fields,
        String tmpl) {
      return SuratModel(
        id: 'SRT-${(id++).toString().padLeft(3, '0')}',
        category: cat,
        title: title,
        description: desc,
        iconCodePoint: icon.codePoint,
        iconFontFamily: icon.fontFamily,
        requirements: reqs,
        fields: fields,
        templateKonten: tmpl,
      );
    }

    return [
      // ── ADMINISTRASI ──────────────────────────────────────────────────────
      mk(
        "Administrasi", "Kartu Keluarga (KK)", "Pembuatan atau Perubahan KK",
        Icons.family_restroom,
        [
          _reqKtp,
          _reqKk,
          _reqFormF102,
          const SuratRequirement(
            id: 'dok_pendukung_kk',
            label: 'Dokumen Pendukung (Buku Nikah / Surat Cerai / Pernyataan)',
            description: 'Sesuai jenis permohonan KK Anda',
            type: RequirementType.upload,
          ),
        ],
        [SuratFieldModel(label: "Jenis Permohonan KK", hint: "Misal: Pecah KK / Cetak Ulang")],
        "Menerangkan bahwa individu di atas sedang dalam proses pengurusan Kartu Keluarga melalui sistem WARTA.",
      ),
      mk(
        "Administrasi", "Kartu Tanda Penduduk (KTP)", "Perekaman atau Penggantian KTP Baru",
        Icons.badge,
        [
          _reqKk,
          _reqFormF102,
          const SuratRequirement(
            id: 'surat_hilang_ktp',
            label: 'Surat Kehilangan dari Kepolisian (jika hilang/rusak)',
            description: 'Surat keterangan kehilangan KTP dari Polsek/Polres',
            type: RequirementType.upload,
          ),
        ],
        [SuratFieldModel(label: "Jenis Permohonan KTP", hint: "Misal: Perekaman Baru / Hilang / Rusak")],
        "Menerangkan bahwa individu di atas sedang dalam proses pengurusan KTP-el melalui Disdukcapil Surabaya.",
      ),
      mk(
        "Administrasi", "Akta Kelahiran", "Penerbitan Surat Keterangan Lahir",
        Icons.child_care,
        [
          _reqKtp,
          _reqKk,
          _reqFormF201,
          const SuratRequirement(
            id: 'surat_lahir_bidan',
            label: 'Surat Keterangan Lahir dari Bidan / Dokter / RS',
            description: 'Surat resmi tempat kelahiran anak',
            type: RequirementType.upload,
          ),
          const SuratRequirement(
            id: 'buku_nikah_ortu',
            label: 'Buku Nikah / Akta Perkawinan Orang Tua',
            description: 'Bukti perkawinan sah orang tua',
            type: RequirementType.upload,
          ),
        ],
        [
          SuratFieldModel(label: "Nama Anak", hint: "Nama lengkap anak"),
          SuratFieldModel(label: "Tanggal Lahir Anak", hint: "DD/MM/YYYY"),
          SuratFieldModel(label: "Tempat Lahir", hint: "Kota/Kabupaten"),
        ],
        "Menerangkan bahwa individu di atas mengajukan permohonan Akta Kelahiran untuk anggota keluarga melalui Disdukcapil Surabaya.",
      ),
      mk(
        "Administrasi", "Akta Kematian", "Pelaporan Meninggal Dunia",
        Icons.nights_stay,
        [
          _reqKtp,
          _reqFormF201,
          const SuratRequirement(
            id: 'surat_kematian_dokter',
            label: 'Surat Keterangan Kematian dari Dokter / Pernyataan Keluarga',
            description: 'Surat resmi yang menerangkan kematian',
            type: RequirementType.upload,
          ),
          const SuratRequirement(
            id: 'ktp_jenazah',
            label: 'NIK / KTP / KK Jenazah',
            description: 'Dokumen identitas almarhum/almarhumah',
            type: RequirementType.upload,
          ),
        ],
        [
          SuratFieldModel(label: "Nama Almarhum/ah", hint: "Nama lengkap jenazah"),
          SuratFieldModel(label: "Tanggal Meninggal", hint: "DD/MM/YYYY"),
        ],
        "Menerangkan bahwa individu di atas mengajukan permohonan Akta Kematian melalui sistem WARTA.",
      ),
      mk(
        "Administrasi", "Surat Pindah", "Mengurus Perpindahan Domisili",
        Icons.transfer_within_a_station,
        [
          _reqKtp,
          _reqKk,
          _reqFormF102,
          _reqFormF103,
          const SuratRequirement(
            id: 'skpwni',
            label: 'Surat Keterangan Pindah WNI (SKPWNI)',
            description: 'Surat pindah dari daerah asal',
            type: RequirementType.upload,
          ),
          const SuratRequirement(
            id: 'alamat_tujuan',
            label: 'Alamat Tujuan Pindah',
            description: 'Isi alamat lengkap tujuan pindah domisili',
            type: RequirementType.text,
            hint: 'Jl. ... No. ... RT/RW ... Kelurahan ... Kota ...',
          ),
          const SuratRequirement(
            id: 'alasan_pindah',
            label: 'Alasan Pindah',
            description: 'Sebutkan alasan kepindahan Anda',
            type: RequirementType.text,
            hint: 'Misal: Mengikuti keluarga / Pekerjaan',
          ),
        ],
        [
          SuratFieldModel(label: "Alamat Tujuan", hint: "Alamat lengkap domisili baru", maxLines: 3),
          SuratFieldModel(label: "Alasan Pindah", hint: "Misal: Mengikuti Keluarga / Pekerjaan"),
        ],
        "Menerangkan bahwa individu di atas mengajukan permohonan pindah domisili dari wilayah ini ke alamat tujuan.",
      ),

      // ── PERIZINAN ────────────────────────────────────────────────────────
      mk(
        "Perizinan", "Surat Izin Tempat Usaha (SITU)", "Pendaftaran Lokasi Usaha",
        Icons.storefront,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'foto_tempat_usaha',
            label: 'Foto Tempat Usaha',
            description: 'Foto tampak depan lokasi usaha yang jelas',
            type: RequirementType.upload,
          ),
        ],
        [
          SuratFieldModel(label: "Nama Usaha", hint: "Misal: Warung Sembako Berkah"),
          SuratFieldModel(label: "Jenis Usaha", hint: "Misal: Kuliner / Dagang"),
          SuratFieldModel(label: "Alamat Usaha", hint: "Alamat lengkap usaha", maxLines: 3),
        ],
        "Menerangkan bahwa individu di atas memiliki usaha yang berdomisili di wilayah ini. Surat keterangan ini menyatakan legalitas dasar usaha tersebut.",
      ),
      mk(
        "Perizinan", "Izin Mendirikan Bangunan (IMB)", "Persetujuan Pendirian Bangunan",
        Icons.domain,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'foto_lahan',
            label: 'Foto Lahan / Lokasi Bangunan',
            description: 'Foto kondisi lahan saat ini',
            type: RequirementType.upload,
          ),
          const SuratRequirement(
            id: 'sertifikat_tanah',
            label: 'Sertifikat / Bukti Kepemilikan Tanah',
            description: 'Dokumen kepemilikan lahan',
            type: RequirementType.upload,
          ),
        ],
        [
          SuratFieldModel(label: "Alamat Bangunan", hint: "Alamat lengkap lokasi bangunan", maxLines: 2),
          SuratFieldModel(label: "Jenis Bangunan", hint: "Misal: Rumah Tinggal / Ruko"),
        ],
        "Menerangkan bahwa individu di atas mengajukan permohonan izin mendirikan bangunan di wilayah ini.",
      ),
      mk(
        "Perizinan", "Izin Reklame", "Pemasangan Papan Reklame/Spanduk",
        Icons.campaign,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'foto_reklame',
            label: 'Foto Desain / Objek Reklame',
            description: 'Foto atau desain reklame yang akan dipasang',
            type: RequirementType.upload,
          ),
        ],
        [
          SuratFieldModel(label: "Jenis Reklame", hint: "Misal: Spanduk / Billboard / Neon Box"),
          SuratFieldModel(label: "Lokasi Pemasangan", hint: "Alamat lengkap lokasi reklame"),
        ],
        "Menerangkan bahwa individu di atas mengajukan permohonan izin pemasangan reklame di wilayah ini.",
      ),
      mk(
        "Perizinan", "Izin Keramaian", "Pemberitahuan Acara Skala Besar",
        Icons.festival,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'proposal_acara',
            label: 'Proposal / Rencana Kegiatan',
            description: 'Dokumen rencana acara secara lengkap',
            type: RequirementType.upload,
          ),
        ],
        [
          SuratFieldModel(label: "Nama Acara", hint: "Misal: Peringatan HUT RI ke-80"),
          SuratFieldModel(label: "Tanggal Acara", hint: "DD/MM/YYYY"),
          SuratFieldModel(label: "Lokasi Acara", hint: "Alamat lengkap lokasi kegiatan"),
        ],
        "Menerangkan bahwa individu di atas mengajukan permohonan izin keramaian untuk acara yang akan diselenggarakan di wilayah ini.",
      ),

      // ── KETERANGAN ───────────────────────────────────────────────────────
      mk(
        "Keterangan", "Surat Keterangan Domisili", "Bukti Tempat Tinggal Sementara",
        Icons.location_on,
        [
          _reqKtp,
          _reqKk,
        ],
        [SuratFieldModel(label: "Keperluan", hint: "Misal: Pendaftaran Sekolah / Keperluan Bank")],
        "Menerangkan bahwa individu di atas benar-benar berdomisili di wilayah ini sesuai data kependudukan.",
      ),
      mk(
        "Keterangan", "Keterangan Tidak Mampu (SKTM)", "Pengajuan Keringanan Biaya",
        Icons.volunteer_activism,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'surat_pernyataan_bermaterai',
            label: 'Surat Pernyataan Tidak Mampu Bermaterai',
            description: 'Pernyataan kondisi ekonomi yang ditandatangani di atas materai',
            type: RequirementType.upload,
          ),
        ],
        [
          SuratFieldModel(label: "Keperluan / Tujuan SKTM", hint: "Misal: Pendaftaran Sekolah Anak"),
          SuratFieldModel(label: "Penghasilan Per Bulan", hint: "Misal: Rp 1.500.000"),
        ],
        "Menerangkan bahwa individu tersebut di atas adalah warga yang berstatus tidak mampu secara ekonomi, sehingga layak mendapat keringanan.",
      ),
      mk(
        "Keterangan", "Surat Keterangan Usaha (SKU)", "Pernyataan Memiliki Usaha",
        Icons.storefront,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'foto_usaha_sku',
            label: 'Foto Tempat / Kegiatan Usaha',
            description: 'Foto yang membuktikan keberadaan usaha',
            type: RequirementType.upload,
          ),
        ],
        [
          SuratFieldModel(label: "Nama Usaha", hint: "Misal: Warung Sembako Berkah"),
          SuratFieldModel(label: "Jenis Usaha", hint: "Misal: Kuliner / Dagang"),
          SuratFieldModel(label: "Alamat Usaha", hint: "Masukkan alamat lengkap usaha", maxLines: 3),
        ],
        "Menerangkan bahwa individu di atas memiliki usaha yang berdomisili di wilayah ini.",
      ),
      mk(
        "Keterangan", "Pengantar SKCK", "Syarat Pembuatan Catatan Kepolisian",
        Icons.local_police,
        [
          _reqKtp,
          _reqKk,
        ],
        [SuratFieldModel(label: "Keperluan SKCK", hint: "Misal: Melamar Pekerjaan / Pendaftaran PNS")],
        "Menerangkan bahwa warga tersebut di atas berkelakuan baik dan surat pengantar ini digunakan untuk keperluan pembuatan SKCK.",
      ),

      // ── HUKUM ────────────────────────────────────────────────────────────
      mk(
        "Hukum", "Keterangan Ahli Waris", "Pernyataan Silsilah Keluarga",
        Icons.account_balance,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'akta_lahir_waris',
            label: 'Akta Kelahiran / Surat Kematian Pewaris',
            description: 'Dokumen yang membuktikan hubungan waris',
            type: RequirementType.upload,
          ),
        ],
        [SuratFieldModel(label: "Nama Pewaris (Almarhum/ah)", hint: "Nama lengkap yang meninggal")],
        "Menerangkan status silsilah dan hak ahli waris individu di atas sesuai catatan register kelurahan.",
      ),
      mk(
        "Hukum", "Keterangan Belum Menikah", "Status Perkawinan Lajang",
        Icons.favorite_border,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'dok_status_belum_nikah',
            label: 'Surat Pernyataan Belum Menikah (jika diperlukan)',
            description: 'Surat pernyataan bermaterai status lajang',
            type: RequirementType.upload,
          ),
        ],
        [SuratFieldModel(label: "Keperluan", hint: "Misal: Melamar Pekerjaan / Pendaftaran Nikah")],
        "Menerangkan bahwa individu di atas berstatus belum menikah sesuai catatan register kelurahan.",
      ),
      mk(
        "Hukum", "Keterangan Janda/Duda", "Pernyataan Status Cerai Mati/Hidup",
        Icons.favorite_border,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'dok_cerai',
            label: 'Akta Cerai / Akta Kematian Pasangan',
            description: 'Bukti status cerai hidup atau cerai mati',
            type: RequirementType.upload,
          ),
        ],
        [SuratFieldModel(label: "Keperluan", hint: "Misal: Keperluan Administrasi / Menikah Kembali")],
        "Menerangkan status hukum individu di atas sebagai janda/duda sesuai bukti sah yang dilampirkan.",
      ),
      mk(
        "Hukum", "Surat Kuasa Tanah", "Pelimpahan Wewenang Properti",
        Icons.landscape,
        [
          _reqKtp,
          _reqKk,
          const SuratRequirement(
            id: 'sertifikat_tanah_kuasa',
            label: 'Sertifikat / Bukti Kepemilikan Tanah',
            description: 'Dokumen tanah yang akan dikuasakan',
            type: RequirementType.upload,
          ),
        ],
        [
          SuratFieldModel(label: "Nama Penerima Kuasa", hint: "Nama lengkap penerima kuasa"),
          SuratFieldModel(label: "Objek Kuasa (Tanah/Properti)", hint: "Deskripsi singkat objek", maxLines: 2),
        ],
        "Menerangkan bahwa individu di atas memberikan kuasa penuh atas pengelolaan properti/tanah kepada pihak yang tercantum.",
      ),
    ];
  }
}
