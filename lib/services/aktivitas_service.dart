import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aktivitas_model.dart';

class AktivitasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Color greenSuccess = Color(0xFF10B981);
  static const Color bgSuccess = Color(0xFFD1FAE5);
  static const Color yellowProcess = Color(0xFFF59E0B);
  static const Color bgProcess = Color(0xFFFEF3C7);
  static const Color redFailed = Color(0xFFEF4444);
  static const Color bgFailed = Color(0xFFFEE2E2);

  CollectionReference<Map<String, dynamic>> get _activities =>
      _firestore.collection('activities');

  Future<void> addActivity({
    required String userId,
    required String title,
    required String subtitle,
    required String status,
    required String activityType,
    String? referenceId,
  }) async {
    await _activities.add({
      'userId': userId,
      'title': title,
      'subtitle': subtitle,
      'status': status, // PROSES | BERHASIL | DITOLAK | SELESAI
      'activityType': activityType, // report | surat | iuran | auth | system
      'referenceId': referenceId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AktivitasModel>> streamUserActivities(String userId, {int? limit}) {
    if (userId.isEmpty) return Stream.value([]);
    Query<Map<String, dynamic>> query = _activities
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
    });
  }

  Future<List<AktivitasModel>> getAktivitasList(String userId) async {
    if (userId.isEmpty) return [];
    final snapshot = await _activities
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
  }

  Future<List<AktivitasModel>> getRecentAktivitas(
    String userId, {
    int limit = 2,
  }) async {
    if (userId.isEmpty) return [];
    final snapshot = await _activities
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
  }

  AktivitasModel _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final status = (data['status'] ?? 'PROSES').toString().toUpperCase();
    final type = (data['activityType'] ?? 'system').toString().toLowerCase();
    final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
    final style = _styleFor(type, status);

    return AktivitasModel(
      userId: data['userId'] ?? '',
      id: doc.id,
      title: data['title'] ?? 'Aktivitas',
      subtitle: data['subtitle'] ?? '-',
      date: _formatRelative(timestamp),
      status: status,
      iconCodePoint: style.icon.codePoint,
      iconFontFamily: style.icon.fontFamily,
      iconColor: style.iconColor,
      iconBgColor: style.iconBgColor,
      statusTextColor: style.statusTextColor,
      statusBgColor: style.statusBgColor,
    );
  }

  String _formatRelative(DateTime? value) {
    if (value == null) return 'Baru saja';
    final diff = DateTime.now().difference(value);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  _ActivityStyle _styleFor(String type, String status) {
    if (status == 'BERHASIL' || status == 'SELESAI') {
      return _ActivityStyle(
        icon: type == 'report' ? Icons.check_circle : Icons.verified,
        iconColor: greenSuccess,
        iconBgColor: bgSuccess,
        statusTextColor: greenSuccess,
        statusBgColor: bgSuccess,
      );
    }

    if (status == 'DITOLAK') {
      return _ActivityStyle(
        icon: Icons.cancel,
        iconColor: redFailed,
        iconBgColor: bgFailed,
        statusTextColor: redFailed,
        statusBgColor: bgFailed,
      );
    }

    return _ActivityStyle(
      icon: type == 'report' ? Icons.report_problem : Icons.pending_actions,
      iconColor: yellowProcess,
      iconBgColor: bgProcess,
      statusTextColor: yellowProcess,
      statusBgColor: bgProcess,
    );
  }
}

class _ActivityStyle {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color statusTextColor;
  final Color statusBgColor;

  _ActivityStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.statusTextColor,
    required this.statusBgColor,
  });
}
