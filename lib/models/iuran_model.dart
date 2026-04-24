import 'package:cloud_firestore/cloud_firestore.dart';

class IuranRtModel {
  final String id;
  final String kelurahan;
  final String rw;
  final String rt;
  final int nominalWajib;
  final bool isActive;
  final String qrImageUrl;
  final String bankName;
  final String accountNumber;

  IuranRtModel({
    required this.id,
    required this.kelurahan,
    required this.rw,
    required this.rt,
    required this.nominalWajib,
    required this.isActive,
    required this.qrImageUrl,
    required this.bankName,
    required this.accountNumber,
  });

  factory IuranRtModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return IuranRtModel(
      id: doc.id,
      kelurahan: data['kelurahan'] ?? '',
      rw: data['rw'] ?? '',
      rt: data['rt'] ?? '',
      nominalWajib: data['nominalWajib'] ?? 0,
      isActive: data['isActive'] ?? false,
      qrImageUrl: data['qrImageUrl'] ?? '',
      bankName: data['bankName'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kelurahan': kelurahan,
      'rw': rw,
      'rt': rt,
      'nominalWajib': nominalWajib,
      'isActive': isActive,
      'qrImageUrl': qrImageUrl,
      'bankName': bankName,
      'accountNumber': accountNumber,
    };
  }
}

class IuranModel {
  final String id;
  final String uidWarga;
  final String namaWarga;
  final String rt;
  final String rw;
  final String kelurahan;
  final String bulan;
  final String tahun;
  final int nominal;
  final int status; // 0 = Pending, 1 = Lunas, 2 = Ditolak
  final String buktiImageUrl;
  final DateTime createdAt;

  IuranModel({
    required this.id,
    required this.uidWarga,
    required this.namaWarga,
    required this.rt,
    required this.rw,
    required this.kelurahan,
    required this.bulan,
    required this.tahun,
    required this.nominal,
    required this.status,
    required this.buktiImageUrl,
    required this.createdAt,
  });

  factory IuranModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return IuranModel(
      id: doc.id,
      uidWarga: data['uidWarga'] ?? '',
      namaWarga: data['namaWarga'] ?? '',
      rt: data['rt'] ?? '',
      rw: data['rw'] ?? '',
      kelurahan: data['kelurahan'] ?? '',
      bulan: data['bulan'] ?? '',
      tahun: data['tahun'] ?? '',
      nominal: data['nominal'] ?? 0,
      status: data['status'] ?? 0,
      buktiImageUrl: data['buktiImageUrl'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uidWarga': uidWarga,
      'namaWarga': namaWarga,
      'rt': rt,
      'rw': rw,
      'kelurahan': kelurahan,
      'bulan': bulan,
      'tahun': tahun,
      'nominal': nominal,
      'status': status,
      'buktiImageUrl': buktiImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
