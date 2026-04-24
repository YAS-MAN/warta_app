import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ronda_model.dart';
import '../models/user_model.dart';

class RondaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _safeKeyPart(String value) {
    final v = value.trim().toLowerCase();
    // Firestore docId tidak boleh mengandung '/', jadi kita normalisasi.
    // Kita juga buang karakter aneh agar konsisten lintas platform.
    return v.isEmpty
        ? 'unknown'
        : v.replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+'), '_');
  }

  String _areaKey(String rt, String rw) => 'rt_${_safeKeyPart(rt)}_rw_${_safeKeyPart(rw)}';

  CollectionReference<Map<String, dynamic>> get _settings =>
      _firestore.collection('ronda_settings');
  CollectionReference<Map<String, dynamic>> get _schedules =>
      _firestore.collection('ronda_schedules');
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  String _normAreaValue(String v) => v.trim();
  String _areaKeyValue(String rt, String rw) => _areaKey(rt, rw);

  Stream<bool> streamRondaEnabled({
    required String rt,
    required String rw,
  }) {
    if (rt.isEmpty || rw.isEmpty) return Stream.value(false);
    final docId = _areaKey(rt, rw);
    return _settings.doc(docId).snapshots().map((doc) {
      if (!doc.exists) return false;
      return (doc.data()?['enabled'] as bool?) ?? false;
    });
  }

  Future<bool> getRondaEnabled({
    required String rt,
    required String rw,
  }) async {
    if (rt.isEmpty || rw.isEmpty) return false;
    final docId = _areaKey(rt, rw);
    final doc = await _settings.doc(docId).get();
    if (!doc.exists) return false;
    return (doc.data()?['enabled'] as bool?) ?? false;
  }

  Future<void> setRondaEnabled({
    required String rt,
    required String rw,
    required bool enabled,
    required String updatedByUid,
  }) async {
    final docId = _areaKey(rt, rw);
    final payload = <String, dynamic>{
      'rt': rt,
      'rw': rw,
      'enabled': enabled,
      'updatedBy': updatedByUid,
      // NOTE: Cloud Firestore Web kadang bermasalah dengan sentinel+merge di beberapa versi.
      // Untuk toggle sederhana, gunakan timestamp client agar stabil.
      'updatedAt': Timestamp.now(),
    };

    final ref = _settings.doc(docId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.update(payload);
    } else {
      await ref.set({
        ...payload,
        'createdAt': Timestamp.now(),
      });
    }
  }

  Stream<List<RondaScheduleModel>> streamSchedulesByArea({
    required String rt,
    required String rw,
  }) {
    if (rt.isEmpty || rw.isEmpty) return Stream.value([]);
    final areaKey = _areaKeyValue(rt, rw);
    return _schedules
        .where('areaKey', isEqualTo: areaKey)
        .orderBy('tanggal')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(RondaScheduleModel.fromFirestore)
            .toList());
  }

  Future<List<RondaScheduleModel>> getSchedulesByArea({
    required String rt,
    required String rw,
  }) async {
    if (rt.isEmpty || rw.isEmpty) return [];
    final areaKey = _areaKeyValue(rt, rw);
    final snapshot = await _schedules
        .where('areaKey', isEqualTo: areaKey)
        .orderBy('tanggal')
        .get();
    return snapshot.docs.map(RondaScheduleModel.fromFirestore).toList();
  }

  Future<void> upsertSchedule({
    required String rt,
    required String rw,
    required DateTime tanggal,
    required String lokasi,
    required List<String> anggota,
    required String createdByUid,
  }) async {
    final normalized = DateTime(tanggal.year, tanggal.month, tanggal.day);
    final docId = '${_areaKey(rt, rw)}_${normalized.toIso8601String()}';
    final areaKey = _areaKeyValue(rt, rw);
    await _schedules.doc(docId).set({
      'areaKey': areaKey,
      'rt': rt,
      'rw': rw,
      'tanggal': Timestamp.fromDate(normalized),
      'lokasi': lokasi.trim(),
      'anggota': anggota,
      'createdBy': createdByUid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<UserModel>> streamResidentsByArea({
    required String rt,
    required String rw,
  }) {
    if (rt.isEmpty || rw.isEmpty) return Stream.value([]);
    return _users
        .where('rt', isEqualTo: rt)
        .where('rw', isEqualTo: rw)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(UserModel.fromFirestore).toList());
  }

  Future<List<UserModel>> getResidentsByArea({
    required String rt,
    required String rw,
  }) async {
    if (rt.isEmpty || rw.isEmpty) return [];
    final rtNorm = _normAreaValue(rt);
    final rwNorm = _normAreaValue(rw);

    // NOTE: Hindari query multi-where (rt+rw) karena butuh composite index.
    // Ambil berdasarkan RW saja lalu filter di client agar tidak perlu index tambahan.
    final byRw = await _users.where('rw', isEqualTo: rwNorm).get();
    final byRwUsers = byRw.docs.map(UserModel.fromFirestore).toList();
    final filtered = byRwUsers.where((u) {
      return _normAreaValue(u.rt ?? '') == rtNorm &&
          _normAreaValue(u.rw ?? '') == rwNorm;
    }).toList();
    if (filtered.isNotEmpty) return filtered;

    // 3) Fallback terakhir: ambil berdasarkan RT saja lalu filter.
    final byRt = await _users.where('rt', isEqualTo: rtNorm).get();
    final byRtUsers = byRt.docs.map(UserModel.fromFirestore).toList();
    return byRtUsers.where((u) {
      return _normAreaValue(u.rt ?? '') == rtNorm &&
          _normAreaValue(u.rw ?? '') == rwNorm;
    }).toList();
  }
}

