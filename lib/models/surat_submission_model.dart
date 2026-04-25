import 'package:cloud_firestore/cloud_firestore.dart';

class SuratSubmissionModel {
  final String id;
  final String userId;
  final String nama;
  final String nik;
  final String jenisSurat;
  final String status;
  final String rt;
  final String rw;
  final String kelurahan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SuratSubmissionModel({
    required this.id,
    required this.userId,
    required this.nama,
    required this.nik,
    required this.jenisSurat,
    required this.status,
    required this.rt,
    required this.rw,
    required this.kelurahan,
    this.createdAt,
    this.updatedAt,
  });

  factory SuratSubmissionModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
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
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
