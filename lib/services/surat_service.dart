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

  Future<List<SuratModel>> getFilteredSurat({
    String? category,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _allSurat.where((surat) {
      bool matchesCategory = true;
      if (category != null && category.isNotEmpty && category != "Semua Kategori") {
        matchesCategory = surat.category.toLowerCase() == category.toLowerCase();
      }
      bool matchesQuery = true;
      if (query != null && query.trim().isNotEmpty) {
        final kw = query.trim().toLowerCase();
        matchesQuery = surat.title.toLowerCase().contains(kw) ||
            surat.description.toLowerCase().contains(kw) ||
            surat.category.toLowerCase().contains(kw);
      }
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> submitSurat({
    required UserModel user,
    required String jenisSurat,
    String? customBody,
  }) async {
    final trimmedJenisSurat = jenisSurat.trim();

    // Cek duplikasi: jika sudah ada submission PROSES untuk jenis surat yang sama
    final existing = await _suratSubmissions
        .where('userId', isEqualTo: user.uid)
        .where('jenisSurat', isEqualTo: trimmedJenisSurat)
        .where('status', isEqualTo: 'PROSES')
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw Exception('Anda sudah memiliki pengajuan "$trimmedJenisSurat" yang sedang diproses.');
    }

    final submissionDoc = await _suratSubmissions.add({
      'userId': user.uid,
      'nama': user.nama,
      'nik': user.nik,
      'jenisSurat': trimmedJenisSurat,
      'status': 'PROSES',
      'rt': user.rt ?? '',
      'rw': user.rw ?? '',
      'kelurahan': user.kelurahan ?? '',
      'customBody': customBody,
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

  /// Ajukan ulang surat yang sudah DITOLAK — update submission lama (bukan buat baru)
  Future<void> resubmitSurat({
    required String submissionId,
    required String userId,
    String? customBody,
  }) async {
    await _suratSubmissions.doc(submissionId).update({
      'status': 'PROSES',
      'customBody': customBody,
      'rejectionReason': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update aktivitas lama, bukan buat baru
    await _aktivitasService.updateActivityByReference(
      userId: userId,
      referenceId: submissionId,
      newStatus: 'PROSES',
      newSubtitle: 'Pengajuan ulang surat telah dikirim dan menunggu verifikasi RT.',
    );
  }

  /// Ambil submission berdasarkan ID (untuk preview/detail)
  Future<SuratSubmissionModel?> getSubmissionById(String submissionId) async {
    if (submissionId.isEmpty) return null;
    final doc = await _suratSubmissions.doc(submissionId).get();
    if (!doc.exists || doc.data() == null) return null;
    // Build a QueryDocumentSnapshot-compatible object manually
    final data = doc.data()!;
    return SuratSubmissionModel(
      id: doc.id,
      userId: (data['userId'] ?? '').toString(),
      nama: (data['nama'] ?? '-').toString(),
      nik: (data['nik'] ?? '-').toString(),
      jenisSurat: (data['jenisSurat'] ?? 'Surat').toString(),
      status: (data['status'] ?? 'PROSES').toString().toUpperCase(),
      rt: (data['rt'] ?? '').toString(),
      rw: (data['rw'] ?? '').toString(),
      kelurahan: (data['kelurahan'] ?? '').toString(),
      customBody: data['customBody'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      actedByUid: data['actedByUid'] as String?,
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

  /// Stream surat submissions yang menunggu persetujuan RW (status 'PROSES RW')
  Stream<List<SuratSubmissionModel>> streamSubmissionsForRw({
    required String kelurahan,
    required String rw,
  }) {
    if (kelurahan.isEmpty || rw.isEmpty) {
      return Stream.value([]);
    }
    return _suratSubmissions
        .where('kelurahan', isEqualTo: kelurahan)
        .where('rw', isEqualTo: rw)
        .where('status', isEqualTo: 'PROSES RW')
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

  /// Stream surat submissions yang menunggu pengesahan akhir Lurah (status 'PROSES LURAH')
  Stream<List<SuratSubmissionModel>> streamSubmissionsForLurah({
    required String kelurahan,
  }) {
    if (kelurahan.isEmpty) {
      return Stream.value([]);
    }
    return _suratSubmissions
        .where('kelurahan', isEqualTo: kelurahan)
        .where('status', isEqualTo: 'PROSES LURAH')
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
    String? rejectionReason,
  }) async {
    final normalizedStatus = newStatus.toUpperCase();
    final doc = await _suratSubmissions.doc(submissionId).get();
    final data = doc.data();
    if (data == null) return;

    final Map<String, dynamic> updateData = {
      'status': normalizedStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'actedByUid': actedByUid,
    };
    if (rejectionReason != null && rejectionReason.isNotEmpty) {
      updateData['rejectionReason'] = rejectionReason;
    }

    await _suratSubmissions.doc(submissionId).update(updateData);

    final userId = (data['userId'] ?? '').toString();
    if (userId.isNotEmpty) {
      String subtitle = 'Pengajuan surat sedang diproses.';
      if (normalizedStatus == 'PROSES RW') {
        subtitle = 'Pengajuan surat telah disetujui RT. Menunggu verifikasi RW.';
      } else if (normalizedStatus == 'PROSES LURAH') {
        subtitle = 'Pengajuan surat telah disetujui RW. Menunggu pengesahan akhir dari Kelurahan/Lurah.';
      } else if (normalizedStatus == 'BERHASIL') {
        subtitle = 'Pengajuan surat telah disetujui dan diterbitkan resmi oleh Kelurahan.';
      } else if (normalizedStatus.contains('TOLAK')) {
        subtitle = 'Pengajuan surat ditolak.${rejectionReason != null && rejectionReason.isNotEmpty ? ' Alasan: $rejectionReason' : ''}';
      }

      // Update aktivitas yang sudah ada, bukan buat baru
      await _aktivitasService.updateActivityByReference(
        userId: userId,
        referenceId: submissionId,
        newStatus: normalizedStatus,
        newSubtitle: subtitle,
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
          const SuratRequirement(
            id: 'dok_pendukung_kk',
            label: 'Dokumen Pendukung (Buku Nikah / Surat Cerai / Pernyataan)',
            description: 'Sesuai jenis permohonan KK Anda',
            type: RequirementType.upload,
            isRequired: false,
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
          const SuratRequirement(
            id: 'surat_hilang_ktp',
            label: 'Surat Kehilangan dari Kepolisian (jika hilang/rusak)',
            description: 'Surat keterangan kehilangan KTP dari Polsek/Polres',
            type: RequirementType.upload,
            isRequired: false,
          ),
        ],
        [SuratFieldModel(label: "Jenis Permohonan KTP", hint: "Misal: Perekaman Baru / Hilang / Rusak")],
        "Menerangkan bahwa individu di atas sedang dalam proses pengurusan KTP-el melalui sistem WARTA.",
      ),
      mk(
        "Administrasi", "Akta Kelahiran", "Penerbitan Surat Keterangan Lahir",
        Icons.child_care,
        [
          _reqKtp,
          _reqKk,
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
        "Menerangkan bahwa individu di atas mengajukan permohonan Akta Kelahiran untuk anggota keluarga melalui sistem WARTA.",
      ),
      mk(
        "Administrasi", "Akta Kematian", "Pelaporan Meninggal Dunia",
        Icons.nights_stay,
        [
          _reqKtp,
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
          SuratFieldModel(label: "Penghasilan Per Bulan", hint: "Misal: 1.500.000", isCurrency: true),
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
            isRequired: false,
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
