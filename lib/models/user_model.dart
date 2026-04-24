import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String nik;
  final String role; // 'warga' | 'rt' | 'rw' | 'lurah' | 'super_admin'
  final String status; // 'pending' | 'aktif' | 'ditolak'
  final String? selfieUrl;
  final String? ktpUrl;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? golDarah;
  final String? agama;
  final String? statusPerkawinan;
  final String? pekerjaan;
  final String? kewarganegaraan;
  final String? alamat;
  final String? rt;
  final String? rw;
  final String? kelurahan;
  final String? kecamatan;
  final String? kabupaten;
  final String? nomorTelepon;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.nik,
    required this.role,
    required this.status,
    this.selfieUrl,
    this.ktpUrl,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.golDarah,
    this.agama,
    this.statusPerkawinan,
    this.pekerjaan,
    this.kewarganegaraan,
    this.alamat,
    this.rt,
    this.rw,
    this.kelurahan,
    this.kecamatan,
    this.kabupaten,
    this.nomorTelepon,
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nama: data['nama'] ?? '',
      nik: data['nik'] ?? '',
      role: data['role'] ?? 'warga',
      status: data['status'] ?? 'pending',
      selfieUrl: data['selfieUrl'],
      ktpUrl: data['ktpUrl'],
      tempatLahir: data['tempat_lahir'],
      tanggalLahir: data['tanggal_lahir'],
      jenisKelamin: data['jenis_kelamin'],
      golDarah: data['gol_darah'],
      agama: data['agama'],
      statusPerkawinan: data['status_perkawinan'],
      pekerjaan: data['pekerjaan'],
      kewarganegaraan: data['kewarganegaraan'],
      alamat: data['alamat'],
      rt: data['rt'],
      rw: data['rw'],
      kelurahan: data['kelurahan'],
      kecamatan: data['kecamatan'],
      kabupaten: data['kabupaten'],
      nomorTelepon: data['nomor_telepon'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nama': nama,
      'nik': nik,
      'role': role,
      'status': status,
      if (selfieUrl != null) 'selfieUrl': selfieUrl,
      if (ktpUrl != null) 'ktpUrl': ktpUrl,
      if (tempatLahir != null) 'tempat_lahir': tempatLahir,
      if (tanggalLahir != null) 'tanggal_lahir': tanggalLahir,
      if (jenisKelamin != null) 'jenis_kelamin': jenisKelamin,
      if (golDarah != null) 'gol_darah': golDarah,
      if (agama != null) 'agama': agama,
      if (statusPerkawinan != null) 'status_perkawinan': statusPerkawinan,
      if (pekerjaan != null) 'pekerjaan': pekerjaan,
      if (kewarganegaraan != null) 'kewarganegaraan': kewarganegaraan,
      if (alamat != null) 'alamat': alamat,
      if (rt != null) 'rt': rt,
      if (rw != null) 'rw': rw,
      if (kelurahan != null) 'kelurahan': kelurahan,
      if (kecamatan != null) 'kecamatan': kecamatan,
      if (kabupaten != null) 'kabupaten': kabupaten,
      if (nomorTelepon != null) 'nomor_telepon': nomorTelepon,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  /// Label ramah untuk ditampilkan di UI
  String get roleLabel {
    switch (role) {
      case 'super_admin':
        return 'Super Admin';
      case 'lurah':
        return 'Lurah';
      case 'rt':
        return 'Ketua RT';
      case 'rw':
        return 'Ketua RW';
      default:
        return 'Warga';
    }
  }
}
