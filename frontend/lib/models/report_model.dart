import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String reporterUid;
  final String reporterName;
  final String reporterRt;
  final String reporterRw;
  final String title;
  final String description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String status; // submitted | in_review | escalated | resolved | rejected
  final String currentLevel; // rt | rw | lurah
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReportModel({
    required this.id,
    required this.reporterUid,
    required this.reporterName,
    required this.reporterRt,
    required this.reporterRw,
    required this.title,
    required this.description,
    required this.status,
    required this.currentLevel,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      reporterUid: data['reporterUid'] ?? '',
      reporterName: data['reporterName'] ?? '',
      reporterRt: data['reporterRt'] ?? '',
      reporterRw: data['reporterRw'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      status: data['status'] ?? 'submitted',
      currentLevel: data['currentLevel'] ?? 'rt',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

