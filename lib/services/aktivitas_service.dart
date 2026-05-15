import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aktivitas_model.dart';

class AktivitasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Color greenSuccess = Color(0xFF10B981);
  static const Color bgSuccess = Color(0xFFD1FAE5);
  static const Color yellowProcess = Color(0xFFF59E0B);
  static const Color bgProcess = Color(0xFFFEF3C7);
  static const Color blueInfo = Color(0xFF0EA5E9);
  static const Color bgInfo = Color(0xFFE0F2FE);
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
      // Fallback client-side timestamp agar dokumen tidak hilang
      // saat persistence off (serverTimestamp bisa null sebelum server merespon)
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Stream<List<AktivitasModel>> streamUserActivities(String userId, {int? limit}) {
    if (userId.isEmpty) return Stream.value([]);
    Query<Map<String, dynamic>> query = _activities
        .where('userId', isEqualTo: userId);
    // Tidak pakai orderBy('createdAt') karena dengan persistenceEnabled: false,
    // dokumen baru memiliki createdAt = null sebelum server merespon,
    // menyebabkan dokumen hilang dari query ordering.

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => _fromDoc(doc)).toList();
      // Sort client-side
      list.sort((a, b) => b.sortTimestamp.compareTo(a.sortTimestamp));
      if (limit != null && list.length > limit) {
        return list.sublist(0, limit);
      }
      return list;
    });
  }

  Future<List<AktivitasModel>> getAktivitasList(String userId) async {
    if (userId.isEmpty) return [];
    final snapshot = await _activities
        .where('userId', isEqualTo: userId)
        .get();
    final list = snapshot.docs.map((doc) => _fromDoc(doc)).toList();
    list.sort((a, b) => b.sortTimestamp.compareTo(a.sortTimestamp));
    return list;
  }

  Future<List<AktivitasModel>> getRecentAktivitas(
    String userId, {
    int limit = 2,
  }) async {
    if (userId.isEmpty) return [];
    final snapshot = await _activities
        .where('userId', isEqualTo: userId)
        .get();
    final list = snapshot.docs.map((doc) => _fromDoc(doc)).toList();
    list.sort((a, b) => b.sortTimestamp.compareTo(a.sortTimestamp));
    return list.take(limit).toList();
  }

  AktivitasModel _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final status = (data['status'] ?? 'PROSES').toString().toUpperCase();
    final type = (data['activityType'] ?? 'system').toString().toLowerCase();
    final timestamp = (data['createdAt'] as Timestamp?)?.toDate();
    final style = _styleFor(type, status);

    // Sorting: prefer server timestamp, fallback ke client-side createdAtMs
    final int sortTs = timestamp?.millisecondsSinceEpoch ??
        (data['createdAtMs'] as int?) ??
        0;

    return AktivitasModel(
      userId: data['userId'] ?? '',
      id: doc.id,
      title: data['title'] ?? 'Aktivitas',
      subtitle: data['subtitle'] ?? '-',
      date: _formatRelative(timestamp ?? (sortTs > 0 ? DateTime.fromMillisecondsSinceEpoch(sortTs) : null)),
      status: status,
      sortTimestamp: sortTs,
      iconCodePoint: style.icon.codePoint,
      iconFontFamily: style.icon.fontFamily,
      iconColor: style.iconColor,
      iconBgColor: style.iconBgColor,
      statusTextColor: style.statusTextColor,
      statusBgColor: style.statusBgColor,
      referenceId: (data['referenceId'] ?? '').toString(),
      activityType: type,
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
      icon: type == 'report'
          ? Icons.report_problem
          : (type == 'surat' ? Icons.description : Icons.pending_actions),
      iconColor: type == 'surat' ? blueInfo : yellowProcess,
      iconBgColor: type == 'surat' ? bgInfo : bgProcess,
      statusTextColor: type == 'surat' ? blueInfo : yellowProcess,
      statusBgColor: type == 'surat' ? bgInfo : bgProcess,
    );
  }

  /// Update aktivitas yang sudah ada berdasarkan referenceId dan userId
  /// Ini mencegah duplikasi aktivitas saat status submission berubah
  Future<void> updateActivityByReference({
    required String userId,
    required String referenceId,
    required String newStatus,
    required String newSubtitle,
    String? newTitle,
  }) async {
    if (userId.isEmpty || referenceId.isEmpty) return;

    final snapshot = await _activities
        .where('userId', isEqualTo: userId)
        .where('referenceId', isEqualTo: referenceId)
        .get();

    if (snapshot.docs.isEmpty) return;

    // Update semua aktivitas yang cocok (biasanya hanya 1)
    for (final doc in snapshot.docs) {
      final Map<String, dynamic> updateData = {
        'status': newStatus,
        'subtitle': newSubtitle,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (newTitle != null) updateData['title'] = newTitle;

      await _activities.doc(doc.id).update(updateData);
    }
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
