import 'package:cloud_firestore/cloud_firestore.dart';

class RondaScheduleModel {
  final String id;
  final String rt;
  final String rw;
  final DateTime tanggal;
  final String lokasi;
  final List<String> anggota;
  final DateTime? createdAt;

  RondaScheduleModel({
    required this.id,
    required this.rt,
    required this.rw,
    required this.tanggal,
    required this.lokasi,
    required this.anggota,
    this.createdAt,
  });

  factory RondaScheduleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RondaScheduleModel(
      id: doc.id,
      rt: data['rt'] ?? '',
      rw: data['rw'] ?? '',
      tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lokasi: data['lokasi'] ?? 'Pos Ronda',
      anggota: List<String>.from(data['anggota'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

