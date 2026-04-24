import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/iuran_model.dart';
import 'auth_service.dart';
import 'aktivitas_service.dart';

class IuranService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final AktivitasService _aktivitasService = AktivitasService();

  // Koleksi nama
  final String _settingsCollection = 'iuran_rt_settings';
  final String _historyCollection = 'iuran_history';

  /// Mendapatkan ID Setting berdasarkan Kelurahan, RW, dan RT
  String _getSettingsDocId(String kelurahan, String rw, String rt) {
    // Normalisasi string untuk ID: hapus spasi dan jadikan lowercase
    final safeKel = kelurahan.replaceAll(' ', '').toLowerCase();
    final safeRw = rw.replaceAll(' ', '').toLowerCase();
    final safeRt = rt.replaceAll(' ', '').toLowerCase();
    return '${safeKel}_${safeRw}_$safeRt';
  }

  // ==============================================
  // PENGATURAN RT
  // ==============================================

  /// Mengambil pengaturan Iuran RT
  Future<IuranRtModel?> getRtSettings(String kelurahan, String rw, String rt) async {
    try {
      final docId = _getSettingsDocId(kelurahan, rw, rt);
      final doc = await _firestore.collection(_settingsCollection).doc(docId).get();
      if (doc.exists) {
        return IuranRtModel.fromFirestore(doc);
      }
    } catch (e) {
      print("Error getRtSettings: $e");
    }
    return null;
  }

  /// Memantau perubahan pengaturan Iuran RT secara real-time
  Stream<IuranRtModel?> streamRtSettings(String kelurahan, String rw, String rt) {
    final docId = _getSettingsDocId(kelurahan, rw, rt);
    return _firestore.collection(_settingsCollection).doc(docId).snapshots().map((doc) {
      if (doc.exists) return IuranRtModel.fromFirestore(doc);
      return null;
    });
  }

  /// Menyimpan/Memperbarui pengaturan Iuran RT
  Future<bool> saveRtSettings(IuranRtModel model) async {
    try {
      final docId = _getSettingsDocId(model.kelurahan, model.rw, model.rt);
      await _firestore.collection(_settingsCollection).doc(docId).set(model.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print("Error saveRtSettings: $e");
      return false;
    }
  }

  // ==============================================
  // TRANSAKSI WARGA
  // ==============================================

  /// Mengirim bukti bayar warga (membuat riwayat pending)
  Future<bool> bayarIuran(IuranModel iuran) async {
    try {
      await _firestore.collection(_historyCollection).add(iuran.toMap());
      
      await _aktivitasService.addActivity(
        userId: iuran.uidWarga,
        title: 'Iuran ${iuran.bulan} ${iuran.tahun}',
        subtitle: 'Bukti terkirim. Menunggu konfirmasi RT.',
        status: 'PROSES',
        activityType: 'iuran',
      );

      return true;
    } catch (e) {
      print("Error bayarIuran: $e");
      return false;
    }
  }

  /// Mengecek apakah warga sudah membayar iuran di bulan tertentu
  Future<IuranModel?> cekPembayaranBulanIni(String uidWarga, String bulan, String tahun) async {
    try {
      final query = await _firestore.collection(_historyCollection)
          .where('uidWarga', isEqualTo: uidWarga)
          .where('bulan', isEqualTo: bulan)
          .where('tahun', isEqualTo: tahun)
          .limit(1)
          .get();
          
      if (query.docs.isNotEmpty) {
        return IuranModel.fromFirestore(query.docs.first);
      }
    } catch (e) {
      print("Error cekPembayaranBulanIni: $e");
    }
    return null;
  }
  
  /// Mengambil seluruh riwayat iuran warga
  Future<List<IuranModel>> getRiwayatIuranWarga(String uidWarga) async {
    try {
      final query = await _firestore.collection(_historyCollection)
          .where('uidWarga', isEqualTo: uidWarga)
          .get();
          
      final list = query.docs.map((doc) => IuranModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      print("Error getRiwayatIuranWarga: $e");
      return [];
    }
  }

  // ==============================================
  // APPROVAL RT
  // ==============================================

  /// Memantau tagihan yang masuk untuk RT tertentu
  Stream<List<IuranModel>> streamTagihanMasuk(String kelurahan, String rw, String rt, {int? status}) {
    Query query = _firestore.collection(_historyCollection)
        .where('kelurahan', isEqualTo: kelurahan)
        .where('rw', isEqualTo: rw)
        .where('rt', isEqualTo: rt);
        
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    
    // Firebase requires an index if filtering and ordering are combined.
    // Querying without ordering here, sort in dart to avoid composite index requirement.
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => IuranModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Memperbarui status iuran (Setujui = 1, Tolak = 2)
  Future<bool> updateStatusIuran({
    required String idTagihan, 
    required int newStatus,
    required String uidWarga,
    required String bulan,
    required String tahun,
    required String uidRt,
  }) async {
    try {
      await _firestore.collection(_historyCollection).doc(idTagihan).update({
        'status': newStatus
      });

      String statusStr = newStatus == 1 ? 'BERHASIL' : 'DITOLAK';
      String subtitleWarga = newStatus == 1 ? 'Pembayaran lunas dikonfirmasi RT.' : 'Bukti pembayaran ditolak RT.';

      // Aktivitas Warga
      await _aktivitasService.addActivity(
        userId: uidWarga,
        title: 'Iuran $bulan $tahun',
        subtitle: subtitleWarga,
        status: statusStr,
        activityType: 'iuran',
      );

      // Aktivitas Pengurus RT
      await _aktivitasService.addActivity(
        userId: uidRt,
        title: 'Verifikasi Iuran Warga',
        subtitle: 'Selesai meninjau iuran $bulan $tahun',
        status: 'SELESAI',
        activityType: 'iuran',
      );

      return true;
    } catch (e) {
      print("Error updateStatusIuran: $e");
      return false;
    }
  }
}
