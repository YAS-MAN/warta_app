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
  final String? customBody;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? actedByUid;

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
    this.customBody,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.actedByUid,
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
      customBody: data['customBody'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      actedByUid: data['actedByUid'] as String?,
    );
  }
}

