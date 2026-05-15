import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import 'aktivitas_service.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AktivitasService _aktivitasService = AktivitasService();

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  Future<void> submitReport({
    required UserModel reporter,
    required String title,
    required String description,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    final doc = await _reports.add({
      'reporterUid': reporter.uid,
      'reporterName': reporter.nama,
      'reporterRt': reporter.rt ?? '',
      'reporterRw': reporter.rw ?? '',
      'title': title.trim(),
      'description': description.trim(),
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'status': 'submitted',
      'currentLevel': 'rt',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _aktivitasService.addActivity(
      userId: reporter.uid,
      title: "Laporan Warga Dikirim",
      subtitle: title.trim(),
      status: "PROSES",
      activityType: "report",
      referenceId: doc.id,
    );
  }

  Stream<List<ReportModel>> streamReportsForRt({
    required String rt,
    required String rw,
  }) {
    if (rt.isEmpty || rw.isEmpty) return Stream.value([]);
    return _reports
        .where('reporterRt', isEqualTo: rt)
        .where('reporterRw', isEqualTo: rw)
        .where('currentLevel', isEqualTo: 'rt')
        .where('status', whereIn: ['submitted', 'in_review', 'escalated'])
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(ReportModel.fromFirestore).toList();
      list.sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });
      return list;
    });
  }

  Stream<List<ReportModel>> streamReportsForRw({required String rw}) {
    if (rw.isEmpty) return Stream.value([]);
    return _reports
        .where('reporterRw', isEqualTo: rw)
        .where('currentLevel', isEqualTo: 'rw')
        .where('status', whereIn: ['submitted', 'in_review', 'escalated'])
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(ReportModel.fromFirestore).toList();
      list.sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });
      return list;
    });
  }

  Stream<List<ReportModel>> streamReportsForLurah() {
    return _reports
        .where('currentLevel', isEqualTo: 'lurah')
        .where('status', whereIn: ['submitted', 'in_review', 'escalated'])
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map(ReportModel.fromFirestore).toList();
      list.sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });
      return list;
    });
  }

  Future<void> forwardReportToRw(String reportId) async {
    final reportDoc = await _reports.doc(reportId).get();
    final data = reportDoc.data();
    await _reports.doc(reportId).update({
      'currentLevel': 'rw',
      'status': 'escalated',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final reporterUid = data?['reporterUid'] as String?;
    if (reporterUid != null && reporterUid.isNotEmpty) {
      await _aktivitasService.addActivity(
        userId: reporterUid,
        title: "Laporan Diteruskan ke RW",
        subtitle: data?['title'] ?? 'Laporan warga',
        status: "PROSES",
        activityType: "report",
        referenceId: reportId,
      );
    }
  }

  Future<void> forwardReportToLurah(String reportId) async {
    final reportDoc = await _reports.doc(reportId).get();
    final data = reportDoc.data();
    await _reports.doc(reportId).update({
      'currentLevel': 'lurah',
      'status': 'escalated',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final reporterUid = data?['reporterUid'] as String?;
    if (reporterUid != null && reporterUid.isNotEmpty) {
      await _aktivitasService.addActivity(
        userId: reporterUid,
        title: "Laporan Diteruskan ke Lurah",
        subtitle: data?['title'] ?? 'Laporan warga',
        status: "PROSES",
        activityType: "report",
        referenceId: reportId,
      );
    }
  }

  Future<void> resolveReport(String reportId) async {
    final reportDoc = await _reports.doc(reportId).get();
    final data = reportDoc.data();
    await _reports.doc(reportId).update({
      'status': 'resolved',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final reporterUid = data?['reporterUid'] as String?;
    if (reporterUid != null && reporterUid.isNotEmpty) {
      await _aktivitasService.addActivity(
        userId: reporterUid,
        title: "Laporan Selesai Ditangani",
        subtitle: data?['title'] ?? 'Laporan warga',
        status: "SELESAI",
        activityType: "report",
        referenceId: reportId,
      );
    }
  }

  Stream<List<ReportModel>> streamHistoryForRt({
    required String rt,
    required String rw,
  }) {
    if (rt.isEmpty || rw.isEmpty) return Stream.value([]);
    // Riwayat adalah laporan yang SUDAH diteruskan (currentLevel != rt) ATAU sudah resolved
    return _reports
        .where('reporterRt', isEqualTo: rt)
        .where('reporterRw', isEqualTo: rw)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          // Filter di client side karena Firestore query limitations
          return snapshot.docs
              .map(ReportModel.fromFirestore)
              .where((r) => r.currentLevel != 'rt' || r.status == 'resolved' || r.status == 'rejected')
              .toList();
        });
  }
}

